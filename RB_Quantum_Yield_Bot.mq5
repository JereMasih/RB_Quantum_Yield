
//+------------------------------------------------------------------+
//| R&B - Quantum Yield Bot | v1.1 | 2025-07-02                      |
//+------------------------------------------------------------------+
#property copyright "© 2025 Jere Masih"
#property version   "1.1"
#property strict

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
static datetime lastBarTime       = 0;
double onePoint;
double tickValue;
int    symmetricalTFs[6] = { PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1 };

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   onePoint   = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   tickValue  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Detect new bar
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime == lastBarTime) return;
   lastBarTime = currentBarTime;

   // Filters: spread & slippage
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpreadPoints) return;

   int trend = GetTrendState();
   if(trend == 0) return; // no clear trend

   // Confirm candle
   if(!ConfirmCandle(trend)) return;

   // Allow countertrend?
   if(!AllowCounterTrend && HasOppositeOrder(trend)) return;

   // Execute orders
   ExecuteOrders(trend);

   // Apply trailing stop
   if(UseTrail) ApplyTrailing();
  }

//+------------------------------------------------------------------+
//| Compute trend state:  1=up, -1=down, 0=neutral                  |
//+------------------------------------------------------------------+
int GetTrendState()
  {
   int alignedUp = 0, alignedDown = 0;
   bool weightUp = false, weightDown = false;
   for(int i=0; i<6; i++)
     {
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)symmetricalTFs[i];
      double emaF = iMA(_Symbol, tf, FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
      double emaS = iMA(_Symbol, tf, SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
      if(emaF > emaS)
        {
         alignedUp++;
         if(tf == WeightTF) weightUp = true;
        }
      else if(emaF < emaS)
        {
         alignedDown++;
         if(tf == WeightTF) weightDown = true;
        }
     }
   if(alignedUp >= MinFramesAligned && weightUp) return(1);
   if(alignedDown >= MinFramesAligned && weightDown) return(-1);
   return(0);
  }

//+------------------------------------------------------------------+
//| Confirm the previous candle in ExecTF matches trend             |
//+------------------------------------------------------------------+
bool ConfirmCandle(int trend)
  {
   double openC  = iOpen(_Symbol, ExecTF, 1);
   double closeC = iClose(_Symbol, ExecTF, 1);
   int    range  = (int)(MathAbs(closeC - openC) / onePoint);
   if(range > MaxCandleRangePoints) return(false);
   if(trend==1 && closeC>openC) return(true);
   if(trend==-1 && closeC<openC) return(true);
   return(false);
  }

//+------------------------------------------------------------------+
//| Check opposite orders                                           |
//+------------------------------------------------------------------+
bool HasOppositeOrder(int trend)
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderSymbol()==_Symbol)
           {
            if((trend==1 && OrderType()==ORDER_TYPE_SELL) ||
               (trend==-1 && OrderType()==ORDER_TYPE_BUY))
               return(true);
           }
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Execute entry orders                                            |
//+------------------------------------------------------------------+
void ExecuteOrders(int trend)
  {
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(trend==1) price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   // SL/TP in points
   double slPoints=0, tpPoints=0;
   if(RiskMode==MONEY)
     {
      slPoints = SL_Money / tickValue;
      tpPoints = TP_Money / tickValue;
     }
   else
     {
      double bal = AccountInfoDouble(ACCOUNT_BALANCE);
      slPoints = (SL_Pct/100.0 * bal) / tickValue;
      tpPoints = (TP_Pct/100.0 * bal) / tickValue;
     }

   double sl = (trend==1) ? price - slPoints*onePoint : price + slPoints*onePoint;
   double tp = (trend==1) ? price + tpPoints*onePoint : price - tpPoints*onePoint;

   int slippage = MaxSlippagePoints;
   int ticket = OrderSend(_Symbol, trend==1?OP_BUY:OP_SELL, 
                          0.1, price, slippage, sl, tp, 
                          "QB Trade", 0, 0, clrNONE);
  }

//+------------------------------------------------------------------+
//| Apply global trailing stop                                      |
//+------------------------------------------------------------------+
void ApplyTrailing()
  {
   double totalProfit = 0;
   double stopLevel;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol)
            totalProfit += OrderProfit();
        }
     }
   if(totalProfit < StartTrailMoney) return;
   stopLevel = (StartTrailMoney - TrailStepMoney) * onePoint;
   // TODO: implement grouping ALL vs LONG_SHORT
   // Move stops accordingly...
  }
