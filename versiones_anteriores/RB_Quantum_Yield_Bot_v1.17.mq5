//+------------------------------------------------------------------+
//| R&B - Quantum Yield Bot | v1.17 | 2025-07-02                     |
//+------------------------------------------------------------------+
#property copyright "© 2025 Jere Masih"
#property version   "1.17"
#property strict

#include <Trade\Trade.mqh>

//--- Inputs
input int    FastEMAPeriod        = 50;
input int    SlowEMAPeriod        = 200;
input int    MinFramesAligned     = 3;
input ENUM_TIMEFRAMES WeightTF    = PERIOD_H1;
input ENUM_TIMEFRAMES ExecTF      = PERIOD_M15;
enum RiskType {MONEY, PERCENT};
input RiskType RiskMode           = MONEY;
input double SL_Money             = 300.0;
input double TP_Money             = 300.0;
input double SL_Pct               = 1.0;
input double TP_Pct               = 1.5;
input bool   UseTrail             = true;

//--- Trailing Stop Inputs (en dólares por trade)
input double TrailStartDollars = 10.0;  // "Trailing activa si la ganancia flotante de la posición supera este valor en USD"
input double TrailStepDollars  = 5.0;   // "Cada vez que la ganancia flotante de la posición sube este valor en USD, el SL avanza ese monto"

//--- Otros inputs
input bool   AllowCounterTrend    = false;
input int    MaxSpreadPoints      = 30;
input int    MaxSlippagePoints    = 5;
input int    MaxCandleRangePoints = 500;
input int    PanelFontSize        = 18;
input double TradeLotSize         = 0.1;
input int    TradesPerSignal      = 1;

//--- Timeframes a evaluar
ENUM_TIMEFRAMES timeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};
//--- Handles de EMA
int fastEMAHandles[6];
int slowEMAHandles[6];

double onePoint;
double tickValue;
CTrade trade;

//+------------------------------------------------------------------+
//| Inicialización                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   onePoint  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   for (int i = 0; i < ArraySize(timeframes); i++)
     {
      fastEMAHandles[i] = iMA(_Symbol, timeframes[i], FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
      slowEMAHandles[i] = iMA(_Symbol, timeframes[i], SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if (fastEMAHandles[i] == INVALID_HANDLE || slowEMAHandles[i] == INVALID_HANDLE)
        {
         Print("Error al crear los handles EMA en ", EnumToString(timeframes[i]));
         return(INIT_FAILED);
        }
     }
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   for(int i=0; i<ArraySize(timeframes); i++)
     {
      if(fastEMAHandles[i]!=INVALID_HANDLE)  IndicatorRelease(fastEMAHandles[i]);
      if(slowEMAHandles[i]!=INVALID_HANDLE)  IndicatorRelease(slowEMAHandles[i]);
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime lastTime=0;
   datetime t = iTime(_Symbol, _Period, 0);
   if(t==lastTime) return;
   lastTime = t;

   if((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpreadPoints) return;

   int trend = GetTrendState();
   if(trend==0) return;
   if(!ConfirmCandle(trend)) return;
   if(!AllowCounterTrend && HasOppositePosition(trend)) return;
   ExecuteOrder(trend);
   if(UseTrail) ApplyTrailingPerTradeDollars();

   // --- Panel visual robusto ---
   string info;
   info += "RB Quantum Yield v1.17\n";
   info += "Trend: " + ((trend==1) ? "ALCISTA" : (trend==-1 ? "BAJISTA" : "NEUTRAL")) + "\n";
   info += "Min TF alineados: " + IntegerToString(MinFramesAligned) + "\n";
   info += "Weight TF: " + EnumToString(WeightTF) + "\n";
   info += "Lot size: " + DoubleToString(TradeLotSize,2) + "\n";
   info += "Trades/Signal: " + IntegerToString(TradesPerSignal) + "\n";
   info += "Modo riesgo: " + (RiskMode==MONEY ? "MONEY" : "PERCENT") + "\n";
   info += "SL: " + DoubleToString(SL_Money,2) + " / " + DoubleToString(SL_Pct,2) + "\n";
   info += "TP: " + DoubleToString(TP_Money,2) + " / " + DoubleToString(TP_Pct,2) + "\n";
   info += "TrailStart: " + DoubleToString(TrailStartDollars,2) + " USD  Step: " + DoubleToString(TrailStepDollars,2) + " USD\n";
   info += "Trailing: Activa cuando cada posición tenga > " + DoubleToString(TrailStartDollars,2) + " USD de ganancia flotante y mueve el SL cada " + DoubleToString(TrailStepDollars,2) + " USD extra.";
   Comment(info);
  }

//+------------------------------------------------------------------+
//| Detección robusta de tendencia con logs en Journal               |
//+------------------------------------------------------------------+
int GetTrendState()
  {
   int bullishCount = 0;
   int bearishCount = 0;
   bool weightBullish = false;
   bool weightBearish = false;
   string trendLog = "DETALLE DE TF: ";

   for (int i = 0; i < ArraySize(timeframes); i++)
   {
      double fast[1], slow[1];
      int copiedFast = CopyBuffer(fastEMAHandles[i], 0, 0, 1, fast);
      int copiedSlow = CopyBuffer(slowEMAHandles[i], 0, 0, 1, slow);

      if (copiedFast != 1 || copiedSlow != 1)
      {
         trendLog += EnumToString(timeframes[i]) + ":SIN DATOS; ";
         continue;
      }

      if (fast[0] > slow[0])
      {
         bullishCount++;
         trendLog += EnumToString(timeframes[i]) + ":BULL; ";
         if (timeframes[i] == WeightTF) weightBullish = true;
      }
      else if (fast[0] < slow[0])
      {
         bearishCount++;
         trendLog += EnumToString(timeframes[i]) + ":BEAR; ";
         if (timeframes[i] == WeightTF) weightBearish = true;
      }
      else
      {
         trendLog += EnumToString(timeframes[i]) + ":NEUTRAL; ";
      }
   }

   Print("[TREND LOG]", trendLog, " Bulls: ", bullishCount, " Bears: ", bearishCount, " PesoBull: ", weightBullish, " PesoBear: ", weightBearish);

   if (bullishCount >= MinFramesAligned && weightBullish)
      return 1;
   else if (bearishCount >= MinFramesAligned && weightBearish)
      return -1;
   else
      return 0;
  }

//+------------------------------------------------------------------+
//| Confirmación de vela (sin cambios)                               |
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
//| Revisa si existe posición opuesta (sin cambios)                  |
//+------------------------------------------------------------------+
bool HasOppositePosition(int trend)
  {
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         string sym = PositionGetString(POSITION_SYMBOL);
         int type = (int)PositionGetInteger(POSITION_TYPE);
         if(sym==_Symbol)
           {
            if((trend==1 && type==POSITION_TYPE_SELL) ||
               (trend==-1 && type==POSITION_TYPE_BUY))
               return true;
           }
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Ejecución de órdenes con SL/TP calculado correctamente           |
//+------------------------------------------------------------------+
void ExecuteOrder(int trend)
  {
   double price = (trend==1 ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID));
   double slPts, tpPts;

   if(RiskMode==MONEY)
     {
      slPts = SL_Money / (TradeLotSize * tickValue);
      tpPts = TP_Money / (TradeLotSize * tickValue);
     }
   else
     {
      double bal = AccountInfoDouble(ACCOUNT_BALANCE);
      slPts = (SL_Pct/100.0 * bal) / (TradeLotSize * tickValue);
      tpPts = (TP_Pct/100.0 * bal) / (TradeLotSize * tickValue);
     }

   double sl = (trend==1 ? price - slPts*onePoint : price + slPts*onePoint);
   double tp = (trend==1 ? price + tpPts*onePoint : price - tpPts*onePoint);

   Print("Ejecutando orden: trend=",trend," price=",price," SL=",sl," TP=",tp," slPts=",slPts," tpPts=",tpPts," RiskMode=",RiskMode);

   for(int i=0; i<TradesPerSignal; i++)
     {
      if(trend==1)
         trade.Buy(TradeLotSize, _Symbol, price, sl, tp, NULL);
      else
         trade.Sell(TradeLotSize, _Symbol, price, sl, tp, NULL);
     }
  }

//+------------------------------------------------------------------+
//| Trailing Stop individual por trade (dólares)                     |
//+------------------------------------------------------------------+
void ApplyTrailingPerTradeDollars()
{
   for(int i=0; i<PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         string sym = PositionGetString(POSITION_SYMBOL);
         int type = (int)PositionGetInteger(POSITION_TYPE);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currPrice = SymbolInfoDouble(_Symbol, (type==POSITION_TYPE_BUY) ? SYMBOL_BID : SYMBOL_ASK);
         double oldSL = PositionGetDouble(POSITION_SL);
         double profitDollars = PositionGetDouble(POSITION_PROFIT);

         // Solo si va a favor más que TrailStartDollars
         if(profitDollars > TrailStartDollars)
         {
            double newSL;
            if(type == POSITION_TYPE_BUY)
               newSL = currPrice - (TrailStepDollars / tickValue) * onePoint;
            else
               newSL = currPrice + (TrailStepDollars / tickValue) * onePoint;

            // Solo mueve si el nuevo SL mejora el actual (BUY sube SL, SELL baja SL)
            if((type==POSITION_TYPE_BUY && (oldSL < newSL || oldSL==0)) ||
               (type==POSITION_TYPE_SELL && (oldSL > newSL || oldSL==0)))
            {
               Print("Trailing activado para ticket ", ticket, ": tipo=", type, " SL viejo=", oldSL, " SL nuevo=", newSL, " ProfitUSD=", profitDollars);
               trade.PositionModify(_Symbol, newSL, PositionGetDouble(POSITION_TP));
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
