
//+------------------------------------------------------------------+
//| R&B - Quantum Yield Bot | v1.1 | 2025-07-02                      |
//+------------------------------------------------------------------+
#property copyright "© 2025 Jere Masih"
#property version   "1.1"
#property strict

#include <Trade\Trade.mqh>
#include <PositionInfo.mqh>

//--- Inputs
input int    FastEMAPeriod        = 50;         // EMA Rápida (periodos)
input int    SlowEMAPeriod        = 200;        // EMA Lenta (periodos)
input int    MinFramesAligned     = 3;          // Mín.TF alineados (2-6)
input ENUM_TIMEFRAMES WeightTF    = PERIOD_H1; // Marco de Peso
input ENUM_TIMEFRAMES ExecTF      = PERIOD_M15; // Marco de Ejecución

enum RiskType {MONEY, PERCENT};
input RiskType RiskMode           = MONEY;      // Modo de Riesgo: MONEY o PERCENT
input double SL_Money             = 100.0;      // SL $/posición
input double TP_Money             = 150.0;      // TP $/posición
input double SL_Pct               = 1.0;        // SL % balance
input double TP_Pct               = 1.5;        // TP % balance

input bool   UseTrail             = true;       // Usar Trailing Stop
input double StartTrailMoney      = 1000.0;     // Trail Inicio $
input double TrailStepMoney       = 500.0;      // Trail Paso $
enum TrailGroup {ALL, LONG_SHORT};
input TrailGroup TrailGroupMode   = ALL;        // Modo Trail Grupo

input bool   AllowCounterTrend    = false;      // Permitir ContraTend.
input int    MaxSpreadPoints      = 30;         // Spread máx (pts)
input int    MaxSlippagePoints    = 5;          // Slippage máx (pts)
input int    MaxCandleRangePoints = 500;        // Vela máx (pts)
input int    PanelFontSize        = 14;         // Tamaño fuente panel

//--- Global variables
double onePoint;
double tickValue;
int handlesFast[6];
int handlesSlow[6];
ENUM_TIMEFRAMES tfs[6] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   onePoint  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   // Create EMA handles for each TF
   for(int i=0; i<6; i++)
     {
      handlesFast[i] = iMA(_Symbol, tfs[i], FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if(handlesFast[i]==INVALID_HANDLE) return(INIT_FAILED);
      handlesSlow[i] = iMA(_Symbol, tfs[i], SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if(handlesSlow[i]==INVALID_HANDLE) return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Release EMA handles
   for(int i=0; i<6; i++)
     {
      if(handlesFast[i]!=INVALID_HANDLE)  IndicatorRelease(handlesFast[i]);
      if(handlesSlow[i]!=INVALID_HANDLE)  IndicatorRelease(handlesSlow[i]);
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime lastTime=0;
   datetime t = iTime(_Symbol, _Period, 0);
   if(t==lastTime) return; // wait new bar
   lastTime = t;

   // Filter by spread
   if((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpreadPoints) return;

   int trend = GetTrendState();
   if(trend==0) return;

   if(!ConfirmCandle(trend)) return;

   if(!AllowCounterTrend && HasOppositePosition(trend)) return;

   ExecuteOrder(trend);

   if(UseTrail) ApplyTrailing();
  }

//+------------------------------------------------------------------+
//| Get global trend state                                           |
//+------------------------------------------------------------------+
int GetTrendState()
  {
   int up=0, down=0;
   bool weightUp=false, weightDown=false;
   double fastBuf[1], slowBuf[1];
   for(int i=0; i<6; i++)
     {
      if(CopyBuffer(handlesFast[i], 0, 1, fastBuf)<=0) continue;
      if(CopyBuffer(handlesSlow[i], 0, 1, slowBuf)<=0) continue;
      if(fastBuf[0] > slowBuf[0])
        {
         up++;
         if(tfs[i]==WeightTF) weightUp=true;
        }
      else if(fastBuf[0] < slowBuf[0])
        {
         down++;
         if(tfs[i]==WeightTF) weightDown=true;
        }
     }
   if(up>=MinFramesAligned && weightUp) return(1);
   if(down>=MinFramesAligned && weightDown) return(-1);
   return(0);
  }

//+------------------------------------------------------------------+
//| Confirm candle in ExecTF                                         |
//+------------------------------------------------------------------+
bool ConfirmCandle(int trend)
  {
   double openC  = iOpen(_Symbol, ExecTF, 1);
   double closeC = iClose(_Symbol, ExecTF, 1);
   int rangePts = (int)MathAbs((closeC-openC)/onePoint);
   if(rangePts > MaxCandleRangePoints) return(false);
   if(trend==1 && closeC>openC) return(true);
   if(trend==-1 && closeC<openC) return(true);
   return(false);
  }

//+------------------------------------------------------------------+
//| Check opposite existing position                                 |
//+------------------------------------------------------------------+
bool HasOppositePosition(int trend)
  {
   for(int i=0; i<PositionsTotal(); i++)
     {
      if(PositionSelectByIndex(i))
        {
         if(PositionGetString(POSITION_SYMBOL)==_Symbol)
           {
            int type = (int)PositionGetInteger(POSITION_TYPE);
            if((trend==1 && type==POSITION_TYPE_SELL) ||
               (trend==-1 && type==POSITION_TYPE_BUY))
               return true;
           }
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Execute one order                                                |
//+------------------------------------------------------------------+
void ExecuteOrder(int trend)
  {
   double lot = 0.1;
   double price = (trend==1 ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID));
   double slPts, tpPts;
   if(RiskMode==MONEY)
     {
      slPts = SL_Money  / tickValue;
      tpPts = TP_Money  / tickValue;
     }
   else
     {
      double bal = AccountInfoDouble(ACCOUNT_BALANCE);
      slPts = (SL_Pct/100.0 * bal) / tickValue;
      tpPts = (TP_Pct/100.0 * bal) / tickValue;
     }
   double sl = (trend==1 ? price - slPts*onePoint : price + slPts*onePoint);
   double tp = (trend==1 ? price + tpPts*onePoint : price - tpPts*onePoint);
<|...|>