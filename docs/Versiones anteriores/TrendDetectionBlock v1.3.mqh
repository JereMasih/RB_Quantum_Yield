//  TrendDetectionBlock v1.3.mqh
//———————————————————————————————————————————————————————
#ifndef  __TREND_DETECTION_BLOCK_V13_MQH__
#define  __TREND_DETECTION_BLOCK_V13_MQH__

#property copyright "Jeremías Abdelmasih 2025"
#property version   "1.3"
#property strict

//--- inputs ------------------------------------------------------------------
input ENUM_TIMEFRAMES TrendTF      = PERIOD_M15; // TF donde se mide la tendencia
input int            FastMAPeriod  = 50;         // media rápida
input int            SlowMAPeriod  = 200;        // media lenta

//--- variables internas ------------------------------------------------------
int   fastMA = INVALID_HANDLE;
int   slowMA = INVALID_HANDLE;
int   TrendDir = 0;               //  1 = alcista, -1 = bajista, 0 = indeterm.


//--- interfaz pública ---------------------------------------------------------
void TrendInit()
{
   // crea / recrea los handles
   if(fastMA!=INVALID_HANDLE)  IndicatorRelease(fastMA);
   if(slowMA!=INVALID_HANDLE)  IndicatorRelease(slowMA);

   fastMA = iMA(_Symbol,TrendTF,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   slowMA = iMA(_Symbol,TrendTF,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE);
}

void TrendDeinit()
{
   if(fastMA!=INVALID_HANDLE)  IndicatorRelease(fastMA);
   if(slowMA!=INVALID_HANDLE)  IndicatorRelease(slowMA);
   fastMA = slowMA = INVALID_HANDLE;
   TrendDir = 0;
}

void TrendUpdate()
{
   if(fastMA==INVALID_HANDLE || slowMA==INVALID_HANDLE)
      return;                       // aún no inicializado

   double f[2], s[2];
   if(CopyBuffer(fastMA,0,0,2,f)!=2) return;
   if(CopyBuffer(slowMA,0,0,2,s)!=2) return;

   // estado actual
   if(f[0] >  s[0]) TrendDir =  1;
   if(f[0] <  s[0]) TrendDir = -1;

   // cruces (opcional: para disparar eventos sólo en el cruce)
   // if(f[0]>s[0] && f[1]<=s[1])  TrendDir =  1;   // cruce alcista
   // if(f[0]<s[0] && f[1]>=s[1])  TrendDir = -1;   // cruce bajista
}

//  lo dejamos accesible a otros módulos
//  (p. ej.  if(TrendDir==1) …)
#endif   // __TREND_DETECTION_BLOCK_V13_MQH__