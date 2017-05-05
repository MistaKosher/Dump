//+------------------------------------------------------------------+
//|                                        Alligator Simple v1.1.mq4 |
//|                                               Nikolay Khrushchev |
//|                                         N.A.Khrushchev@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Nikolay Khrushchev"
#property link      "N.A.Khrushchev@gmail.com"
extern string qqqqqqqqq    = " Параметры торговли";
extern bool   Market_Exec  = false;
extern double Currency     = 1;
extern bool   EveryTick    = true;
extern int    TF           = 30;
extern double Lot          = 0.1;
extern double Prof         = 75;
extern double Loss         = 25;
extern double magic        = 2512201020;
extern string eeeeeeeee    = " Параметры трала";
extern bool   TrallEn      = true;
extern double TrallSt      = 30;
extern double TrallPp      = 10;
extern string wwwwwwwww    = " Параметры Алигатора";
extern double ChelPr       = 13;
extern double ChelSh       = 8;
extern double TeethPr      = 8;
extern double TeethSh      = 5;
extern double LipsPr       = 5;
extern double LipsSh       = 3;
extern int    MAmethod     = 2;
extern int    MAprice      = 4;
extern string sarase       = " MAprice 0,1,4,5,6";

int Ticket, TimeN;
bool TickeT, Work = true;
double TrallClosePrice,Pp;

//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
void start()
   {
   Comment("Nikolay Khrushchev","\n","N.A.Khrushchev@gmail.com");
   if (TF*60 != Time[0]-Time[1]) return;
   if (EveryTick==false)
      {
      if(TimeN == Time[0]) return;
      TimeN = Time[0];
      }
   if (Work==false)
      {
      return;
      }
   for (int i=OrdersTotal()-1; i>=0; i--)   // Переборка открытых ордеров
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) // есть следующий
         {
         if (OrderMagicNumber()==magic)  // сравнение меджика
            {
            if (TrallEn==true) Tralling(OrderTicket());
            return;
            }   
         }
      }
   double JAW = iAlligator(NULL, 0, ChelPr, ChelSh, TeethPr, TeethSh, LipsPr, LipsSh, MAmethod, MAprice, MODE_GATORJAW, 1);
   double TEETH = iAlligator(NULL, 0, ChelPr, ChelSh, TeethPr, TeethSh, LipsPr, LipsSh, MAmethod, MAprice, MODE_GATORTEETH, 1);
   double LIPS = iAlligator(NULL, 0, ChelPr, ChelSh, TeethPr, TeethSh, LipsPr, LipsSh, MAmethod, MAprice, MODE_GATORLIPS, 1);
   if(LIPS>TEETH && TEETH>JAW) OrderSendBuy();
   if(LIPS<TEETH && TEETH<JAW) OrderSendSell();
   return;
   }
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
void CloseOrders(int Nomber)
   {
   if(OrderSelect(Nomber,SELECT_BY_TICKET,MODE_TRADES)==true) // есть следующий
      {
      if(OrderType()==OP_BUY)
        {
        while(true)
           {
           Ticket=OrderClose(OrderTicket(),OrderLots(),Bid,30,Black);
           if (Ticket > 0)                        
              {
              return;                             
              }
           if (Fun_Error(GetLastError())==1)      
              {
              continue;                           
              }
           }
        }
     if (OrderType()==OP_SELL)
        {
        while(true)
           {
           Ticket=OrderClose(OrderTicket(),OrderLots(),Ask,30,Black);
           if (Ticket > 0)                        
              {
              return;                            
              }
           if (Fun_Error(GetLastError())==1)      
              {
              continue;                           
              }
           }
        }
     }
   return;
   }
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
void OrderSendBuy()
   {
   double SL=Ask-Loss*Pp;
   double TP=Ask+Prof*Pp;
   if (Market_Exec) { SL=0; TP=0; }
   while(true)
      {
      TrallClosePrice= Ask-Loss*Pp;
      Ticket=OrderSend(Symbol(),OP_BUY,Lot,Ask,3,SL,TP,NULL,magic,0,Blue);  
      if (Ticket > 0) { Print ("Открыт ордер Buy ",Ticket); break; }
      if (Fun_Error(GetLastError())==1) { continue; }
      return;                               
      }
   if (Market_Exec)
      {
      SL=Ask-Loss*Pp;
      TP=Ask+Prof*Pp;
      while(true)
         {
         if(!OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES)) break;
         TickeT=OrderModify(Ticket,OrderOpenPrice(),SL,0,0,Black);
         if (Ticket==true) { Print ("успешно установлен стоп лосс",OrderTicket()); break; }
         if (Fun_Error(GetLastError())==1) { continue; }
         break;                                
         }
      while(true)
         {
         if(!OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES)) break;
         TickeT=OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,Black);
         if (Ticket==true) { Print ("успешно установлен тейк профит",OrderTicket()); break; }
         if (Fun_Error(GetLastError())==1) { continue; }
         break;                                
         }
      }
   return;
   }
//+------------------------------------------------------------------+
void OrderSendSell()
   {
   double SL=Bid+Loss*Pp;
   double TP=Bid-Prof*Pp;
   if (Market_Exec) { SL=0; TP=0; }
   while(true)
      {
      TrallClosePrice= Bid+Loss*Pp;
      Ticket=OrderSend(Symbol(),OP_SELL,Lot,Bid,3,SL,TP,NULL,magic,0,Red);
      if (Ticket > 0) { Print ("Открыт ордер Sell ",Ticket); break; }
      if (Fun_Error(GetLastError())==1) { continue; }
      return;                                
      }
   if (Market_Exec)
      {
      SL=Bid+Loss*Pp;
      TP=Bid-Prof*Pp;
      while(true)
         {
         if(!OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES)) break;
         TickeT=OrderModify(Ticket,OrderOpenPrice(),SL,0,0,Black);
         if (Ticket==true) { Print ("успешно установлен стоп лосс",OrderTicket()); break; }
         if (Fun_Error(GetLastError())==1) { continue; }
         break;                                
         }
      while(true)
         {
         if(!OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES)) break;
         TickeT=OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,Black);
         if (Ticket==true) { Print ("успешно установлен тейк профит",OrderTicket()); break; }
         if (Fun_Error(GetLastError())==1) { continue; }
         break;                                
         }
      }   
   return;
   }
//+------------------------------------------------------------------+
void Tralling(int Nomber)
   {
   if(OrderSelect(Nomber,SELECT_BY_TICKET,MODE_TRADES)==true)
      {
      if (OrderProfit()/OrderLots()/10/Currency >= TrallSt)
         {
         if (OrderType()==OP_BUY)
            {
            if (Ask>OrderOpenPrice())
               {
               if (Ask-TrallPp*Pp > TrallClosePrice) TrallClosePrice=Ask-TrallPp*Pp;
               if (Ask<=TrallClosePrice) CloseOrders(OrderTicket());
               }
            }
         if (OrderType()==OP_SELL)
            {
            if (Bid<OrderOpenPrice())
               {
               if (Bid+TrallPp*Pp < TrallClosePrice) TrallClosePrice=Bid+TrallPp*Pp;
               if (Bid>=TrallClosePrice) CloseOrders(OrderTicket());
               }
            }
         }
      }
   return;
   }
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
//896896896869869869869869689686986986986986968869869869869689689686986986986986986968968986
int Fun_Error(int Error)                        // Ф-ия обработ ошибок
  {
   switch(Error)
     {                                          // Преодолимые ошибки            
      case  4: Alert("Торговый сервер занят. Пробуем ещё раз..");
         Sleep(3000);                           // Простое решение
         return(1);                             // Выход из функции
      case 135:Alert("Цена изменилась. Пробуем ещё раз..");
         RefreshRates();                        // Обновим данные
         return(1);                             // Выход из функции
      case 136:Alert("Нет цен. Ждём новый тик..");
         while(RefreshRates()==false)           // До нового тика
            Sleep(1);                           // Задержка в цикле
         return(1);                             // Выход из функции
      case 137:Alert("Брокер занят. Пробуем ещё раз..");
         Sleep(3000);                           // Простое решение
         return(1);                             // Выход из функции
      case 138:Alert ("Ошибка цен");
         Sleep(3000);
         RefreshRates();
         return(1);
      case 146:Alert("Подсистема торговли занята. Пробуем ещё..");
         Sleep(500);                            // Простое решение
         return(1);                             // Выход из функции
         // Критические ошибки
      case  2: Alert("Общая ошибка.");
         return(0);                             // Выход из функции
      case  5: Alert("Старая версия терминала.");
         Work=false;                            // Больше не работать
         return(0);                             // Выход из функции
      case 64: Alert("Счет заблокирован.");
         Work=false;                            // Больше не работать
         return(0);                             // Выход из функции
      case 133:Alert("Торговля запрещена.");
         return(0);                             // Выход из функции
      case 134:Alert("Недостаточно денег для совершения операции.");
         return(0);                             // Выход из функции
      default: Alert("Возникла ошибка ",Error); // Другие варианты   
         return(0);                             // Выход из функции
     }
  }
void init()
   {
   if (Point==0.0001 || Point==0.00001) Pp=0.0001;
   if (Point==0.01 || Point==0.001) Pp=0.01;
   return;
   }
void deinit()
   {
   return;
   }

