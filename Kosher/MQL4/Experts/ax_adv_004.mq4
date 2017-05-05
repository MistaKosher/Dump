//+------------------------------------------------------------------+
//|                                                   ax_adv_004.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>

MqlRates g_mqlrates[];

MqlRates g_ready_bar;

int g_ticket=-1;//тикет текущего ордера
int g_delta_points=1;//
input double g_lots=0.01;//размер лота
input int g_slippage=3;//проскальзывание
//input double g_gator_magic_value=1.00000018;//волшебное число гатора
//double g_gator_magic_value=1.001;//волшебное число гатора
double g_gator_wake_up_val=1.001;//гатора просыпается
double g_gator_sleep_val=1.0001;//гатор реально уснул
input bool g_set_tp=false;//устанавливать явно TakeProfit
int g_reversal_bar_cnt_wait=2;//сколько баров после разворотного ждать, чтобы ордер включился
int g_order_count;//внутренний счетчик ордеров 
double g_gator_bar_diff=1;//расстояние между гатором и баром (разворотным) (в барах:))
double g_profit_coef=2.5;//уровень TakeProfit в отношении TakeProfit/StopLoss
input int g_gator_sleeps_bar_count=5;//через сколько баров убеждаемся, что гатор реально спит
int gator_sleep_bar_count=0;
int g_handle;
int g_orders_to_modify=0;

#include "ax_bar_utils.mqh"

double g_prev_ao_val=0;
ao_trend_mode g_AO_trend;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
 g_ticket=-1;//ордера нет
 
 g_delta_points=1; 
 
 g_reversal_bar_cnt_wait=1;
 
 g_order_count=0; 

 g_gator_wake_up_val   =ax_bar_utils::get_gator_wake_up_val(); 
 g_gator_sleep_val     =ax_bar_utils::get_gator_sleep_val();
 
 gator_sleep_bar_count =0;
 
 g_orders_to_modify=0;
 
 //сразу получаем значение последнего сформированного бара
 ArrayCopyRates(g_mqlrates,NULL,0);

 g_ready_bar=g_mqlrates[1]; 
 
 //получаем два значения назад и по ним определяем текущий тренд
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
 
 return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
 FileClose(g_handle);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
 ArrayCopyRates(g_mqlrates,NULL,0);
   
 string msg="";
  
 if(!ax_bar_utils::is_equal(g_ready_bar,g_mqlrates[1]))//подошел следующий бар
 {
  g_ready_bar=g_mqlrates[1];//это будет новый сформированный бар - работаем с ним
  
///////////////////////////////////////  
/* double val_up=iFractals(NULL,0,MODE_UPPER,3);
 double val_down=iFractals(NULL,0,MODE_LOWER,3);
 
 Comment("UP:",DoubleToString(NormalizeDouble(val_up,Digits),Digits),"\n",
         "DOWN:",DoubleToString(NormalizeDouble(val_down,Digits),Digits));
 
 return;*/
//////////////////////////////////////
  
  
  
  
  if(ax_bar_utils::gator_waked_up())//гатор проснулся
  {
   gator_sleep_bar_count=0;
   
   //определяем тип получившегося бара
   bar_types bar_type=ax_bar_utils::get_type(g_ready_bar,g_mqlrates[2]);
   
   if(bar_type!=BARTYPE_NONE)//бар разворотный
   {
    if(ax_bar_utils::is_out_of_gator(g_ready_bar,bar_type))//разворотный бар вне гатора
    {
     //ставим новый ордер
     if(bar_type==BARTYPE_BULLISH)//покупаем
     {
      string err_msg;    
      int ticket=ax_bar_utils::OpenOrder2(g_ready_bar,TRADEMODE_BUY,err_msg);
   
      if(ticket<0)
       msg+="[BUYSTOP]:"+err_msg;
      else
      {
       g_ticket=ticket;
       g_orders_to_modify++;
      }
     }//if покупаем
    
     if(bar_type==BARTYPE_BEARISH)//продаем
     {
      string err_msg;    
      int ticket=ax_bar_utils::OpenOrder2(g_ready_bar,TRADEMODE_SELL,err_msg);
   
      if(ticket<0)
       msg+="[SELLSTOP]:"+err_msg;
      else
      {
       g_ticket=ticket;
       g_orders_to_modify++;
      }
     }//if продаем
    }//out of gator
   }//разворотный
   else//обычный (не разворотный)
   {
   }
  }//if gator не спит
  else//gator спит
  {
   if(ax_bar_utils::gator_sleeps())//похоже, что гатор засыпает
    gator_sleep_bar_count++;
   
   if(gator_sleep_bar_count>=g_gator_sleeps_bar_count)//убедились, что реально заснул
   {
    //принудительно закроем все имеющиеся ордера
    //если открытых ордеров было несколько, то за один тик все могут не закрыться
    //попытка закрытия произойдет на следующем тике спящего гатора
    g_orders_to_modify=ax_bar_utils::CloseAllOrders();
   }
  }//спит
  
  double ao_val=iAO(NULL,0,1);

  if(g_AO_trend==AOTREND_UP && ao_val<g_prev_ao_val)
  {
   //переключился с зеленого на красный - тянем стопы у BUY ордеров
   g_AO_trend=AOTREND_DOWN;
   
   g_orders_to_modify=1;//формально - для того, чтобы произошло подтягивание стопов внутри бара на следующем тике
   
   //if(!g_set_tp)//похоже эти строки можно убрать - ничего не изменится
   // g_orders_to_modify=ax_bar_utils::SetAllOrderSL(g_ready_bar,g_AO_trend);
  }
  
  if(g_AO_trend==AOTREND_DOWN && ao_val>g_prev_ao_val)
  {
   //переключился с красного на зеленый - тянем стопы у SELL ордеров
   g_AO_trend=AOTREND_UP;
   
   g_orders_to_modify=1;//формально - для того, чтобы произошло подтягивание стопов внутри бара на следующем тике
   
   //if(!g_set_tp)
   // g_orders_to_modify=ax_bar_utils::SetAllOrderSL(g_ready_bar,g_AO_trend);
  }
  
  g_prev_ao_val=ao_val;
  
  //ax_bar_utils::WriteFile(g_handle,msg);
 }
 else//тот же самый бар
 {
  //пытаться закрывать не закрытые ордера здесь уже не будем
  //может здесь уже g_gator_sleeps_bar_count баров пройдут и гатор начнет просыпаться
  //так что, что закрылось, то закрылось, а оставшиеся пусть работают дальше, а вот подтянуть неподтянутые стопы стоит
  if(!g_set_tp && g_orders_to_modify!=0)
   g_orders_to_modify=ax_bar_utils::SetAllOrderSL(g_ready_bar,g_AO_trend);
 }
 
 Comment(msg);
}
//+------------------------------------------------------------------+
