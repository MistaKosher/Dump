//+------------------------------------------------------------------+
//|                                                  ax_bar_type.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum bar_types
{
 BARTYPE_NONE,
 BARTYPE_BEARISH,
 BARTYPE_BULLISH
};//struct bar_types

enum ao_trend_mode
{
 AOTREND_UP,
 AOTREND_DOWN,
 AOTREND_HOR
};

enum trade_mode
{
 TRADEMODE_BUY,
 TRADEMODE_SELL
};

enum bar_reversal_type
{
 BARREVERSAL_NONE,
 BARREVERSAL_BULLISH,
 BARREVERSAL_BEARISH
};

enum ac_mode
{
 ACMODE_NONE,
 ACMODE_GREEN2,
 ACMODE_GREEN3,
 ACMODE_RED2,
 ACMODE_RED3
};

enum bar_position
{
 BARPOSITION_UNDERGATOR,
 BARPOSITION_ABOVEGATOR
};

enum bar_position_mode
{
 BARPOSITIONMODE_FULL,
 BARPOSITIONMODE_PART,
 BARPOSITIONMODE_MEDIUM
};

class ax_bar_utils
{
 private:
  static double get_avg_value(MqlRates& bar);

 public:
  ax_bar_utils();
 ~ax_bar_utils();
 
  static bar_types get_type(MqlRates& ready_bar, MqlRates& prev_bar);
                    
  static bar_types get_type2(MqlRates& ready_bar);
  
  static bool is_price_in_range(MqlRates& bar, double price);
  
  static bool is_out_of_gator(MqlRates& bar);
  
  static bool get_bar_gator_position(MqlRates& bar,bar_position bp,bar_position_mode bpm);
  
  static bool is_out_of_gator(MqlRates& bar, bar_types bt);
  
  static double get_min(double v1,double v2,double v3);
  
  static double get_max(double v1,double v2,double v3);
  
  static bool is_equal(MqlRates& b1,MqlRates& b2);
  
  static int OpenOrder(MqlRates& b,bar_types bt,string& err_msg,datetime _exp=0);
  
  static int OpenOrder(MqlRates& b,trade_mode tm,string& err_msg,datetime _exp=0);
  
  static int OpenOrder2(MqlRates& b,trade_mode tm,string& err_msg,int _exp,double lot,string comment);
  
  static int CloseAllOrders();
  
  static int CloseAllOrdersSAR();
  
  static int CloseAllOrdersByProfit();
  
  static bool SetOrderSL(MqlRates& b,ao_trend_mode ao_mode,datetime _exp=0);
  
  static bool SetOrderSL(MqlRates& b,datetime _exp=0);
  
  static int SetAllOrderSL(MqlRates& b,ao_trend_mode ao_mode);
  
  static int SetAllOrderSLbyFibo(MqlRates& b,double fibo_coef);
  
  static int RemoveAllOrders();
  
  static string err_msg();
  
  static bool gator_sleeps();
  
  static bool gator_waked_up();
  
  static void WriteFile(int handle,string msg);
  
  static void GetGatorStat(int handle,int shift);
  
  static double get_gator_wake_up_val();
  
  static double get_gator_sleep_val();
  
  static double rad_to_grad(double rad);
  
  static bool is_angulation(MqlRates& b,bar_types bt,double& angle);
  
  static bool is_bar_over_gator(MqlRates& b,int shift,double& avg_gator);
  
  static ac_mode get_ac_mode();
  
  static ac_mode get_ac_mode2();
  
  static bar_reversal_type get_bar_reversal_type(MqlRates& ready_bar, MqlRates& prev_bar);
  
  static void get_dummy_bar(MqlRates& dummy_bar,trade_mode tm,int mode);
  
  static int get_more_period();
  
  static double get_local_extremum(MqlRates& rates[],trade_mode tm);
};//class ax_bar_utils

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ax_bar_utils::ax_bar_utils()
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ax_bar_utils::~ax_bar_utils()
{
}
//+------------------------------------------------------------------+
static bar_types ax_bar_utils::get_type(MqlRates& ready_bar, MqlRates& prev_bar)
{
  //bull
  if(ready_bar.low<prev_bar.low && ready_bar.close>ax_bar_utils::get_avg_value(ready_bar))
   return BARTYPE_BULLISH;
   
  //bear
  if(ready_bar.high>prev_bar.high && ready_bar.close<ax_bar_utils::get_avg_value(ready_bar))
   return BARTYPE_BEARISH;
   
  return BARTYPE_NONE;
}

//+------------------------------------------------------------------+
static bar_types ax_bar_utils::get_type2(MqlRates& bar)
{
  //bull
  if(bar.close>ax_bar_utils::get_avg_value(bar))
   return BARTYPE_BULLISH;
   
  //bear
  if(bar.close<ax_bar_utils::get_avg_value(bar))
   return BARTYPE_BEARISH;
   
  return BARTYPE_NONE;
}

//-------------------------------------------------------------------- 
static double ax_bar_utils::get_avg_value(MqlRates& bar)
{
 return (bar.high-bar.low)/2+bar.low;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::is_price_in_range(MqlRates& bar, double price)
{
 return bar.high>=price&&bar.low<=price;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::is_out_of_gator(MqlRates& bar)
{
 //получаем значение Алигатора
 double lips_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
 double teeth_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
 double jaw_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
 
 return (bar.high<ax_bar_utils::get_min(lips_val,teeth_val,jaw_val)) || (bar.low>ax_bar_utils::get_max(lips_val,teeth_val,jaw_val)); 
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::get_bar_gator_position(MqlRates& bar,bar_position bp,bar_position_mode bpm)
{
 //получаем значение Алигатора
 double lips_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
 double teeth_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
 double jaw_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
 
 if(bp==BARPOSITION_UNDERGATOR)
 {
  double min=ax_bar_utils::get_min(lips_val,teeth_val,jaw_val);
  
  switch(bpm)
  {
   case BARPOSITIONMODE_FULL: return bar.high<min;
   case BARPOSITIONMODE_PART: return bar.low<min;
   case BARPOSITIONMODE_MEDIUM: return ax_bar_utils::get_avg_value(bar)<min;
  }  
 }
 
 if(bp==BARPOSITION_ABOVEGATOR) 
 {
  double max=ax_bar_utils::get_max(lips_val,teeth_val,jaw_val);
  
  switch(bpm)
  {
   case BARPOSITIONMODE_FULL: return bar.low>max;
   case BARPOSITIONMODE_PART: return bar.high>max;
   case BARPOSITIONMODE_MEDIUM: return ax_bar_utils::get_avg_value(bar)>max;
  }  
 }
 
 return false;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::is_out_of_gator(MqlRates& bar, bar_types bt)
{
 //получаем значение Алигатора
 double lips_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
 double teeth_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
 double jaw_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
  
 if(bt==BARTYPE_BEARISH)
 {
  double gator_val=ax_bar_utils::get_max(lips_val,teeth_val,jaw_val);
  
  //return bar.low>gator_val;
  return bar.low>(gator_val+(bar.high-bar.low)*g_gator_bar_diff);
 }
 
 if(bt==BARTYPE_BULLISH)
 {
  double gator_val=ax_bar_utils::get_min(lips_val,teeth_val,jaw_val);
  
  //return bar.high<gator_val;
  return bar.high<(gator_val-(bar.high-bar.low)*g_gator_bar_diff);
 }
 
 return false;
}

//-------------------------------------------------------------------- 
static double ax_bar_utils::get_min(double v1,double v2,double v3)
{
 return MathMin(v1,MathMin(v2,v3));
}

//-------------------------------------------------------------------- 
static double ax_bar_utils::get_max(double v1,double v2,double v3)
{
 return MathMax(v1,MathMax(v2,v3));
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::is_equal(MqlRates& b1,MqlRates& b2)
{
 return b1.time==b2.time;
}

//-------------------------------------------------------------------- 
static int ax_bar_utils::OpenOrder(MqlRates& b,bar_types bt,string& err_msg,datetime _exp)
{
 datetime expiration=0;
 
 if(_exp!=0)
  expiration=TimeCurrent()+g_reversal_bar_cnt_wait*PeriodSeconds(Period());
 
 err_msg="";
 //--- получим минимальное значение Stop level 
 //double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 double price =0;
 double sl    =0;
 double tp    =0;
 
 int ticket=-1;
 
 if(bt==BARTYPE_BULLISH)//покупаем
 {
  price =NormalizeDouble(b.high+g_delta_points*Point,Digits);
  sl    =NormalizeDouble(b.low-g_delta_points*Point,Digits);
  tp    =NormalizeDouble(b.high+g_profit_coef*(b.high-b.low),Digits);
  ticket=OrderSend(Symbol(),OP_BUYSTOP,g_lots,price,g_slippage,sl,tp,"AX Order Buy",g_order_count++,expiration,clrWhiteSmoke);
 }
 
 if(bt==BARTYPE_BEARISH)//продаем
 {
  price =NormalizeDouble(b.low-g_delta_points*Point,Digits);
  sl    =NormalizeDouble(b.high+g_delta_points*Point,Digits);
  tp    =NormalizeDouble(b.low-g_profit_coef*(b.high-b.low),Digits);
  ticket=OrderSend(Symbol(),OP_SELLSTOP,g_lots,price,g_slippage,sl,tp,"AX Order Sell",g_order_count++,expiration,clrWhiteSmoke);
 }
 
 if(ticket<0)
 {
  int err=GetLastError();
  
  err_msg=IntegerToString(err)+":"+ErrorDescription(err)+"\n"+
          "Price:"+DoubleToString(price)+"\n"+
          "Loss:"+DoubleToString(sl)+"\n"+
          "Profit:"+DoubleToString(tp);
 }
 
 return ticket;
}

//-------------------------------------------------------------------- 
static int ax_bar_utils::OpenOrder(MqlRates& b,trade_mode tm,string& err_msg,datetime _exp=0)
{
 datetime expiration=_exp;
 
 /*if(_exp!=0)
  expiration=TimeCurrent()+g_bar_cnt_wait*PeriodSeconds(Period());*/
 
 err_msg="";
 //--- получим минимальное значение Stop level 
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 double price =0;
 double sl    =0;
 double tp    =0;
 int ticket   =-1;
 
 if(tm==TRADEMODE_BUY)//покупаем
 {
  price =Ask;
  sl    =MathMin(NormalizeDouble(b.low-g_delta_points*Point,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
  //tp    =NormalizeDouble(b.high+g_profit_coef*(b.high-b.low),Digits);
  //sl=NormalizeDouble(Bid-minstoplevel*Point,Digits);
  ticket=OrderSend(Symbol(),OP_BUY,g_lots,price,g_slippage,sl,tp,"AX Order Buy",g_order_count++,expiration,clrWhiteSmoke);
 }
 
 if(tm==TRADEMODE_SELL)//продаем
 {
  price =Bid;
  sl    =MathMax(NormalizeDouble(b.high+g_delta_points*Point,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));
  //tp    =NormalizeDouble(b.low-g_profit_coef*(b.high-b.low),Digits);
  //sl=NormalizeDouble(Ask-minstoplevel*Point,Digits);
  ticket=OrderSend(Symbol(),OP_SELL,g_lots,price,g_slippage,sl,tp,"AX Order Sell",g_order_count++,expiration,clrWhiteSmoke);
 }
 
 if(ticket<0)
 {
  int err=GetLastError();
  
  err_msg=IntegerToString(err)+":"+ErrorDescription(err)+"\n"+
          "Price:"+DoubleToString(price)+"\n"+
          "Stop Loss:"+DoubleToString(sl)+"\n"+
          "Take Profit:"+DoubleToString(tp);
 }
 
 return ticket;
}

//-------------------------------------------------------------------- 
static int ax_bar_utils::OpenOrder2(MqlRates& b,trade_mode tm,string& err_msg,int _exp,double lot,string comment)
{
 datetime expiration=0;
 
 if(_exp!=0)
  expiration=TimeCurrent()+g_reversal_bar_cnt_wait*PeriodSeconds(Period())+1;
 
 err_msg="";
 //--- получим минимальное значение Stop level 
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 double price   =0;
 double sl      =0;
 double tp      =0;
 int ticket     =-1;
 
 if(tm==TRADEMODE_BUY)//покупаем
 {
  price   =MathMax(NormalizeDouble(Ask+minstoplevel*Point,Digits),NormalizeDouble(b.high+g_delta_points*Point,Digits));
  sl      =MathMin(NormalizeDouble(b.low-g_delta_points*Point,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
  tp      =g_set_tp?NormalizeDouble(MathMax(b.high,price)+g_profit_coef*(b.high-b.low),Digits):0;
  ticket  =OrderSend(Symbol(),OP_BUYSTOP,lot,price,g_slippage,sl,tp,comment,g_order_count++,expiration,clrWhiteSmoke);
  
  /*double tmp=price;
  price  =sl;
  sl     =tmp;
  tp     =NormalizeDouble(b.low-g_profit_coef*(b.high-b.low),Digits);
  ticket =OrderSend(Symbol(),OP_SELLSTOP,g_lots,price,g_slippage,sl,tp,"AX Order Sell",g_order_count++,expiration,clrWhiteSmoke);*/
 }
 
 if(tm==TRADEMODE_SELL)//продаем
 {
  price  =MathMin(NormalizeDouble(Bid-minstoplevel*Point,Digits),NormalizeDouble(b.low-g_delta_points*Point,Digits));
  sl     =MathMax(NormalizeDouble(b.high+g_delta_points*Point,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));
  tp     =g_set_tp?NormalizeDouble(MathMin(b.low,price)-g_profit_coef*(b.high-b.low),Digits):0;
  ticket =OrderSend(Symbol(),OP_SELLSTOP,lot,price,g_slippage,sl,tp,comment,g_order_count++,expiration,clrWhiteSmoke);
  
  /*double tmp  =price;
  price  =sl;
  sl     =tmp;
  tp     =NormalizeDouble(b.high+g_profit_coef*(b.high-b.low),Digits);  
  ticket =OrderSend(Symbol(),OP_BUYSTOP,g_lots,price,g_slippage,sl,tp,"AX Order Buy",g_order_count++,expiration,clrWhiteSmoke);*/
 }
 
 if(ticket<0)
 {
  int err=GetLastError();
  
  err_msg=IntegerToString(err)+":"+ErrorDescription(err)+"\n"+
          "Price:"+DoubleToString(price)+"\n"+
          "Stop Loss:"+DoubleToString(sl)+"\n"+
          "Take Profit:"+DoubleToString(tp);
 }
 
 return ticket;
}

//-------------------------------------------------------------------- 
//возвращает количество оставшихся открытых
static int ax_bar_utils::CloseAllOrders()
{
 int cnt=OrdersTotal();
 
 int close_success=0;
 int close_failed=0;
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  int order_type=OrderType();
  
  if(order_type==OP_BUY)
  {
   if(OrderClose(OrderTicket(),g_lots,Bid,g_slippage))
    close_success++;
   else
    close_failed++;
  }
  
  if(order_type==OP_SELL)
  {
   if(OrderClose(OrderTicket(),g_lots,Ask,g_slippage))
    close_success++;
   else
    close_failed++;
  }
 } 
 
 cnt=OrdersTotal();
 
 return (cnt-close_success)<0?0:(cnt-close_success);
}

//--------------------------------------------------------------------
static int ax_bar_utils::CloseAllOrdersSAR()
{
 int new_period=ax_bar_utils::get_more_period();
 
 MqlRates mqlrates[];
 
 ArrayCopyRates(mqlrates,NULL,new_period);
 
 int cnt=OrdersTotal();

 int close_success=0;
 int close_failed=0;
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  int order_type=OrderType();
  
  if(order_type==OP_BUY && OrderComment()=="SL.NE.CR" && mqlrates[1].time>OrderOpenTime() && mqlrates[1].high<=iSAR(NULL,new_period,0.02,0.2,1) && mqlrates[2].low>=iSAR(NULL,new_period,0.02,0.2,2))
  {    
   if(OrderClose(OrderTicket(),OrderLots(),Bid,g_slippage))
    close_success++;
   else
    close_failed++;
  }
   
  if(order_type==OP_SELL && OrderComment()=="SL.NE.CR" && mqlrates[1].time>OrderOpenTime() && mqlrates[1].low>=iSAR(NULL,new_period,0.02,0.2,1) && mqlrates[2].high<=iSAR(NULL,new_period,0.02,0.2,2))
  {
   if(OrderClose(OrderTicket(),OrderLots(),Ask,g_slippage))
    close_success++;
   else
    close_failed++;
  }
 }
 
 cnt=OrdersTotal();
 
 return (cnt-close_success)<0?0:(cnt-close_success); 
}

//--------------------------------------------------------------------
static int ax_bar_utils::CloseAllOrdersByProfit()
{
 int cnt=OrdersTotal();

 int close_success=0;
 int close_failed=0;
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  int order_type=OrderType();
  
  if(order_type==OP_BUY)
  {
   double p=OrderProfit();
   
   if(p>=g_profit || p<=g_loss)
   {
    if(OrderClose(OrderTicket(),OrderLots(),Bid,g_slippage))
     close_success++;
    else
     close_failed++;
   }
  }
   
  if(order_type==OP_SELL)
  {
   double p=OrderProfit();
   
   if(p>=g_profit || p<=g_loss)
   {
    if(OrderClose(OrderTicket(),OrderLots(),Ask,g_slippage))
     close_success++;
    else
     close_failed++;
   }
  }
 }
 
 cnt=OrdersTotal();
 
 return (cnt-close_success)<0?0:(cnt-close_success); 
}

//--------------------------------------------------------------------
static bool ax_bar_utils::SetOrderSL(MqlRates& b,ao_trend_mode ao_mode,datetime _exp=0)
{
 if(!(g_ticket>0&&OrderSelect(g_ticket,SELECT_BY_TICKET)))
  return false;
  
 bool retval=false;
 
 double sl=OrderStopLoss();
 
 if(ao_mode==AOTREND_UP)
 {
  sl    =MathMin(NormalizeDouble(b.low-g_delta_points*Point,Digits),Bid);
  retval=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),_exp);
 }
 
 if(ao_mode==AOTREND_DOWN)
 {
  sl    =MathMax(NormalizeDouble(b.high+g_delta_points*Point,Digits),Ask);
  retval=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),_exp);
 }
 
 return retval;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::SetOrderSL(MqlRates& b,datetime _exp=0)
{
 if(g_ticket<0)
  return true;
  
 if(!OrderSelect(g_ticket,SELECT_BY_TICKET))
 {
  g_ticket=-1;//похоже, что ордер уже закрылся по stoploss
  return false;
 }
  
 bool retval=false;
 
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 double sl=0;
 
 int order_type=OrderType();
 
 if(order_type==OP_BUY)
 {
  sl=MathMin(NormalizeDouble(b.low,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
  //sl=MathMin(NormalizeDouble(b.low-g_delta_points*Point,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
  retval =OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),_exp);
 }
 
 if(order_type==OP_SELL)
 {
  sl    =MathMax(NormalizeDouble(b.high,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));
  //sl    =MathMax(NormalizeDouble(b.high+g_delta_points*Point,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));
  retval =OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),_exp);
 }
 
 return retval;
}

//-------------------------------------------------------------------- 
static int ax_bar_utils::SetAllOrderSL(MqlRates& b,ao_trend_mode ao_mode)
{
 if(ao_mode==AOTREND_HOR)
  return 0;
  
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 int modify_success=0;
 
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  int order_type=OrderType();

  if(ao_mode==AOTREND_DOWN && order_type==OP_BUY)
  {
   //double sl=MathMin(NormalizeDouble(b.low,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
   double sl=MathMin(NormalizeDouble(b.low-g_delta_points*Point,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
   
   if(OrderModify(OrderTicket(),OrderOpenPrice(),MathMax(sl,OrderStopLoss()),OrderTakeProfit(),OrderExpiration()))
    modify_success++;
  }
  
  if(ao_mode==AOTREND_UP && order_type==OP_SELL)
  {
   //double sl=MathMax(NormalizeDouble(b.high,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));
   double sl=MathMax(NormalizeDouble(b.high+g_delta_points*Point,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));

   if(OrderModify(OrderTicket(),OrderOpenPrice(),MathMin(sl,OrderStopLoss()),OrderTakeProfit(),OrderExpiration()))
    modify_success++;
  }
 }
 
 cnt=OrdersTotal();
 
 return (cnt-modify_success)<0?0:(cnt-modify_success);//сколько осталось не модифицированных
}

//-------------------------------------------------------------------- 
static int ax_bar_utils::SetAllOrderSLbyFibo(MqlRates& b,double fibo_coef)
{
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 int modify_success=0;
 
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  //if(OrderComment()=="SL.NE.CR")
  // continue;
   
  int order_type=OrderType();

  if(order_type==OP_BUY)
  {
   double order_low=g_buy_loc_min;//NormalizeDouble(StringToDouble(OrderComment()),Digits);
   
   double diff=g_buy_max-order_low;
   
   if(diff>0)//Текущая цена выше стартовой точки
   {
    diff-=diff*fibo_coef;
    //double sl=MathMin(NormalizeDouble(b.low,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
    double sl=MathMin(NormalizeDouble(order_low+diff,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
   
    if(OrderModify(OrderTicket(),OrderOpenPrice(),MathMax(sl,OrderStopLoss()),OrderTakeProfit(),OrderExpiration()))
     modify_success++;
   }
  }
  
  if(order_type==OP_SELL)
  {
   double order_high=g_sell_loc_max;//NormalizeDouble(StringToDouble(OrderComment()),Digits);
   
   double diff=order_high-g_sell_min;
   
   if(diff>0)//текущая цена ниже стартовой точки
   {
    diff-=diff*fibo_coef;
    //double sl=MathMax(NormalizeDouble(b.high,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));
    double sl=MathMax(NormalizeDouble(order_high-diff,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));

    if(OrderModify(OrderTicket(),OrderOpenPrice(),MathMin(sl,OrderStopLoss()),OrderTakeProfit(),OrderExpiration()))
     modify_success++;
   }
  }
 }
 
 cnt=OrdersTotal();
 
 return (cnt-modify_success)<0?0:(cnt-modify_success);//сколько осталось не модифицированных
}

//-------------------------------------------------------------------- 
static int ax_bar_utils::RemoveAllOrders()
{
 int remove_success=0;
 
 int cnt=OrdersTotal();
 
 Comment("CNT:"+IntegerToString(cnt));
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  if(OrderDelete(OrderTicket()))
   remove_success++;
 }
 
 return remove_success;
}

//-------------------------------------------------------------------- 
static string ax_bar_utils::err_msg()
{
 int err=GetLastError();
 
 return err==ERR_NO_ERROR?"":"("+IntegerToString(err)+")"+ErrorDescription(err);
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::gator_sleeps()
{
 //получаем значение Алигатора
 double lips  =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
 double teeth =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
 double jaw   =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
 
 double max_val =ax_bar_utils::get_max(lips,teeth,jaw);
 double min_val =ax_bar_utils::get_min(lips,teeth,jaw);
 
 return max_val/min_val<g_gator_sleep_val;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::gator_waked_up()
{
 //получаем значение Алигатора
 double lips  =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
 double teeth =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
 double jaw   =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
 
 double max_val =ax_bar_utils::get_max(lips,teeth,jaw);
 double min_val =ax_bar_utils::get_min(lips,teeth,jaw);
 
 return max_val/min_val>g_gator_wake_up_val;
}

//-------------------------------------------------------------------- 
static void ax_bar_utils::WriteFile(int handle,string msg)
{
 FileWrite(handle,TimeToString(TimeCurrent())+":"+msg);
 //FileWrite(handle,msg); 
 FileFlush(handle);
}

//-------------------------------------------------------------------- 
static void ax_bar_utils::GetGatorStat(int handle,int shift)
{
 MqlRates mqlrates[];

 ArrayCopyRates(mqlrates,Symbol(),Period());
 
 for(int s=0;s<shift;s++)
 {
  double lips=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,s);
  double teeth=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,s);
  double jaw=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,s);
  
  double max_val=ax_bar_utils::get_max(lips,teeth,jaw);
  double min_val=ax_bar_utils::get_min(lips,teeth,jaw);
  
  string msg=DoubleToString(max_val/min_val,12);
 
  MqlRates bar=mqlrates[s]; 
  
  msg+=CharToString(9)+TimeToString(bar.time);
  
  ax_bar_utils::WriteFile(handle,msg);
 }
}

//-------------------------------------------------------------------- 
static double ax_bar_utils::get_gator_wake_up_val()
{
 switch(Period())
 {
  case PERIOD_M1:  return 1.00006;
  case PERIOD_M5:  return 1.001;
  case PERIOD_M15: return 1.001;
  case PERIOD_M30: return 1.001;
  case PERIOD_H1:  return 1.002;
  default: return 1.003;
/*  case PERIOD_M1: return 1.0006;
  case PERIOD_M5: return 1.00065;
  case PERIOD_M15: return 1.001;
  case PERIOD_M30: return 1.002;
  default: return 1.003;*/
/*  case PERIOD_H1:
  case PERIOD_H4:
  case PERIOD_D1:
  case PERIOD_W1:
  case PERIOD_MN1:*/
 } 
}

//-------------------------------------------------------------------- 
static double ax_bar_utils::get_gator_sleep_val()
{
 switch(Period())
 {
  case PERIOD_M1:  return 1.000006;
  case PERIOD_M5:  return 1.0001;
  case PERIOD_M15: return 1.00009;
  case PERIOD_M30: return 1.0002;//return 1.0007;
  case PERIOD_H1:  return 1.0007;
  default: return 1.0003; 
 }
}

//-------------------------------------------------------------------- 
static double ax_bar_utils::rad_to_grad(double rad)
{
 const double pi=3.1415926535;

 return rad*180/pi;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::is_angulation(MqlRates& b,bar_types bt,double& angle)
{
 angle=0;
 
 if(bt==BARTYPE_NONE)
  return false;
  
 //пытаемся определить точку пересечения гатор с каким-то баром назад
 MqlRates bars[];
 
 int bars_count=ArrayCopyRates(bars,NULL,0);
 
 double bar_val=(bt==BARTYPE_BULLISH)?b.high:b.low;
 
 for(int i=1;i<bars_count;i++)
 {
  double avg_gator;//среднее значение гатора в точке пересечения с графиком (точка 0)
  
  if(ax_bar_utils::is_bar_over_gator(bars[i],i,avg_gator))//график пересек график
  {
   double teeth=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
   double jaw=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
   
   double teeth_jaw_val=(teeth+jaw)/2;
   
   double y1=MathAbs(avg_gator-bar_val)*MathPow(10,Digits);
   double y2=MathAbs(avg_gator-teeth_jaw_val)*MathPow(10,Digits);
   
   datetime cur_time=TimeCurrent();
   datetime past_time=bars[i].time;
   
   int secs=(int)(cur_time-past_time);
   
   double x1=secs;
   double x2=secs;  
   
   double cos_fi=MathAbs(x1*x2+y1*y2)/(MathSqrt(x1*x1+y1*y1)*MathSqrt(x2*x2+y2*y2));
   
   angle=ax_bar_utils::rad_to_grad(MathArccos(cos_fi));
   
   //фильтруем значение angle
   
   return true;
  }
 }
 
 return false;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::is_bar_over_gator(MqlRates& b,int shift,double& avg_gator)
{
 avg_gator=0;
 
 double lips=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,shift);
 double teeth=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,shift);
 double jaw=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,shift);
 
 double max_val=ax_bar_utils::get_max(lips,teeth,jaw);
 double min_val=ax_bar_utils::get_min(lips,teeth,jaw);

 if(max_val<=b.high && min_val>=b.low)
 {
  avg_gator=(max_val+min_val)/2;
  return true;
 }
 
 return false;
}

//-------------------------------------------------------------------- 
static ac_mode ax_bar_utils::get_ac_mode()
{
 double v1=iAC(NULL,0,1);//-1
 double v2=iAC(NULL,0,2);//-2
 double v3=iAC(NULL,0,3);//-3
 double v4=iAC(NULL,0,4);//-4
 
 if(v1>0&&v2>0&&v1>v2&&v2>v3)
  return ACMODE_GREEN2;
  
 if(v1<0&&v2<0&&v1<v2&&v2<v3)
  return ACMODE_RED2;
  
 if(v1<0&&v2<0&&v3<0&&v1>v2&&v2>v3&&v3>v4)
  return ACMODE_GREEN3;
  
 if(v1>0&&v2>0&&v3>0&&v1<v2&&v2<v3&&v3<v4)
  return ACMODE_RED3;

 return ACMODE_NONE;  
}

//-------------------------------------------------------------------- 
static ac_mode ax_bar_utils::get_ac_mode2()
{
 double v1=iAC(NULL,0,1);//-1
 double v2=iAC(NULL,0,2);//-2
 double v3=iAC(NULL,0,3);//-3
 double v4=iAC(NULL,0,4);//-4
 
 if(v1>0&&v2>0&&v1>v2&&v2>v3)
  return ACMODE_GREEN2;
  
 if(v1<0&&v2<0&&v1<v2&&v2<v3)
  return ACMODE_RED2;
  
 if(v1>0&&v2<0&&v3<0&&v1>v2&&v2>v3&&v3>v4)
  return ACMODE_GREEN3;
  
 if(v1<0&&v2>0&&v3>0&&v1<v2&&v2<v3&&v3<v4)
  return ACMODE_RED3;

 return ACMODE_NONE;  
}

//-------------------------------------------------------------------- 
static bar_reversal_type ax_bar_utils::get_bar_reversal_type(MqlRates& ready_bar, MqlRates& prev_bar)
{
 bar_types bt=ax_bar_utils::get_type(ready_bar,prev_bar);
 
 if(bt==BARTYPE_NONE)
  return BARREVERSAL_NONE;
 
 if(bt==BARTYPE_BULLISH&&ax_bar_utils::is_out_of_gator(ready_bar,bt))
  return BARREVERSAL_BULLISH;
  
 if(bt==BARTYPE_BEARISH&&ax_bar_utils::is_out_of_gator(ready_bar,bt))
  return BARREVERSAL_BEARISH;

 return BARREVERSAL_NONE;
}

//--------------------------------------------------------------------
static void ax_bar_utils::get_dummy_bar(MqlRates& dummy_bar,trade_mode tm,int mode)
{
 MqlRates rates[];
 
 ArrayCopyRates(rates,NULL,0);
 
 if(tm==TRADEMODE_BUY)
 {
  dummy_bar.high =rates[1].high;
  dummy_bar.low  =(mode==3)?MathMin(ax_bar_utils::get_min(rates[1].low,rates[2].low,rates[3].low),MathMin(rates[4].low,rates[5].low)):
//  dummy_bar.low  =(mode==3)?rates[1].low:
//                            MathMin(rates[1].low,rates[2].low);
                            ax_bar_utils::get_min(rates[1].low,rates[2].low,rates[3].low);
//                            rates[1].low;
 }
 else
 {
  dummy_bar.high =(mode==3)?MathMax(ax_bar_utils::get_max(rates[1].high,rates[2].high,rates[3].high),MathMax(rates[4].high,rates[5].high)):
//  dummy_bar.high =(mode==3)?rates[1].high:
//                            MathMax(rates[1].high,rates[2].high);
                            ax_bar_utils::get_max(rates[1].high,rates[2].high,rates[3].high);
//                            rates[1].high;
  dummy_bar.low  =rates[1].low;
 }
 //dummy_bar.open=ax_bar_utils::get_min(rates[1].open,rates[2].open,rates[3].open);//эти значения нас не интересуют
 //dummy_bar.close=ax_bar_utils::get_max(rates[1].close,rates[2].close,rates[3].close);//эти значения нас не интересуют
 dummy_bar.open=0;//эти значения нас не интересуют
 dummy_bar.close=0;//эти значения нас не интересуют
}

//--------------------------------------------------------------------
static int ax_bar_utils::get_more_period()
{
 switch(Period())
 {
  /*
  case PERIOD_M1: return PERIOD_M5;
  case PERIOD_M5: return PERIOD_M15;
  case PERIOD_M15: return PERIOD_M30;
  case PERIOD_H1: return PERIOD_H4;
  case PERIOD_D1: return PERIOD_W1;
  */
  ///*  
  case PERIOD_M1: return PERIOD_M5;
  case PERIOD_M5: return PERIOD_M15;
  case PERIOD_M15: return PERIOD_H1;
  case PERIOD_H1: return PERIOD_H4;
  case PERIOD_D1: return PERIOD_W1;
  //*/
 }
 
 return Period();
}

//--------------------------------------------------------------------
static double ax_bar_utils::get_local_extremum(MqlRates& rates[],trade_mode tm)
{
 double loc_ext=(tm==TRADEMODE_BUY)?rates[1].low:rates[1].high;
 
 double lips_val;
 double jaw_val;
 
 for(int i=2;;i++)
 {
  if(tm==TRADEMODE_BUY)
  {
   jaw_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,i);
   
   if(rates[i].low>jaw_val)
    break;
    
   if(rates[i].low<loc_ext)
    loc_ext=rates[i].low;
  }
  
  if(tm==TRADEMODE_SELL)
  {
   lips_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,i);
   
   if(rates[i].high<lips_val)
    break;
    
   if(rates[i].high>loc_ext)
    loc_ext=rates[i].high;
  }
 }
 
 return loc_ext;
}
