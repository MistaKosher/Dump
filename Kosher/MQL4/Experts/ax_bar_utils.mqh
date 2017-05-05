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
 BARPOSITIONMODE_MEDIUM,
 BARPOSITIONMODE_MEDIUM3,
 BARPOSITIONMODE_MEDIUM2,
 BARPOSITIONMODE_PART,
 BARPOSITIONMODE_PART3,
 BARPOSITIONMODE_PART2
};

enum fibo_levels
{
//0.382;//0.236 0.382 0.500 0.618
 FIBO_100  =0,
 FIBO_618  =1,
 FIBO_500  =2,
 FIBO_382  =3,
 FIBO_236  =4
};

enum gator_mode
{
 GATORMODE_NONE,
 GATORMODE_NORMAL,
 GATORMODE_REVERSAL
};

enum rsi_mode
{
 RSIMODE_NONE,
 RSIMODE_UPPER,
 RSIMODE_MIDDLE_UPPER,
 RSIMODE_UPPER_MIDDLE,
 RSIMODE_LOWER,
 RSIMODE_MIDDLE_LOWER,
 RSIMODE_LOWER_MIDDLE
};

enum sl_mode
{
 SLMODE_NONE,
 SLMODE_CROSSGATOR_DOWNUP,
 SLMODE_CROSSGATOR_UPDOWN,
 SLMODE_LOCALEXT_MIN_ABOVEGATOR,
 SLMODE_LOCALEXT_MIN_UNDERGATOR,
 SLMODE_LOCALEXT_MAX_ABOVEGATOR,
 SLMODE_LOCALEXT_MAX_UNDERGATOR
};

enum adv_trade_mode
{
 ADVTRADEMODE_BUY,//0
 ADVTRADEMODE_SELL,//1
 ADVTRADEMODE_BOTH//2
};

enum macd_trade_mode
{
 MACDTRADEMODE_NONE,
 MACDTRADEMODE_BUY,
 MACDTRADEMODE_SELL
};

//-------------------------------------------------------
struct ax_order_settings
{
 const double      lot;
 const int         slippage;
 const string      comment;
 const int         expire_bar_count;
 const double      profit_coef;
 const fibo_levels fibo;
 
 ax_order_settings(double _lot,int _slippage,string _comment,int _expire_bar_count,double _profit_coef,fibo_levels _fibo):
  lot(_lot),
  slippage(_slippage),
  comment(_comment),
  expire_bar_count(_expire_bar_count),
  profit_coef(_profit_coef),
  fibo(_fibo)
 {
 }
};

//-------------------------------------------------------
class ax_bar_utils
{
 private:
  static double get_avg_value(MqlRates& bar);

 public:
  ax_bar_utils();
 ~ax_bar_utils();
 
  static bar_types get_type(MqlRates& ready_bar, MqlRates& prev_bar);
                    
  static bar_types get_type2(MqlRates& ready_bar);
  
  static bar_types get_type3(MqlRates& rates[],bar_position_mode bpm);
  
  static bar_types get_type_via_ac(MqlRates& rates[],bar_position_mode bpm,MqlRates& out_bar);
  
  static bool is_price_in_range(MqlRates& bar, double price);
  
  static bool is_out_of_gator(MqlRates& bar);
  
  static bool is_in_gator(MqlRates& bar,int shift);
  
  static bool get_bar_gator_position(MqlRates& rates[],bar_position bp,bar_position_mode bpm,int shift);
  
  static bool get_bar_gator_position(MqlRates& bar,bar_position bp,bar_position_mode bpm,int shift);
  
  static bool get_bar_gator_position2(MqlRates& rates[],bar_position bp,bar_position_mode bpm,int shift);
  
  static bool is_out_of_gator(MqlRates& bar, bar_types bt);
  
  static double get_min(double v1,double v2,double v3);
  
  static double get_max(double v1,double v2,double v3);
  
  static bool is_equal(MqlRates& b1,MqlRates& b2);
  
  static int OpenOrder(MqlRates& b,bar_types bt,string& err_msg,datetime _exp=0);
  
  static int OpenOrder(MqlRates& b,trade_mode tm,string& err_msg,datetime _exp=0);
  
  static int OpenOrder2(MqlRates& b,trade_mode tm,string& err_msg,int _exp,double lot,string comment);
  
  static int OpenOrder3(MqlRates& b,trade_mode tm,double lot,int slippage,string comment,int exp_bar_count,double profit_coef,string& err_msg);
  
  static int OpenOrderReverse(MqlRates& b,trade_mode tm,double lot,int slippage,string comment,int exp_bar_count,double profit_coef,string& err_msg);
  //static int OpenOrderReverse(double price,double sl,double tp,trade_mode tm,double lot,int slippage,string comment,int exp_bar_count,double profit_coef,string& err_msg);
  
  static int CloseAllOrders();
  
  static int CloseAllOrdersSAR();
  
  static int CloseAllOrdersSAR2(int slippage);
  
  static int CloseAllOrdersByProfit();
  
  static bool SetOrderSL(MqlRates& b,ao_trend_mode ao_mode,datetime _exp=0);
  
  static bool SetOrderSL(MqlRates& b,datetime _exp=0);
  
  static int SetAllOrderSL(MqlRates& b,ao_trend_mode ao_mode);
  
  static int SetAllOrderSLbyFibo(MqlRates& b,double fibo_coef);
  
  static int SetAllOrderSLbyFibo2(MqlRates& b,double fibo_coef);
  
  static int SetAllOrderSLbyFibo3(int op_type,double v);
  
  static int SetAllOrderSLbyFrac(double frac_sl,int op_type);
  
  static int SetAllOrderSLbyValue(double sl_val,int op_type);
  
  static int SetAllOrderSLbyValue(sl_mode slm,double sl_val);
  
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
  
  static ac_mode get_ac_mode3();
  
  static ac_mode get_ac_mode4();
  
  static ac_mode get_ac_mode5();
  
  static bar_reversal_type get_bar_reversal_type(MqlRates& ready_bar, MqlRates& prev_bar);
  
  static void get_dummy_bar(MqlRates& dummy_bar,trade_mode tm,int mode);
  
  static int get_more_period();
  
  static double get_local_extremum(MqlRates& rates[],trade_mode tm);
  
  static int find_order(ac_mode ac);
  
  static gator_mode get_gator_mode();
  
  static fibo_levels get_next_fibo(fibo_levels current_fibo);
  
  static fibo_levels get_next_fibo(fibo_levels current_fibo,double& coef);
  
  static double get_fractal(int mode);
  
  static void SweepOrderArray();
  
  static rsi_mode get_rsi_mode();
  
  static sl_mode get_sl_mode(MqlRates& rates[],double& sl_val);
  
  static bool inIchimokuCloud(double v);
  
  static double getPercentValueFromBarToExtrem(double bar_val,double extrem_val,double percent);
  
  static double get_sl_by_SAR(MqlRates& rates[],int op_type);
  
  static double get_sl_by_SAR2(MqlRates& rates[],int op_type);
  
  static bool __period();
  
  static bool volatile();
  
  static double get_max_lot();
  
  static void get_dummy_bar_reverse(MqlRates& direct_bar,double direct_lot,trade_mode tm,double profit_coef,MqlRates& reverse_bar,double& reverse_lot);
  //static void get_dummy_bar_reverse(MqlRates& direct_bar,double direct_lot,trade_mode tm,double profit_coef,double& price,double& sl,double& tp,double& reverse_lot);
  static macd_trade_mode get_tm_by_macd(int timeframe,int shift);
  
  //-------------------------------------------------------------------
  static bar_types get_bar_type_by_AC(MqlRates& rates[],MqlRates& out_bar,double& local_extremum);
  
  static void trade(MqlRates& rates[],trade_mode tm,ax_order_settings& direct,string& err_msg);
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

//+------------------------------------------------------------------+
static bar_types ax_bar_utils::get_type3(MqlRates& rates[],bar_position_mode bpm)
{
 bar_types bt=ax_bar_utils::get_type(rates[1],rates[2]);
 
 if(bt==BARTYPE_NONE)
  return BARTYPE_NONE;
  
 if(bt==BARTYPE_BULLISH && ax_bar_utils::get_bar_gator_position(rates,BARPOSITION_UNDERGATOR,bpm,1))
  return BARTYPE_BULLISH;
  
 if(bt==BARTYPE_BEARISH && ax_bar_utils::get_bar_gator_position(rates,BARPOSITION_ABOVEGATOR,bpm,1))
  return BARTYPE_BEARISH;
  
 return BARTYPE_NONE;
}

//-------------------------------------------------------------------- 
static bar_types ax_bar_utils::get_type_via_ac(MqlRates& rates[],bar_position_mode bpm,MqlRates& out_bar)
{
 out_bar.open  =rates[3].open;
 out_bar.close =rates[1].close;
 
 double v1=iAC(NULL,0,1);//-1
 double v2=iAC(NULL,0,2);//-2
 double v3=iAC(NULL,0,3);//-3
 double v4=iAC(NULL,0,4);//-4
 
 //BUY - определяем переход красное->зеленое (ниже нуля) - пик на графике AC
 if((v1<0&&v2<0&&v1>v2&&v2<v3&&v3<v4) || (v1<0&&v2<0&&v1>v2&&v2>v3&&v3<v4)|| (v1<0&&v1<0&&v1>v2&&v2>v3&&v3>v4))
 {
  out_bar.high  =rates[1].high;
  out_bar.low   =ax_bar_utils::get_min(rates[1].low,rates[2].low,rates[3].low);
  
  //if(ax_bar_utils::get_type(out_bar,rates[4])==BARTYPE_BULLISH && ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_UNDERGATOR,bpm,1))
  if(ax_bar_utils::get_type2(out_bar)==BARTYPE_BULLISH && ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_UNDERGATOR,bpm,1))
   return BARTYPE_BULLISH;
   
  return BARTYPE_NONE;
 }
 
 //SELL  - определяем переход зеленое->красное (выше нуля) - пик на графике AC
 if(v1>0&&v2>0&&v1<v2&&v2>v3&&v3>v4)
 {
  out_bar.high  =ax_bar_utils::get_max(rates[1].high,rates[2].high,rates[3].high);
  out_bar.low   =rates[1].low;
  
  //if(ax_bar_utils::get_type(out_bar,rates[4])==BARTYPE_BEARISH && ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_ABOVEGATOR,bpm,1))
  if(ax_bar_utils::get_type2(out_bar)==BARTYPE_BEARISH && ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_ABOVEGATOR,bpm,1))
   return BARTYPE_BEARISH;
   
  return BARTYPE_NONE;
 }
  
 return BARTYPE_NONE;
}

//-------------------------------------------------------------------- 
static double ax_bar_utils::get_avg_value(MqlRates& bar)
{
 return NormalizeDouble((bar.high-bar.low)/2+bar.low,Digits);
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
 double lips  =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1),Digits);
 double teeth =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1),Digits);
 double jaw   =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1),Digits);
 
 return (bar.high<ax_bar_utils::get_min(lips,teeth,jaw)) || (bar.low>ax_bar_utils::get_max(lips,teeth,jaw)); 
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::is_in_gator(MqlRates& bar,int shift)
{
 double lips  =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,shift),Digits);
 double teeth =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,shift),Digits);
 double jaw   =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,shift),Digits);
 
 double max=ax_bar_utils::get_max(lips,teeth,jaw);
 double min=ax_bar_utils::get_min(lips,teeth,jaw);
 
 return bar.low>=min && bar.high<=max;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::get_bar_gator_position(MqlRates& rates[],bar_position bp,bar_position_mode bpm,int shift)
{
 MqlRates bar=rates[shift];
 
 return ax_bar_utils::get_bar_gator_position(bar,bp,bpm,shift);
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::get_bar_gator_position(MqlRates& bar,bar_position bp,bar_position_mode bpm,int shift)
{
 //получаем значение Алигатора
 double lips  =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,shift),Digits);
 double teeth =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,shift),Digits);
 double jaw   =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,shift),Digits);
 
 double max=ax_bar_utils::get_max(lips,teeth,jaw);
 double min=ax_bar_utils::get_min(lips,teeth,jaw);
 
 if(bp==BARPOSITION_UNDERGATOR)
 {
  switch(bpm)
  {
   case BARPOSITIONMODE_FULL: return bar.high<min;
   case BARPOSITIONMODE_MEDIUM: return ax_bar_utils::get_avg_value(bar)<min && bar.high<max;
   case BARPOSITIONMODE_MEDIUM3: return ax_bar_utils::get_avg_value(bar)<min && bar.high<max;
   case BARPOSITIONMODE_MEDIUM2: return ax_bar_utils::get_avg_value(bar)<min;
   case BARPOSITIONMODE_PART: return bar.low<min && bar.high<max;
   case BARPOSITIONMODE_PART3: return bar.low<min && bar.high<max;
   case BARPOSITIONMODE_PART2: return bar.low<min;
  }  
 }
 
 if(bp==BARPOSITION_ABOVEGATOR)
 {
  switch(bpm)
  {
   case BARPOSITIONMODE_FULL: return bar.low>max;
   case BARPOSITIONMODE_MEDIUM: return ax_bar_utils::get_avg_value(bar)>max && bar.low>min;
   case BARPOSITIONMODE_MEDIUM3: return ax_bar_utils::get_avg_value(bar)>max && bar.low>min;
   case BARPOSITIONMODE_MEDIUM2: return ax_bar_utils::get_avg_value(bar)>max;
   case BARPOSITIONMODE_PART: return bar.high>max && bar.low>min;
   case BARPOSITIONMODE_PART3: return bar.high>max && bar.low>min;
   case BARPOSITIONMODE_PART2: return bar.high>max;
  }  
 }
 
 return false;
}

//-------------------------------------------------------------------- 
static bool ax_bar_utils::get_bar_gator_position2(MqlRates& rates[],bar_position bp,bar_position_mode bpm,int shift)
{
 //получаем значение Алигатора
 //double lips_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,shift);
 //double teeth_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,shift);
 double gator=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,shift);
 //double jaw_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,shift);
 //double gator=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,shift);
 
 MqlRates bar=rates[shift];
 
 if(bp==BARPOSITION_UNDERGATOR)
 {
  switch(bpm)
  {
   case BARPOSITIONMODE_FULL: return bar.high<gator;
   case BARPOSITIONMODE_MEDIUM3: return ax_bar_utils::get_avg_value(bar)<gator;
   case BARPOSITIONMODE_MEDIUM2: return ax_bar_utils::get_avg_value(bar)<gator;
   case BARPOSITIONMODE_PART3: return bar.low<gator;;
   case BARPOSITIONMODE_PART2: return bar.low<gator;
  }  
 }
 
 if(bp==BARPOSITION_ABOVEGATOR)
 {
  switch(bpm)
  {
   case BARPOSITIONMODE_FULL: return bar.low>gator;
   case BARPOSITIONMODE_MEDIUM3: return ax_bar_utils::get_avg_value(bar)>gator;
   case BARPOSITIONMODE_MEDIUM2: return ax_bar_utils::get_avg_value(bar)>gator;
   case BARPOSITIONMODE_PART3: return bar.high>gator;
   case BARPOSITIONMODE_PART2: return bar.high>gator;
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
static int ax_bar_utils::OpenOrder3(MqlRates& b,trade_mode tm,double lot,int slippage,string comment,int exp_bar_count,double profit_coef,string& err_msg)
{
 err_msg="";
 
 datetime expiration=(exp_bar_count==0)?0:TimeCurrent()+exp_bar_count*PeriodSeconds(Period())+1;
 
 //--- получим минимальное значение Stop level 
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 double price   =0;
 double sl      =0;
 double tp      =0;
 int ticket     =-1;
 
 if(tm==TRADEMODE_BUY)//покупаем
 {
  price   =MathMax(NormalizeDouble(Ask+(minstoplevel+g_delta_points)*Point,Digits),NormalizeDouble(b.high+g_delta_points*Point,Digits));
  sl      =MathMin(NormalizeDouble(b.low-g_delta_points*Point,Digits),NormalizeDouble(price-(minstoplevel+g_delta_points)*Point,Digits));
  tp      =(profit_coef==0)?0:NormalizeDouble(MathMax(b.high,price)+profit_coef*(b.high-b.low),Digits);
  ticket  =OrderSend(Symbol(),OP_BUYSTOP,lot,price,slippage,sl,tp,comment,g_order_count++,expiration,clrWhiteSmoke);
 }
 
 if(tm==TRADEMODE_SELL)//продаем
 {
  price  =MathMin(NormalizeDouble(Bid-minstoplevel*Point,Digits),NormalizeDouble(b.low-g_delta_points*Point,Digits));
  sl     =MathMax(NormalizeDouble(b.high+g_delta_points*Point,Digits),NormalizeDouble(price+(minstoplevel+g_delta_points)*Point,Digits));
  tp     =(profit_coef==0)?0:NormalizeDouble(MathMin(b.low,price)-profit_coef*(b.high-b.low),Digits);
  ticket =OrderSend(Symbol(),OP_SELLSTOP,lot,price,slippage,sl,tp,comment,g_order_count++,expiration,clrWhiteSmoke);
 }
 
 if(ticket<0)
 {
  int err=GetLastError();
  
  err_msg="error:("+IntegerToString(err)+")"+ErrorDescription(err)+"\n"+
          "open price:"+DoubleToString(price)+"\n"+
          "sl:"+DoubleToString(sl)+"\n"+
          "tp:"+DoubleToString(tp);
 }
 
 return ticket;
}

//-------------------------------------------------------------------- 
static int ax_bar_utils::OpenOrderReverse(MqlRates& b,trade_mode tm,double lot,int slippage,string comment,int exp_bar_count,double profit_coef,string& err_msg)
//static int ax_bar_utils::OpenOrderReverse(double price,double sl,double tp,trade_mode tm,double lot,int slippage,string comment,int exp_bar_count,double profit_coef,string& err_msg)
{
 err_msg="";
 
 datetime expiration=(exp_bar_count==0)?0:TimeCurrent()+exp_bar_count*PeriodSeconds(Period())+1;
 
 //--- получим минимальное значение Stop level 
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 double price   =0;
 double sl      =0;
 double tp      =0;
 int ticket     =-1;
 
 if(tm==TRADEMODE_BUY)//покупаем
 {
  price   =MathMax(NormalizeDouble(Ask+(minstoplevel+g_delta_points)*Point,Digits),NormalizeDouble(b.high+g_delta_points*Point,Digits));
  sl      =MathMin(NormalizeDouble(b.low-g_delta_points*Point,Digits),NormalizeDouble(price-(minstoplevel+g_delta_points)*Point,Digits));
  tp      =(profit_coef==0)?0:NormalizeDouble(price+MathMax(profit_coef*(b.high-b.low),(minstoplevel+g_delta_points)*Point),Digits);
  ticket  =OrderSend(Symbol(),OP_BUYSTOP,lot,price,slippage,sl,tp,comment,g_order_count++,expiration,clrWhiteSmoke);
 }
 
 if(tm==TRADEMODE_SELL)//продаем
 {
  price  =MathMin(NormalizeDouble(Bid-(minstoplevel+g_delta_points)*Point,Digits),NormalizeDouble(b.low-g_delta_points*Point,Digits));
  sl     =MathMax(NormalizeDouble(b.high+g_delta_points*Point,Digits),NormalizeDouble(price+(minstoplevel+g_delta_points)*Point,Digits));
  tp     =(profit_coef==0)?0:NormalizeDouble(price-MathMax(profit_coef*(b.high-b.low),(minstoplevel+g_delta_points)*Point),Digits);
  ticket =OrderSend(Symbol(),OP_SELLSTOP,lot,price,slippage,sl,tp,comment,g_order_count++,expiration,clrWhiteSmoke);
 }
 
 if(ticket<0)
 {
  int err=GetLastError();
  
  err_msg="error:("+IntegerToString(err)+")"+ErrorDescription(err)+"\n"+
          "open price:"+DoubleToString(price)+"\n"+
          "sl:"+DoubleToString(sl)+"\n"+
          "tp:"+DoubleToString(tp)+"\n"+
          //"minstoplevel:"+DoubleToString(minstoplevel)+"\n"+
          "Ask:"+DoubleToString(Ask)+"\n"+
          "Bid:"+DoubleToString(Bid);
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
static int ax_bar_utils::CloseAllOrdersSAR2(int slippage)
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
  
  if(OrderTakeProfit()!=0)
   continue;
   
  int order_type=OrderType();
  
  if(order_type==OP_BUY && mqlrates[1].time>OrderOpenTime() && mqlrates[1].high<=iSAR(NULL,new_period,0.02,0.2,1) && mqlrates[2].low>=iSAR(NULL,new_period,0.02,0.2,2))
  {    
   if(OrderClose(OrderTicket(),OrderLots(),Bid,slippage))
    close_success++;
   else
    close_failed++;
  }
   
  if(order_type==OP_SELL && mqlrates[1].time>OrderOpenTime() && mqlrates[1].low>=iSAR(NULL,new_period,0.02,0.2,1) && mqlrates[2].high<=iSAR(NULL,new_period,0.02,0.2,2))
  {
   if(OrderClose(OrderTicket(),OrderLots(),Ask,slippage))
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
static int ax_bar_utils::SetAllOrderSLbyFibo2(MqlRates& b,double fibo_coef)
{
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 int modify_success=0;
 
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  int order_type=OrderType();

  if(order_type==OP_BUY/* && 
     ax_bar_utils::get_bar_gator_position(b,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_FULL) &&
     ax_bar_utils::get_gator_mode()==GATORMODE_NORMAL*/)
  {
   string order_comment=OrderComment();
   
   double order_low=order_comment==""?g_buy_loc_min:NormalizeDouble(StringToDouble(order_comment),Digits);
   
   double diff=g_buy_max-order_low;
   
   if(diff>0)//Текущая цена выше стартовой точки
   {
    diff-=diff*fibo_coef;
    //double sl=MathMin(NormalizeDouble(b.low,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
    double sl=MathMin(NormalizeDouble(order_low+diff-g_delta_points*Point,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));

    if(sl>OrderStopLoss())   
     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration()))
      modify_success++;
   }
  }
  
  if(order_type==OP_SELL/* &&
     ax_bar_utils::get_bar_gator_position(b,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_FULL) &&
     ax_bar_utils::get_gator_mode()==GATORMODE_REVERSAL*/)
  {
   string order_comment=OrderComment();
   
   double order_high=order_comment==""?g_sell_loc_max:NormalizeDouble(StringToDouble(order_comment),Digits);
   
   double diff=order_high-g_sell_min;
   
   if(diff>0)//текущая цена ниже стартовой точки
   {
    diff-=diff*fibo_coef;
    //double sl=MathMax(NormalizeDouble(b.high,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));
    double sl=MathMax(NormalizeDouble(order_high-diff+g_delta_points*Point,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));

    if(sl<OrderStopLoss())   
     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration()))
      modify_success++;
   }
  }
 }
 
 cnt=OrdersTotal();
 
 return (cnt-modify_success)<0?0:(cnt-modify_success);//сколько осталось не модифицированных
}

//--------------------------------------------------------------------
static int ax_bar_utils::SetAllOrderSLbyFibo3(int op_type,double v)
{
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 int modify_success=0;
 
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  if(OrderTakeProfit()!=0)
   continue;
   
  int order_type =OrderType();
  
  int ticket     =OrderTicket();
  
  if(order_type==op_type && op_type==OP_BUY && v>axGetOrderByRSI(ticket))
  {
   double order_low =axGetOrderSL(ticket);
   
   double diff      =v-order_low;
   
   if(diff>0)//Текущая цена выше стартовой точки
   {
    double fibo=g_fibo_coefs[axGetOrderFiboLevel(ticket)];
    
    diff-=diff*fibo;

    double sl=MathMin(NormalizeDouble(order_low+diff-g_delta_points*Point,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));

    if(sl>OrderStopLoss() && OrderModify(ticket,OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration()))   
    {
      modify_success++;
      //axSetOrderFiboLevel(ticket,ax_bar_utils::get_next_fibo((fibo_levels)axGetOrderFiboLevel(ticket)));
    }
    
    axSetOrderFiboLevel(ticket,ax_bar_utils::get_next_fibo((fibo_levels)axGetOrderFiboLevel(ticket)));
    
    axSetOrderByRSI(ticket,v);
   }
  }
  
  if(order_type==op_type && op_type==OP_SELL && v<axGetOrderByRSI(ticket))
  {
   double order_high =axGetOrderSL(ticket);
   
   double diff       =order_high-v;
   
   if(diff>0)//текущая цена ниже стартовой точки
   {
    double fibo=g_fibo_coefs[axGetOrderFiboLevel(ticket)];
    
    diff-=diff*fibo;

    double sl=MathMax(NormalizeDouble(order_high-diff+g_delta_points*Point,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));

    if(sl<OrderStopLoss() && OrderModify(ticket,OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration()))
    {
      modify_success++;
      //axSetOrderFiboLevel(ticket,ax_bar_utils::get_next_fibo((fibo_levels)axGetOrderFiboLevel(ticket)));
    }
    
    axSetOrderFiboLevel(ticket,ax_bar_utils::get_next_fibo((fibo_levels)axGetOrderFiboLevel(ticket)));
    
    axSetOrderByRSI(ticket,v);
   }
  }
 }
 
 cnt=OrdersTotal();
 
 return (cnt-modify_success)<0?0:(cnt-modify_success);//сколько осталось не модифицированных
}

//--------------------------------------------------------------------
static int ax_bar_utils::SetAllOrderSLbyFrac(double frac_sl,int op_type)
{
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 int modify_success=0;
 
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  int order_type=OrderType();

  if(order_type==op_type/* && //OP_BUY
     ax_bar_utils::get_bar_gator_position(b,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_FULL) &&
     ax_bar_utils::get_gator_mode()==GATORMODE_NORMAL*/)
  {
   double sl=MathMin(NormalizeDouble(frac_sl-g_delta_points*Point,Digits),NormalizeDouble(Bid-minstoplevel*Point,Digits));
   
   if(sl>OrderStopLoss())
    if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration()))
      modify_success++;
  }
  
  if(order_type==op_type/* && //OP_SELL
     ax_bar_utils::get_bar_gator_position(b,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_FULL) &&
     ax_bar_utils::get_gator_mode()==GATORMODE_REVERSAL*/)
  {
   double sl=MathMax(NormalizeDouble(frac_sl+g_delta_points*Point,Digits),NormalizeDouble(Ask+minstoplevel*Point,Digits));

   if(sl<OrderStopLoss())
    if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration()))
     modify_success++;
  }
 }
 
 cnt=OrdersTotal();
 
 return (cnt-modify_success)<0?0:(cnt-modify_success);//сколько осталось не модифицированных
}

//--------------------------------------------------------------------
static int ax_bar_utils::SetAllOrderSLbyValue(double sl_val,int op_type)
{
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 int modify_success=0;
 
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  if(OrderTakeProfit()!=0)
   continue;
   
  int order_type=OrderType();
  
  string comment=OrderComment();

  if(order_type==op_type && op_type==OP_BUY)
  {
   double sl=MathMin(NormalizeDouble(sl_val-g_delta_points*Point,Digits),NormalizeDouble(Bid-(minstoplevel+1)*Point,Digits));
   double tp=comment=="DIRECT"?0:OrderTakeProfit();
   
   //if(sl<OrderOpenPrice())
   // sl=OrderOpenPrice();
   
   if(sl>OrderStopLoss() && OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,OrderExpiration()))
    modify_success++;
  }
  
  if(order_type==op_type && op_type==OP_SELL)
  {
   double sl=MathMax(NormalizeDouble(sl_val+g_delta_points*Point,Digits),NormalizeDouble(Ask+(minstoplevel+1)*Point,Digits));
   double tp=comment=="DIRECT"?0:OrderTakeProfit();

   //if(sl>OrderOpenPrice())
   // sl=OrderOpenPrice();
    
   if(sl<OrderStopLoss() && OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,OrderExpiration()))
    modify_success++;
  }
 }
 
 cnt=OrdersTotal();
 
 return (cnt-modify_success)<0?0:(cnt-modify_success);//сколько осталось не модифицированных
}

//--------------------------------------------------------------------
static int ax_bar_utils::SetAllOrderSLbyValue(sl_mode slm,double sl_val)
{
 double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 int modify_success=0;
 
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  if(OrderTakeProfit()!=0)
   continue;
   
  int order_type=OrderType();
  
  string comment=OrderComment();

  if(order_type==OP_BUY)
  {
   if((comment=="DIRECT" && (slm==SLMODE_CROSSGATOR_DOWNUP||slm==SLMODE_LOCALEXT_MIN_ABOVEGATOR)) || (comment=="REVERSE" && slm==SLMODE_LOCALEXT_MIN_UNDERGATOR))
   {
    double sl=MathMin(NormalizeDouble(sl_val-g_delta_points*Point,Digits),NormalizeDouble(Bid-(minstoplevel+1)*Point,Digits));
   
    if(sl>OrderStopLoss() && OrderModify(OrderTicket(),OrderOpenPrice(),sl,0,OrderExpiration()))
     modify_success++;
   }
  }
  
  if(order_type==OP_SELL)
  {
   if((comment=="DIRECT" && (slm==SLMODE_CROSSGATOR_UPDOWN||slm==SLMODE_LOCALEXT_MAX_ABOVEGATOR)) || (comment=="REVERSE" && slm==SLMODE_LOCALEXT_MAX_UNDERGATOR))
   {
    double sl=MathMax(NormalizeDouble(sl_val+g_delta_points*Point,Digits),NormalizeDouble(Ask+(minstoplevel+1)*Point,Digits));

    if(sl<OrderStopLoss() && OrderModify(OrderTicket(),OrderOpenPrice(),sl,0,OrderExpiration()))
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
static ac_mode ax_bar_utils::get_ac_mode3()
{
 double v1=iAC(NULL,0,1);//-1
 double v2=iAC(NULL,0,2);//-2
 double v3=iAC(NULL,0,3);//-3
 double v4=iAC(NULL,0,4);//-4
 
 if(v1>0&&v2>0&&v1>v2&&v2>v3&&v3<0)
  return ACMODE_GREEN2;
  
 if(v1<0&&v2<0&&v1<v2&&v2<v3&&v3>0)
  return ACMODE_RED2;
  
 if(v1<0&&v2<0&&v3<0&&v1>v2&&v2>v3&&v3<v4)
  return ACMODE_GREEN3;
  
 if(v1>0&&v2>0&&v3>0&&v1<v2&&v2<v3&&v3>v4)
  return ACMODE_RED3;

 return ACMODE_NONE;  
}

//-------------------------------------------------------------------- 
static ac_mode ax_bar_utils::get_ac_mode4()
{
 double v1=iAC(NULL,0,1);//-1
 double v2=iAC(NULL,0,2);//-2
 double v3=iAC(NULL,0,3);//-3
 double v4=iAC(NULL,0,4);//-4
 double v5=iAC(NULL,0,5);//-5
 
 if(v1>0&&v2>0&&v1>v2&&v2>v3&&v3<0)
  return ax_bar_utils::__period()?ACMODE_GREEN2:ACMODE_NONE;
  
 if(v1<0&&v2<0&&v1<v2&&v2<v3&&v3>0)
  return ax_bar_utils::__period()?ACMODE_RED2:ACMODE_NONE;
 
 if(ax_bar_utils::__period()) 
 {
 if(v1<0&&v2<0&&v3<0&&v1>v2&&v2>v3&&v3>v4&&v4<v5)
  return ACMODE_GREEN3;
  
 if(v1>0&&v2>0&&v3>0&&v1<v2&&v2<v3&&v3<v4&&v4>v5)
  return ACMODE_RED3;
 }
 else
 {
 if(v1<0&&v2<0&&v3<0&&v1>v2&&v2>v3&&v3<v4)
  return ACMODE_GREEN3;
  
 if(v1>0&&v2>0&&v3>0&&v1<v2&&v2<v3&&v3>v4)
  return ACMODE_RED3;
 }

 return ACMODE_NONE;  
}

//-------------------------------------------------------------------- 
static ac_mode ax_bar_utils::get_ac_mode5()
{
 double v1=iAC(NULL,0,1);//-1
 double v2=iAC(NULL,0,2);//-2
 double v3=iAC(NULL,0,3);//-3
 double v4=iAC(NULL,0,4);//-4
 
 /*if(v1>0&&v2>0&&v1>v2&&v2>v3&&v3<0)
  return ax_bar_utils::__period()?ACMODE_GREEN2:ACMODE_NONE;
  
 if(v1<0&&v2<0&&v1<v2&&v2<v3&&v3>0)
  return ax_bar_utils::__period()?ACMODE_RED2:ACMODE_NONE;*/
 
 if((v1<0&&v2<0&&v1>v2&&v2>v3&&v3<v4) || (v1<0&&v2<0&&v3<0&&v1>v2&&v2>v3&&v3>v4))
  return ACMODE_GREEN3;
  
 if((v1>0&&v2>0&&v1<v2&&v2<v3&&v3>v4) || (v1>0&&v2>0&&v3>0&&v1<v2&&v2<v3&&v3<v4))
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
//  dummy_bar.low  =MathMin(ax_bar_utils::get_min(rates[1].low,rates[2].low,rates[3].low),MathMin(rates[4].low,rates[5].low));
  dummy_bar.low  =(mode==3)?MathMin(ax_bar_utils::get_min(rates[1].low,rates[2].low,rates[3].low),MathMin(rates[4].low,rates[5].low)):
//  dummy_bar.low  =(mode==3)?rates[1].low:
//                            MathMin(rates[1].low,rates[2].low);
                            ax_bar_utils::get_min(rates[1].low,rates[2].low,rates[3].low);
//                            rates[1].low;
 }
 else
 {
//  dummy_bar.high =MathMax(ax_bar_utils::get_max(rates[1].high,rates[2].high,rates[3].high),MathMax(rates[4].high,rates[5].high));
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
 
 double gator;
 
 for(int i=2;;i++)
 {
  if(tm==TRADEMODE_BUY)
  {
   gator=NormalizeDouble(ax_bar_utils::get_min(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,i),
                                               iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,i),
                                               iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,i)),Digits);
   
   if(rates[i].low>gator)
    break;
    
   if(rates[i].low<loc_ext)
    loc_ext=rates[i].low;
  }
  
  if(tm==TRADEMODE_SELL)
  {
   gator=NormalizeDouble(ax_bar_utils::get_max(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,i),
                                               iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,i),
                                               iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,i)),Digits);
   
   if(rates[i].high<gator)
    break;
    
   if(rates[i].high>loc_ext)
    loc_ext=rates[i].high;
  }
 }
 
 return loc_ext;
}

//--------------------------------------------------------------------
static int ax_bar_utils::find_order(ac_mode ac)
{
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;
   
  if(OrderComment()==EnumToString(ac))
   return OrderTicket();
 }
 
 return -1;
}

//--------------------------------------------------------------------
static gator_mode ax_bar_utils::get_gator_mode()
{
 double lips_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
 double teeth_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
 double jaw_val=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
 
 if(lips_val==ax_bar_utils::get_max(lips_val,teeth_val,jaw_val))
  return GATORMODE_NORMAL;
  
 if(lips_val==ax_bar_utils::get_min(lips_val,teeth_val,jaw_val))
  return GATORMODE_REVERSAL;
 
 return GATORMODE_NONE;
}

//--------------------------------------------------------------------
static fibo_levels ax_bar_utils::get_next_fibo(fibo_levels current_fibo)
{
 switch(current_fibo)
 {
  case FIBO_100: return FIBO_618;
  case FIBO_618: return FIBO_500;
  case FIBO_500: return FIBO_382;
  case FIBO_382: return FIBO_236;  
 }
 
 return FIBO_236;
}

//--------------------------------------------------------------------
static fibo_levels ax_bar_utils::get_next_fibo(fibo_levels current_fibo,double& coef)
{
 switch(current_fibo)
 {
  case FIBO_100: coef=g_fibo_coefs[FIBO_100]; return FIBO_618;
  case FIBO_618: coef=g_fibo_coefs[FIBO_618]; return FIBO_500;
  case FIBO_500: coef=g_fibo_coefs[FIBO_500]; return FIBO_382;
  case FIBO_382: coef=g_fibo_coefs[FIBO_382]; return FIBO_236;  
 }
 
 coef=g_fibo_coefs[FIBO_236];
 
 return FIBO_236;
}

//--------------------------------------------------------------------
static double ax_bar_utils::get_fractal(int mode)
{
 int shift=3;
 
 double lips  =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,3);
 double teeth =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,3);
 double jaw   =iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,3);
 
 double frac=iFractals(NULL,0,mode,shift);
 
 if(mode==MODE_UPPER)
 {
  if(frac>=ax_bar_utils::get_max(lips,teeth,jaw))
   return frac;
 }
 else
 if(mode==MODE_LOWER)
 {
  if(frac<=ax_bar_utils::get_min(lips,teeth,jaw))
   return frac;
 }
 
 return 0;
}

//--------------------------------------------------------------------
static void ax_bar_utils::SweepOrderArray()
{
 int cnt=OrdersTotal();
 
 for(int i=0;i<cnt;i++)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
   continue;
   
  axRemoveOrder(OrderTicket());
 }
}

//--------------------------------------------------------------------
static rsi_mode ax_bar_utils::get_rsi_mode()
{
 double upper_level=0.7;
 double lower_level=0.3;
 
 double rsi=iRSI(NULL,0,g_rsi_period,PRICE_CLOSE,1)/100;
 double prev_rsi=iRSI(NULL,0,g_rsi_period,PRICE_CLOSE,2)/100;
 
 double dem=iDeMarker(NULL,0,g_demark_period,1);
 double prev_dem=iDeMarker(NULL,0,g_demark_period,2);
 
 double iVal=MathMax(rsi,dem);
 double iPrevVal=MathMax(prev_rsi,prev_dem);
 
 if(iPrevVal<=upper_level && iVal>upper_level)
  return RSIMODE_MIDDLE_UPPER;
  
 if(iPrevVal>upper_level && iVal<=upper_level)
  return RSIMODE_UPPER_MIDDLE;
 
 if(iVal>upper_level)
  return RSIMODE_UPPER;
  
 iVal=MathMin(rsi,dem);
 iPrevVal=MathMin(prev_rsi,prev_dem);
 
 if(iPrevVal>=lower_level && iVal<lower_level)
  return RSIMODE_MIDDLE_LOWER;
  
 if(iPrevVal<lower_level && iVal>=lower_level)
  return RSIMODE_LOWER_MIDDLE;

 if(iVal<lower_level)
  return RSIMODE_LOWER;
 /*
 if((prev_rsi<=upper_level && rsi>upper_level) || (prev_dem<=upper_level && dem>upper_level))
  return RSIMODE_MIDDLE_UPPER;
 
 if((prev_rsi>upper_level && rsi<=upper_level) || (prev_dem>upper_level && dem<=upper_level))
  return RSIMODE_UPPER_MIDDLE;
 
 if((prev_rsi>=lower_level && rsi<lower_level) || (prev_dem>=lower_level && dem<lower_level))
  return RSIMODE_MIDDLE_LOWER;
  
 if((prev_rsi<lower_level && rsi>=lower_level) || (prev_dem<lower_level && dem>=lower_level))
  return RSIMODE_LOWER_MIDDLE;
 
 if(rsi>upper_level || dem>upper_level)
  return RSIMODE_UPPER;
  
 if(rsi<lower_level || dem<lower_level)
  return RSIMODE_LOWER;
 */
 
 return RSIMODE_NONE;
}

//--------------------------------------------------------------------
static sl_mode ax_bar_utils::get_sl_mode(MqlRates& rates[],double& sl_val)
{
 sl_val=0;
 
 MqlRates ready_bar=rates[1];
 
 double lips  =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1),Digits);
 double teeth =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1),Digits);
 double jaw   =NormalizeDouble(iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1),Digits);
 
 if(ready_bar.low<=teeth && teeth<=ready_bar.high)
 {
  sl_val=teeth;
  return lips<jaw?SLMODE_CROSSGATOR_DOWNUP:SLMODE_CROSSGATOR_UPDOWN;
 }
 
 if(rates[3].low>=rates[2].low && rates[2].low<=rates[1].low)
 {
  sl_val=rates[2].low;
  return rates[2].low>jaw?SLMODE_LOCALEXT_MIN_ABOVEGATOR:SLMODE_LOCALEXT_MIN_UNDERGATOR;
 }
 
 if(rates[3].high<=rates[2].high && rates[2].high>=rates[1].high)
 {
  sl_val=rates[2].high;
  return rates[2].high>jaw?SLMODE_LOCALEXT_MAX_ABOVEGATOR:SLMODE_LOCALEXT_MAX_UNDERGATOR;
 }
 
 return SLMODE_NONE;
}

//--------------------------------------------------------------------
static bool ax_bar_utils::inIchimokuCloud(double v)
{
 double senkou_a=iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,1);
 double senkou_b=iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,1);
 
 double max_span=MathMax(senkou_a,senkou_b);
 double min_span=MathMin(senkou_a,senkou_b);
 
 return min_span<=v && v<=max_span;
}

//--------------------------------------------------------------------
static double ax_bar_utils::getPercentValueFromBarToExtrem(double bar_val,double extrem_val,double percent)
{
 double percent_diff=MathAbs(extrem_val-bar_val)*percent;
 
 return bar_val>extrem_val?bar_val-percent_diff:bar_val+percent_diff;
}

//--------------------------------------------------------------------
static double ax_bar_utils::get_sl_by_SAR(MqlRates& rates[],int op_type)
{
 double sar1=NormalizeDouble(iSAR(NULL,0,0.02,0.2,1),Digits);
 double sar2=NormalizeDouble(iSAR(NULL,0,0.02,0.2,2),Digits);
 
 if(op_type==OP_BUY)//sar1<sar2
  return (sar1<rates[1].low && sar2>rates[2].high)?rates[1].low:0;
  
 if(op_type==OP_SELL)
  return (sar1>rates[1].high && sar2<rates[2].low)?rates[1].high:0;
  
 return 0;
}

//--------------------------------------------------------------------
static double ax_bar_utils::get_sl_by_SAR2(MqlRates& rates[],int op_type)
{
 double sar1=NormalizeDouble(iSAR(NULL,0,0.02,0.2,1),Digits);
 double sar2=NormalizeDouble(iSAR(NULL,0,0.02,0.2,2),Digits);
 
 if(op_type==OP_BUY)
  return (sar1>rates[1].high && sar2<rates[2].low)?rates[1].low:0;
  
 if(op_type==OP_SELL)
  return (sar1<rates[1].low && sar2>rates[2].high)?rates[1].high:0;
  
 return 0;
}

//--------------------------------------------------------------------
static bool ax_bar_utils::__period()
{
 switch(Period())
 {
 case PERIOD_M1:  return false;
 case PERIOD_M5:  return false;
 case PERIOD_M15: return false;
 case PERIOD_M30: return true;
 case PERIOD_H1:  return true;
 case PERIOD_H4:  return true;
 case PERIOD_D1:  return true;
 case PERIOD_W1:  return true;
 case PERIOD_MN1: return true;
 }
 
 return false;
}

//--------------------------------------------------------------------
static bool ax_bar_utils::volatile()
{
 bool asia    =Hour()>=4 && Hour()<12;
 bool europe  =Hour()>=10 && Hour()<19; 
 bool america =Hour()>=17 && Hour()<2;
 
 return true;
}

//--------------------------------------------------------------------
static double ax_bar_utils::get_max_lot()
{
 //MarketInfo(Symbol(),MODE_MAXLOT)const int standard_lot=100000;
 
 return 0.02;
}

//--------------------------------------------------------------------
static void ax_bar_utils::get_dummy_bar_reverse(MqlRates& direct_bar,double direct_lot,trade_mode tm,double profit_coef,MqlRates& reverse_bar,double& reverse_lot)
//static void ax_bar_utils::get_dummy_bar_reverse(MqlRates& direct_bar,double direct_lot,trade_mode tm,double profit_coef,double& price,double& sl,double& tp,double& reverse_lot)
{
 reverse_lot=ax_bar_utils::get_max_lot();
 
// double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
 
 double coef=reverse_lot/direct_lot;
 
 //open и close нас не интересует
 reverse_bar.open  =0;
 reverse_bar.close =0;
 
 //price   =0;
 //sl      =0;
 //tp      =0;
 
 if(tm==TRADEMODE_SELL)//обратный для прямого BUY
 {
  //double diff=(direct_bar.high-direct_bar.low)/coef;
  
  //tp     =direct_bar.low-g_delta_points*Point;
  //price  =MathMin(NormalizeDouble(Bid-minstoplevel*Point,Digits),NormalizeDouble(tp+MathMax(diff,minstoplevel*Point),Digits));
  //sl     =NormalizeDouble(price+MathMax(diff/profit_coef,minstoplevel*Point),Digits);
  
  reverse_bar.low  =direct_bar.low;
  reverse_bar.high =NormalizeDouble(direct_bar.low+(direct_bar.high-direct_bar.low)/coef/profit_coef,Digits);
 }
 
 if(tm==TRADEMODE_BUY)//обратный для SELL
 {
 }
}

//--------------------------------------------------------------------
static macd_trade_mode ax_bar_utils::get_tm_by_macd(int timeframe,int shift)
{
 int fast_ema_period =5; // период быстрой средней 
 int slow_ema_period =34;// период медленной средней 
 int signal_period   =5; // период сигнальной линии 
 double main_val   =iMACD(NULL,timeframe,fast_ema_period,slow_ema_period,signal_period,PRICE_CLOSE,MODE_MAIN,shift);
 double signal_val =iMACD(NULL,timeframe,fast_ema_period,slow_ema_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,shift);
 
 if(main_val<0 && main_val>signal_val)
  return MACDTRADEMODE_BUY;
  
 if(main_val>0 && main_val<signal_val)
  return MACDTRADEMODE_SELL;
  
 return MACDTRADEMODE_NONE;
}

//--------------------------------------------------------------------
static bar_types ax_bar_utils::get_bar_type_by_AC(MqlRates& rates[],MqlRates& out_bar,double& local_extremum)
{
 local_extremum=0;
 
 out_bar.open  =rates[3].open;
 out_bar.close =rates[1].close;
 
 double v1=iAC(NULL,0,1);//-1
 double v2=iAC(NULL,0,2);//-2
 double v3=iAC(NULL,0,3);//-3
 double v4=iAC(NULL,0,4);//-4
 
 //BUY - определяем переход красное->зеленое (ниже нуля) - пик на графике AC
 if((v1<0&&v1>v2&&v2<v3&&v3<v4) || (v1<0&&v1>v2&&v2>v3&&v3<v4) || (v1<0&&v1>v2&&v2>v3&&v3>v4))//-rrg rgg ggg
 {
  out_bar.high  =rates[1].high;
  out_bar.low   =ax_bar_utils::get_min(rates[1].low,rates[2].low,rates[3].low);
  
  if(ax_bar_utils::get_type2(out_bar)==BARTYPE_BULLISH)
  {
   if(ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_FULL,1) && !ax_bar_utils::is_in_gator(rates[1],1))
   {
    local_extremum=ax_bar_utils::get_local_extremum(rates,TRADEMODE_BUY);
    return BARTYPE_BULLISH;
   }
   
   if((ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_MEDIUM,1) ||
       ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_PART,1)) && !ax_bar_utils::is_in_gator(rates[1],1))
   {
    local_extremum=out_bar.low;
    return BARTYPE_BULLISH;
   }
  }
   
  return BARTYPE_NONE;
 }
 
 if(v1>0&&v2>0&&v1>v2&&v2>v3)//+gg
 {
  out_bar.high  =rates[1].high;
  out_bar.low   =ax_bar_utils::get_local_extremum(rates,TRADEMODE_BUY);
  
  if(ax_bar_utils::get_type2(out_bar)==BARTYPE_BULLISH)
  {
   if(ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_UNDERGATOR,BARPOSITIONMODE_PART,1) && !ax_bar_utils::is_in_gator(rates[1],1))
   {
    local_extremum=out_bar.low;
    return BARTYPE_BULLISH;
   }
  }
   
  return BARTYPE_NONE;
 }
 
 //SELL  - определяем переход зеленое->красное (выше нуля) - пик на графике AC
 if((v1>0&&v1<v2&&v2>v3&&v3>v4) || (v1>0&&v1<v2&&v2<v3&&v3>v4) || (v1>0&&v1<v2&&v2<v3&&v3<v4))//+ggr grr rrr
 {
  out_bar.high  =ax_bar_utils::get_max(rates[1].high,rates[2].high,rates[3].high);
  out_bar.low   =rates[1].low;
  
  if(ax_bar_utils::get_type2(out_bar)==BARTYPE_BEARISH)
  {
   if(ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_FULL,1))
   {
    local_extremum=ax_bar_utils::get_local_extremum(rates,TRADEMODE_SELL);
    return BARTYPE_BEARISH;
   }
   
   if(ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_MEDIUM,1) ||
      ax_bar_utils::get_bar_gator_position(out_bar,BARPOSITION_ABOVEGATOR,BARPOSITIONMODE_PART,1))
   {
    local_extremum=out_bar.high;
    return BARTYPE_BEARISH;
   }
  }
   
  return BARTYPE_NONE;
 }
 
 /*
 if(v1<0&&v2<0&&v3<0&&v1<v2&&v2<v3&&v3<v4)//-rrr
 {
  out_bar.high  =ax_bar_utils::get_max(rates[1].high,rates[2].high,rates[3].high);
  out_bar.low   =rates[1].low;
  
  if(ax_bar_utils::get_type2(out_bar)==BARTYPE_BEARISH)
  {
   local_extremum=out_bar.high;
   return BARTYPE_BEARISH;
  }
   
  return BARTYPE_NONE;
 }
 */
  
 return BARTYPE_NONE;
}

//--------------------------------------------------------------------
static void ax_bar_utils::trade(MqlRates& rates[],trade_mode tm,ax_order_settings& direct,string& err_msg)
{
 err_msg="";
 
 string msg="";
 
 MqlRates dummy_bar;
 
 double local_extremum;
  
 bar_types bt=ax_bar_utils::get_bar_type_by_AC(rates,dummy_bar,local_extremum);
 
 if(ax_bar_utils::inIchimokuCloud(dummy_bar.high) || ax_bar_utils::inIchimokuCloud(dummy_bar.low))
  return;
 
 if(tm==TRADEMODE_BUY && bt==BARTYPE_BULLISH)
 {
  dummy_bar.low=local_extremum;
   
  int ticket=ax_bar_utils::OpenOrder3(dummy_bar,tm,direct.lot,direct.slippage,direct.comment,direct.expire_bar_count,direct.profit_coef,msg);

  if(ticket>0)
   axAddOrder(ticket,local_extremum,direct.fibo,1,dummy_bar.high);
  else
   err_msg="[BUYSTOP "+direct.comment+"]:"+msg;
 }//TRADEMODE_BUY
 else
 if(tm==TRADEMODE_SELL && bt==BARTYPE_BEARISH)
 {
  dummy_bar.high=local_extremum;
   
  int ticket=ax_bar_utils::OpenOrder3(dummy_bar,tm,direct.lot,direct.slippage,direct.comment,direct.expire_bar_count,direct.profit_coef,msg);

  if(ticket>0)
   axAddOrder(ticket,local_extremum,direct.fibo,1,dummy_bar.low);
  else
   err_msg="[SELLSTOP "+direct.comment+"]:"+msg;
 }//TRADEMODE_SELL
}

//--------------------------------------------------------------------
