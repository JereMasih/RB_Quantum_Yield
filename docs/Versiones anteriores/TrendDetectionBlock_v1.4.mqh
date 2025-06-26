/************************  R&B Quantum-Yield  *************************
*  Bloque 1 – Detección de Tendencia Multitemporal (v1.4)
*  Autor  : Jeremías Abdelmasih – 2025
*********************************************************************/
#ifndef  __TREND_DETECTION_BLOCK_V14_MQH__
#define  __TREND_DETECTION_BLOCK_V14_MQH__

#include <Trade\SymbolInfo.mqh>         // sólo para EnumToString

//=== INPUTS =========================================================
input ENUM_TIMEFRAMES InpWeightTF     = PERIOD_H1;  // Marco «de peso»
input int             InpFastPeriod   = 50;         // EMA rápida
input int             InpSlowPeriod   = 200;        // EMA lenta
input int             InpMinMatches   = 3;          // Mín. coincidencias
input bool            InpShowPanel    = true;       // Mostrar panel info
//====================================================================

//— variables públicas ————————————————————————————————————————
int  TrendDir        = 0;             //  1 = alcista, –1 = bajista, 0 = neutro
int  TrendMatchesUp  = 0;
int  TrendMatchesDn  = 0;

//— internas ————————————————————————————————————————————————
static const ENUM_TIMEFRAMES TFs[6] =
   {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_H1,PERIOD_H4,PERIOD_D1};

int    fastH[6], slowH[6];
double fastBuf[1], slowBuf[1];

//------------------------------------------------------------------//
//  INIT                                                             //
bool TrendInit()
{
   for(int i=0;i<6;i++)
   {
      fastH[i]=iMA(_Symbol,TFs[i],InpFastPeriod,0,MODE_EMA,PRICE_CLOSE);
      slowH[i]=iMA(_Symbol,TFs[i],InpSlowPeriod,0,MODE_EMA,PRICE_CLOSE);
      if(fastH[i]==INVALID_HANDLE || slowH[i]==INVALID_HANDLE)
      {
         Print(__FUNCTION__,": error creando handles en ",EnumToString(TFs[i]));
         return(false);
      }
   }
   return(true);
}
//------------------------------------------------------------------//
//  DEINIT                                                           //
void TrendDeinit()
{
   for(int i=0;i<6;i++)
   {
      if(fastH[i]!=INVALID_HANDLE)  IndicatorRelease(fastH[i]);
      if(slowH[i]!=INVALID_HANDLE)  IndicatorRelease(slowH[i]);
   }
}
//------------------------------------------------------------------//
//  UPDATE (se llama en cada tick)                                   //
void TrendUpdate()
{
   TrendMatchesUp = TrendMatchesDn = 0;
   bool weightBull=false, weightBear=false;

   for(int i=0;i<6;i++)
   {
      if(CopyBuffer(fastH[i],0,0,1,fastBuf)<=0 ||
         CopyBuffer(slowH[i],0,0,1,slowBuf)<=0)
         continue;

      if(fastBuf[0] > slowBuf[0])        // alcista
      {
         if(TFs[i]==InpWeightTF) weightBull=true;
         TrendMatchesUp++;
      }
      else if(fastBuf[0] < slowBuf[0])   // bajista
      {
         if(TFs[i]==InpWeightTF) weightBear=true;
         TrendMatchesDn++;
      }
   }

   //— resultado final
   if(TrendMatchesUp>=InpMinMatches && weightBull)      TrendDir= 1;
   else if(TrendMatchesDn>=InpMinMatches && weightBear) TrendDir=-1;
   else                                                 TrendDir= 0;

   //— panel HUD
   if(InpShowPanel)
   {
      string state  = TrendDir== 1? "▲ Alcista":
                      TrendDir==-1? "▼ Bajista":"▪ Lateral";
      Comment("🟢  R&B QY – BLOQUE 1 (Trend)\n",
              "Peso TF      : ",EnumToString(InpWeightTF),"\n",
              "Coincidencias : ",TrendMatchesUp," ↑  /  ",TrendMatchesDn," ↓\n",
              "Tendencia    : ",state,"\n",
              "Precio Ask   : ",DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits));
   }
}

#endif //__TREND_DETECTION_BLOCK_V14_MQH__