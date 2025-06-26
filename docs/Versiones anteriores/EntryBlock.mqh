
//+------------------------------------------------------------------+
//| Bloque 2 - Confirmación de vela y ejecución de órdenes           |
//| R&B Quantum Yield - Versión modular                              |
//+------------------------------------------------------------------+

#include "TrendDetectionBlock.mqh"  // Requiere el Bloque 1

//--- Inputs
input int    NumOrders   = 1;
input double LotSize     = 0.1;
input double TP_Percent  = 1.0;   // % del balance
input double SL_Percent  = 0.5;   // % del balance

//--- Variables internas
static datetime lastBarTime = 0;

void CheckAndExecuteEntry()
{
  datetime currentBarTime = iTime(_Symbol, _Period, 0);
  if (currentBarTime == lastBarTime)
    return;

  lastBarTime = currentBarTime;

  int trend = GetTrendState();
  if (trend == 0 || NumOrders <= 0)
    return;

  double open  = iOpen(_Symbol, _Period, 1);
  double close = iClose(_Symbol, _Period, 1);

  // Confirmación de vela
  bool validCandle =
    (trend == 1 && close > open) ||
    (trend == -1 && close < open);

  if (!validCandle)
    return;

  // Verificar que no haya operaciones abiertas en contra
  for (int i = 0; i < OrdersTotal(); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
      if (OrderSymbol() == _Symbol)
      {
        if ((trend == 1 && OrderType() == ORDER_SELL) ||
            (trend == -1 && OrderType() == ORDER_BUY))
          return; // Hay operación en contra
      }
    }
  }

  // Calcular TP/SL como porcentaje del balance
  double balance = AccountInfoDouble(ACCOUNT_BALANCE);
  double onePoint = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

  double tpPoints = (TP_Percent / 100.0) * balance / (LotSize * tickValue);
  double slPoints = (SL_Percent / 100.0) * balance / (LotSize * tickValue);

  double price  = trend == 1 ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
  double tp     = 0.0;
  double sl     = 0.0;

  int type = (trend == 1) ? ORDER_BUY : ORDER_SELL;
  double slippage = 5;

  for (int n = 0; n < NumOrders; n++)
  {
    if (trend == 1)
    {
      tp = price + tpPoints * onePoint;
      sl = price - slPoints * onePoint;
    }
    else
    {
      tp = price - tpPoints * onePoint;
      sl = price + slPoints * onePoint;
    }

    OrderSend(_Symbol, type, LotSize, price, slippage, sl, tp, "R&B Quantum Yield", 0, 0, clrBlue);
  }
}
