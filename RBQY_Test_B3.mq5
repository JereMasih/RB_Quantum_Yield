
//+------------------------------------------------------------------+
//|                                               RBQY_Test_B3.mq5   |
//|   RB Quantum Yield – Test harness                                 |
//|   Author: JereMasih & ChatGPT (OpenAI o3)                         |
//+------------------------------------------------------------------+
#property copyright "© 2025 Jere Masih"
#property link      "https://github.com/JereMasih/RB_Quantum_Yield"
#property version   "1.0"
#property strict

#include "TrendDetectionBlock v1.2.mqh"
#include "EntryBlock_Modernov1.1.mqh"

//--- ‑‑‑ Configuración de inputs
input bool   InMoney          = false;   // true = TP/SL definidos en dinero; false = % balance
input double TP_Money         = 1000.0;  // beneficio en divisa de la cuenta
input double SL_Money         = 300.0;   // pérdida máxima en divisa de la cuenta
input double TP_Percent       = 10.0;    // % balance como take‑profit
input double SL_Percent       = 3.0;     // % balance como stop‑loss
input bool   AllowCounterTrend= false;   // Permitir señales contra‑tendencia

//--- Funciones utilitarias
double MoneyToPoints(double money)
{
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tick_value<=0) return 0;
   return (money / tick_value) / _Point;
}

double PercentToPoints(double percent)
{
   return (AccountInfoDouble(ACCOUNT_BALANCE) * percent / 100.0) / (_Point * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
}

double GetTPPoints() { return InMoney ? MoneyToPoints(TP_Money) : PercentToPoints(TP_Percent); }
double GetSLPoints() { return InMoney ? MoneyToPoints(SL_Money) : PercentToPoints(SL_Percent); }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Inicializa bloques
   TrendInit();
   EntryInit();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert de‑initialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   TrendDeinit();
   EntryDeinit();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   TrendUpdate();   // actualiza la información de tendencia

   int tradeMode = AllowCounterTrend ? MODE_TREND_AND_COUNTER : MODE_TREND_ONLY;

   CheckAndExecuteEntry(GetSLPoints(), GetTPPoints(), tradeMode);
}
//+------------------------------------------------------------------+
