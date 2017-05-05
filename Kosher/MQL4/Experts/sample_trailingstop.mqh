//+------------------------------------------------------------------+
//|                                          Sample_TrailingStop.mqh |
//|                                        MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

class CTrailingStop{
   protected:
      string m_symbol;              // символ
      ENUM_TIMEFRAMES m_timeframe;  // таймфрейм
      bool m_eachtick;              // работать на каждом тике
      bool m_indicator;             // показывать индикатор на графике
      bool m_button;                // показывать кнопку включения/выключения
      int m_button_x;               // координата х кнопки
      int m_button_y;               // координата у кнопки
      color m_bgcolor;              // цвет кнопки
      color m_txtcolor;             // цвет надписи кнопки
      int m_shift;                  // смещение бара
      bool m_onoff;                 // включено/выключено
      int m_handle;                 // хэндл индикатора
      datetime m_lasttime;          // время последнего выполнения трейлинг стопа
      //MqlTradeRequest m_request;    // структура торгового запроса
     // MqlTradeResult m_result;      // структура результата торгового запроса
      int m_digits;                 // количество знаков после запятой у цены
      double m_point;               // значение пункта
      string m_objname;             // имя кнопки
      string m_typename;            // имя типа трейлинг стопа
      string m_caption;             // надпись на кнопке
   public:   
   void CTrailingStop(){};
   void ~CTrailingStop(){};
   
      //--- Метод инициализации трейлинг стопа
      void Init(string             symbol,
                ENUM_TIMEFRAMES timeframe,
                bool    eachtick  =  true,
                bool    indicator = false,
                bool    button    = false,
                int     button_x  =     5,
                int     button_y  =    15,
                color   bgcolor   = Silver,
                color   txtcolor  =   Blue)
           {
         //--- установка параметров
         m_symbol    = symbol;    // символ
         m_timeframe = timeframe; // таймфрейм
         m_eachtick  = eachtick;  // true - работать на каждом тике, false - работать раз на бар 
            //--- установка бара с которого используется значение индикатора
            if(eachtick){ 
               m_shift=0; // формирующийся бар, при потиковом режиме
            }
            else{
               m_shift=1;  // сформированный бар при побарном режиме
            }          
         m_indicator = indicator; // true - присоединять индикатор на график
         m_button = button;       // true - создавать кнопку для включения/выключения трейлинг стопа
         m_button_x = button_x;   // координата Х кнопки
         m_button_y = button_y;   // координата Y кнопки
         m_bgcolor = bgcolor;     // цвет кнопки
         m_txtcolor = txtcolor;   // цвет надписи на кнопке   
         //--- получение неизменной рыночной информации     
         m_digits=(int)SymbolInfoInteger(m_symbol,SYMBOL_DIGITS); // количество знаков после запятой у цены
         m_point=SymbolInfoDouble(m_symbol,SYMBOL_POINT);         // значение пункта           
         //--- формирование имени кнопки и надписи на ней
         m_objname="CTrailingStop_"+m_typename+"_"+symbol;        // имя кнопки
         m_caption=symbol+" "+m_typename+" Trailing";             // надпись на кнопке
         //--- заполнении структуры торгового запроса
         m_request.symbol=m_symbol;                               // подготовка структуры торгового запроса, установка символа
         m_request.action=TRADE_ACTION_SLTP;                      // подготовка структуры торгового запроса, установка типа торгового действия
         //--- созание кнопки
            if(m_button){ 
               ObjectCreate(0,m_objname,OBJ_BUTTON,0,0,0);                 // создание
               ObjectSetInteger(0,m_objname,OBJPROP_XDISTANCE,m_button_x); // установка координаты Х
               ObjectSetInteger(0,m_objname,OBJPROP_YDISTANCE,m_button_y); // установка координаты Y
               ObjectSetInteger(0,m_objname,OBJPROP_BGCOLOR,m_bgcolor);    // установка цвета фона
               ObjectSetInteger(0,m_objname,OBJPROP_COLOR,m_txtcolor);     // установка цвета надписи
               ObjectSetInteger(0,m_objname,OBJPROP_XSIZE,120);            // установка ширины
               ObjectSetInteger(0,m_objname,OBJPROP_YSIZE,15);             // установка высоты
               ObjectSetInteger(0,m_objname,OBJPROP_FONTSIZE,7);           // установка размера шрифта
               ObjectSetString(0,m_objname,OBJPROP_TEXT,m_caption);        // установка надписи 
               ObjectSetInteger(0,m_objname,OBJPROP_STATE,false);          // установка состояния кнопки, по умолчанию выключена, отжата
               ObjectSetInteger(0,m_objname,OBJPROP_SELECTABLE,false);     // пользователь не сможет выделять и перемещать кнопку, только нажимать
               ChartRedraw();                                              // обновление отображения графика 
            }
         //--- установка состояния трейлинг стопа          
         m_onoff=false;                                                    // состояние трейлинг стопа - включен/выключен, по умолчанию выключен            
      };
      //--- Запуск таймера
      bool StartTimer(){
         return(EventSetTimer(1));
      };
      //--- Остановка таймера
      void StopTimer(){
         EventKillTimer();
      };
      //--- Включение трейлинг стопа
      void On(){
         m_onoff=true; 
            // если используется кнопка, она переводится в нажатое положение
            if(m_button){ 
               if(!ObjectGetInteger(0,m_objname,OBJPROP_STATE)){
                  ObjectSetInteger(0,m_objname,OBJPROP_STATE,true);
               }
            }
      }
      //--- Выключение трейлинг стопа
      void Off(){ 
         m_onoff=false;
            // Если используется кнопка, она переводится в отжатое положение
            if(m_button){ 
               if(ObjectGetInteger(0,m_objname,OBJPROP_STATE)){
                  ObjectSetInteger(0,m_objname,OBJPROP_STATE,false);
               }
            }
      }   
      //--- Основной метод управления уровнем стоплосс позиции   
      bool DoStoploss(){
            //--- если трейлинг стоп выключен
            if(!m_onoff){
               return(true);
            } 
         datetime tm[1];
            //--- в побарном режиме получаем время последнего бара
            if(!m_eachtick){ 
               //--- если не удалось скопировать время, завершаем работу метода, повтор произойдет на следующем тике, 
               if(CopyTime(m_symbol,m_timeframe,0,1,tm)==-1){
                  return(false); 
               }
               //--- если время бара равно времени последнего выполнения метода - завершаем работу метода
               if(tm[0]==m_lasttime){ 
                  return(true);
               }
            }               
            //--- получаем значения индикатора
            if(!Refresh()){ 
               return(false);
            }    
         double sl;                          
            //--- в зависимости от тренда показываемого индикатором выполняем различные действия
            switch (Trend()){ 
               //--- тренд вверх
               case 1: 
                  //--- выделение позиции, если ее удалось выделить, значит позиция существует
                  if(PositionSelect(m_symbol)){ 
                     //--- если позиция buy
                     if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){ 
                        //--- получаем значение стоплосс для позиции buy
                        sl=BuyStoploss(); 
                        //--- определяем допустимый уровень установки стоплосс для позиции buy
                        double minimal=SymbolInfoDouble(m_symbol,SYMBOL_BID)-m_point*SymbolInfoInteger(m_symbol,SYMBOL_TRADE_STOPS_LEVEL); 
                        //--- нормализация значения
                        sl=NormalizeDouble(sl,m_digits); 
                        //--- нормализация значения
                        minimal=NormalizeDouble(minimal,m_digits); 
                        //--- если на полученный от индикатора уровень невозможно установить стоплосс, он будет установлен на ближайший возможный уровень
                        sl=MathMin(sl,minimal); 
                        //--- значение стоплосс позиции
                        double possl=PositionGetDouble(POSITION_SL); 
                        //--- нормализация значения
                        possl=NormalizeDouble(possl,m_digits); 
                           //--- если новое значение стоплосс выше, чем текущее значение стоплосс, будет выполнена попытка переместить стоплосс на новый уровень
                           if(sl>possl){ 
                              //--- заполнение структуры запроса
                              m_request.sl=sl; 
                              //--- заполнение структуры запроса
                              m_request.tp=PositionGetDouble(POSITION_TP); 
                              //--- запрос
                              OrderSend(m_request,m_result); 
                                 //--- проверка результата выполнения запроса
                                 if(m_result.retcode!=TRADE_RETCODE_DONE){ 
                                    //--- вывод в журнал сообщения об ошибке 
                                    printf("Не удалось переместить стоплосс позиции %s, ошибка: %I64u",m_symbol,m_result.retcode); 
                                    //--- не удалось переместить стоплосс, завершаем выполнение
                                    return(false); 
                                 }
                           }
                     }
                  }
               break;
               //--- тренд вниз
               case -1: 
                  if(PositionSelect(m_symbol)){
                     if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
                        sl=SellStoploss();
                        //--- прибавляется спред, поскольку sell закрывается по цене Ask
                        sl+=(SymbolInfoDouble(m_symbol,SYMBOL_ASK)-SymbolInfoDouble(m_symbol,SYMBOL_BID)); 
                        double minimal=SymbolInfoDouble(m_symbol,SYMBOL_ASK)+m_point*SymbolInfoInteger(m_symbol,SYMBOL_TRADE_STOPS_LEVEL);
                        sl=NormalizeDouble(sl,m_digits);
                        minimal=NormalizeDouble(minimal,m_digits);
                        sl=MathMax(sl,minimal);
                        double possl=PositionGetDouble(POSITION_SL);
                        possl=NormalizeDouble(possl,m_digits);
                           if(sl<possl || possl==0){
                              m_request.sl=sl;
                              m_request.tp=PositionGetDouble(POSITION_TP);
                              OrderSend(m_request,m_result);
                                 if(m_result.retcode!=TRADE_RETCODE_DONE){
                                    printf("Не удалось переместить стоплосс позиции %s, ошибка: %I64u",m_symbol,m_result.retcode);
                                    return(false);
                                 }
                           }
                     }
                  }
               break;
            }
         //--- запоминаем время последнего выполнения метода
         m_lasttime=tm[0]; 
         return(true);
      }
      //--- Метод отслеживания нажатия/отжатия кнопки
      void EventHandle(const int id,const long & lparam,const double& dparam,const string& sparam){
         //--- есть событие с кнопкой
         if(id==CHARTEVENT_OBJECT_CLICK && sparam==m_objname){ 
            //--- проверка состояния кнопки
            if(ObjectGetInteger(0,m_objname,OBJPROP_STATE)){ 
               On();  // включение
            }
            else{
               Off(); // выключение
            }
         }
      }
      //--- Метод деинициализации
      void Deinit(){
         StopTimer();                     // остановка таймера
         IndicatorRelease(m_handle);      // освобождение хэндла индикатора
            if(m_button){
               ObjectDelete(0,m_objname); // удаление кнопки
               ChartRedraw(); 
            }
      }
      //--- Метод для получения значений индикатора
      virtual bool Refresh(){
         return(false);
      }
      //--- Метод установки параметров индикатора
      virtual void SetParameters(){
      };
      //--- Метод определения тренда показываемого индикатором
      virtual int Trend(){ 
         return(0);
      };
      //--- Метод получения значения стоплосс для buy
      virtual double BuyStoploss(){
         return(0);
      };   
      //--- Метод получения значения стоплосс для sell      
      virtual double SellStoploss(){
         return(0);
      };   
};

class CParabolicStop: public CTrailingStop {
   protected:
      double pricebuf[1]; // значение цены
      double indbuf[1];   // значение индикатора
   public:  
      void  CParabolicStop(){
         m_typename="SAR"; // установка имени типа трейлинг стопа
      };
      //--- Метод установки параметров и загрузки индикатора
      bool SetParameters(double sarstep=0.02,double sarmaximum=0.2){
         //--- загрузка индикатора
         m_handle=iSAR(m_symbol,m_timeframe,sarstep,sarmaximum); 
            //--- если не удалось загрузить индикатор, метод возвращает false
            if(m_handle==-1){
               return(false); 
            }
            if(m_indicator){
               //--- присоединение индикатора к графику
               ChartIndicatorAdd(0,0,m_handle); 
            }         
         return(true);
      }
      //--- Метод получения значений индикатора
      bool Refresh(){
            //--- если не удалось скопировать значение в массив, возвращается false
            if(CopyBuffer(m_handle,0,m_shift,1,indbuf)==-1){
               return(false); 
            } 
            //--- если не удалось скопировать значение в массив, возвращается false
            if(CopyClose(m_symbol,m_timeframe,m_shift,1,pricebuf)==-1){
               return(false); 
            }  
         return(true);                   
      }
      //--- Метод определения тренда
      int Trend(){
            //--- цена выше линии индикатора, тренд вверх
            if(pricebuf[0]>indbuf[0]){ 
               return(1);
            }
            //--- цена ниже линии индикатора, тренд вниз
            if(pricebuf[0]<indbuf[0]){ 
               return(-1);
            }            
         return(0);
      } 
      //--- Метод определения уровня стоплосс для buy
      virtual double BuyStoploss(){
         return(indbuf[0]);
      };   
      //--- Метод определения уровня стоплосс для sell
      virtual double SellStoploss(){
         return(indbuf[0]);
      };            
};  
      


class CNRTRStop : public CTrailingStop {
   protected:
   double sup[1]; // значение уровня поддержки
   double res[1]; // значение уровня сопротивления  
   public:  
      void  CNRTRStop(){
         m_typename="NRTR"; // установка имени типа трейлинг стопа
      };
      //--- Метод установки параметров и загрузки индикатора
      bool SetParameters(int period,double k){
         m_handle=iCustom(m_symbol,m_timeframe,"NRTR",period,k); // загрузка индикатора
            //--- если не удалось загрузить индикатор, метод возвращает false
            if(m_handle==-1){ 
               return(false); 
            }
            if(m_indicator){  
               //--- присоединение индикатора к графику
               ChartIndicatorAdd(0,0,m_handle); 
            }
         return(true);
      }
      //--- Метод получения значений индикатора
      bool Refresh(){
            //--- если не удалось скопировать значение в массив, возвращается false
            if(CopyBuffer(m_handle,0,m_shift,1,sup)==-1){
               return(false); 
            }      
            //--- если не удалось скопировать значение в массив, возвращается false
            if(CopyBuffer(m_handle,1,m_shift,1,res)==-1){
               return(false); 
            }              
         return(true);
      }
      //--- Метод определения тренда
      int Trend(){
            //--- есть линия поддержки, значит тренд вверх
            if(sup[0]!=0){ 
               return(1);
            }
            //--- есть линия сопротивления, значит тренд вниз
            if(res[0]!=0){ 
               return(-1);
            }            
         return(0);
      }

      //--- Метод определения уровня стоплосс для buy
      double BuyStoploss(){
         return(sup[0]);
      }; 
      //--- Метод определения уровня стоплосс для sell
      double SellStoploss(){
         return(res[0]);
      };       
};  
  



