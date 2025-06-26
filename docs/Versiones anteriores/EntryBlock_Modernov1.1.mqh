//+------------------------------------------------------------------+
//| EntryBlock_Modernov v1.1                                         |
//| – Contiene la lógica de entrada y money-management               |
//+------------------------------------------------------------------+
#property strict
#include <Trade/Trade.mqh>
#include "TrendDetectionBlock v1.2.mqh"   // para usar IsDirectionAllowed()

//––– Parámetros de gestión monetaria --------------------------------
input double RiskPercent     = 1.0;      // % de balance arriesgado
input bool   UseMoneyTP_SL   = true;     // true = TP/SL en dinero
input double SL_Value        = 300.0;    // USD o %
input double TP_Value        = 1000.0;   // USD o %
input bool   AllowCounterTrend = false;  // Ignorar filtro de tendencia

//––– Helpers internos ----------------------------------------------
CTrade trade;

//––– Conversión de $/%, devuelve puntos -----------------------------
double GetSLPoints()
  {
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tickValue <= 0) return 0;

   if(UseMoneyTP_SL)
      return SL_Value / tickValue;                         // dinero→pts
   else
     {
      double money = AccountInfoDouble(ACCOUNT_BALANCE) * SL_Value / 100.0;
      return money / tickValue;                            // %→pts
     }
  }

double GetTPPoints()
  {
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tickValue <= 0) return 0;

   if(UseMoneyTP_SL)
      return TP_Value / tickValue;
   else
     {
      double money = AccountInfoDouble(ACCOUNT_BALANCE) * TP_Value / 100.0;
      return money / tickValue;
     }
  }

//––– Señal de entrada DEMO (cruce de MAs) ---------------------------
bool EntrySignal(bool &isBuy)
  {
   double fast = iMA(_Symbol,_Period,20,0,MODE_SMA,PRICE_CLOSE,0);
   double slow = iMA(_Symbol,_Period,50,0,MODE_SMA,PRICE_CLOSE,0);

   if(fast > slow && Close[1] <= slow) { isBuy = true;  return true; }
   if(fast < slow && Close[1] >= slow) { isBuy = false; return true; }
   return false;
  }

//––– Bloque principal: llamar desde OnTick() ------------------------
void CheckAndExecuteEntry()
  {
   bool isBuy;
   if(!EntrySignal(isBuy))          // sin señal
      return;

   if(PositionSelect(_Symbol))      // ya hay posición
      return;

   if(!AllowCounterTrend && !IsDirectionAllowed(isBuy))
      return;                       // filtrado por tendencia

   double sl = GetSLPoints()*_Point;
   double tp = GetTPPoints()*_Point;

   //––– Tamaño fijo 0.1 lots DEMO (ajusta a tu gusto/riesgo)
   if(isBuy)
      trade.Buy(0.1,_Symbol, Ask, sl, tp, "RBQ-Buy");
   else
      trade.Sell(0.1,_Symbol, Bid, sl, tp, "RBQ-Sell");
  }
//+------------------------------------------------------------------+