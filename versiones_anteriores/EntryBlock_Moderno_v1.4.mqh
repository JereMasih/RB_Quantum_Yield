//+------------------------------------------------------------------+
//|                  EntryBlock_Moderno.mqh                         |
//|     Lógica de entrada con vela confirmada + control trend       |
//|     Versión: 1.4.1 - 2025-06-30                                  |
//|     Rama principal: 1.4 (archivo actual en GitHub)               |
//|     Autor: Jere Masih + ChatGPT (R&B Quantum Yield Project)     |
//+------------------------------------------------------------------+

#define ENTRYBLOCK_VERSION "1.4.1"
#define ENTRYBLOCK_DATE    "2025-06-30"

#include "TrendDetectionBlock.mqh"  // Asegura que este archivo esté en la misma carpeta

// === INPUTS DEL BLOQUE ===
input int    NumOrders         = 1;
input double LotSize           = 0.1;
input double TP_Percent        = 1.0;
input double SL_Percent        = 0.5;
input bool   allowCounterTrend = false;

// === VARIABLES PARA CONTROL DE VELA ===
static datetime lastBarTime = 0;
datetime currentBarTime     = iTime(_Symbol, _Period, 0);
if (currentBarTime == lastBarTime) return;  // No hay nueva vela
lastBarTime = currentBarTime;

// === OBTENER ESTADO DE LA TENDENCIA ===
int trend = GetTrendState();
if (trend == 0 || NumOrders <= 0) return;

// === CONFIRMAR QUE LA VELA ANTERIOR VA A FAVOR DE LA TENDENCIA ===
double open  = iOpen(_Symbol, _Period, 1);
double close = iClose(_Symbol, _Period, 1);
bool validCandle = (trend == 1 && close > open) || (trend == -1 && close < open);
if (!validCandle) return;

// === CONTROL DE OPERACIONES CONTRARIAS SEGÚN allowCounterTrend ===
if (!allowCounterTrend) {
  for (int i = 0; i < OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol() == _Symbol) {
        if ((trend == 1 && OrderType() == ORDER_SELL) || 
            (trend == -1 && OrderType() == ORDER_BUY)) {
          Print("🔒 Entrada bloqueada: ya existe una operación contraria y allowCounterTrend está en FALSE.");
          return;
        }
      }
    }
  }
} else {
  Print("⚠️ Entrada permitida aunque haya operaciones contrarias (allowCounterTrend = TRUE)");
}

// === CÁLCULO DE TP Y SL EN PUNTOS (usando el balance) ===
double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
double tpPoints = (TP_Percent / 100.0) * balance / (LotSize * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
double slPoints = (SL_Percent / 100.0) * balance / (LotSize * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
double onePoint = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

// === PRECIO ACTUAL ===
double price = (trend == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);

// === ENVÍO DE ORDEN ===
for (int n = 0; n < NumOrders; n++) {
  double tpPrice = (trend == 1) ? price + tpPoints * onePoint : price - tpPoints * onePoint;
  double slPrice = (trend == 1) ? price - slPoints * onePoint : price + slPoints * onePoint;
  int orderType  = (trend == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;

  MqlTradeRequest request;
  MqlTradeResult  result;
  ZeroMemory(request);
  ZeroMemory(result);

  request.action    = TRADE_ACTION_DEAL;
  request.symbol    = _Symbol;
  request.volume    = LotSize;
  request.type      = orderType;
  request.price     = price;
  request.tp        = tpPrice;
  request.sl        = slPrice;
  request.deviation = 10;
  request.magic     = 123456;
  request.comment   = "RBY Entry";

  if (!OrderSend(request, result)) {
    Print("⛔️ Error al enviar orden: ", result.retcode);
  } else {
    Print("✅ Orden enviada: ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"), " | Precio: ", price);
  }
}