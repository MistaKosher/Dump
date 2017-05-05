//+------------------------------------------------------------------+
//|                                             eVOLution-levels.mq4 |
//|                Copyright © 2016, someBody, trading-evolution.com |
//|                                 http://www.trading-evolution.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009-2016, someBody, trading-evolution.com"
#property link      "http://www.trading-evolution.com"
// βεπρθÿ 02.04.2016
#property indicator_chart_window
#property indicator_buffers 1

#import

extern int NumberOfDaysBackToShow = 10;
extern double LevelsVerticalShift = 0;
extern string FileNamePruductCode  = "";
extern string separator = "-------------";
extern bool HideForLongTimeframe = True;
extern bool ReverseDataFromFile = False;
extern bool ShowKeyZone = True;
extern bool ShowMajorLevels = True;
extern bool ShowMajorCALLLevels = True;
extern bool ShowMajorPUTLevels = True;
extern color KeyZonePositiveColor = SteelBlue;
extern color KeyZoneNegativeColor = Yellow;
extern color KeyZoneArrowColor = White;
extern color MajorCALLColor = Green;
extern color MajorPUTColor = Red;
extern color MajorLevelsColor = Gainsboro;
extern int MajorCALLStyle=0;
extern int MajorPUTStyle=0;



int FirstLevelWidth=1;
int correction=1;


string currency,currency1;
string curmonth,nextmonth,curdate,curyear,nextyear;
bool reverse = false;
int clevel1count,clevel2count,arrowcode;
color KeyZoneColor;
string varray[50];
double varray_[50];
//---- input parameters
int          corner=0;




double ExtMapBuffer1[];
  
string time_to_string(int time)
{
   if(time < 10)return("0"+time);
   return(time);
}

int init()
{
   //---- checking if timeframe is begger than 1hour, if so - drow nothing
   if (HideForLongTimeframe && Period()>240) return(0);
   NumberOfDaysBackToShow=NumberOfDaysBackToShow+1;
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   
//---- trying to indentify what file to load based on symbol
   currency =StringSubstr( Symbol(),0,2);
   currency1 = StringSubstr( Symbol(),0,6);
   if (ReverseDataFromFile)reverse=true;
   
   if(StringLen(FileNamePruductCode )>1) currency = FileNamePruductCode;
   else if(currency=="6E" || currency1=="EURUSD") currency = "EC";
   else if(currency =="6B" || currency1=="GBPUSD")currency = "BP";
   else if(currency=="6J") currency ="JY";
   else if(currency == "6A" || currency1 == "AUDUSD") currency ="AD";
   else if(currency=="GC" || currency1=="XAUUSD") currency = "GC";
   else if(currency=="SI" || currency1=="XAGUSD") currency = "SI";
   else if(currency=="CL") currency = "CL";
   else if(currency == "6C") currency ="CD";
   else if(currency =="ES" || currency1 =="S&P_50") currency = "ES";
   else if (currency1=="USDJPY")
   {
      currency = "JY";
      reverse = true;
      correction = 100;
   }
   else if (currency1 =="USDCAD")
   {
      currency = "CD";
      reverse= true;
   }
   else
   {
      Alert("Product not recognized.");
      return(0);
   }
   
   if(currency == "JY" && reverse) correction = 100;
   
   Print ("symbol_code is "+currency);
//----
   string filename;
   int handle, j, m;
   for (j=-1;j<NumberOfDaysBackToShow;j++)
   {
      m=iTime(Symbol(),PERIOD_D1,1+j);
      //Print("j = "+j+" time = "+m);
      curdate=time_to_string(TimeDay(m));
      curmonth=time_to_string(TimeMonth(m));
      curyear=TimeYear(m);
      nextyear = curyear;
      nextmonth = time_to_string(TimeMonth(m)+1);
      if(nextmonth == 13)
      {
         nextmonth = "01";
         nextyear = curyear + 1;
      }
      curyear=StringSubstr(curyear,2,2);
      nextyear=StringSubstr(nextyear,2,2);

//---- loading file
      filename = "/evolution-options/ol-"+curyear+curmonth+curdate+"-"+currency+"-"+curyear+curmonth+".csv";
      Print ("---> Filename "+filename);
      handle=FileOpen(filename, FILE_CSV|FILE_READ,",");
      
      //current month file opening problem
      if(handle<0)    
      {
         Print("No such file "+filename+" , trying next month contract period");
         filename = "/evolution-options/ol-"+curyear+curmonth+curdate+"-"+currency+"-"+nextyear+nextmonth+".csv";
         handle=FileOpen(filename, FILE_CSV|FILE_READ,",");
         Print (filename);
         //next month file opening problem
         if(handle<0)
         {
            Print("No such file "+filename);
            continue;
         }
      }
      if (handle>0)
      {
         int i=0;
         while ( !FileIsEnding(handle))
         {
            varray[i] = FileReadString(handle);
            if( i > 0 )
            {
               varray_[i] = StrToDouble( varray[i]);
               if(reverse && varray_[i] > 0) varray_[i] = correction /varray_[i];
               
               varray_[i] +=  LevelsVerticalShift;
            }
            i++;
         }
         FileClose( handle );
      }
      
      Print ("Go for it "+varray[0]);
      if(varray[0]=="")return(0);
//---------------------------------------------------------------

      if (varray_[1]<varray_[2])
      {
         KeyZoneColor=KeyZonePositiveColor;
         arrowcode=241;
      }
      else
      {
         KeyZoneColor=KeyZoneNegativeColor;
         arrowcode=242;
      }
         
      if (ShowKeyZone)
        drawArea("keyzone-", j , varray_[1], varray_[2], KeyZoneColor,0,0,FirstLevelWidth);
      
      if (ShowMajorLevels)
      {
        drawLine("major1-", "nothing" , j , varray_[3], MajorLevelsColor,0,0,FirstLevelWidth);
        drawLine("major2-", "nothing" , j , varray_[4], MajorLevelsColor,0,0,FirstLevelWidth);
      }
      if (ShowMajorCALLLevels)
      {
        drawLine("call1-", "nothing" , j , varray_[5], MajorCALLColor,MajorCALLStyle,0,FirstLevelWidth);
        drawLine("call2-", "nothing" , j , varray_[6], MajorCALLColor,MajorCALLStyle,0,FirstLevelWidth);
        drawLine("call3-", "nothing" , j , varray_[7], MajorCALLColor,MajorCALLStyle,0,FirstLevelWidth);
      }
      if (ShowMajorPUTLevels)
      {
        drawLine("put1-", "nothing" , j , varray_[8], MajorPUTColor,MajorPUTStyle,0,FirstLevelWidth);
        drawLine("put2-", "nothing" , j , varray_[9], MajorPUTColor,MajorPUTStyle,0,FirstLevelWidth);
        drawLine("put3-", "nothing" , j , varray_[10], MajorPUTColor,MajorPUTStyle,0,FirstLevelWidth);
      }

   }
//----
   return(0);
}
  
int deinit()
{
   for (int k = -1; k < NumberOfDaysBackToShow; k++)
   {   
      ObjectDelete("keyzone-"+k);
      ObjectDelete("keyzone-"+k+"arrow");
      ObjectDelete("major1-"+k);
      ObjectDelete("major2-"+k);
      ObjectDelete("call1-"+k);
      ObjectDelete("call2-"+k);
      ObjectDelete("call3-"+k);
      ObjectDelete("put1-"+k);
      ObjectDelete("put2-"+k);
      ObjectDelete("put3-"+k);
   }
   return(0);
}

int start()
{
   return(0);
}

void drawLine(string name, string dummy, int j, double price1, color col, int style, bool rayflag, int width)
{  
   name = name + j;
   int time1, time2;
   bar_to_time(j , time1, time2);

   if (ObjectFind(name) != 0) ObjectDelete(name);
  
   ObjectCreate(name, OBJ_TREND, 0, time1, price1, time2, price1);
	ObjectSet(name, OBJPROP_COLOR, col);
	ObjectSet(name, OBJPROP_BACK, false);
	ObjectSet(name, OBJPROP_STYLE,style);
   ObjectSet(name, OBJPROP_RAY, rayflag);
   ObjectSet(name, OBJPROP_WIDTH, width);
           
}

void drawArea(string name, int j, double price1, double price2, color col, int style, bool rayflag, int width)
{  
   name = name + j;
   int time1, time2;
   bar_to_time(j , time1, time2);
   
   if (ObjectFind(name) != 0) ObjectDelete(name);
   
   ObjectCreate(name, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
	ObjectSet(name, OBJPROP_COLOR, col);
	ObjectSet(name, OBJPROP_BACK, true);
	ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSetText(name,"price2="+price2,10);
   
   ObjectCreate(name+"arrow",OBJ_ARROW,0,time1+30,price1);
   ObjectSet(name+"arrow",OBJPROP_ARROWCODE,arrowcode);
   ObjectSet(name+"arrow",OBJPROP_COLOR,KeyZoneArrowColor);
}

void bar_to_time(int bar_shift, int &time1, int &time2)
{
   if(bar_shift < 0) time1 = iTime(Symbol(),PERIOD_D1,1 + bar_shift) + PERIOD_D1 * 60;
   else time1 = iTime(Symbol(), PERIOD_D1, bar_shift);
   
   time2 = time1 + PERIOD_D1 * 60;
}