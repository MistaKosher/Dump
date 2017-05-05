//+------------------------------------------------------------------+
//|                                                          eee.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  extern double Lot = 0.1;

#define Ave 2 // "период" усреднения тиков 

double vClose[Ave], v, vPrev=0; 

void start()
{
  for (int i=Ave-1; i>=1; i--) vClose[i] = vClose[i-1]; vClose[0] = (Bid+Ask)/2.0;
  v = 0; for (i=Ave-1; i>=0; i--) { v+= vClose[i]; } v /= Ave;
  if ( vPrev > v ) 
  {
    if ( OrdersTotal() > 0  )   
    {
      OrderSelect(0, SELECT_BY_POS, MODE_TRADES );
      if ( OrderType() == OP_BUY ) OrderClose(OrderTicket(),OrderLots(),Bid,30,Red);
    }
    if ( OrdersTotal() == 0  ) OrderSend(Symbol(),OP_SELL, Lot,Bid,3,0,0,"",0,0,Red);
  }
  if ( vPrev < v )  
  {
    if ( OrdersTotal() > 0  )   
    {
      OrderSelect(0, SELECT_BY_POS, MODE_TRADES );
      if ( OrderType() == OP_SELL ) OrderClose(OrderTicket(),OrderLots(),Ask,30,Red);
    }
    if ( OrdersTotal() == 0  ) OrderSend(Symbol(),OP_BUY, Lot,Ask,3,0,0,"",0,0,Red);
  }
  vPrev = v;
}
//---
   
//---
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
//---
   
  }
//+------------------------------------------------------------------+
