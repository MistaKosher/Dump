#property copyright "Scriptong"
#property link      "http://advancetools.net"
#property description "����������� ���� ����� � �������� ��� �������� ����� ������.\n�������� �������� �� ����� AdvanceTools.net � ������� \"������� ������.\""
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrLime
#property indicator_color2 clrRed

#property indicator_width1 2
#property indicator_width2 2

struct TickStruct                                                                                  // ��������� ��� ������ ������ �� ����� ����
{
   datetime time;
   double   bid;
   double   ask;   
};

enum ENUM_TICKSPOINTS
{
    TICKS,                                                                                         // ����
    POINTS                                                                                         // ������
};


// ����������� ��������� ����������
input ENUM_TICKSPOINTS  i_useTicksAtPrice       = TICKS;                                           // ������ � ����� ��� � �������
input int               i_indBarsCount          = 50000;                                           // ���������� ����� ��� �����������

// ������������ ������
double g_bullBuffer[];
double g_bearBuffer[];
double g_bullPrevalenceBuffer[];
double g_bearPrevalenceBuffer[];


// ������ ���������� ���������� ����������
bool g_activate,                                                                                   // ������� �������� ������������� ����������
     g_init;                                                                                       // ���������� ��� ������������� ����������� ���������� ������ ������� � ������ ����������..
                                                                                                   // ..��������� �������������
                                                                                                   
double g_tickSize;

TickStruct        g_ticks[];                                                                       // ������ ��� �������� �����, ����������� ����� ������ ������ ����������                    

//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
   g_activate = false;                                                                             // ��������� �� ���������������
   g_init = true;
   
   if (!IsTuningParametersCorrect())                                                               // ������� ��������� �������� ����������� ���������� - ������� ��������� �������������
      return (INIT_FAILED);                                 
           
   if (!BuffersBind())                             
      return (INIT_FAILED);                                 
       
   if (!IsLoadTempTicks())                                                                         // �������� ������ � �����, ����������� �� ���������� ������ ������ ����������   
      return INIT_FAILED;
           
   g_activate = true;                                                                              // ��������� ������� ���������������
   return(INIT_SUCCEEDED);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ������������ ����������� ����������                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
{
   string name = WindowExpertName();

   int period = Period();
   if (period == 0)
   {
      Alert(name, ": ��������� ������ ��������� - ������ 0 �����. ��������� ��������.");
      return (false);
   }
   
   g_tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   if (g_tickSize == 0)
   {
      Alert(name, ": ��������� ������ ��������� - �������� ���� ������ ���� ����� ����. ��������� ��������.");
      return (false);
   }

   
   return (true);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������� ���������� � ���������                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool BuffersBind()
{
   string name = WindowExpertName();
   IndicatorBuffers(4);

   if (
       !SetIndexBuffer(0, g_bullPrevalenceBuffer)        ||
       !SetIndexBuffer(1, g_bearPrevalenceBuffer)        ||
       !SetIndexBuffer(2, g_bullBuffer)                  ||
       !SetIndexBuffer(3, g_bearBuffer)                 
      )
   {
      Alert(name, ": ������ ���������� �������� � �������� ����������. ������ �", GetLastError());
      return (false);
   }

   for (int i = 0; i < 4; i++)   
   {
      if (i > 1)
         SetIndexStyle(i, DRAW_NONE);
      else      
         SetIndexStyle(i, DRAW_HISTOGRAM);
      SetIndexEmptyValue(i, 0);
   }
      
   SetIndexLabel(0, "Bull Prevalence");
   SetIndexLabel(1, "Bear Prevalence");
   
   return (true);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � �����, ����������� � ������� ���������� ������� ������ ���������                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsLoadTempTicks()
{
   // �������� ����� ������� �������
   int hTicksFile = FileOpen(Symbol() + "temp.tks", FILE_BIN | FILE_READ | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if (hTicksFile < 1)
      return true;
      
   // ������������� ������ ��� ������� g_ticks
   int recSize = (int)(FileSize(hTicksFile) / sizeof(TickStruct));   
   if (ArrayResize(g_ticks, recSize, 1000) < 0)
   {
      Alert(WindowExpertName(), ": �� ������� ������������ ������ ��� �������� ������ �� ���������� ����� �����. ��������� ��������.");
      FileClose(hTicksFile);
      return false;
   }
   
   // ������ �����
   int i = 0;
   while (i < recSize)
   {
      if (FileReadStruct(hTicksFile, g_ticks[i]) == 0)
      {
         Alert(WindowExpertName(), ": ������ ������ ������ �� ���������� �����. ��������� ��������.");
         return false;
      }
      
      i++;
   }

   FileClose(hTicksFile);
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (!IsSavedFile())                                                                             // ���� �� ���� �� ������������ ����������� �� �������� ������, �� �� �������� ������� ���������
      SaveTempTicks();                                                                             // ���������� ������ � �����, ����������� �� ������� ������ ������ ����������   
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ������� ���������� ������ ������ �����������                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSavedFile()
{
   // ��������� ������� ����������� ���������� ����������� ����
   int lastTickIndex = ArraySize(g_ticks) - 1;
   if (lastTickIndex < 0)                                                                          // �� ���� ��� �� ��� �������. ������ ������ �� ���������
      return true;

   // �������� ����� ������� �������
   int hTicksFile = FileOpen(Symbol() + "temp.tks", FILE_BIN | FILE_READ | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if (hTicksFile < 1)
      return false;
   
   // ����������� � ��������� ������ � �����
   if (!FileSeek(hTicksFile, -sizeof(TickStruct), SEEK_END))
   {
      FileClose(hTicksFile);
      return false;
   }
   
   // ������ ��������� ������ � �������� �����
   TickStruct tick;
   uint readBytes = FileReadStruct(hTicksFile, tick);
   FileClose(hTicksFile);
   if (readBytes == 0)
      return false;
  
   // ��������� ���� ����, ����������� � �����, � ���� ���������� ������������ ����
   return tick.time >= g_ticks[lastTickIndex].time;                                                // ����/����� ���������� ����������� � ����� ���� ������ ��� ����� ����/�������..
                                                                                                   // ..������������������� ����. ������, ���� ��� �������, � ��������� ������ �� ���������
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������ � �����, ����������� �� ������� ������� ������ ���������                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SaveTempTicks()
{
   // �������� ����� ������� �������
   int hTicksFile = FileOpen(Symbol() + "temp.tks", FILE_BIN | FILE_READ | FILE_WRITE | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if (hTicksFile < 1)
      return;
   
   // ������ �����
   int total = ArraySize(g_ticks), i = 0;
   while (i < total)
   {
      if (FileWriteStruct(hTicksFile, g_ticks[i]) == 0)
      {
         Print("������ ���������� ������ �� ��������� ����...");
         return;
      }
      
      i++;
   }

   FileClose(hTicksFile);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� �������� � �������� ������ ����                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double NP(double value)
{
   if (g_tickSize == 0)
      return (0);
      
   return (MathRound(value / g_tickSize) * g_tickSize);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������������� ���� ������������ �������                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void BuffersInitializeAll()
{
   ArrayInitialize(g_bullBuffer, 0);     
   ArrayInitialize(g_bearBuffer, 0);     
   ArrayInitialize(g_bullPrevalenceBuffer, 0);     
   ArrayInitialize(g_bearPrevalenceBuffer, 0);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������� ����, � �������� ���������� ����������� ����������                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int& total, const int ratesTotal, const int prevCalculated)
{
   // ����������� ������� ���� �������, �� ������� ����� �������� ���������� �������� ����������
   total = ratesTotal - 1;                                                                         
                                                   
   // � ����� �������� ���������� �� ����� ���������� �� ���� �������?
   if (i_indBarsCount > 0 && i_indBarsCount < total)
      total = MathMin(i_indBarsCount, total);                      
                                                   
   // ������ ����������� ���������� ��� ��������� �������� ������, �. �. �� ���������� ���� ����� ���� �� �� ���� ��� ������, ��� ��� ���������� �������� �������, � �� ��� ��� ����� ����� ������
   if (prevCalculated < ratesTotal - 1)                     
   {       
      BuffersInitializeAll();
      return (total);
   }
   
   // ���������� �������� �������. ���������� ����� �������� ���� ���������� �� ���������� ����� ����������� ���� �� ������, ��� �� ���� ���
   return (MathMin(ratesTotal - prevCalculated, total));                            
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ �� ������ �����, ��� ������?                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsFirstMoreThanSecond(double first, double second)
{
   return (first - second > Point / 10);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����� �� ������������ ��������?                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsValuesEquals(double first, double second)
{
   return (MathAbs(first - second) < Point / 10);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ ���� �� �����                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsReadTimeAndBidAskOfTick(int hTicksFile, TickStruct &tick)
{
   if (FileIsEnding(hTicksFile))
   {
      FileClose(hTicksFile);
      return false;
   }
   
   uint bytesCnt = FileReadStruct(hTicksFile, tick);
   if (bytesCnt == sizeof(TickStruct))
      return true;
   
   FileClose(hTicksFile);
   return false;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ��������� ������ ����                                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessOneTick(int index, TickStruct &curTick, TickStruct &lastTick)
{
   // ��������� ���� ����
   if (IsFirstMoreThanSecond(curTick.bid, lastTick.bid))
   {
      if (i_useTicksAtPrice == POINTS)
         g_bullBuffer[index] += MathRound((curTick.bid - lastTick.bid) / g_tickSize);
      else
         g_bullBuffer[index]++;
   }

   // ���������� ������� ����
   if (IsFirstMoreThanSecond(lastTick.bid, curTick.bid))
   {
      if (i_useTicksAtPrice == POINTS)
         g_bearBuffer[index] -= MathRound((lastTick.bid - curTick.bid) / g_tickSize);
      else
         g_bearBuffer[index]--;
   }
      
   lastTick = curTick;
    
   // ����� ����� ���� ������, ��� ����� ������� ����    
   if (g_bullBuffer[index] >= MathAbs(g_bearBuffer[index]))
   {
      g_bearPrevalenceBuffer[index] = 0;
      g_bullPrevalenceBuffer[index] = g_bullBuffer[index] + g_bearBuffer[index];
      return;
   }

   // ����� ������� ���� ������, ��� ����� ����� ����    
   if (MathAbs(g_bearBuffer[index]) > g_bullBuffer[index])
   {
      g_bullPrevalenceBuffer[index] = 0;
      g_bearPrevalenceBuffer[index] = g_bearBuffer[index] + g_bullBuffer[index];
   }
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� �������������� ���� ���������� ����                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTickBelongToBar(const TickStruct &tick, const int barIndex)
{
   if (barIndex > 0)
      return (tick.time >= Time[barIndex] && tick.time < Time[barIndex - 1]);
      
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������ �� ������������ �����, ������� � ����������                                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessOldCandles(int limit, TickStruct &lastTick)
{
   // �������� ����� ������� �������
   int hTicksFile = FileOpen(Symbol() + ".tks", FILE_BIN | FILE_READ | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if (hTicksFile < 1)
      return;
      
   // ����� ������� ����, �������������� ���� limit ��� ������ ����� �������� ����
   TickStruct tick = {0, 0, 0};
   while (!IsStopped())
   {
      if (!IsReadTimeAndBidAskOfTick(hTicksFile, tick))
         return;
         
      if (tick.time >= Time[limit])
         break;
   }
   lastTick = tick;
   int barIndex = iBarShift(NULL, 0, tick.time);
   
   // ����������� ������
   while (barIndex >= 0)
   {
      if (!IsReadTimeAndBidAskOfTick(hTicksFile, tick))
         return;
      
      if (!IsTickBelongToBar(tick, barIndex))
         barIndex = iBarShift(NULL, 0, tick.time);
         
      ProcessOneTick(barIndex, tick, lastTick);
   }
   
   FileClose(hTicksFile);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� � ���� ����������� ���������� ������, ����������� ����� �� ����� ������ ����������                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessBufferTicks(int limit, TickStruct &lastTick)
{
   int total = ArraySize(g_ticks), i = 0;
   datetime limitTime = Time[limit];
   
   if (lastTick.time > 0)
      limitTime = lastTick.time + 1;

   // ����� ������ � ������, ����� ������� ������ ��� ����� ������� �������� ���� limit, ��� ������, ��� ������ � ��������� ����������� �� ����� ����
   while (i < total && g_ticks[i].time < limitTime)
      i++;
      
   if (i >= total)                                                                              // ��� ������ ��� �����������
      return;
      
   // ����������� ������ � ������ ����������
   while (i < total)
   {
      int barIndex = iBarShift(NULL, 0, g_ticks[i].time);
      ProcessOneTick(barIndex, g_ticks[i], lastTick);
      i++;  
   }
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � ���� � ������ g_ticks                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsUpdateTicksArray(TickStruct &tick)
{
   int total = ArraySize(g_ticks);
   if (ArrayResize(g_ticks, total + 1, 100) < 0)
   {
      Alert(WindowExpertName(), ": ���������� �� ������� ������ ��� ���������� ������ �� ��������� ����.");
      return false;
   }
   
   g_ticks[total] = tick;
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ���� � ����� ����� �����                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool AddNewTick(TickStruct &tick)
{
   tick.time = TimeCurrent();
   tick.bid = Bid;
   tick.ask = Ask;
   
   // ���������� ������ ���� � ������ �������� �����   
   if (IsUpdateTicksArray(tick))
      return true;

   g_activate = false;
   return false;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������ ����������                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowIndicatorData(int limit, int total)
{
   static TickStruct lastTick = {0, 0, 0};

   if (limit > 0)
   {
      if (limit > 1)
      {
         lastTick.time = 0;
         lastTick.bid = 0;
         lastTick.ask = 0;
      }
      ProcessOldCandles(limit, lastTick);
      ProcessBufferTicks(limit, lastTick);
   }
         
   TickStruct tick = {0, 0, 0};
   if (!AddNewTick(tick))
      return;
      
   ProcessOneTick(0, tick, lastTick);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (!g_activate)                                                                                // ���� ��������� �� ������ �������������, �� �������� �� �� ������
      return rates_total;                                 
                                                   
   int total;   
   int limit = GetRecalcIndex(total, rates_total, prev_calculated);                                // � ������ ���� �������� ����������?

   ShowIndicatorData(limit, total);                                                                // ����������� ������ ����������
   
   return(rates_total);
}
