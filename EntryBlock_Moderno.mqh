
//+------------------------------------------------------------------+
//| Bloque 2 - Confirmación de vela y ejecución con CTrade (MT5)     |
//| R&B Quantum Yield - versión compatible con builds actuales       |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>

input int    NumOrders   = 1;
input double LotSize     = 0.1;
input double TP_Percent  = 1.0;   // % del balance
input double SL_Percent  = 0.5;   // % del balance

//--- Variables internas
static datetime lastBarTime = 0;
CTrade trade;  // Objeto para ejecutar órdenes de forma moderna

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

  bool validCandle =
    (trend == 1 && close > open) ||
    (trend == -1 && close < open);

  if (!validCandle)
    return;

  // Verificar que no haya posición abierta en contra
  if (PositionSelect(_Symbol))
  {
    long type;
    if (PositionGetInteger(POSITION_TYPE, type))
    {
      if ((trend == 1 && type == POSITION_TYPE_SELL) ||
          (trend == -1 && type == POSITION_TYPE_BUY))
        return;
    }
  }

  double balance = AccountInfoDouble(ACCOUNT_BALANCE);
  double onePoint = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

  double tpPoints = (TP_Percent / 100.0) * balance / (LotSize * tickValue);
  double slPoints = (SL_Percent / 100.0) * balance / (LotSize * tickValue);

  double price  = trend == 1 ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
  double tp     = 0.0;
  double sl     = 0.0;

  for (int n = 0; n < NumOrders; n++)
  {
    if (trend == 1)
    {
      tp = price + tpPoints * onePoint;
      sl = price - slPoints * onePoint;
      trade.Buy(LotSize, _Symbol, price, sl, tp, "R&B Quantum Yield");
    }
    else
    {
      tp = price - tpPoints * onePoint;
      sl = price + slPoints * onePoint;
      trade.Sell(LotSize, _Symbol, price, sl, tp, "R&B Quantum Yield");
    }
  }
}
