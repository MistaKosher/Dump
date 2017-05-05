#property copyright ""
#include <stderror.mqh>
#include <stdlib.mqh>

extern int     StopLoss       =  6;  //начальный стоплосс
 
extern int     TrSt           =  6; //Трал
extern int     Speed          =  5;
extern double  timeSpeed      =  3; 
extern double  Lots           =  0.01; // лот                                     
extern bool    autoLots       = false;

double         Point_;
datetime       nextTime;
int            cnt, total, lastBars;
int            up, down, TimeSpeedUp, TimeSpeedDown, Magic;
bool           TimBoolUp,TimBoolDown, OrderSal;
double         priceUp, priceDown;


int              PipMultiplier=0;



int Get.Magic()
 {
   string mag;
   int Magic.g;
   Sleep(1000);
   while (true)
   {
      MathSrand (TimeLocal());
      mag = StringConcatenate(mag, MathRand()/15, MathRand()/8, MathRand()/32); 
      Magic.g = MathRound(MathAbs(StrToInteger(mag)));
      mag = DoubleToStr(Magic.g,10);
      if (StringLen (mag) >= 15) {Magic.g = StrToInteger(mag); break;}
   }
   return (MathRound(MathAbs(Magic.g)));
 }

void LotsSize()
{
   if(AccountBalance() < 200)
   {
      Lots = 0.02;
   }
   if(AccountBalance() > 200)
   {
      Lots = 0.04;
   }
   if(AccountBalance() > 300)
   {
      Lots = 0.05;
   }
   if(AccountBalance() > 400)
   {
      Lots = 0.06;
   }
   if(AccountBalance() > 500)
   {
      Lots = 0.07;
   }
   if(AccountBalance() > 600)
   {
      Lots = 0.08;
   }
   if(AccountBalance() > 700)
   {
      Lots = 0.09;
   }
   if(AccountBalance() > 800)
   {
      Lots = 0.1;
   }
   if(AccountBalance() > 900)
   {
      Lots = 0.2;
   }
   if(AccountBalance() > 1000)
   {
      Lots = 0.3;
   }
   if(AccountBalance() > 2000)
   {
      Lots = 0.4;
   }
   if(AccountBalance() > 3000)
   {
      Lots = 0.5;
   }
   if(AccountBalance() > 4000)
   {
      Lots = 0.6;
   }
   if(AccountBalance() > 5000)
   {
      Lots = 0.7;
   }
   if(AccountBalance() > 6000)
   {
      Lots = 0.8;
   }
   if(AccountBalance() > 7000)
   {
      Lots = 0.9;
   }
   if(AccountBalance() > 8000)
   {
      Lots = 1;
   }
   if(AccountBalance() > 9000)
   {
      Lots = 2;
   }
   if(AccountBalance() > 10000)
   {
      Lots = 3;
   }
   if(AccountBalance() > 11000)
   {
      Lots = 4;
   }
   if(AccountBalance() > 12000)
   {
      Lots = 5;
   }
   if(AccountBalance() > 13000)
   {
      Lots = 6;
   }
   if(AccountBalance() > 14000)
   {
      Lots = 7;
   }
   if(AccountBalance() > 15000)
   {
      Lots = 8;
   }
   if(AccountBalance() > 20000)
   {
      Lots = 9;
   }
   if(AccountBalance() > 30000)
   {
      Lots = 10;
   }
   if(AccountBalance() > 40000)
   {
      Lots = 11;
   }
   if(AccountBalance() > 50000)
   {
      Lots = 12;
   }
   if(AccountBalance() > 60000)
   {
      Lots = 13;
   }
   if(AccountBalance() > 70000)
   {
      Lots = 14;
   }
   if(AccountBalance() > 80000)
   {
      Lots = 15;
   }
   if(AccountBalance() > 90000)
   {
      Lots = 16;
   }
   if(AccountBalance() > 100000)
   {
      Lots = 17;
   }
   if(AccountBalance() > 110000)
   {
      Lots = 18;
   }
   if(AccountBalance() > 120000)
   {
      Lots = 19;
   }
   if(AccountBalance() > 130000)
   {
      Lots = 20;
   }
  
   
   
}

void openOrders()
{  
   int try;
   if(autoLots == true)
   {
      LotsSize();                        
   }   
   
   if(up < down)
   {
      Print("Параметр вниз - удовлетворяет условию");
      if(TimeCurrent() - TimeSpeedDown <= timeSpeed)
      {           
         Print("Параметр ВРЕМЯ - удовлетворяет условию"); 
         RefreshRates(); 
         for(try = 1; try <= 2; try++)
         {          
            if (OrderSend(Symbol(),OP_SELL,Lots,Bid,10,0,0 ,"",Magic,0,Red) < 0)
            {  Print("Ошибка ", ErrorDescription(GetLastError()));
               Print("Невозможно открыть ордер, попытка ", try);
               Sleep(1000);
               RefreshRates();
            }
            else
            {
               OrderSal = true;
               break;
            }   
         }
      }   
   }
    else 
   {  
      Print("Параметр вверх - удовлетворяет условию");
      if(TimeCurrent() - TimeSpeedUp <= timeSpeed)
      {           
         Print("Параметр ВРЕМЯ - удовлетворяет условию"); 
         RefreshRates();    
         for(try = 1; try <= 2; try++)
         {                    
            if (OrderSend(Symbol(),OP_BUY,Lots,Ask,10,0,0, "", Magic, 0, Green) < 0)
            {  Print("Ошибка ", ErrorDescription(GetLastError()));
               Print("Невозможно открыть ордер, попытка ", try);
               Sleep(1000);
               RefreshRates();
            } 
            else
            {
               OrderSal = true;
               break; 
            }   
        }
                
      }   
   }    
   priceUp   = 0;
   priceDown = 0;
   up        = 0;
   down      = 0;
   TimBoolUp = false;
   TimBoolDown = false;
   TimeSpeedUp = 0;
   TimeSpeedDown = 0;       
}

int init()
{
   Magic = Get.Magic();
 if (Digits==3 || Digits==5)
         PipMultiplier=10;
   else  PipMultiplier=1;
   return(0);
}

int deinit()
{
   return(0);
}



int start()
{   
   total = OrdersTotal();
   int   i, currentSymbolOrderPos = -1;
      
   for (i = 0; i < total; i++)   
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol())
      {
         currentSymbolOrderPos = i;
         break;
      }
   }
   
   if (currentSymbolOrderPos < 0)
   {      
      if(priceUp < Ask)
      {
         up = up + 1;
         priceUp = Ask;
         if(TimBoolUp == false)
         {
            TimeSpeedUp = TimeCurrent();
            TimBoolUp = true;
         }   
      }
   else
      {
        priceUp = 0;
       
        up      = 0;
        TimBoolUp = false;
        TimeSpeedUp = 0;
      }
   
      if(priceDown > Ask)
      {
         down = down + 1;
         priceDown = Ask;
         if(TimBoolDown == false)
         {
            TimeSpeedDown = TimeCurrent();
            TimBoolDown = true;
         }   
      }
      else
      {
         priceDown = 0;
         down      = 0;
         TimBoolDown = false;
         TimeSpeedDown = 0;   
      }
 
      if(up == Speed || down == Speed)
      {          
            openOrders();                  
      }   
   
         
      if(priceUp == 0)
      {
         priceUp   = Ask;         
      }
      if(priceDown == 0)
      {        
         priceDown = Ask;
      }
   }   
else // Есть открытый ордер по текущему символу
   {
      OrderSelect(currentSymbolOrderPos, SELECT_BY_POS, MODE_TRADES);
          
      if (OrderType() == OP_BUY)
      {
         if(OrderSal == true)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid - StopLoss*Point*PipMultiplier,Digits),'', 0, Red);
            OrderSal = false;
         }
         if (Bid-OrderOpenPrice()>TrSt*Point*PipMultiplier)
         {
            if (OrderStopLoss()<Bid-(TrSt)*Point*PipMultiplier)
            {
              OrderModify(OrderTicket(),OrderOpenPrice(),Bid - (TrSt)*Point*PipMultiplier,'', 0, Red);
            }
         }        
      }
      if (OrderType() == OP_SELL)
      {   
         if(OrderSal == true)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask + StopLoss*Point*PipMultiplier, Digits),'', 0, Red);
            OrderSal = false;
         }    
         if (OrderOpenPrice()-Ask > TrSt*Point*PipMultiplier)
         {
           if (OrderStopLoss() > Ask +(TrSt)*Point*PipMultiplier) 
           {
              OrderModify(OrderTicket(),OrderOpenPrice(),Ask + (TrSt)*Point*PipMultiplier,'', 0, Red);
           }
         }            
      }
   }   
   return(0);
}