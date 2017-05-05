//+------------------------------------------------------------------+
//|                                                     momentum.mq4 |
//|                                      Copyright © 2011, Serg Deev |
//|                                            http://www.work2it.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Serg Deev"
#property link      "http://www.work2it.ru"

#define MAGICMA  20050610

extern double Lots               = 0.05;
extern int TrailingStop          = 110;

extern int fast_ema_period       = 26;
extern int fast_ema_shift        = 8;
extern int fast_ema_method       = 2; // 0-MODE_SMA; 1-MODE_EMA; 2-MODE_SMMA; 3-MODE_LWMA;
extern int fast_ema_price        = 3; // 0-PRICE_CLOSE, 1-PRICE_OPEN, 2-PRICE_HIGH, 3-PRICE_LOW, 4-PRICE_MEDIAN, 5-PRICE_TYPICAL, 6-PRICE_WEIGHTED

extern double MO_Min             = 100.0;
extern double MO_Shift           = -0.2;
extern int MO_Period             = 23;
extern int MO_Price              = 1; // 0-PRICE_CLOSE, 1-PRICE_OPEN, 2-PRICE_HIGH, 3-PRICE_LOW, 4-PRICE_MEDIAN, 5-PRICE_TYPICAL, 6-PRICE_WEIGHTED

extern int MO_OpenTime           = 6;
extern int MO_CloseTime          = 10;

int GAP_Level                    = 30;
int GAP_TimeOUT                  = 100;
int GAP_Timer                    = 0;

//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
   if(buys>0) return(buys);
   else       return(-sells);
}

//+------------------------------------------------------------------+
bool CheckMO_Up(int t) {
 double y;
 double x = iMomentum(NULL,0,MO_Period,MO_Price,t);
 for (int i=t-1; i>=0; i--) {
  y = iMomentum(NULL,0,MO_Period,MO_Price,i);
  if (y < x) return(false);
  else x = y; 
 }
 return(true);
}

//+------------------------------------------------------------------+
bool CheckMO_Down(int t) {
 double y;
 double x = iMomentum(NULL,0,MO_Period,MO_Price,t);
 for (int i=t-1; i>=0; i--) {
  y = iMomentum(NULL,0,MO_Period,MO_Price,i);
  if (y > x) return(false);
  else x = y; 
 }
 return(true);
}

//+------------------------------------------------------------------+
void CheckForOpen() {
   int res;

   if(Volume[0]>1) return;

   int gap = (Open[0]-Close[1])/Point; 
   if (gap > GAP_Level) GAP_Timer = GAP_TimeOUT;
   if (GAP_Timer > 0) {
    GAP_Timer--;
    if (GAP_Timer > 0) return;
   }

   double ma=iMA(NULL,0,fast_ema_period,fast_ema_shift,fast_ema_method,fast_ema_price,0);
   double mo = iMomentum(NULL,0,MO_Period,MO_Price,0);

    if (mo < (MO_Min+MO_Shift)) {
     if ((Close[1] < ma) && (Open[0] < ma)) {
      if (CheckMO_Down(MO_OpenTime)) {
       res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Red);
       return;
      }
     }
    }
    if (mo > (MO_Min-MO_Shift)) {
     if ((Close[1] > ma) && (Open[0] > ma)) {
      if (CheckMO_Up(MO_OpenTime)) {
       res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Blue);
       return;
      }
     }
    }
}

//+------------------------------------------------------------------+
void CheckForClose() {
  int res;
  double SL;

  if(Volume[0]>1) return;

  double ma=iMA(NULL,0,fast_ema_period,fast_ema_shift,fast_ema_method,fast_ema_price,0);
  
  for(int i=0;i<OrdersTotal();i++) {
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
     if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
     //---- check order type 
     if(OrderType()==OP_BUY) {
        if ((CheckMO_Down(MO_CloseTime)) || (Close[1] < ma)) { // условие закрытия
         OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
        }
        else if (TrailingStop > 0) { // TrallingStop
         if (OrderStopLoss() == 0.0) OrderModify(OrderTicket(),OrderOpenPrice(),Low[0]-Point*TrailingStop,OrderTakeProfit(),0,Blue);
         else {
          SL = Low[0]-Point*TrailingStop;
          if (OrderStopLoss() < SL) OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Blue);
         }
         break;
        }
     }
     if(OrderType()==OP_SELL) {
        if ((CheckMO_Up(MO_CloseTime) || (Close[1] > ma))) { // условие закрытия
         OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
         break;
        }
        else if (TrailingStop > 0) { // TrallingStop
         if (OrderStopLoss() == 0.0) OrderModify(OrderTicket(),OrderOpenPrice(),High[0]+Point*TrailingStop,OrderTakeProfit(),0,Blue);
         else {
          SL = High[0]+Point*TrailingStop;
          if (OrderStopLoss() > SL) OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Blue);
         }
         break;
        }
     }
  }
}

//+------------------------------------------------------------------+
int init() {
   return(0);
}

//+------------------------------------------------------------------+
int deinit() {
   return(0);
}

//+------------------------------------------------------------------+
int start() {
   if(Bars<100 || IsTradeAllowed()==false) return;
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else CheckForClose();
}

