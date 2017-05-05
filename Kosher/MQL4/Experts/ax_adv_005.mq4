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

#include <stdlib.mqh>

MqlRates g_mqlrates[];
MqlRates g_ready_bar;

int g_ticket=-1;//тикет текущего ордера
int g_delta_points=1;//
double g_lots=0.01;//размер лота
input double g_lots_3=0.01;//размер лота
input double g_lots_2=0.02;//размер лота
input int g_slippage=3;//проскальзывание
//input double g_gator_magic_value=1.00000018;//волшебное число гатора
//double g_gator_magic_value=1.001;//волшебное число гатора
double g_gator_wake_up_val=1.001;//гатора просыпается
double g_gator_sleep_val=1.0001;//гатор реально уснул
input bool g_set_tp=false;//устанавливать явно TakeProfit
input int g_reversal_bar_cnt_wait=7;//сколько баров после разворотного ждать, чтобы ордер включился
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
input double g_fibo_coef=0.382;//0.236 0.382 0.500 0.618

double g_buy_max;
double g_sell_min;
double g_buy_loc_min;
double g_sell_loc_max;

#include "ax_bar_utils.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
 g_ticket=-1;//ордера нет
 
 g_green3_ticket=-1;
 g_green2_ticket=-1;
 g_red3_ticket=-1;
 g_red2_ticket=-1;
 
 g_delta_points=1; 
 
 //g_reversal_bar_cnt_wait=3;
 
 g_order_count=0; 

 g_gator_wake_up_val   =ax_bar_utils::get_gator_wake_up_val(); 
 g_gator_sleep_val     =ax_bar_utils::get_gator_sleep_val();
 
 gator_sleep_bar_count =0;
 
 g_orders_to_modify=0;
 
 g_buy_max  =Ask;
 g_sell_min =Bid;
 
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
  
 string filename=Symbol()+"_"+IntegerToString(Period())+".log"; 
 
 g_handle=FileOpen(filename,FILE_WRITE|FILE_TXT); 
 
 if(g_handle<0) 
  Comment(filename,"\n",ErrorDescription(GetLastError())); 
 */
 
 //Comment(EnumToString(ax_bar_utils::get_ac_mode()));

 return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   
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
  if(Ask>g_buy_max)
  {
   g_buy_max=Ask;
   
   ax_bar_utils::SetAllOrderSLbyFibo(g_ready_bar,g_fibo_coef);
  }
   
  if(Bid<g_sell_min)
  {
   g_sell_min=Bid;
   
   ax_bar_utils::SetAllOrderSLbyFibo(g_ready_bar,g_fibo_coef);
  }
   
  //ax_bar_utils::CloseAllOrdersSAR();
  
  //ax_bar_utils::SetAllOrderSLbyFibo(g_ready_bar,g_fibo_coef);
  
  g_ready_bar=g_mqlrates[1];//это будет новый сформированный бар - работаем с ним
  
  ac_mode ac=ax_bar_utils::get_ac_mode2();
  
  //bar_types         bt  =ax_bar_utils::get_type(g_ready_bar,g_mqlrates[2]);
  //bar_types         bt2 =ax_bar_utils::get_type2(g_ready_bar);
  //bar_reversal_type brt =ax_bar_utils::get_bar_reversal_type(g_ready_bar,g_mqlrates[2]);
  
  //покупка - GREEN3+BARREVERSAL_BULLISH (разворотный), который ниже гатора
  //      или GREEN2+NOT BEARISH (разворотный) - это выше гатора
  //продажа - RED3+BARREVERSAL_BEARISH
  //      или RED2+NOT BULLISH
  
//  if((ac==ACMODE_GREEN3&&brt==BARREVERSAL_BULLISH) ||
  //   (ac==ACMODE_GREEN2&&bt==BARTYPE_BULLISH&&ax_bar_utils::is_out_of_gator(g_ready_bar)))
//  if(ac==ACMODE_GREEN3 || ac==ACMODE_GREEN2)
/*  if((ac==ACMODE_GREEN3 || ac==ACMODE_GREEN2) && iSAR(NULL,0,0.02,0.2,1)<g_ready_bar.low && ax_bar_utils::is_out_of_gator(g_ready_bar))
  {
   //buy
   string err_msg;    
   int ticket=ax_bar_utils::OpenOrder2(g_ready_bar,TRADEMODE_BUY,err_msg,1);
   
   if(ticket<0)
    msg+="[BUYSTOP]:"+err_msg;
   else
   {
    g_ticket=ticket;
    g_orders_to_modify++;
   }
  }*/
  
  if(ac==ACMODE_GREEN3 && /*g_green3_ticket<0 &&*/
     ax_bar_utils::get_bar_gator_position(g_ready_bar,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_PART))//GREEN3 еще не поставлен
  {
   //buy
   string err_msg;
   
   MqlRates dummy_bar;
   ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_BUY,3);
   
   dummy_bar.low=ax_bar_utils::get_local_extremum(g_mqlrates,TRADEMODE_BUY);
   
   g_buy_max     =dummy_bar.high;
   g_buy_loc_min =dummy_bar.low;
   
   string comment="";//dummy_bar.low<g_ready_bar.low?"SL.NE.CR":DoubleToString(g_ready_bar.low);
   
   int ticket=ax_bar_utils::OpenOrder2(dummy_bar,TRADEMODE_BUY,err_msg,1,g_lots_3,comment);
   
   if(ticket<0)
    msg+="[BUYSTOP]:"+err_msg;
   else
   {
    g_green3_ticket=ticket;
    //g_orders_to_modify++;
   }
  }
  
  //проверим все текущие тикеты (может они уже закрылись по SL (ну или по TP))
  if(!(OrderSelect(g_green3_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   g_green3_ticket=-1;
   
  if(!(OrderSelect(g_green2_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   g_green2_ticket=-1;
   
  if(ac==ACMODE_GREEN2 && g_green3_ticket>0 && g_green2_ticket<0 && 
     ax_bar_utils::get_bar_gator_position(g_ready_bar,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_MEDIUM))//GREEN3 уже поставлен, GREEN2 еще нет
  {
   string err_msg;
   
   MqlRates dummy_bar;
   ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_BUY,2);
   
   string comment="";//dummy_bar.low<g_ready_bar.low?"SL.NE.CR":DoubleToString(g_ready_bar.low);
   
   int ticket=ax_bar_utils::OpenOrder2(dummy_bar,TRADEMODE_BUY,err_msg,1,g_lots_2,comment);
   
   if(ticket<0)
    msg+="[BUYSTOP]:"+err_msg;
   else
   {
    g_green2_ticket=ticket;
    //g_orders_to_modify++;
   }
  }
  
  //SELL------------------------------------------------------
  if(ac==ACMODE_RED3 && /*g_red3_ticket<0 &&*/
     ax_bar_utils::get_bar_gator_position(g_ready_bar,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_PART))//RED3 еще не поставлен
  {
   //sell
   string err_msg;
   
   MqlRates dummy_bar;
   ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_SELL,3);

   dummy_bar.high=ax_bar_utils::get_local_extremum(g_mqlrates,TRADEMODE_SELL);
   
   g_sell_min     =dummy_bar.low;
   g_sell_loc_max =dummy_bar.high;
   
   string comment="";//dummy_bar.high>g_ready_bar.high?"SL.NE.CR":DoubleToString(g_ready_bar.high);
   
   int ticket=ax_bar_utils::OpenOrder2(dummy_bar,TRADEMODE_SELL,err_msg,1,g_lots_3,comment);
   
   if(ticket<0)
    msg+="[SELLSTOP]:"+err_msg;
   else
   {
    g_red3_ticket=ticket;
    //g_orders_to_modify++;
   }
  }
  
  //проверим все текущие тикеты (может они уже закрылись по SL (ну или по TP))
  if(!(OrderSelect(g_red3_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   g_red3_ticket=-1;
   
  if(!(OrderSelect(g_red2_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   g_red2_ticket=-1;
   
  if(ac==ACMODE_RED2 && g_red3_ticket>0 && g_red2_ticket<0 &&
     ax_bar_utils::get_bar_gator_position(g_ready_bar,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_MEDIUM))//RED3 уже поставлен, RED2 еще нет
  {
   string err_msg;
   
   MqlRates dummy_bar;
   ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_SELL,2);

   string comment=dummy_bar.high>g_ready_bar.high?"SL.NE.CR":DoubleToString(g_ready_bar.high);
   
   int ticket=ax_bar_utils::OpenOrder2(dummy_bar,TRADEMODE_SELL,err_msg,1,g_lots_2,comment);
   
   if(ticket<0)
    msg+="[SELLSTOP]:"+err_msg;
   else
   {
    g_red2_ticket=ticket;
    //g_orders_to_modify++;
   }
  }
//  if((ac==ACMODE_RED3&&brt==BARREVERSAL_BEARISH) ||
//     (ac==ACMODE_RED2&&bt==BARTYPE_BEARISH&&ax_bar_utils::is_out_of_gator(g_ready_bar)))
//  if(ac==ACMODE_RED3 || ac==ACMODE_RED2)
 /* if((ac==ACMODE_RED3 || ac==ACMODE_RED2) && iSAR(NULL,0,0.02,0.2,1)>g_ready_bar.high && ax_bar_utils::is_out_of_gator(g_ready_bar))
  {
   //sell
   string err_msg;    
   int ticket=ax_bar_utils::OpenOrder2(g_ready_bar,TRADEMODE_SELL,err_msg,1);
   
   if(ticket<0)
    msg+="[SELLSTOP]:"+err_msg;
   else
   {
    g_ticket=ticket;
    g_orders_to_modify++;
   }
  }*/

  //Comment(msg);
 }//подошел следующий бар
 
/* if(ax_bar_utils::gator_sleeps())//похоже, что гатор засыпает
  gator_sleep_bar_count++;
   
 if(gator_sleep_bar_count>=g_gator_sleeps_bar_count)//убедились, что реально заснул
 {
  //принудительно закроем все имеющиеся ордера
  //если открытых ордеров было несколько, то за один тик все могут не закрыться
  //попытка закрытия произойдет на следующем тике спящего гатора
  g_orders_to_modify=ax_bar_utils::CloseAllOrders();
 }*/
}
//+------------------------------------------------------------------+
