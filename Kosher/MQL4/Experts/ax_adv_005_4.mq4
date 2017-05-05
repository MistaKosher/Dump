//+------------------------------------------------------------------+
//|                                                   ax_adv_005.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict
//Accelerator

#import "fx_sample_001.dll"
        void   axInit();
        void   axDeinit();
        void   axAddOrder(int ticket, double sl, int fibo_level);
        void   axRemoveOrder(int ticket);
        double axGetOrderSL(int ticket);
        int    axGetOrderFiboLevel(int ticket);
        bool   axSetOrderSL(int ticket, double sl);
        bool   axSetOrderFiboLevel(int ticket, int fibo_level);
        void   axClearArray();
        void   axAddArrayValue(double v);
        double axGetArrayMinValue();
        double axGetArrayMaxValue();
#import

#include <stdlib.mqh>

MqlRates g_mqlrates[];
MqlRates g_ready_bar;

int g_ticket=-1;//тикет текущего ордера
int g_delta_points=1;//
double g_lots=0.01;//размер лота
input double g_lots_3=0.01;//размер лота 3
input double g_lots_2=0.02;//размер лота 2
input int g_slippage=3;//проскальзывание
//input double g_gator_magic_value=1.00000018;//волшебное число гатора
//double g_gator_magic_value=1.001;//волшебное число гатора
double g_gator_wake_up_val=1.001;//гатора просыпается
double g_gator_sleep_val=1.0001;//гатор реально уснул
input bool g_set_tp=false;//устанавливать явно TakeProfit
int g_reversal_bar_cnt_wait=1;//сколько баров после разворотного ждать, чтобы ордер включился
int g_order_count;//внутренний счетчик ордеров 
double g_gator_bar_diff=1;//расстояние между гатором и баром (разворотным) (в барах:))
double g_profit_coef=2.5;//уровень TakeProfit в отношении TakeProfit/StopLoss
int g_gator_sleeps_bar_count=5;//через сколько баров убеждаемся, что гатор реально спит
int gator_sleep_bar_count=0;
int g_handle;
int g_orders_to_modify=0;
int g_green3_ticket=-1;
int g_green2_ticket=-1;
int g_red3_ticket=-1;
int g_red2_ticket=-1;
double g_profit=1.5;
double g_loss=-0.5;
double g_fibo_coef=0.382;//0.236 0.382 0.500 0.618
input int g_rsi_period=14;//RSI период
input int g_demark_period=14;//DeMarker период

double g_buy_max;
double g_sell_min;
double g_buy_loc_min;
double g_sell_loc_max;
double g_upper_frac;
double g_lower_frac;

double g_fibo_coefs[5];

#include "ax_bar_utils.mqh"

fibo_levels g_fibo_start3;
fibo_levels g_fibo_start2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
 axInit();
 
 g_ticket=-1;//ордера нет
 
 g_green3_ticket=-1;
 g_green2_ticket=-1;
 g_red3_ticket=-1;
 g_red2_ticket=-1;
 
 g_delta_points=2; 
 
 g_reversal_bar_cnt_wait=7;
 
 g_order_count=0; 

 g_gator_wake_up_val   =ax_bar_utils::get_gator_wake_up_val(); 
 g_gator_sleep_val     =ax_bar_utils::get_gator_sleep_val();
 
 gator_sleep_bar_count =0;
 
 g_orders_to_modify=0;
 
 g_buy_max  =Ask;
 g_sell_min =Bid;
 
 g_upper_frac =Ask;
 g_lower_frac =Bid;
 
 g_fibo_coefs[FIBO_100]=1.000;
 g_fibo_coefs[FIBO_618]=0.618;
 g_fibo_coefs[FIBO_500]=0.500;
 g_fibo_coefs[FIBO_382]=0.382;
 g_fibo_coefs[FIBO_236]=0.236;
 
 g_fibo_start3=FIBO_500;
 g_fibo_start2=FIBO_500;
//сразу получаем значение последнего сформированного бара
 ArrayCopyRates(g_mqlrates,NULL,0);

 g_ready_bar=g_mqlrates[1]; 
 
 //получаем два значения назад и по ним определяем текущий тренд
 /*
 g_prev_ao_val=iAO(NULL,0,1);
 
 double prev_ao_val2=iAO(NULL,0,2);
 
 g_AO_trend=AOTREND_HOR;
 
 if(g_prev_ao_val>prev_ao_val2)
  g_AO_trend=AOTREND_UP;

 if(g_prev_ao_val<prev_ao_val2)
  g_AO_trend=AOTREND_DOWN;
*/  
 /*string filename=Symbol()+"_"+IntegerToString(Period())+".log"; 
 
 g_handle=FileOpen(filename,FILE_WRITE|FILE_TXT); 
 
 if(g_handle<0) 
  Comment(filename,"\n",ErrorDescription(GetLastError())); */
 
 //Comment(EnumToString(ax_bar_utils::get_ac_mode()));

 return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
 axDeinit();
 
 FileClose(g_handle);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
 ArrayCopyRates(g_mqlrates,NULL,0);
   
 string msg="";
 
 //ax_bar_utils::CloseAllOrdersByProfit();
 
 if(!ax_bar_utils::is_equal(g_ready_bar,g_mqlrates[1]))//подошел следующий бар
 {
 /*
  if(Ask>g_buy_max)
  {
   g_buy_max=Ask;
   
   ax_bar_utils::SetAllOrderSLbyFibo3();
   //ax_bar_utils::SetAllOrderSLbyFibo2(g_ready_bar,g_fibo_coef);
  }
   
  if(Bid<g_sell_min)
  {
   g_sell_min=Bid;
   
   ax_bar_utils::SetAllOrderSLbyFibo3();
   //ax_bar_utils::SetAllOrderSLbyFibo2(g_ready_bar,g_fibo_coef);
  }
  */
  /*
  double frac_val=ax_bar_utils::get_fractal(MODE_UPPER);
  
  if(frac_val>g_upper_frac)
  {
   //тянем стопы у BUY
   g_buy_max=frac_val;
   g_upper_frac=frac_val;
   
   ax_bar_utils::SetAllOrderSLbyFibo3(OP_BUY);
  }
  
  frac_val=ax_bar_utils::get_fractal(MODE_LOWER);
  
  if(frac_val>0 && frac_val<g_lower_frac)
  {
   //тянем стопы у SELL
   g_sell_min=frac_val;
   g_lower_frac=frac_val;
   
   ax_bar_utils::SetAllOrderSLbyFibo3(OP_SELL);
  }
  */
  
  g_ready_bar=g_mqlrates[1];//это будет новый сформированный бар - работаем с ним
  
  //работа с RSI и DeM
  double temp_ext;
  
  switch(ax_bar_utils::get_rsi_mode())
  {
   case RSIMODE_MIDDLE_UPPER: axClearArray();
   case RSIMODE_UPPER: axAddArrayValue(g_ready_bar.high); break;
   
   case RSIMODE_MIDDLE_LOWER: axClearArray();
   case RSIMODE_LOWER:axAddArrayValue(g_ready_bar.low); break;
   
   case RSIMODE_UPPER_MIDDLE: //тянем стопы у BUY
                              temp_ext=axGetArrayMaxValue();
                              
                              if(temp_ext>g_buy_max)
                              {
                               g_buy_max=temp_ext;
                               ax_bar_utils::SetAllOrderSLbyFibo3(OP_BUY);
                              }
                              
                              axClearArray();
                              break;
   case RSIMODE_LOWER_MIDDLE: //тянем стопы у SELL
                              temp_ext=axGetArrayMinValue();
                              
                              if(temp_ext<g_sell_min)
                              {
                               g_sell_min=temp_ext;
                               ax_bar_utils::SetAllOrderSLbyFibo3(OP_SELL);
                              }
                              
                              axClearArray();
                              break;

  }
   
  //ax_bar_utils::CloseAllOrdersSAR();
  
  //ax_bar_utils::SetAllOrderSLbyFibo(g_ready_bar,g_fibo_coef);  
  
  ac_mode ac=ax_bar_utils::get_ac_mode4();
  
  if(ac==ACMODE_GREEN3 && /*g_green3_ticket<0 &&*/
     ax_bar_utils::get_bar_gator_position(g_mqlrates,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_PART3,1))//GREEN3 еще не поставлен
  {
   //buy
   string err_msg;
   
   MqlRates dummy_bar;
   ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_BUY,3);
   
   dummy_bar.low=ax_bar_utils::get_local_extremum(g_mqlrates,TRADEMODE_BUY);
   
   g_buy_max     =dummy_bar.high;
   g_buy_loc_min =dummy_bar.low;
   g_upper_frac  =dummy_bar.high;
   
   string comment="";//DoubleToString(dummy_bar.low);
   
   int ticket=ax_bar_utils::OpenOrder2(dummy_bar,TRADEMODE_BUY,err_msg,1,g_lots_3,comment);
   
   if(ticket<0)
    msg+="[BUYSTOP]:"+err_msg;
   else
   {
    g_green3_ticket=ticket;
    //g_orders_to_modify++;
    axAddOrder(ticket,dummy_bar.low,g_fibo_start3);
   }
  }
  
  //проверим все текущие тикеты (может они уже закрылись по SL (ну или по TP))
  if(!(OrderSelect(g_green3_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   g_green3_ticket=-1;
   
  if(!(OrderSelect(g_green2_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   g_green2_ticket=-1;
   
  if(ac==ACMODE_GREEN2 && g_green3_ticket>0 && g_green2_ticket<0 && 
     ax_bar_utils::get_bar_gator_position(g_mqlrates,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_MEDIUM2,1))//GREEN3 уже поставлен, GREEN2 еще нет
  {
   string err_msg;
   
   MqlRates dummy_bar;
   ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_BUY,2);
   
   string comment="";//DoubleToString(dummy_bar.low);
   
   int ticket=ax_bar_utils::OpenOrder2(dummy_bar,TRADEMODE_BUY,err_msg,1,g_lots_2,comment);
   
   if(ticket<0)
    msg+="[BUYSTOP]:"+err_msg;
   else
   {
    g_green2_ticket=ticket;
    //g_orders_to_modify++;
    axAddOrder(ticket,dummy_bar.low,g_fibo_start2);
   }
  }
  
  //SELL------------------------------------------------------
  if(ac==ACMODE_RED3 && /*g_red3_ticket<0 &&*/
     ax_bar_utils::get_bar_gator_position(g_mqlrates,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_PART3,1))//RED3 еще не поставлен
  {
   //sell
   string err_msg;
   
   MqlRates dummy_bar;
   ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_SELL,3);

   dummy_bar.high=ax_bar_utils::get_local_extremum(g_mqlrates,TRADEMODE_SELL);
   
   g_sell_min     =dummy_bar.low;
   g_sell_loc_max =dummy_bar.high;
   g_lower_frac   =dummy_bar.low;
   
   string comment="";//DoubleToString(dummy_bar.high);
   
   int ticket=ax_bar_utils::OpenOrder2(dummy_bar,TRADEMODE_SELL,err_msg,1,g_lots_3,comment);
   
   if(ticket<0)
    msg+="[SELLSTOP]:"+err_msg;
   else
   {
    g_red3_ticket=ticket;
    //g_orders_to_modify++;
    axAddOrder(ticket,dummy_bar.high,g_fibo_start3);
   }
  }
  
  //проверим все текущие тикеты (может они уже закрылись по SL (ну или по TP))
  if(!(OrderSelect(g_red3_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   g_red3_ticket=-1;
   
  if(!(OrderSelect(g_red2_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   g_red2_ticket=-1;
   
  if(ac==ACMODE_RED2 && g_red3_ticket>0 && g_red2_ticket<0 &&
     ax_bar_utils::get_bar_gator_position(g_mqlrates,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_MEDIUM2,1))//RED3 уже поставлен, RED2 еще нет
  {
   string err_msg;
   
   MqlRates dummy_bar;
   ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_SELL,2);

   string comment="";//DoubleToString(dummy_bar.high);
   
   int ticket=ax_bar_utils::OpenOrder2(dummy_bar,TRADEMODE_SELL,err_msg,1,g_lots_2,comment);
   
   if(ticket<0)
    msg+="[SELLSTOP]:"+err_msg;
   else
   {
    g_red2_ticket=ticket;
    //g_orders_to_modify++;
    axAddOrder(ticket,dummy_bar.high,g_fibo_start2);
   }
  }
  //Comment(msg);
 }//подошел следующий бар
}
//+------------------------------------------------------------------+
