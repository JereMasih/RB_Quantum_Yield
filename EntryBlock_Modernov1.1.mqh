
//+------------------------------------------------------------------+
//| EntryBlock_Moderno.mqh v1.2                                      |
//| Cambios 2025‑06‑25:                                              |
//|  * Opción de objetivos/SL en dinero absoluto                     |
//|  * Soporte para contra‑tendencia (vía TrendDetectionBlock)       |
//+------------------------------------------------------------------+
#property copyright "R&B Quantum‑Yield"
#property link      "https://github.com/JereMasih/RB_Quantum_Yield"
#property version   "1.2"

#include <Trade\Trade.mqh>
#include "TrendDetectionBlock.mqh"

//––– Entrada de usuario –––––––––––––––––––––––––––––––––––––––––––––
input double  Lots                = 0.10;     // Tamaño de lote fijo
input bool    UseMoneyTargets     = false;    // true = SL/TP expresados en dinero; false = en % del precio
input double  TakeProfitMoney     = 100.0;    // Beneficio objetivo (divisa de la cuenta) – solo si UseMoneyTargets
input double  StopLossMoney       = 50.0;     // Pérdida máxima (divisa de la cuenta) – solo si UseMoneyTargets
input double  TakeProfitPercent   = 2.0;      // % sobre el precio de entrada – solo si !UseMoneyTargets
input double  StopLossPercent     = 1.0;      // % sobre el precio de entrada – solo si !UseMoneyTargets
input bool    AllowCounterTrend   = false;    // Permitir señales contra la tendencia detectada

//––– Variables internas ––––––––––––––––––––––––––––––––––––––––––––-
CTrade trade;               // wrapper de operaciones
int     TrendDir   = 0;     // 1 = alcista, ‑1 = bajista, 0 = neutro

//+------------------------------------------------------------------+
//| Convierte una cantidad de dinero en puntos de precio             |
//+------------------------------------------------------------------+
double MoneyToPoints(double money,double lots,bool isBuy)
{
   // Valor de un tick por lote para el símbolo actual
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickValue==0 || tickSize==0) return(0);
   // nº de ticks necesarios para alcanzar "money" con "lots"
   double ticksNeeded = money / (tickValue * lots);
   // convertir ticks a puntos de precio
   double points = ticksNeeded * (tickSize / _Point);
   return(MathAbs(points));
}
//+------------------------------------------------------------------+
//| Calcula TP & SL y los devuelve por referencia                    |
//+------------------------------------------------------------------+
void CalculateTargets(bool isBuy,double lots,double &slPoints,double &tpPoints)
{
   if(UseMoneyTargets)
     {
      tpPoints = MoneyToPoints(TakeProfitMoney,lots,isBuy);
      slPoints = MoneyToPoints(StopLossMoney,lots,isBuy);
     }
   else
     {
      double entry   = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      tpPoints = entry * TakeProfitPercent/100.0 / _Point;
      slPoints = entry * StopLossPercent /100.0 / _Point;
     }
}
//+------------------------------------------------------------------+
//| Comprueba si la señal va en la misma dirección de la tendencia   |
//+------------------------------------------------------------------+
bool TrendFilter(int signalDir)
{
   if(AllowCounterTrend) return true;
   return (signalDir == TrendDir);
}
//+------------------------------------------------------------------+
//| OnTick: lógica simplificada de ejemplo                           |
//+------------------------------------------------------------------+
void OnTick()
{
   // 1) Actualizar estado de tendencia
   TrendDir = GetTrendState();
   
   // 2) Ejemplo de lógica de señal (AQUÍ sustituir por la tuya)
   int signalDir = 0; // 1 = buy, ‑1 = sell
   if(Close[1] > iMA(_Symbol,0,20,0,MODE_EMA,PRICE_CLOSE,1)) signalDir=1;
   if(Close[1] < iMA(_Symbol,0,20,0,MODE_EMA,PRICE_CLOSE,1)) signalDir=-1;
   
   // 3) Filtrar por tendencia si se requiere
   if(!TrendFilter(signalDir)) return;
   if(signalDir==0)            return;
   
   // 4) Evitar duplicar posiciones
   if(PositionSelect(_Symbol)) return;
   
   // 5) Calcular objetivos
   double slPts,tpPts;
   CalculateTargets(signalDir==1,Lots,slPts,tpPts);
   
   // 6) Enviar orden
   if(signalDir==1)
      trade.Buy (Lots,NULL,0,(slPts>0)?slPts:_Trade.STOPLIMIT, (tpPts>0)?tpPts:_Trade.TAKEPROFIT);
   else if(signalDir==-1)
      trade.Sell(Lots,NULL,0,(slPts>0)?slPts:_Trade.STOPLIMIT, (tpPts>0)?tpPts:_Trade.TAKEPROFIT);
}
//+------------------------------------------------------------------+
