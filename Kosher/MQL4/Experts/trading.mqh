//+------------------------------------------------------------------+
//|                                                                  |
//|                                                Alexander Fedosov |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alexander Fedosov"
#property link      "https://www.mql5.com/ru/users/alex2356"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrading
  {
private:
   bool              m_useECNNDD;
   int               m_magic;
   int               m_slpg;
   double            m_op_lt;
   bool              m_op_lt_of_bln;
   double            m_bln_risk;
   int               m_num_retr;
   color             m_b_clr;
   color             m_s_clr;
   int               Dig();
   void              isECN();
   string            Errors(int id);
   bool              IsConnect();
   double            NL(double lot);
   int               NE(int pr);

   int               SendOrd(int tip,double lot,double op,double sl,double tp);
   bool              FreeM(double lot);
   bool              StopLev(double pr1,double pr2);
   bool              Freez(double pr1,double pr2);
   bool              CheckStop(int tip,double oop,double osl,double otp,double op,double sl,double tp,int mod=0);

public:
                     CTrading(int magic_number=1111,
                              int slippage=5,
                              double open_lot=0.01,
                              bool lot_of_balance=false,
                              double risk=2.0,
                              int number_of_try=5,
                              color buy_color=clrGreen,
                              color sell_color=clrTomato);
   string            m_com_exp;
   double            Lots(int type);
   double            ND(double pr);
   bool              OpnOrd(int tip,double lot,int take,int stop);
   bool              ClosePosAll(int magik,int OrdType=-1);
   bool              isOpened(int m);
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
void CTrading::CTrading(int magic_number,
                        int slippage,
                        double open_lot,
                        bool lot_of_balance,
                        double risk,
                        int number_of_try,
                        color buy_color,
                        color sell_color)
  {
   m_magic=magic_number;
   m_slpg=slippage;
   m_op_lt=open_lot;
   m_op_lt_of_bln=lot_of_balance;
   m_bln_risk=risk;
   m_num_retr=number_of_try;
   m_b_clr=buy_color;
   m_s_clr=sell_color;
   isECN();
  }
//+------------------------------------------------------------------+
//| Определение количества знаков                                    |
//+------------------------------------------------------------------+
int CTrading::Dig()
  {
   return((_Digits==5 || _Digits==3 || _Digits==1)?10:1);
  }
//+------------------------------------------------------------------+
//| Определение типа счета                                           |
//+------------------------------------------------------------------+
void CTrading::isECN()
  {
   switch(int(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_EXEMODE)))
     {
      case SYMBOL_TRADE_EXECUTION_MARKET:
         m_useECNNDD=true;
         m_slpg=0;
         break;
      default:
         m_useECNNDD=false;
         break;
     }
  }
//+------------------------------------------------------------------+
//| Определение корректности работы терминала                        |
//+------------------------------------------------------------------+
bool CTrading::IsConnect()
  {
   return((!TerminalInfoInteger(TERMINAL_CONNECTED) || !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || IsTradeContextBusy())?false:true);
  }
//+------------------------------------------------------------------+
//| Определение торгового лота                                       |
//| 1 - от баланса, 2 - от эквити, 3 - от маржи                      |
//+------------------------------------------------------------------+
double CTrading::Lots(int type=1)
  {
   type=(type>3 || type<1)?1:type;
   double res,bal;
   switch(type)
     {
      case 1: bal = AccountBalance();break;
      case 2: bal = AccountEquity();break;
      case 3: bal = AccountFreeMargin();break;
      default:bal = AccountBalance();break;
     }
   if(!m_op_lt_of_bln)
      res=m_op_lt;
   else if(m_bln_risk>0.0)
      res=NL((bal/(100.0/m_bln_risk))/MarketInfo(_Symbol,MODE_MARGINREQUIRED));
   return(res);
  }
//+------------------------------------------------------------------+
//| Нормализация цены                                                |
//+------------------------------------------------------------------+
double CTrading::ND(double pr)
  {
   return(NormalizeDouble(pr,_Digits));
  }
//+------------------------------------------------------------------+
//| Нормализация торгового лота                                      |
//+------------------------------------------------------------------+
double CTrading::NL(double lot)
  {
   int mf=int(MathCeil(lot/SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)));
   double res=mf*SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   res=MathMax(res,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
   res=MathMin(res,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   return(res);
  }
//+------------------------------------------------------------------+
//| Конвертация пунктов в цены                                       |
//+------------------------------------------------------------------+
int CTrading::NE(int pr)
  {
   long res=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   res++;
   if(pr>res)
      res=pr;
   return(int(res));
  }
//+------------------------------------------------------------------+
//| Функция открытия ордера                                          |
//+------------------------------------------------------------------+
bool CTrading::OpnOrd(int tip,double lot,int take,int stop)
  {
   bool res=false;
   double sl=0.0,tp=0.0,opr=0.0;
   switch(tip)
     {
      case 0:
         opr=Ask;
         break;
      case 1:
         opr=Bid;
         break;
     }
   if(MathMod(tip,2.0)==0.0)
     {
      if(!m_useECNNDD)
        {
         if(stop>0)
            sl=opr-NE(stop*Dig())*_Point;
         if(take>0)
            tp=opr+NE(take*Dig())*_Point;
        }
     }
   else
     {
      if(!m_useECNNDD)
        {
         if(stop>0)
            sl=opr+NE(stop*Dig())*_Point;
         if(take>0)
            tp=opr-NE(take*Dig())*_Point;
        }
     }
   if(SendOrd(tip,lot,opr,sl,tp)>0)
      res=true;
   else
      GetLastError();
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CTrading::SendOrd(int tip,double lot,double op,double sl,double tp)
  {
   int i=0,tiket=0;
   if(!FreeM(lot))
     {
      Alert("Not enough money for trading!");
      return(tiket);
     }
   color col=m_s_clr;
   if(MathMod(tip,2.0)==0.0)
      col=m_b_clr;
   for(i=0;i<m_num_retr;i++)
     {
      if(!IsConnect())
         Sleep(4000);
      RefreshRates();
      switch(tip)
        {
         case 0:
            op=Ask;
            break;
         case 1:
            op=Bid;
            break;
        }
      if(!CheckStop(tip,0.0,0.0,0.0,op,sl,tp,0))
         break;
      tiket=OrderSend(_Symbol,tip,lot,ND(op),m_slpg,ND(sl),ND(tp),m_com_exp,m_magic,0,col);
      if(tiket>0)
         break;
     }
   return(tiket);
  }
//+------------------------------------------------------------------+
//| Функция проверки установленных в ордере стопов                   |
//| oop,osl,otp - отложки, закрытые                                  |
//+------------------------------------------------------------------+
bool CTrading::CheckStop(int tip,double oop,double osl,double otp,double op,double sl,double tp,int mod=0)
  {
   bool res=true;
   double pro=0.0,prc=0.0;
   if(MathMod(tip,2.0)==0.0)
     {pro=Ask;prc=Bid;}
   else
     {pro=Bid;prc=Ask;}
   switch(mod)
     {
      case 0: // Открытие ордеров
         switch(tip)
           {
            case 0:
            if(sl>0.0 && !StopLev(prc,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,prc)){res=false;break;}
            break;
            case 1:
            if(sl>0.0 && !StopLev(sl,prc)){res=false;break;}
            if(tp>0.0 && !StopLev(prc,tp)){res=false;break;}
            break;
            case 2:
            if(!StopLev(pro,op)){res=false;break;}
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            break;
            case 3:
            if(!StopLev(op,pro)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            break;
            case 4:
            if(!StopLev(op,pro)){res=false;break;}
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            break;
            case 5:
            if(!StopLev(pro,op)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            break;
           }
         break;
      case 1: // Закрытие рыночных
         switch(tip)
           {
            case 0:
            if(osl>0.0 && !Freez(prc,osl)){res=false;break;}
            if(otp>0.0 && !Freez(otp,prc)){res=false;break;}
            break;
            case 1:
            if(osl>0.0 && !Freez(osl,prc)){res=false;break;}
            if(otp>0.0 && !Freez(prc,otp)){res=false;break;}
            break;
           }
         break;
      case 2: // Удаление отложенников
         if(prc>oop)
           {
            if(!Freez(prc,oop))
              {res=false;break;}
           }
         else
           {
            if(!Freez(oop,prc))
              {res=false;break;}
           }
         break;
      case 3: // Модификация
         switch(tip)
           {
            case 0:
            if(osl>0.0 && !Freez(prc,osl)){res=false;break;}
            if(otp>0.0 && !Freez(otp,prc)){res=false;break;}
            if(sl>0.0 && !StopLev(prc,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,prc)){res=false;break;}
            break;
            case 1:
            if(osl>0.0 && !Freez(osl,prc)){res=false;break;}
            if(otp>0.0 && !Freez(prc,otp)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,prc)){res=false;break;}
            if(tp>0.0 && !StopLev(prc,tp)){res=false;break;}
            break;
            case 2:
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            if(!StopLev(pro,op) || !Freez(pro,op)){res=false;break;}
            break;
            case 3:
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            if(!StopLev(op,pro) || !Freez(op,pro)){res=false;break;}
            break;
            case 4:
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            if(!StopLev(op,pro) || !Freez(op,pro)){res=false;break;}
            break;
            case 5:
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            if(!StopLev(pro,op) || !Freez(pro,op)){res=false;break;}
            break;
           }
         break;
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| Закрытие всех ордеров заданного типа                             |
//+------------------------------------------------------------------+
bool CTrading::ClosePosAll(int magik,int OrdType=-1)
  {
   double price;
   int i;
   bool _Ans=true;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol || OrderMagicNumber()!=magik)
         continue;
      int order_type=OrderType();
      if(order_type>1 || (OrdType>=0 && OrdType!=order_type))
         continue;
      RefreshRates();
      i=0;
      bool Ans=false;
      while(!Ans && i<m_num_retr)
        {
         price=(order_type==OP_BUY)?Bid:Ask;
         Ans=OrderClose(OrderTicket(),OrderLots(),ND(price),m_slpg);
         i++;
        }
      if(!Ans)
         _Ans=false;
     }
   return(_Ans);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTrading::isOpened(int m)
  {
   int i=0;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==_Symbol && OrderMagicNumber()==m)
         i++;
     }
   return((i>0)?true:false);
  }
//+------------------------------------------------------------------+
//| Проверка на кол-во денег для открытие лота                       |
//+------------------------------------------------------------------+
bool CTrading::FreeM(double lot)
  {
   double a,b;
   a=lot*MarketInfo(_Symbol,MODE_MARGINREQUIRED);
   b= AccountFreeMargin();
//return((lot*SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_INITIAL)>AccountFreeMargin())?false:true);
   return (a>b)?false:true;
  }
//+------------------------------------------------------------------+
//| Проверка правильности стоп-приказов                              |
//+------------------------------------------------------------------+
bool CTrading::StopLev(double pr1,double pr2)
  {
   return(long(MathCeil((pr1-pr2)/Point))<=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL))?false:true;
  }
//+------------------------------------------------------------------+
//| Проверка на дистанцию заморозки дейстий над ордерами             |
//+------------------------------------------------------------------+
bool CTrading::Freez(double pr1,double pr2)
  {
   return(long(MathCeil((pr1-pr2)/_Point))<=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL))?false:true;
  }
//+------------------------------------------------------------------+
