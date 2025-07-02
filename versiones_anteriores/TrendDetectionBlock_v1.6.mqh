//+------------------------------------------------------------------+
//| RBQY – Bloque de Detección de Tendencia Multitemporal           |
//+------------------------------------------------------------------+
#ifndef INC_RBQY_TREND_DETECTION
#define INC_RBQY_TREND_DETECTION
#property strict

//--- INPUTS
input ENUM_TIMEFRAMES   WeightTF   =  PERIOD_H1;
input int               FastPeriod =  50;
input int               SlowPeriod = 200;

//--- Arrays y Handles
#define TF_CNT 6
static const ENUM_TIMEFRAMES TF[TF_CNT] =
        {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_H1,PERIOD_H4,PERIOD_D1};
static int    hFast[TF_CNT],hSlow[TF_CNT];
static double bufFast[], bufSlow[];

//--- Estado Global
int TrendDir = 0;

//--- Inicialización
bool TrendInit()
{
   for(int i=0;i<TF_CNT;i++)
     {
      hFast[i]=iMA(_Symbol,TF[i],FastPeriod,0,MODE_EMA,PRICE_CLOSE);
      hSlow[i]=iMA(_Symbol,TF[i],SlowPeriod,0,MODE_EMA,PRICE_CLOSE);
      if(hFast[i]==INVALID_HANDLE || hSlow[i]==INVALID_HANDLE)
        { PrintFormat("❌ Handle inválido en %s",EnumToString(TF[i])); return(false); }
     }
   ArrayResize(bufFast,1);  ArrayResize(bufSlow,1);
   return(true);
}

//--- Liberación
void TrendDeinit(){ for(int i=0;i<TF_CNT;i++){ IndicatorRelease(hFast[i]); IndicatorRelease(hSlow[i]); } }

//--- Update y cálculo de tendencia
int TrendUpdate()
{
   int bulls=0,bears=0; bool wBull=false,wBear=false;
   for(int i=0;i<TF_CNT;i++)
     {
      if(CopyBuffer(hFast[i],0,0,1,bufFast)<=0 || CopyBuffer(hSlow[i],0,0,1,bufSlow)<=0)
         continue;
      if(bufFast[0]>bufSlow[0]) { bulls++; if(TF[i]==WeightTF) wBull=true; }
      else if(bufFast[0]<bufSlow[0]){ bears++; if(TF[i]==WeightTF) wBear=true; }
     }
   if(bulls>=3 && wBull)   TrendDir =  1;
   else if(bears>=3 && wBear) TrendDir = -1;
   else TrendDir = 0;
   return(TrendDir);
}

//--- HUD único (solo aquí)
void DrawHUD()
{
   string dirStr = (TrendDir==1)?  "📈 Alcista":
                   (TrendDir==-1)? "📉 Bajista":"➖ Lateral";
   Comment(StringFormat("Trend %s  |  WeightTF %s\nBalance: %.2f  |  Equity: %.2f",
           dirStr,EnumToString(WeightTF),
           AccountInfoDouble(ACCOUNT_BALANCE),
           AccountInfoDouble(ACCOUNT_EQUITY)));
}
#endif //INC_RBQY_TREND_DETECTION
