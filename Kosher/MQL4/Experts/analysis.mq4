//+------------------------------------------------------------------+
//|                                                                  |
//|                                                Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Alexander Fedosov"
#property link      "https://www.mql5.com/ru/users/alex2356"
#property version   "1.00"
#property strict

#include "trading.mqh"

input int            tm = 1;                       //Test mode 1,2 or 3
input int            SL = 40;                      //Stop-loss
input int            TP = 70;                      //Take-profit
input bool           lot_const = false;            //Lot of balance?
input double         lt=0.01;                      //Lot if Lot of balance=false 
input double         Risk=2;                       //The risk in the lot of the balance, %
input int            Slippage= 5;                  //Slippage
input int            magic = 2356;                 //Magic number
input ENUM_TIMEFRAMES tf1 = PERIOD_H1;             //Timeframe for the calculation module1
input ENUM_TIMEFRAMES tf2 = PERIOD_M5;             //Timeframe for the calculation module2
input double         Step = 0.02;                  //Step PSAR
input double         Mxm = 0.2;                    //Maximum PSAR

CTrading tr(magic,Slippage,lt,lot_const,Risk,5);
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(tm<1 || tm>3)
      return;
//--- Условия для входа в рынок для модуля на Parabolic SAR
   if(tm==1 && !tr.isOpened(magic))
     {
      double psar[],prc[];
      ArrayResize(psar,3);
      ArrayResize(prc,3);
      for(int i=0; i<3; i++)
        {
         psar[i]=iSAR(_Symbol,tf1,Step,Mxm,i);
         prc[i]=iClose(_Symbol,tf1,i);
        }

      if(psar[2]>prc[2] && psar[1]<prc[1] && psar[0]<prc[0])
         tr.OpnOrd(OP_BUY,lt,TP,SL);
      if(psar[2]<prc[2] && psar[1]>prc[1] && psar[0]>prc[0])
         tr.OpnOrd(OP_SELL,lt,TP,SL);
     }
//--- Условия для входа в рынок для модуля на AC
   if(tm==2 && !tr.isOpened(magic))
     {
      double ac[];
      ArrayResize(ac,3);
      for(int i=0; i<3; i++)
         ac[i]=iAC(Symbol(),tf2,i);

      if(ac[2]>0 && ac[1]>0 && ac[1]>ac[2])
         tr.OpnOrd(OP_BUY,lt,TP,SL);
      if(ac[2]<0 && ac[1]<0 && ac[1]<ac[2])
         tr.OpnOrd(OP_SELL,lt,TP,SL);
     }
//--- Условия для входа в рынок при совместной работе двух модулей
   if(tm==3 && !tr.isOpened(magic))
     {
      double psar[],prc[],ac[];
      ArrayResize(psar,3);
      ArrayResize(prc,3);
      ArrayResize(ac,3);
      for(int i=0; i<3; i++)
        {
         psar[i]=iSAR(_Symbol,tf1,Step,Mxm,i);
         prc[i]=iClose(_Symbol,tf1,i);
         ac[i]=iAC(Symbol(),tf2,i);
        }
      if((psar[2]>prc[2] && psar[1]<prc[1] && psar[0]<prc[0]) || (ac[2]>0 && ac[1]>0 && ac[1]>ac[2]))
         tr.OpnOrd(OP_BUY,lt,TP,SL);
      if((psar[2]<prc[2] && psar[1]>prc[1] && psar[0]>prc[0]) || (ac[2]<0 && ac[1]<0 && ac[1]<ac[2]))
         tr.OpnOrd(OP_SELL,lt,TP,SL);
     }
  }
//+------------------------------------------------------------------+
