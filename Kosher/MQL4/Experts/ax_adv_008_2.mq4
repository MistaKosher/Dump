//+------------------------------------------------------------------+
//|                                                 ax_adv_008_2.mq4 |
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
        void   axAddOrder(int ticket, double sl, int fibo_level, int ext_data);
        void   axRemoveOrder(int ticket);
        double axGetOrderSL(int ticket);
        int    axGetOrderFiboLevel(int ticket);
        int    axGetOrderExtData(int ticket);
        bool   axSetOrderSL(int ticket, double sl);
        bool   axSetOrderFiboLevel(int ticket, int fibo_level);
        bool   axSetOrderExtData(int ticket, int ext_data);
        void   axClearArray();
        void   axAddArrayValue(double v);
        double axGetArrayMinValue();
        double axGetArrayMaxValue();
#import

#include <stdlib.mqh>

//#define BUY
//#define SELL

MqlRates g_mqlrates[];
MqlRates g_ready_bar;

int g_ticket=-1;//����� �������� ������
int g_delta_points=1;//
double g_lots=0.01;//������ ����
input double g_lots_3=0.01;//������ ���� 3
input double g_lots_2=0.01;//������ ���� 2
input int g_slippage=3;//���������������
//input double g_gator_magic_value=1.00000018;//��������� ����� ������
//double g_gator_magic_value=1.001;//��������� ����� ������
double g_gator_wake_up_val=1.001;//������ �����������
double g_gator_sleep_val=1.0001;//����� ������� �����
input bool g_set_tp=false;//������������� ���� TakeProfit
input int g_reversal_bar_cnt_wait=3;//���������� ����� ��� ��������� �����������
input int g_direct_order_exp_bar_count=3;//����� �������� ��������� (������ �����),� �����
input int g_reverse_order_exp_bar_count=21;//����� �������� ��������� (�������� �����),� �����
int g_order_count;//���������� ������� ������� 
double g_gator_bar_diff=1;//���������� ����� ������� � ����� (�����������) (� �����:))
double g_profit_coef=1.0;//������� TakeProfit � ��������� TakeProfit/StopLoss
input double g_direct_profit_coef=1.0;//(direct)������� TakeProfit � ��������� TakeProfit/StopLoss
input double g_reverse_profit_coef=1.0;//(reverse)������� TakeProfit � ��������� TakeProfit/StopLoss
int g_gator_sleeps_bar_count=5;//����� ������� ����� ����������, ��� ����� ������� ����
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
input int g_rsi_period=14;//RSI ������
input int g_demark_period=14;//DeMarker ������
input double g_percent_bar_to_extrem=0.01;

extern bool UseTradingHours = FALSE;
extern int StartHour = 20;  // ������ �������� �� ������� �������
extern int EndHour = 6;     // ��������� �������� �� ������� �������

double g_buy_max;
double g_sell_min;
double g_buy_loc_min;
double g_sell_loc_max;
double g_upper_frac;
double g_lower_frac;

bool trade;

double g_fibo_coefs[5];

#include "ax_bar_utils.mqh"

input adv_trade_mode g_trade_mode;//����� ������ 0-������ BUY,1-������ SELL,2-� BUY, � SELL

fibo_levels g_fibo_start3;
fibo_levels g_fibo_start2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
 axInit();
 
 g_ticket=-1;//������ ���
 
 g_green3_ticket=-1;
 g_green2_ticket=-1;
 g_red3_ticket=-1;
 g_red2_ticket=-1;
 
 g_delta_points=2; 
 
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
 
 g_fibo_start3=FIBO_618;
 g_fibo_start2=FIBO_382;
//����� �������� �������� ���������� ��������������� ����
 ArrayCopyRates(g_mqlrates,NULL,0);

 g_ready_bar=g_mqlrates[1]; 
 
 //�������� ��� �������� ����� � �� ��� ���������� ������� �����
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
 
 Comment(AccountLeverage());
 
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

   trade = TRUE;
   if (UseTradingHours)
   {
      datetime currenttime = TimeHour(TimeCurrent());	
		if (EndHour < StartHour)
      {
         EndHour += 24;
         if (currenttime < 24)
            currenttime += 24;
	   }
		if (currenttime < StartHour || currenttime > EndHour)
         trade = FALSE;	
	}

 ArrayCopyRates(g_mqlrates,NULL,0);
   
 string msg="";
 
 //ax_bar_utils::CloseAllOrdersByProfit();
 
 if(!ax_bar_utils::is_equal(g_ready_bar,g_mqlrates[1]))//������� ��������� ���
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
   //����� ����� � BUY
   g_buy_max=frac_val;
   g_upper_frac=frac_val;
   
   ax_bar_utils::SetAllOrderSLbyFibo3(OP_BUY);
  }
  
  frac_val=ax_bar_utils::get_fractal(MODE_LOWER);
  
  if(frac_val>0 && frac_val<g_lower_frac)
  {
   //����� ����� � SELL
   g_sell_min=frac_val;
   g_lower_frac=frac_val;
   
   ax_bar_utils::SetAllOrderSLbyFibo3(OP_SELL);
  }
  */
  
  g_ready_bar=g_mqlrates[1];//��� ����� ����� �������������� ��� - �������� � ���
  
  double sl_val=ax_bar_utils::get_sl_by_SAR(g_mqlrates,OP_BUY);
  
  if(sl_val!=0)
  {
  
  //sl_mode slm=SLMODE_CROSSGATOR_DOWNUP;//ax_bar_utils::get_sl_mode(g_mqlrates,sl_val);
  
  //if(slm!=SLMODE_NONE)
   ax_bar_utils::SetAllOrderSLbyValue(sl_val,OP_BUY);
  }
  
  sl_val=ax_bar_utils::get_sl_by_SAR(g_mqlrates,OP_SELL);
  
  if(sl_val!=0)
   ax_bar_utils::SetAllOrderSLbyValue(sl_val,OP_SELL);
  
  //������ � RSI � DeM
  /*
  double temp_ext;
  
  switch(ax_bar_utils::get_rsi_mode())
  {
   case RSIMODE_MIDDLE_UPPER: axClearArray();
   case RSIMODE_UPPER: axAddArrayValue(g_ready_bar.high); break;
   
   case RSIMODE_MIDDLE_LOWER: axClearArray();
   case RSIMODE_LOWER:axAddArrayValue(g_ready_bar.low); break;
   
   case RSIMODE_UPPER_MIDDLE: //����� ����� � BUY
                              temp_ext=axGetArrayMaxValue();
                              
                              if(temp_ext>g_buy_max)
                              {
                               g_buy_max=temp_ext;
                               ax_bar_utils::SetAllOrderSLbyFibo3(OP_BUY);
                              }
                              
                              axClearArray();
                              break;
   case RSIMODE_LOWER_MIDDLE: //����� ����� � SELL
                              temp_ext=axGetArrayMinValue();
                              
                              if(temp_ext<g_sell_min)
                              {
                               g_sell_min=temp_ext;
                               ax_bar_utils::SetAllOrderSLbyFibo3(OP_SELL);
                              }
                              
                              axClearArray();
                              break;

  }
  */
  //ax_bar_utils::CloseAllOrdersSAR();
  
  //ax_bar_utils::SetAllOrderSLbyFibo(g_ready_bar,g_fibo_coef);  
  
  ac_mode ac=ax_bar_utils::get_ac_mode4();
  if (trade == TRUE)
  {
    if(g_trade_mode==ADVTRADEMODE_BUY || g_trade_mode==ADVTRADEMODE_BOTH)
  {
   if(ac==ACMODE_GREEN3 && ax_bar_utils::get_bar_gator_position(g_mqlrates,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_FULL,1))
   {
    string err_msg;
   
    MqlRates dummy_bar;
    dummy_bar.high =g_ready_bar.high;
    //dummy_bar.low  =ax_bar_utils::getPercentValueFromBarToExtrem(g_ready_bar.low,ax_bar_utils::get_local_extremum(g_mqlrates,TRADEMODE_BUY),g_percent_bar_to_extrem);
    dummy_bar.low  =ax_bar_utils::get_local_extremum(g_mqlrates,TRADEMODE_BUY);
    //dummy_bar.low  =g_ready_bar.low;
   
    if(!ax_bar_utils::inIchimokuCloud(dummy_bar.high) && !ax_bar_utils::inIchimokuCloud(dummy_bar.low))
    {
     g_buy_max      =dummy_bar.high;
     g_buy_loc_min  =dummy_bar.low;
   
     int ticket=ax_bar_utils::OpenOrder3(dummy_bar,TRADEMODE_BUY,g_lots_3,g_slippage,"DIRECT",g_direct_order_exp_bar_count,0,err_msg);
   
     if(ticket<0)
      msg+="[BUYSTOP]:"+err_msg;
     else
     {
      //g_green3_ticket=ticket;
      axAddOrder(ticket,dummy_bar.low,FIBO_618,1);

      //������������� RED2
      ticket=ax_bar_utils::OpenOrder3(dummy_bar,TRADEMODE_SELL,g_lots_2,g_slippage,"REVERSE",g_reverse_order_exp_bar_count,g_reverse_profit_coef,err_msg);
   
      if(ticket<0)
       msg+="[SELLSTOP]:"+err_msg;
      else
       axAddOrder(ticket,dummy_bar.high,FIBO_618,0);
     }
    }
   }
   
   //�������� ��� ������� ������ (����� ��� ��� ��������� �� SL (�� ��� �� TP))
   //if(!(OrderSelect(g_green3_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
   // g_green3_ticket=-1;
   
   if(!(OrderSelect(g_green2_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
    g_green2_ticket=-1;

   if(ac==ACMODE_GREEN2 && g_green2_ticket<0 && ax_bar_utils::get_bar_gator_position(g_mqlrates,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_MEDIUM2,1))
   {
    string err_msg;
   
    MqlRates dummy_bar;
    ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_BUY,2);
    //dummy_bar.high  =g_ready_bar.high;
    //dummy_bar.low   =g_ready_bar.low;
    //dummy_bar.low=g_buy_loc_min;
    
    if(!ax_bar_utils::inIchimokuCloud(dummy_bar.high) && !ax_bar_utils::inIchimokuCloud(dummy_bar.low))
    {
     int ticket=ax_bar_utils::OpenOrder3(dummy_bar,TRADEMODE_BUY,g_lots_2,g_slippage,"DIRECT",g_direct_order_exp_bar_count,0,err_msg);
   
     if(ticket<0)
      msg+="[BUYSTOP]:"+err_msg;
     else
     {
      g_green2_ticket=ticket;
      axAddOrder(ticket,dummy_bar.low,FIBO_618,1);

      //������������� RED2
      ticket=ax_bar_utils::OpenOrder3(dummy_bar,TRADEMODE_SELL,g_lots_2,g_slippage,"REVERSE",g_reverse_order_exp_bar_count,g_reverse_profit_coef,err_msg);
   
      if(ticket<0)
       msg+="[SELLSTOP]:"+err_msg;
      else
       axAddOrder(ticket,dummy_bar.high,FIBO_618,0);
     }
    }
   }
  }
  
  if(g_trade_mode==ADVTRADEMODE_SELL || g_trade_mode==ADVTRADEMODE_BOTH)
  {
   //SELL------------------------------------------------------
   if(ac==ACMODE_RED3 && ax_bar_utils::get_bar_gator_position(g_mqlrates,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_FULL,1))
   {
    //sell
    string err_msg;
   
    MqlRates dummy_bar;

    //dummy_bar.high =ax_bar_utils::get_local_extremum(g_mqlrates,TRADEMODE_SELL);
    dummy_bar.high =g_ready_bar.high;
    dummy_bar.low  =g_ready_bar.low;
   
    if(!ax_bar_utils::inIchimokuCloud(dummy_bar.high) && !ax_bar_utils::inIchimokuCloud(dummy_bar.low))
    {
     g_sell_min     =dummy_bar.low;
     g_sell_loc_max =dummy_bar.high;
   
     int ticket=ax_bar_utils::OpenOrder3(dummy_bar,TRADEMODE_SELL,g_lots_3,g_slippage,"DIRECT",g_direct_order_exp_bar_count,0,err_msg);
   
     if(ticket<0)
      msg+="[SELLSTOP]:"+err_msg;
     else
     {
      //g_red3_ticket=ticket;
      axAddOrder(ticket,dummy_bar.high,FIBO_618,1);
      
      //������������� GREEN2
      ticket=ax_bar_utils::OpenOrder3(dummy_bar,TRADEMODE_BUY,g_lots_2,g_slippage,"REVERSE",g_reverse_order_exp_bar_count,g_reverse_profit_coef,err_msg);
   
      if(ticket<0)
       msg+="[BUYSTOP]:"+err_msg;
      else
       axAddOrder(ticket,dummy_bar.low,FIBO_618,1);
     }
    }
   }
   /*
   //�������� ��� ������� ������ (����� ��� ��� ��������� �� SL (�� ��� �� TP))
   if(!(OrderSelect(g_red3_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
    g_red3_ticket=-1;
   */
   if(!(OrderSelect(g_red2_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0))
    g_red2_ticket=-1;
    
   if(ac==ACMODE_RED2 && g_red2_ticket<0 && ax_bar_utils::get_bar_gator_position(g_mqlrates,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_MEDIUM2,1))
   {
    string err_msg;
   
    MqlRates dummy_bar;
    ax_bar_utils::get_dummy_bar(dummy_bar,TRADEMODE_SELL,2);
    //dummy_bar.high=g_sell_loc_max;

    if(!ax_bar_utils::inIchimokuCloud(dummy_bar.high) && !ax_bar_utils::inIchimokuCloud(dummy_bar.low))
    {
     int ticket=ax_bar_utils::OpenOrder3(dummy_bar,TRADEMODE_SELL,g_lots_2,g_slippage,"DIRECT",g_direct_order_exp_bar_count,0,err_msg);
   
     if(ticket<0)
      msg+="[SELLSTOP]:"+err_msg;
     else
     {
      g_red2_ticket=ticket;
      axAddOrder(ticket,dummy_bar.high,FIBO_618,1);
      
      //������������� GREEN2
      ticket=ax_bar_utils::OpenOrder3(dummy_bar,TRADEMODE_BUY,g_lots_2,g_slippage,"REVERSE",g_reverse_order_exp_bar_count,g_reverse_profit_coef,err_msg);
   
      if(ticket<0)
       msg+="[BUYSTOP]:"+err_msg;
      else
       axAddOrder(ticket,dummy_bar.low,FIBO_618,1);       
     }
    }
   }
  }
  }
  //������ GREEN3 + ������������� RED2

  //Comment(msg);
 }//������� ��������� ���
}
//+------------------------------------------------------------------+
