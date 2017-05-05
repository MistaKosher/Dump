//+------------------------------------------------------------------+
//|                                                 ccfp_cc_beta.mq4 |
//|                                       Copyright © 2010,Lexandros |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009,Lexandros"
#property link      "lexandros@yandex.ru"
extern double step=0.0001;
extern double start_lot=0.01;
extern double min_lot=0.01;
extern int magicnumber=12345;
extern bool MM=true;
extern int delta=100;
extern bool close=true;
extern int bars=1;
extern bool trail=true;
extern int trailing=15;
extern int stop=0;
extern int profit=0;
double ccfp [8,2],ccfp_old [8,2],cc [8,2],cc_old [8,2],lot[1];
int cnt,n,x,y;  
string day,val[8];
color clr;
bool open;
datetime time;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
val[0]="USD";
val[1]="EUR";
val[2]="GBP";
val[3]="CHF";
val[4]="JPY";
val[5]="AUD";
val[6]="CAD";
val[7]="NZD";

   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----



///////////Money Management
if (MM)
   {
   lot[0]=start_lot*MathFloor (AccountBalance()/delta);
   if (lot[0]<start_lot) lot[0]=start_lot;
   if (lot[0]>MarketInfo(Symbol(),MODE_MAXLOT)) lot[0]=MarketInfo(Symbol(),MODE_MAXLOT);
   }
   else lot[0]=start_lot; 
/////////////////////////////////////////////


//////////трейлинг
if (trail) tral(trailing,min_lot,magicnumber);
//////////////////////

///////////////////Вывод информации
if (DayOfWeek( )==0) day="Воскресенье";
if (DayOfWeek( )==1) day="Понедельник";
if (DayOfWeek( )==2) day="Вторник";
if (DayOfWeek( )==3) day="Среда";
if (DayOfWeek( )==4) day="Четверг";
if (DayOfWeek( )==5) day="Пятница";
if (DayOfWeek( )==6) day="Суббота";
string info=StringConcatenate(AccountCompany(),",  ",AccountName(),". Счет №: ",AccountNumber(),", Валюта счета:  ",AccountCurrency(),". Начальный лот=",DoubleToStr(start_lot,2),". MM=",MM,". Дельта=",delta);
if (AccountMargin()!=0) Comment (info,"\n",Hour(),":00. ",Day(),".",Month(),".",Year(),". ",day,"\n","Балланс=",AccountBalance(),"\n","Средства=",AccountEquity(),"\n","Просадка=",NormalizeDouble((AccountBalance()-AccountEquity())/AccountBalance(),2)*100,"%","\n","Lot=",lot[0],"\n","Открытых ордеров=",OrdersTotal(),"\n","Уровень маржи=",AccountEquity()*100/AccountMargin(),"%");
else Comment (info,"\n",Hour(),":00. ",Day(),".",Month(),".",Year(),". ",day,"\n","Балланс=",AccountBalance(),"\n","Средства=",AccountEquity(),"\n","Просадка=",NormalizeDouble((AccountBalance()-AccountEquity())/AccountBalance(),2),"\n","Lot=",lot[0],"\n","Открытых ордеров=",OrdersTotal(),"\n","Уровень маржи=0");
//////////////////////////////////////////

/////////////Заполнение массива данными индикатора CCFp
for (cnt=0;cnt<8;cnt++)
   {
   ccfp [cnt,1]=iCustom(NULL,0,"CCFp",1,0,3,5,cnt,bars);
   ccfp [cnt,0]=cnt+1;
   ccfp_old [cnt,1]=iCustom(NULL,0,"CCFp",1,0,3,5,cnt,bars+1);
   ccfp_old [cnt,0]=cnt+1;
   }
////////////////////////////////////////



/////////////////Проверка сигнала
for (x=0;x<8;x++)
   {
   for (y=0;y<8;y++)
      {
      if (ccfp[x,0]==ccfp[y,0])continue;
      if (ccfp[x,1]-ccfp[y,1]>step&&ccfp_old[x,1]-ccfp_old[y,1]<=step&&ccfp[x,1]>ccfp_old[x,1]&&ccfp[y,1]<ccfp_old[y,1]) {open=true; oper_up(ccfp[x,0],ccfp[y,0],lot[0],stop,profit,close,open,magicnumber);}
      }
   }
//////////////////////////////////





//----
   return(0);
  }
//+------------------------------------------------------------------+

////////////////////Открытие/закрытие ордеров///////////////////////
//Входные данные: top=номер валюты идущией вверх, down=номер валюты идущей вниз,l=лот,s=стоплосс в пунктах,p=профит в пунктах,cl - флаг, определяющий, закрывать ли позиции при появлении противоположного сигнала
void oper_up (int top,int down,double l,int s,int p,bool cl, bool ops, int mn)
{


int op1,op2,k,no_open1,no_open2,ticket;
string sym1="",sym2="",comment;
double price1,price2,st1,st2,pr1,pr2;

comment=StringConcatenate("(",val[top-1],val[down-1],")");


 
   //USD
   if (top==1)
      {
      if (down==2){ sym1="EURUSD"; op1=1;}
      if (down==3){ sym1="GBPUSD"; op1=1;}
      if (down==4){ sym1="USDCHF"; op1=0;}
      if (down==5){ sym1="USDJPY"; op1=0;}
      if (down==6){ sym1="AUDUSD"; op1=1;}
      if (down==7){ sym1="USDCAD"; op1=0;}
      if (down==8){ sym1="NZDUSD"; op1=1;}
      }
   
   
   //EUR
   if (top==2)
      {
      if (down==1){ if (ccfp[1,1]>ccfp[0,1]) {sym1="EURUSD";op1=0;}}
      if (down==3){ if (ccfp[1,1]>ccfp[0,1]) {sym1="EURUSD";op1=0;} if (ccfp[2,1]<ccfp[0,1]){sym2="GPBUSD"; op2=1;}}
      if (down==4){ if (ccfp[1,1]>ccfp[0,1]) {sym1="EURUSD";op1=0;} if (ccfp[0,1]>ccfp[2,1]){sym2="USDCHF"; op2=0;}}
      if (down==5){ if (ccfp[1,1]>ccfp[0,1]) {sym1="EURUSD";op1=0;} if (ccfp[0,1]>ccfp[4,1]){sym2="USDJPY"; op2=0;}}
      if (down==6){ if (ccfp[1,1]>ccfp[0,1]) {sym1="EURUSD";op1=0;} if (ccfp[5,1]<ccfp[0,1]){sym2="AUDUSD"; op2=1;}}
      if (down==7){ if (ccfp[1,1]>ccfp[0,1]) {sym1="EURUSD";op1=0;} if (ccfp[0,1]>ccfp[6,1]){sym2="USDCAD"; op2=0;}}
      if (down==8){ if (ccfp[1,1]>ccfp[0,1]) {sym1="EURUSD";op1=0;} if (ccfp[7,1]<ccfp[0,1]){sym2="NZDUSD"; op2=1;}}
//**************************      
      }
   //GBP
   if (top==3)
      {
      if (down==1){ if (ccfp[2,1]>ccfp[0,1]) {sym1="GBPUSD"; op1=0;}}
      if (down==2){ if (ccfp[2,1]>ccfp[0,1]) {sym1="GBPUSD"; op1=0;} if (ccfp[1,1]<ccfp[0,1]){sym2="EURUSD"; op2=1;}}
      if (down==4){ if (ccfp[2,1]>ccfp[0,1]) {sym1="GBPUSD"; op1=0;} if (ccfp[0,1]>ccfp[3,1]){sym2="USDCHF"; op2=0;}}
      if (down==5){ if (ccfp[2,1]>ccfp[0,1]) {sym1="GBPUSD"; op1=0;} if (ccfp[0,1]>ccfp[4,1]){sym2="USDJPY"; op2=0;}}
      if (down==6){ if (ccfp[2,1]>ccfp[0,1]) {sym1="GBPUSD"; op1=0;} if (ccfp[5,1]<ccfp[0,1]){sym2="AUDUSD"; op2=1;}}
      if (down==7){ if (ccfp[2,1]>ccfp[0,1]) {sym1="GBPUSD"; op1=0;} if (ccfp[0,1]>ccfp[6,1]){sym2="USDCAD"; op2=0;}}
      if (down==8){ if (ccfp[2,1]>ccfp[0,1]) {sym1="GBPUSD"; op1=0;} if (ccfp[7,1]<ccfp[0,1]){sym2="NZDUSD"; op2=1;}}
      }
      
   //CHF
   if (top==4)
      {
      if (down==1){ if (ccfp[0,1]<ccfp[3,1]) {sym1="USDCHF"; op1=1;}}
      if (down==2){ if (ccfp[0,1]<ccfp[3,1]) {sym1="USDCHF"; op1=1;} if (ccfp[1,1]<ccfp[0,1]){sym2="EURUSD"; op2=1;}}
      if (down==3){ if (ccfp[0,1]<ccfp[3,1]) {sym1="USDCHF"; op1=1;} if (ccfp[2,1]<ccfp[0,1]){sym2="GBPUSD"; op2=1;}}
      if (down==5){ if (ccfp[0,1]<ccfp[3,1]) {sym1="USDCHF"; op1=1;} if (ccfp[0,1]>ccfp[4,1]){sym2="USDJPY"; op2=0;}}
      if (down==6){ if (ccfp[0,1]<ccfp[3,1]) {sym1="USDCHF"; op1=1;} if (ccfp[5,1]<ccfp[0,1]){sym2="AUDUSD"; op2=1;}}
      if (down==7){ if (ccfp[0,1]<ccfp[3,1]) {sym1="USDCHF"; op1=1;} if (ccfp[0,1]>ccfp[6,1]){sym2="USDCAD"; op2=0;}}
      if (down==8){ if (ccfp[0,1]<ccfp[3,1]) {sym1="USDCHF"; op1=1;} if (ccfp[7,1]<ccfp[0,1]){sym2="NZDUSD"; op2=1;}}
//*****************      
      }   
//JPY
   if (top==5)
      {
      if (down==1){ if (ccfp[0,1]<ccfp[4,1]) {sym1="USDJPY"; op1=1;}}
      if (down==2){ if (ccfp[0,1]<ccfp[4,1]) {sym1="USDJPY"; op1=1;} if (ccfp[1,1]<ccfp[0,1]){sym2="EURUSD"; op2=1;}}
      if (down==3){ if (ccfp[0,1]<ccfp[4,1]) {sym1="USDJPY"; op1=1;} if (ccfp[2,1]<ccfp[0,1]){sym2="GBPUSD"; op2=1;}}
      if (down==4){ if (ccfp[0,1]<ccfp[4,1]) {sym1="USDJPY"; op1=1;} if (ccfp[0,1]>ccfp[3,1]){sym2="USDCHF"; op2=0;}}
      if (down==6){ if (ccfp[0,1]<ccfp[4,1]) {sym1="USDJPY"; op1=1;} if (ccfp[5,1]<ccfp[0,1]){sym2="AUDUSD"; op2=1;}}
      if (down==7){ if (ccfp[0,1]<ccfp[4,1]) {sym1="USDJPY"; op1=1;} if (ccfp[0,1]>ccfp[6,1]){sym2="USDCAD"; op2=0;}}
      if (down==8){ if (ccfp[0,1]<ccfp[4,1]) {sym1="USDJPY"; op1=1;} if (ccfp[7,1]<ccfp[0,1]){sym2="NZDUSD"; op2=1;}}
      }

   //AUD
   if (top==6)
      {
      if (down==1){ if (ccfp[5,1]>ccfp[0,1]) {sym1="AUDUSD"; op1=0;}}
      if (down==2){ if (ccfp[5,1]>ccfp[0,1]) {sym1="AUDUSD"; op1=0;} if (ccfp[1,1]<ccfp[0,1]){sym2="EURUSD"; op2=1;}}
      if (down==3){ if (ccfp[5,1]>ccfp[0,1]) {sym1="AUDUSD"; op1=0;} if (ccfp[2,1]<ccfp[0,1]){sym2="GBPUSD"; op2=1;}}
      if (down==4){ if (ccfp[5,1]>ccfp[0,1]) {sym1="AUDUSD"; op1=0;} if (ccfp[0,1]>ccfp[3,1]){sym2="USDCHF"; op2=0;}}
      if (down==5){ if (ccfp[5,1]>ccfp[0,1]) {sym1="AUDUSD"; op1=0;} if (ccfp[0,1]>ccfp[4,1]){sym2="USDJPY"; op2=0;}}
      if (down==7){ if (ccfp[5,1]>ccfp[0,1]) {sym1="AUDUSD"; op1=0;} if (ccfp[0,1]>ccfp[6,1]){sym2="USDCAD"; op2=0;}}
      if (down==8){ if (ccfp[5,1]>ccfp[0,1]) {sym1="AUDUSD"; op1=0;} if (ccfp[7,1]<ccfp[0,1]){sym2="NZDUSD"; op2=1;}}
//***********************      
      }
      
//CAD
   if (top==7)
      {
      if (down==1){ if (ccfp[0,1]<ccfp[6,1]) {sym1="USDCAD"; op1=1;}}
      if (down==2){ if (ccfp[0,1]<ccfp[6,1]) {sym1="USDCAD"; op1=1;} if (ccfp[1,1]<ccfp[0,1]){sym2="EURUSD"; op2=1;}}
      if (down==3){ if (ccfp[0,1]<ccfp[6,1]) {sym1="USDCAD"; op1=1;} if (ccfp[2,1]<ccfp[0,1]){sym2="GBPUSD"; op2=1;}}
      if (down==4){ if (ccfp[0,1]<ccfp[6,1]) {sym1="USDCAD"; op1=1;} if (ccfp[0,1]>ccfp[3,1]){sym2="USDCHF"; op2=0;}}
      if (down==5){ if (ccfp[0,1]<ccfp[6,1]) {sym1="USDCAD"; op1=1;} if (ccfp[0,1]>ccfp[4,1]){sym2="USDJPY"; op2=0;}}
      if (down==6){ if (ccfp[0,1]<ccfp[6,1]) {sym1="USDCAD"; op1=1;} if (ccfp[5,1]<ccfp[0,1]){sym2="AUDUSD"; op2=1;}}
      if (down==8){ if (ccfp[0,1]<ccfp[6,1]) {sym1="USDCAD"; op1=1;} if (ccfp[7,1]<ccfp[0,1]){sym2="NZDUSD"; op2=1;}}
//**************************      
      }

//NZD
   if (top==8)
      {
      if (down==1){ if (ccfp[7,1]>ccfp[0,1]) {sym1="NZDUSD"; op1=0;}}
      if (down==2){ if (ccfp[7,1]>ccfp[0,1]) {sym1="NZDUSD"; op1=0;} if (ccfp[1,1]<ccfp[0,1]){sym2="EURUSD"; op2=1;}}
      if (down==3){ if (ccfp[7,1]>ccfp[0,1]) {sym1="NZDUSD"; op1=0;} if (ccfp[2,1]<ccfp[0,1]){sym2="GBPUSD"; op2=1;}}
      if (down==4){ if (ccfp[7,1]>ccfp[0,1]) {sym1="NZDUSD"; op1=0;} if (ccfp[0,1]>ccfp[3,1]){sym2="USDCHF"; op2=0;}}
      if (down==5){ if (ccfp[7,1]>ccfp[0,1]) {sym1="NZDUSD"; op1=0;} if (ccfp[0,1]>ccfp[4,1]){sym2="USDJPY"; op2=0;}}
      if (down==6){ if (ccfp[7,1]>ccfp[0,1]) {sym1="NZDUSD"; op1=0;} if (ccfp[5,1]<ccfp[0,1]){sym2="AUDUSD"; op2=1;}}
      if (down==7){ if (ccfp[7,1]>ccfp[0,1]) {sym1="NZDUSD"; op1=0;} if (ccfp[0,1]>ccfp[6,1]){sym2="USDCAD"; op2=0;}}
//**************************      
      }      
for (k=0;k<OrdersTotal();k++)
   {
   OrderSelect(k,SELECT_BY_POS);
   if (OrderSymbol()==sym1&&OrderType()==op1&&OrderMagicNumber()==mn&&OrderComment()==comment) {sym1="";}
   if (OrderSymbol()==sym2&&OrderType()==op2&&OrderMagicNumber()==mn&&OrderComment()==comment) {sym2="";}
   }

if (sym1==""&&sym2=="") return (0);

///Проверка сигнала на CFP
if (sym1!=""&&op1==0&&iCustom (sym1,0,"CFP",0,bars)<=iCustom (sym1,0,"CFP",0,bars+1)) {Print ("Сигнал по ",sym1," ",op1," не подтвержден!"); sym1="";}
if (sym1!=""&&op1==1&&iCustom (sym1,0,"CFP",0,bars)>=iCustom (sym1,0,"CFP",0,bars+1)) {Print ("Сигнал по ",sym1," ",op1," не подтвержден!"); sym1="";}
if (sym2!=""&&op2==0&&iCustom (sym2,0,"CFP",0,bars)<=iCustom (sym2,0,"CFP",0,bars+1)) {Print ("Сигнал по ",sym2," ",op2," не подтвержден!"); sym2="";}
if (sym2!=""&&op2==1&&iCustom (sym2,0,"CFP",0,bars)>=iCustom (sym2,0,"CFP",0,bars+1)) {Print ("Сигнал по ",sym2," ",op2," не подтвержден!"); sym2="";}

if (sym1==""&&sym2=="") return (0);

//////////////Закрываем открытые ордера

for (k=0;k<OrdersTotal();k++)
   {
   if (sym1!="")
      {
      OrderSelect(k,SELECT_BY_POS);
      if (OrderSymbol()==sym1&&OrderType()!=op1&&OrderMagicNumber()==mn&&cl)
         {
         if (OrderType()==OP_BUY) {OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),10000); Print("Закрываем ",OrderSymbol()," ",OrderType()," ",comment); }
         if (OrderType()==OP_SELL) {OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),10000); Print("Закрываем ",OrderSymbol()," ",OrderType()," ",comment); }
         }
      }
   
   if (sym2!="")
      {
      if (OrderSymbol()==sym2&&OrderType()!=op2&&OrderMagicNumber()==mn&&cl)
         {
         if (OrderType()==OP_BUY) {OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),10000); Print("Закрываем ",OrderSymbol()," ",OrderType()," ",comment); }
         if (OrderType()==OP_SELL) {OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),10000); Print("Закрываем ",OrderSymbol()," ",OrderType()," ",comment); }
         }
      }
   }



///

///Открываем ордера
no_open1=0;
no_open2=0;
if (ops&&sym1!="")
   {
   if (op1==0) {price1=MarketInfo(sym1,MODE_ASK); st1=price1-s*MarketInfo(sym1,MODE_POINT);pr1=price1+p*MarketInfo(sym1,MODE_POINT);}
   if (op1==1) {price1=MarketInfo(sym1,MODE_BID); st1=price1+s*MarketInfo(sym1,MODE_POINT);pr1=price1-p*MarketInfo(sym1,MODE_POINT);}
   if (s<=0) st1=0; else if (s<=MarketInfo(sym1,MODE_STOPLEVEL)) {Print("Стоп-лосс по инструменту ",sym1," меньше разрешенного ДЦ!!!");no_open1=1;}
   if (p<=0) pr1=0; else if (p<=MarketInfo(sym1,MODE_STOPLEVEL)) {Print("Тейк-профит по инструменту ",sym1," меньше разрешенного ДЦ!!!");no_open1=1;}
   if (MarketInfo(sym1,MODE_TRADEALLOWED)!=1) {Print ("Торговля по инструменту ",sym1," запрещена ДЦ!!!");no_open1=1;}
   if (no_open1==0) { ticket=0;ticket=OrderSend(sym1,op1,l,price1,10000,st1,pr1,comment,mn);Print ("Открываем ",sym1," ",op1," ",comment);}
   }
   
if (ops&&sym2!="")
   {
   if (op2==0) {price2=MarketInfo(sym2,MODE_ASK); st2=price2-s*MarketInfo(sym2,MODE_POINT);pr2=price2+p*MarketInfo(sym2,MODE_POINT);}
   if (op2==1) {price2=MarketInfo(sym2,MODE_BID); st2=price2+s*MarketInfo(sym2,MODE_POINT);pr2=price2-p*MarketInfo(sym2,MODE_POINT);}
   if (s<=0) st2=0; else if (s<=MarketInfo(sym2,MODE_STOPLEVEL)) {Print("Стоп-лосс по инструменту ",sym2," меньше разрешенного ДЦ!!!");no_open2=1;}
   if (p<=0) pr2=0; else if (p<=MarketInfo(sym2,MODE_STOPLEVEL)) {Print("Тейк-профит по инструменту ",sym2," меньше разрешенного ДЦ!!!");no_open2=1;}
   if (MarketInfo(sym2,MODE_TRADEALLOWED)!=1) {Print ("Торговля по инструменту ",sym2," запрещена ДЦ!!!");no_open2=1;}
   if (no_open2==0) {ticket=0;Print ("Открываем ",sym2," ",op2," ",comment); ticket=OrderSend(sym2,op2,l,price2,10000,st2,pr2,comment,mn);}
   }   

}

///////////////////////////////////////////////////



////////////////Трейлинг (tr=уровень трейлинга в пунктах, ml=минимальный лот)
void tral (int tr,double ml,int mn)
{
int cnt;
int k;
int x;
datetime last_time;
double close_lot;
for (cnt=0;cnt<OrdersTotal();cnt++)
   {
   OrderSelect(cnt,SELECT_BY_POS);
   if (OrderMagicNumber()!=mn) continue;
   close_lot=NormalizeDouble(OrderLots()/2,2);
   if (close_lot<ml) close_lot=ml;
   if (OrderType()==OP_BUY)
      {
      if (OrderStopLoss()==0||OrderStopLoss()<OrderOpenPrice())
         {
         if (MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice()>=tr*MarketInfo(OrderSymbol(),MODE_POINT))
            {
            Print("Двигаем стоп и закрываем половину ",OrderTicket()," ", OrderSymbol()," ",OrderType());
            OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-tr*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS)),0,0);
            OrderClose (OrderTicket(),close_lot,MarketInfo(OrderSymbol(),MODE_BID),10000);
            }
         }
      else
         {
         if (MarketInfo(OrderSymbol(),MODE_BID)-OrderStopLoss()>=tr*MarketInfo(OrderSymbol(),MODE_POINT)*2)
            {
            Print("Двигаем стоп и закрываем половину ",OrderTicket()," ", OrderSymbol()," ",OrderType());
            OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-tr*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS)),0,0);
            OrderClose (OrderTicket(),close_lot,MarketInfo(OrderSymbol(),MODE_BID),10000);
            }
         }
      }
   if (OrderType()==OP_SELL)
      {
      if (OrderStopLoss()==0||OrderStopLoss()>OrderOpenPrice())
         {
         if (OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK)>=tr*MarketInfo(OrderSymbol(),MODE_POINT))
            {
            Print("Двигаем стоп и закрываем половину ",OrderTicket()," ", OrderSymbol()," ",OrderType());
            OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+tr*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS)),0,0);
            OrderClose (OrderTicket(),close_lot,MarketInfo(OrderSymbol(),MODE_ASK),10000);
            }
         }
      else
         {
         if (OrderStopLoss()-MarketInfo(OrderSymbol(),MODE_ASK)>=tr*MarketInfo(OrderSymbol(),MODE_POINT)*2)
            {
            Print("Двигаем стоп и закрываем половину ",OrderTicket()," ", OrderSymbol()," ",OrderType());
            OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+tr*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS)),0,0);
            OrderClose (OrderTicket(),close_lot,MarketInfo(OrderSymbol(),MODE_ASK),10000);
            }
         }
      }
   
   
   } 
}      
      
         
///////////////////////////////////////////////////        