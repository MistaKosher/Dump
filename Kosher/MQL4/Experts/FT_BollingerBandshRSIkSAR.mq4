//+------------------------------------------------------------------+
//|                                    FT_BollingerBands+RSI+SAR.mq4 |
//|                            FORTRADER.RU, Юрий, ftyuriy@gmail.com |
//|   http://FORTRADER.RU, торговля по болленджеру, параболику и RSI |
//+------------------------------------------------------------------+
/*Разработано для 51 выпуска журнала FORTRADER.Ru. 
Отчеты: http://finfile.ru/index.php/files/get/ZpUthihnKs/test2100809.rar
Сет файлы: http://finfile.ru/index.php/files/get/0BF1iPGVQJ/eurusd4h.set
Обсуждение: http://fxnow.ru/group_discussion_view.php?group_id=49&grouptopic_id=409&grouppost_id=3439#post_3439
Архив журнала: http://www.fortrader.ru/arhiv.php
51 выпуск: http://www.fortrader.ru/
*/

#property copyright "FORTRADER.RU, Юрий, ftyuriy@gmail.com"
#property link      "http://FORTRADER.RU, торговля по болленджеру, параболику и RSI"

double upfractal;
double dwfractal;

int bars;
int start()
  {
  if(Bars!=bars)
  {bars=Bars;
  Pattern();
  SarTrailingStop();
  }
   return(0);
  }

extern int rsiperiod=8;
extern int bbperiod=14;
extern int bbotcl=1;
extern int SL=50;
extern int TP=135;
int err;

extern int MG=564651;
extern double Lots=0.1;

extern int mn=10;
extern int otstup=105;
extern int rsiup=30;
extern int rsidw=70;

int okbuy,oksell;
 int Pattern()
 {
   double op,sl,tp;
   double rsi[101]; 
   double irsi;  
   double fractal;
   ArraySetAsSeries(rsi,true);
   for(int i=100; i>=0; i--)  
   {
   rsi[i]=iRSI(NULL,0,rsiperiod,PRICE_CLOSE,i);
   if(i==1){irsi=rsi[i];}
   }
   
   double bbup=iBandsOnArray(rsi,0,bbperiod,bbotcl,0,MODE_UPPER,1);
   double bblow=iBandsOnArray(rsi,0,bbperiod,bbotcl,0,MODE_LOWER,1); 
   
   fractal=iFractals(NULL, 0, MODE_UPPER, 3);
   if(fractal!=0)  upfractal=iFractals(NULL, 0, MODE_UPPER, 3); 
   fractal=iFractals(NULL, 0, MODE_LOWER, 3);
   if(fractal!=0)  dwfractal=iFractals(NULL, 0, MODE_LOWER, 3); 
   
   if(irsi>bbup && Close[1]<upfractal && okbuy==0) {
   op=upfractal+otstup*Point*mn;if(SL>0){sl=op-SL*Point*mn;}if(TP>0){tp=op+TP*Point*mn;}
   err=OrderSend(Symbol(),OP_BUYSTOP,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"FT_BollingerBands",MG,0,Red);
   if(err<0){Print("OrderSend()-  Ошибка OP_BUYSTOP.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());return(-1);}
   okbuy=1;
   }
   
   if(irsi<rsiup){
   _DeleteOrder(1);
   okbuy=0;
   }
   
   /*Продажи*/
   
   if(irsi<bblow && Close[1]>dwfractal && oksell==0 ) {
   op=dwfractal-otstup*Point*mn;if(SL>0){sl=op+SL*Point*mn;}if(TP>0){tp=op-TP*Point*mn;}
   err=OrderSend(Symbol(),OP_SELLSTOP,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"FT_BollingerBands",MG,0,Red);
   if(err<0){Print("OrderSend()-  Ошибка OP_SELL.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());return(-1);}
   oksell=1;
   }
   
   if(irsi>rsidw){
   _DeleteOrder(0);
   oksell=0;
   }
   
 //  Print("bbup "+bbup+" dwfractal "+dwfractal+" upfractal "+upfractal);
  
 
 return(0);
 }

//удаляет отложенные стоп ордера
int _DeleteOrder(int type)
{
   for( int i=1; i<=OrdersTotal(); i++)          
   {
    if(OrderSelect(i-1,SELECT_BY_POS)==true) 
    {                                       
     if(OrderType()==OP_SELLSTOP && OrderSymbol()==Symbol() && type==0 && OrderMagicNumber()==MG)
     {
      OrderDelete(OrderTicket()); 
     }//if
  
    if(OrderType()==OP_BUYSTOP && OrderSymbol()==Symbol() && type==1 && OrderMagicNumber()==MG)
     {
      OrderDelete(OrderTicket()); 
     }//if
    }//if
   }
   return(0);
}

//Трейдинг стоп по параболику
extern double SARstep=0.003;
extern double SARmax=0.2;
extern int SarTrailingStop=1;
extern int TrailingStep=5;

int  SarTrailingStop()
{int i;bool err;

double sar=iSAR(NULL,0,SARstep,SARmax,1);

   for( i=1; i<=OrdersTotal(); i++)        
   {
      if(OrderSelect(i-1,SELECT_BY_POS)==true)
       {  
        if(SarTrailingStop>0 && OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MG)  
        {                
         if(sar>OrderStopLoss())
          {
           if((sar-OrderStopLoss())>=TrailingStep*Point*mn && (Ask-sar)>MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)
           {
            Print("ТРЕЙЛИМ");
            err=OrderModify(OrderTicket(),OrderOpenPrice(),sar,OrderTakeProfit(),0,Green);
            if(err==false){return(-1);}
           }//if(Bid>=OrderStopLoss()
          }//if(Bid-OrderOpenPrice()
         }//if(BBUSize>0
        }//if(OrderSelect(i
           
       if(OrderSelect(i-1,SELECT_BY_POS)==true)
       {
        if(SarTrailingStop>0 && OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MG)  
        {        
         if(OrderStopLoss()>sar)
          {
           if((OrderStopLoss()-sar)>TrailingStep*Point*mn && (sar-Ask)>MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)
           {
            Print("ТРЕЙЛИМ");
            err=OrderModify(OrderTicket(),OrderOpenPrice(),sar,OrderTakeProfit(),0,Green);
            if(err==false){return(-1);}
           }//if(Ask<=OrderStopLoss()
          }//if(OrderOpenPrice()
         }//if(BBUSize>0 
       }// if(OrderSelect
    }// for( i=1;
return(0);
}

