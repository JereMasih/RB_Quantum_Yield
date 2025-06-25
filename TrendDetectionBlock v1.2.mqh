
//+------------------------------------------------------------------+
//| TrendDetectionBlock.mqh v1.1                                     |
//| * Agrega export AllowCounterTrend flag (usado por EntryBlock)    |
//+------------------------------------------------------------------+
#property copyright "R&B Quantum‑Yield"
#property version   "1.1"

//--- Parámetros de entrada
input ENUM_TIMEFRAMES WeightTF = PERIOD_H1;
input int  FastPeriod         = 50;
input int  SlowPeriod         = 200;

//--- Timeframes analizados
ENUM_TIMEFRAMES timeframes[] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_H1,PERIOD_H4,PERIOD_D1};

//--- Handles EMA
int fastEMAHandles[6];
int slowEMAHandles[6];

//+------------------------------------------------------------------+
//| Inicialización                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   for(int i=0;i<ArraySize(timeframes);i++)
     {
      fastEMAHandles[i]=iMA(_Symbol,timeframes[i],FastPeriod,0,MODE_EMA,PRICE_CLOSE);
      slowEMAHandles[i]=iMA(_Symbol,timeframes[i],SlowPeriod,0,MODE_EMA,PRICE_CLOSE);
      if(fastEMAHandles[i]==INVALID_HANDLE || slowEMAHandles[i]==INVALID_HANDLE)
        {
         Print("❌ Error al inicializar EMA en ",EnumToString(timeframes[i]));
         return(INIT_FAILED);
        }
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Devuelve el estado de tendencia                                  |
//|  1 = alcista, ‑1 = bajista, 0 = neutro                           |
//+------------------------------------------------------------------+
int GetTrendState()
  {
   int bullish=0,bearish=0;
   bool weightBull=false,weightBear=false;
   double fastBuf[1],slowBuf[1];
   for(int i=0;i<ArraySize(timeframes);i++)
     {
      if(CopyBuffer(fastEMAHandles[i],0,0,1,fastBuf)<=0 ||
         CopyBuffer(slowEMAHandles[i],0,0,1,slowBuf)<=0) continue;
      if(fastBuf[0]>slowBuf[0])
        {
         bullish++;
         if(timeframes[i]==WeightTF) weightBull=true;
        }
      else if(fastBuf[0]<slowBuf[0])
        {
         bearish++;
         if(timeframes[i]==WeightTF) weightBear=true;
        }
     }
   if(bullish>=3 && weightBull)  return 1;
   if(bearish>=3 && weightBear)  return -1;
   return 0;
  }
//+------------------------------------------------------------------+
