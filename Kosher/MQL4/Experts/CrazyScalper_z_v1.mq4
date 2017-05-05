//+------------------------------------------------------------------+
//|                                            CrazyScalper_z_v1.mq4 |
//|                                       full version from pilot-65 |
//|   CrazyScalper_zero версия 1. Первый ордер должен быть  |
//|                                                 pilot-65@mail.ru |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0);
//#import "crazyscalper.dll"
//   void SetWindowHandle(int a0);
//   bool A(double a0, double a1, double a2);
//   bool B(int a0, double a1, double a2, int a3, double a4);
//   bool C(int a0, int a1, double a2, double a3, int a4, double a5);
#import

extern int    TakeProfit    = 10;    // размер фиксирования прибыли в пунктах рыночной позиции.
extern int    Lock_Level    = 22;    // расстояние выставления локирующей позиции в пунктах от убыточной рыночной позиции.
extern double koef_lock     = 1.8;   // коэффициент умножения объема локирующей позиции к рыночной позиции ушедшей в убыток.
extern double TakeProfit_Av = 10.0;  // размер фиксирования прибыли при выводе в прибыль убыточных позиций в пунктах.
extern int    AV_Level      = 50;    // расстояние от лока и сетки между отложенными ордерами для вывода в прибыль локирующей позиции.
extern int    OR_Level      = 24;    // расстояние от рыночной цены выставление отложенных ордеров.
extern double koef_av       = 2.0;   // коэффициент умножения объема отложенных ордеров к убыточной локирующей позиции.
extern double Lot           = 0.0;   // объем рыночной позиции. Если =0, Lot рассчитывается советником от маржи и переменной Risk.
extern double Risk          = 0.3;   // переменная для рассчета лота, при значении Lot=0.0.
extern bool   Choice_method = FALSE; // рассчет маржи: TRUE - от баланса, FALSE - от свободных средств.
extern int    NumberOfTry   = 5;     // переменная в коде не используется. Вероятно раньше задавалось количество попыток для торговых операций.
extern int    Slippage      = 3;     // проскальзывание.
extern int    MagicNumber   = 1000;
extern bool   StartTrading   = FALSE; // автоматическая торговля.
extern bool   MarketWatch   = TRUE;  // отслеживаем ордера в рынке.
bool NotTrade = FALSE;
int Magic_1;
int Magic_2;

int init() {
//   SetWindowHandle(WindowHandle(Symbol(), Period()));
   Slippage *= Dig() / Point;
   Magic_1 = MagicNumber + 1;
   Magic_2 = MagicNumber + 2;
   return (0);
}

int deinit() {
   return (0);
}
//+------------------------------------------------------------------+
//|                          S  T  A  R  T                           |
//+------------------------------------------------------------------+
int start() {
   double MinStop = MarketInfo(Symbol(), MODE_STOPLEVEL) / (Dig() / Point);
   if (TakeProfit < MinStop) TakeProfit = MinStop;
   if (OR_Level < MinStop) OR_Level = MinStop;
   double Non = MinStop * Dig();//                                            Переменная в коде не используется. Атавизм?
   double TP = 0;
   double Price_BUY = -1;
   double Lot_BUY = -1;
   double Price_SELL = -1;
   double Lot_SELL = -1;
   double Profit_BUY = 0;
   double Profit_SELL = 0;
   int    Ticket_BUY = -1;
   int    Ticket_SELL = -1;
   double Price_Mag1 = -1;
   double Lot_Mag1 = -1;
   int    Ticket_Mag1 = -1;
   double Profit_Mag1 = 0;
   double Price_Mag2 = -1;
   double Lot_Mag2 = -1;
   int    Ticket_Mag2 = -1;
   double Profit_Mag2 = 0;
   for (int i=0; i <= OrdersTotal() - 1; i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            if (OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_BUY) {
                  Price_BUY = OrderOpenPrice();
                  Lot_BUY = OrderLots();
                  Ticket_BUY = OrderTicket();
                  Profit_BUY += OrderProfit() + OrderCommission() + OrderSwap();
               }
               if (OrderType() == OP_SELL) {
                  Price_SELL = OrderOpenPrice();
                  Lot_SELL = OrderLots();
                  Ticket_SELL = OrderTicket();
                  Profit_SELL += OrderProfit() + OrderCommission() + OrderSwap();
               }
            }
            if (OrderMagicNumber() == Magic_1) {
               Price_Mag1 = OrderOpenPrice();
               Lot_Mag1 = OrderLots();
               Ticket_Mag1 = OrderTicket();
               Profit_Mag1 += OrderProfit() + OrderCommission() + OrderSwap();
            }
            if (OrderMagicNumber() == Magic_2) {
               Price_Mag2 = OrderOpenPrice();
               Lot_Mag2 = OrderLots();
               Ticket_Mag2 = OrderTicket();
               Profit_Mag2 += OrderProfit() + OrderCommission() + OrderSwap();
            }
         }
      }
   }
   Comment("профит = " + DoubleToStr(TakePr_Av(LotSize()), 2) 
      + "\nGetLot() = " + DoubleToStr(LotSize(), 2) 
   + "\nTakeProfit_Av = " + DoubleToStr(TakeProfit_Av, 0));
   double Balance = 0;
   if (A(Profit_BUY, Profit_Mag1, TakePr_Av(LotSize())) && Ticket_Mag1 > 0) {
      Balance = AccountBalance();
      Print(DoubleToStr(TakePr_Av(LotSize()), 2), " ----  начало -------- Fix, BUY+LOCK_sell, profit_b(", DoubleToStr(Profit_BUY, 2), ")+profit_1(", DoubleToStr(Profit_Mag1, 2), ") = ",
         DoubleToStr(Profit_BUY + Profit_Mag1, 2), "  AccountBalance = ", Balance);
      if (Ticket_BUY > 0) CloseOrder(Ticket_BUY);
      Find_Close(Symbol(), -1, MagicNumber + 1);
      Find_Delete(Symbol(), -1, MagicNumber + 1);
      Print(" ----  конец -------- Fix, BUY+LOCK_sell  AccountBalance = ", AccountBalance(), "  реально заработано ", DoubleToStr(AccountBalance() - Balance, 2));
   }
   if (B(Ticket_Mag1, Bid, Price_Mag1, AV_Level, Dig())) SetOrder(Symbol(), OP_SELLSTOP, NormalizeDouble(Lot_Mag1 * koef_av, DigitsLot()), NormalizeDouble(Bid - OR_Level * Dig(), Digits), 0, 0, MagicNumber + 1, "AW locka buya");
   if (C(Ticket_Mag1, Ticket_BUY, Price_BUY, Ask, Lock_Level, Dig())) OpenOrder(NULL, OP_SELL, NormalizeDouble(Lot_BUY * koef_lock, DigitsLot()), 0, 0, MagicNumber + 1, "lock buya");
   if (Ticket_BUY < 0) {
      if (TakeProfit > 0) TP = Ask + TakeProfit * Dig();
      else TP = 0;
      if (StartTrading)//добавлено в этой версии
      OpenOrder(NULL, OP_BUY, LotSize(), 0, TP, MagicNumber, "buy основной");
   }
   if (A(Profit_SELL, Profit_Mag2, TakePr_Av(LotSize())) && Ticket_Mag2 > 0) {
      Balance = AccountBalance();
      Print(DoubleToStr(TakePr_Av(LotSize()), 2), " ----  начало -------- Fix, SELL+LOCK_buy, profit_s(", DoubleToStr(Profit_SELL, 2), ")+profit_2(", DoubleToStr(Profit_Mag2, 2), ") = ",
         DoubleToStr(Profit_SELL + Profit_Mag2, 2), "  AccountBalance = ", Balance);
      if (Ticket_SELL > 0) CloseOrder(Ticket_SELL);
      Find_Close(Symbol(), -1, MagicNumber + 2);
      Find_Delete(Symbol(), -1, MagicNumber + 2);
      Print(" ---- конец -------- Fix, SELL+LOCK_buy  AccountBalance = ", AccountBalance(), "  реально заработано ", DoubleToStr(AccountBalance() - Balance, 2));
   }
   if (B(Ticket_Mag2, Price_Mag2, Ask, AV_Level, Dig())) SetOrder(Symbol(), OP_BUYSTOP, NormalizeDouble(Lot_Mag2 * koef_av, DigitsLot()), NormalizeDouble(Ask + OR_Level * Dig(), Digits), 0, 0, MagicNumber + 2, "AW locka sella");
   if (C(Ticket_Mag2, Ticket_SELL, Bid, Price_SELL, Lock_Level, Dig())) OpenOrder(NULL, OP_BUY, NormalizeDouble(Lot_SELL * koef_lock, DigitsLot()), 0, 0, MagicNumber + 2, "lock sella");
   if (Ticket_SELL < 0) {
      if (TakeProfit > 0) TP = Bid - TakeProfit * Dig();
      else TP = 0;
      if (StartTrading)//добавлено в этой версии
      OpenOrder(NULL, OP_SELL, LotSize(), 0, TP, MagicNumber, "sell основной");
   }
   return (0);
}
//+-------------------------------------------------------------------+
//|                          Ф  У  Н  К  Ц  И  И                      |
//+-------------------------------------------------------------------+
void OpenOrder(string symbol, int cmd, double volume, double stoploss = 0.0, double takeprofit = 0.0, int magic = 0, string comment = "") {
   color ar_color;
   int date_time;
   double price;
   double ask;
   double bid;
   int digits;
   int error;
   int ticket = 0;
   string order_comment = comment;
   if (symbol == "" || symbol == "0") symbol = Symbol();
   if (cmd == OP_BUY) ar_color = Lime;
   else ar_color = Red;
   for (int i = 1; i <= 5; i++) {
      if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) {
         Print("OpenPosition(): Stopping function");
         break;
      }
      while (!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      digits = MarketInfo(symbol, MODE_DIGITS);
      ask = MarketInfo(symbol, MODE_ASK);
      bid = MarketInfo(symbol, MODE_BID);
      if (cmd == OP_BUY) price = ask;
      else price = bid;
      price = NormalizeDouble(price, digits);
      date_time = TimeCurrent();
      if (AccountFreeMarginCheck(Symbol(), cmd, volume) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
         Alert("Для открытия позиции ", OP_Type(cmd), ", Лотом=", volume, ", свободных средств не хватает.");
         return;
      }
      if (MarketWatch) ticket = OrderSend(symbol, cmd, volume, price, Slippage, 0, 0, order_comment, magic, 0, ar_color);
      else ticket = OrderSend(symbol, cmd, volume, price, Slippage, stoploss, takeprofit, order_comment, magic, 0, ar_color);
      if (ticket > 0) {
         PlaySound("ok");
         break;
      }
      error = GetLastError();
      if (ask == 0.0 && bid == 0.0) PrintCheck("Check in the Review of the market presence of the symbol " + symbol);
      Print("Error(", error, ") opening position: ", ErrorDescription(error), ", try ", i);
      Print("Ask=", ask, " Bid=", bid, " sy=", symbol, " ll=", volume, " op=", OP_Type(cmd), " pp=", price, " sl=", stoploss, " tp=", takeprofit, " mn=",
         magic);
      if (error == 2/* COMMON_ERROR */ || error == 64/* ACCOUNT_DISABLED */ || error == 65/* INVALID_ACCOUNT */ || error == 133/* TRADE_DISABLED */) {
         NotTrade = TRUE;
         break;
      }
      if (error == 4/* SERVER_BUSY */ || error == 131/* INVALID_TRADE_VOLUME */ || error == 132/* MARKET_CLOSED */) {
         Sleep(300000);
         break;
      }
      if (error == 128/* TRADE_TIMEOUT */ || error == 142 || error == 143) {
         Sleep(66666.0);
         if (FindOrder_1(symbol, cmd, magic, date_time)) {
            PlaySound("ok");
            break;
         }
      }
      if (error == 140/* LONG_POSITIONS_ONLY_ALLOWED */ || error == 148/* TRADE_TOO_MANY_ORDERS */ || error == 4110/* LONGS__NOT_ALLOWED */ || error == 4111/* SHORTS_NOT_ALLOWED */) break;
      if (error == 141/* TOO_MANY_REQUESTS */) Sleep(100000);
      if (error == 145/* TRADE_MODIFY_DENIED */) Sleep(17000);
      if (error == 146/* TRADE_CONTEXT_BUSY */) while (IsTradeContextBusy()) Sleep(11000);
      if (error != 135/* PRICE_CHANGED */) Sleep(7700.0);
   }
   if (MarketWatch && ticket > 0 && stoploss > 0.0 || takeprofit > 0.0)
      if (OrderSelect(ticket, SELECT_BY_TICKET)) ModifyOrder(-1, stoploss, takeprofit);
}
/////////////////////////////////////////////////////////////////////////////////////////
void CloseOrder(int ticket) {
   bool closed;
   color ar_color;
   double lots;
   double ask;
   double bid;
   double price;
   int error;
   if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
      for (int i = 1; i <= 5; i++) {
         if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) break;
         while (!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         ask = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_ASK), Digits);
         bid = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_BID), Digits);
         if (OrderType() == OP_BUY) {
            price = bid;
            ar_color = Aqua;
         } else {
            price = ask;
            ar_color = Gold;
         }
         lots = OrderLots();
         closed = OrderClose(OrderTicket(), lots, price, Slippage, ar_color);
         if (closed) {
            PlaySound("tick");
            Print(" *-------* ",OP_Type(OrderType()), " закрыт с прибылью = ", DoubleToStr(OrderProfit(), 2));
            return;
         }
         error = GetLastError();
         if (error == 146/* TRADE_CONTEXT_BUSY */) while (IsTradeContextBusy()) Sleep(11000);
         Print("Error(", error, ") Close ", OrderType(), " ", ", try ", i);
         Print(OrderTicket(), "  Ask=", ask, "  Bid=", bid, "  pp=", price);
         Print("sy=", OrderSymbol(), "  ll=", lots, "  sl=", OrderStopLoss(), "  tp=", OrderTakeProfit(), "  mn=", OrderMagicNumber());
         Sleep(5000);
      }
   } else Print("Incorrect trade operation. Close ", OrderType());
}
/////////////////////////////////////////////////////////////////////////////////////////
double TakePr_Av(double LotSize) {
   int digits = Digits;
   int k = 100;
   if (digits == 3 || digits >= 5) k = 1000;
   double TP_Av = 1000.0 * LotSize * TakeProfit_Av / k;
   return (TP_Av);
}
/////////////////////////////////////////////////////////////////////////////////////////
void Find_Close(string symbol = "", int type = -1, int magic = -1) {
   int order_total = OrdersTotal();
   if (symbol == "0") symbol = Symbol();
   for (int i = order_total - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == symbol || symbol == "" && type < OP_BUY || OrderType() == type) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
               if (magic < 0 || OrderMagicNumber() == magic) CloseOrder(OrderTicket());
         }
      }
   }
}
/////////////////////////////////////////////////////////////////////////////////////////
void SetOrder(string symbol, int cmd, double volume, double price, double stoploss = 0.0, double takeprofit = 0.0, int magic = 0, string comment = "") {
   color ar_color;
   int date_time;
   double ask;
   double bid;
   double point;
   int error;
   int ticket;
   int type;
   string order_comment = comment;
   if (symbol == "" || symbol == "0") symbol = Symbol();
   int stoplevel = MarketInfo(symbol, MODE_STOPLEVEL);
   if (cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP) {
      ar_color = Lime;
      type = 0;
   } else {
      ar_color = Red;
      type = 1;
   }
   for (int i = 1; i <= 5; i++) {
      if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) {
         Print("SetOrder(): Stop");
         return;
      }
      while (!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      date_time = TimeCurrent();
      if (AccountFreeMarginCheck(Symbol(), type, volume) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
         Alert(WindowExpertName() + " " + Symbol(), " ", " ", "For opening a position ", cmd, ", Lots=", volume, ", The free means do not suffice.");
         return;
      }
      ticket = OrderSend(symbol, cmd, volume, price, Slippage, stoploss, takeprofit, order_comment, magic, 0, ar_color);
      if (ticket > 0) {
         PlaySound("ok");
         return;
      }
      error = GetLastError();
      if (error == 128/* TRADE_TIMEOUT */ || error == 142 || error == 143) {
         Sleep(66000);
         if (FindOrder_2(symbol, cmd, magic, date_time)) {
            PlaySound("alert2");
            return;
         }
         Print("Error(", error, ") set order: ", error, ", try ", i);
      } else {
         point = MarketInfo(symbol, MODE_POINT);
         ask = MarketInfo(symbol, MODE_ASK);
         bid = MarketInfo(symbol, MODE_BID);
         if (error == 130/* INVALID_STOPS */) {
            switch (cmd) {
            case OP_BUYLIMIT:
               if (price > ask - stoplevel * point) price = ask - stoplevel * point;
               if (stoploss > price - (stoplevel + 1) * point) stoploss = price - (stoplevel + 1) * point;
               if (!(takeprofit > 0.0 && takeprofit < price + (stoplevel + 1) * point)) break;
               takeprofit = price + (stoplevel + 1) * point;
               break;
            case OP_BUYSTOP:
               if (price < ask + (stoplevel + 1) * point) price = ask + (stoplevel + 1) * point;
               if (stoploss > price - (stoplevel + 1) * point) stoploss = price - (stoplevel + 1) * point;
               if (!(takeprofit > 0.0 && takeprofit < price + (stoplevel + 1) * point)) break;
               takeprofit = price + (stoplevel + 1) * point;
               break;
            case OP_SELLLIMIT:
               if (price < bid + stoplevel * point) price = bid + stoplevel * point;
               if (stoploss > 0.0 && stoploss < price + (stoplevel + 1) * point) stoploss = price + (stoplevel + 1) * point;
               if (takeprofit <= price - (stoplevel + 1) * point) break;
               takeprofit = price - (stoplevel + 1) * point;
               break;
            case OP_SELLSTOP:
               if (price > bid - stoplevel * point) price = bid - stoplevel * point;
               if (stoploss > 0.0 && stoploss < price + (stoplevel + 1) * point) stoploss = price + (stoplevel + 1) * point;
               if (takeprofit <= price - (stoplevel + 1) * point) break;
               takeprofit = price - (stoplevel + 1) * point;
            }
            Print("SetOrder(): The price levels are corrected");
         }
         Print("Error(", error, ") set order: ", error, ", try ", i);
         Print("Ask=", ask, "  Bid=", bid, "  sy=", symbol, "  ll=", volume, "  op=", cmd, "  pp=", price, "  sl=", stoploss, "  tp=", takeprofit, "  mn=", magic);
         if (ask == 0.0 && bid == 0.0) Print("SetOrder(): Check up in the review of the market presence of a symbol " + symbol);
         if (error == 4/* SERVER_BUSY */ || error == 131/* INVALID_TRADE_VOLUME */ || error == 132/* MARKET_CLOSED */) {
            Sleep(300000);
            return;
         }
         if (error == 8/* TOO_FREQUENT_REQUESTS */ || error == 141/* TOO_MANY_REQUESTS */) Sleep(100000);
         if (error == 139/* ORDER_LOCKED */ || error == 140/* LONG_POSITIONS_ONLY_ALLOWED */ || error == 148/* TRADE_TOO_MANY_ORDERS */) break;
         if (error == 146/* TRADE_CONTEXT_BUSY */) while (IsTradeContextBusy()) Sleep(11000);
         if (error != 135/* PRICE_CHANGED */ && error != 138/* REQUOTE */) Sleep(7700.0);
      }
   }
}
/////////////////////////////////////////////////////////////////////////////////////////
bool FindOrder_1(string symbol = "", int cmd = -1, int magic = -1, int date_time = 0) {
   int order_total = OrdersTotal();
   if (symbol == "0") symbol = Symbol();
   for (int i=0; i < order_total; i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == symbol || symbol == "") {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (cmd < OP_BUY || OrderType() == cmd) {
                  if (magic < 0 || OrderMagicNumber() == magic)
                     if (date_time <= OrderOpenTime()) return (1);
               }
            }
         }
      }
   }
   return (0);
}
/////////////////////////////////////////////////////////////////////////////////////////
bool FindOrder_2(string symbol = "", int cmd = -1, int magic = -1, int date_time = 0) {
   int type;
   int order_total = OrdersTotal();
   if (symbol == "0") symbol = Symbol();
   for (int i = 0; i < order_total; i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         type = OrderType();
         if (type > OP_SELL && type < 6) {
            if (OrderSymbol() == symbol || symbol == "" && cmd < OP_BUY || type == cmd) {
               if (magic < 0 || OrderMagicNumber() == magic)
                  if (date_time <= OrderOpenTime()) return (1);
            }
         }
      }
   }
   return (0);
}
/////////////////////////////////////////////////////////////////////////////////////////
void Find_Delete(string symbol = "", int cmd = -1, int magic = -1) {
   bool deleted;
   int error;
   int type;
   int order_total = OrdersTotal();
   if (symbol == "0") symbol = Symbol();
   for (int i = order_total - 1; i >= 0; i--) {//  Возможно -1 тут лишнее
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         type = OrderType();
         if (type > OP_SELL && type < 6) {
            if (OrderSymbol() == symbol || symbol == "" && cmd < OP_BUY || type == cmd) {
               if (magic < 0 || OrderMagicNumber() == magic) {
                  for (int j = 1; j <= 5; j++) {
                     if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) break;
                     while (!IsTradeAllowed()) Sleep(5000);
                     deleted = OrderDelete(OrderTicket(), White);
                     if (deleted) {
                        PlaySound("timeout");
                        break;
                     }
                     error = GetLastError();
                     Print("Error(", error, ") delete order ", type, ": ", error, ", try ", j);
                     Sleep(5000);
                  }
               }
            }
         }
      }
   }
}
/////////////////////////////////////////////////////////////////////////////////////////
double LotSize() {
   double free_magrin = 0;
   if (Choice_method) free_magrin = AccountBalance();
   else free_magrin = AccountFreeMargin();
   double minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double risk = Risk / 100.0;
   double volume = MathFloor(free_magrin * risk / MarketInfo(Symbol(), MODE_MARGINREQUIRED) / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
   if (Lot > 0.0) volume = Lot;
   if (volume < minlot) volume = minlot;
   if (volume > maxlot) volume = maxlot;
   return (volume);
}
/////////////////////////////////////////////////////////////////////////////////////////
void PrintCheck(string Check) {
   Comment(Check);
   if (StringLen(Check) > 0) Print(Check);
}
/////////////////////////////////////////////////////////////////////////////////////////
string OP_Type(int type) {
   switch (type) {
   case 0:
      return ("Buy");
   case 1:
      return ("Sell");
   case 2:
      return ("Buy Limit");
   case 3:
      return ("Sell Limit");
   case 4:
      return ("Buy Stop");
   case 5:
      return ("Sell Stop");
   }
   return ("Unknown Operation");
}
/////////////////////////////////////////////////////////////////////////////////////////
void ModifyOrder(double open_price = -1.0, double stoploss = 0.0, double takeprofit = 0.0, int date_time = 0) {
   bool modify;
   color ar_color; // Цвет не задан
   double ask;
   double bid;
   int error;
   int digits = MarketInfo(OrderSymbol(), MODE_DIGITS);
   if (open_price <= 0.0) open_price = OrderOpenPrice();
   if (stoploss < 0.0) stoploss = OrderStopLoss();
   if (takeprofit < 0.0) takeprofit = OrderTakeProfit();
   open_price = NormalizeDouble(open_price, digits);
   stoploss = NormalizeDouble(stoploss, digits);
   takeprofit = NormalizeDouble(takeprofit, digits);
   double op = NormalizeDouble(OrderOpenPrice(), digits);
   double sl = NormalizeDouble(OrderStopLoss(), digits);
   double tp = NormalizeDouble(OrderTakeProfit(), digits);
   if (open_price != op || stoploss != sl || takeprofit != tp) {
      for (int i = 1; i <= 5; i++) {
         if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) break;
         while (!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         modify = OrderModify(OrderTicket(), open_price, stoploss, takeprofit, date_time, ar_color);
         if (modify) {
            PlaySound("alert");
            return;
         }
         error = GetLastError();
         ask = MarketInfo(OrderSymbol(), MODE_ASK);
         bid = MarketInfo(OrderSymbol(), MODE_BID);
         Print("Error(", error, ") modifying order: ", ErrorDescription(error), ", try ", i);
         Print("Ask=", ask, "  Bid=", bid, "  sy=", OrderSymbol(), "  op=" + OP_Type(OrderType()), "  pp=", open_price, "  sl=", stoploss, "  tp=", takeprofit);
         Sleep(10000);
      }
   }
}
/////////////////////////////////////////////////////////////////////////////////////////
double Dig() {
   int SymbJPY = StringFind(Symbol(), "JPY");
   if (SymbJPY == -1) return (0.0001);         // Если не JPY
   return (0.01);                              // Если JPY
}
/////////////////////////////////////////////////////////////////////////////////////////
double DigitsLot() {
   double lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
   int digits = MathCeil(MathAbs(MathLog(lotstep) / MathLog(10)));
   return (digits);
}
//+-------------------------------------------------------------------+
//|                       Ф У Н К Ц И И  из DLL                       |
//+-------------------------------------------------------------------+
bool A(double a0, double a1, double a2){
   if ( a0 + a1 > a2) return (true); 
   return (false);
}
///////////////////////////////////////////////////////////////////////
bool B(int a0, double a1, double a2, int a3, double a4){
   if ( a0 > 0 )
   {
      if (a3 * a4 < a1 - a2 ) return (true);
   }
   return(false);
}
///////////////////////////////////////////////////////////////////////
bool C(int a0, int a1, double a2, double a3, int a4, double a5){
   if ( a0 < 0 )
    {
      if ( a1 > 0 )
      {
        if ( a4 * a5 < a2 - a3 ) return (true);
      }
    }
   return(false);
}