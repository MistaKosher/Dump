//+------------------------------------------------------------------+
//|                                                    Alligator.mq4 |
//|                                           Copyright © 2011, AM2. |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2011, AM2."
 
#define MagicNumber  20110204

extern double StopLoss   = 350;
extern double TakeProfit = 2000;
extern int    ZeroLevel  = 400;
extern int TrailingLevel = 850;
extern int TrailingStep  = 400;

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int pos=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()==OP_BUY || OrderType()==OP_SELL)  pos++;
        }
     }
//---- return orders volume
   if(pos>0) return(pos);
    }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
//---- go trading only for first tiks of new bar
   if(Volume[0]>1) return;  
//----   
   int    res;  
//---- get Indicatorrs 
   double JAW = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, 1);
   double TEETH = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 1);
   double LIPS = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 1);
//---- buy 
   if(LIPS>TEETH && TEETH>JAW)  
     {
      res=OrderSend(Symbol(),OP_BUY,Lots(),Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point,"",MagicNumber,0,Blue);
      return;
     }        
//---- sell   
   if(LIPS<TEETH && TEETH<JAW) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots(),Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"",MagicNumber,0,Red);
      return;
     }   
  }  
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double Lots()
  {
   double Lots;
   Lots=AccountFreeMargin()/10000*2;
   Lots=MathMin(15,MathMax(0.1,Lots));
   if(Lots<0.1) 
     Lots=NormalizeDouble(Lots,2);
   else
     {
     if(Lots<1) Lots=NormalizeDouble(Lots,1);
     else       Lots=NormalizeDouble(Lots,0);
     }
     return(Lots);
  }
  
//+------------------------------------------------------------------+
//|                Ttailingstop                                      |
//+------------------------------------------------------------------+
int Tral()
{     
    if (OrderType() == OP_BUY) { // 1
        if ((OrderStopLoss() < ND(Bid - TrailingLevel * Point - TrailingStep * Point)) || (OrderStopLoss() == 0)) { // 2
          OrderModify(OrderTicket(),OrderOpenPrice(),ND(Bid - TrailingLevel * Point),OrderTakeProfit(),0,Green);
        } // 2
    } // 1 BUY
    if (OrderType() == OP_SELL) { // 1
        if ((OrderStopLoss() > ND(Ask + TrailingLevel * Point + TrailingStep * Point)) || (OrderStopLoss() == 0)) { // 2
          OrderModify(OrderTicket(),OrderOpenPrice(),ND(Ask + TrailingLevel * Point),OrderTakeProfit(),0,Red);
        } // 2
    } // 1
}
//+------------------------------------------------------------------+
//|                       Zero                                       |
//+------------------------------------------------------------------+
int Zero()
{
    if (OrderType() == OP_BUY) { // 1
      if (OrderOpenPrice() <= ND(Bid - ZeroLevel * Point) && OrderOpenPrice() > OrderStopLoss()) { // 2
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green);
      } // 2
    } // 1 BUY
    if (OrderType() == OP_SELL) { // 1
      if (OrderOpenPrice() >= ND(Ask + ZeroLevel * Point) && OrderOpenPrice() < OrderStopLoss()) { // 2
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Red);
      } // 2
    } // 1 SELL
}
//+------------------------------------------------------------------+
//|                   NormalizeDouble                                |
//+------------------------------------------------------------------+
double ND(double d, int n=-1) 
{  
    if (n<0) 
      return(NormalizeDouble(d, Digits)); 
    return(NormalizeDouble(d, n)); 
} 

//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
void start()
  {
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
//---- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
//----
    for (int i=0; i<OrdersTotal(); i++) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        if (MagicNumber != 0 && OrderMagicNumber() != MagicNumber) 
          continue;
        if (OrderSymbol()==Symbol()) {
          RefreshRates();
          Zero();
          Tral();
        }
    }
//----
   return(0);   
  }
//+------------------------------------------------------------------+   