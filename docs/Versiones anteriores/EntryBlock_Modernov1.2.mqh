//  EntryBlock_Modernov1.2.mqh
//———————————————————————————————————————————————————————
#ifndef  __ENTRYBLOCK_MODERNOV12_MQH__
#define  __ENTRYBLOCK_MODERNOV12_MQH__

#property copyright "Jeremías Abdelmasih 2025"
#property version   "1.2"
#property strict

#include <Trade/Trade.mqh>      // CTrade
static  CTrade trade;

//--- utilidades rápidas -------------------------------------------------------
#define Ask  SymbolInfoDouble(_Symbol,SYMBOL_ASK)
#define Bid  SymbolInfoDouble(_Symbol,SYMBOL_BID)

//--- inputs -------------------------------------------------------------------
input bool   AllowCounterTrend = false; // ¿operar contra-tendencia?
input double TrendSLP          = 30;    // SL  (puntos)
input double TrendTPP          = 60;    // TP  (puntos)
input double SetSlippage       = 5;     // máx. slippage

//--- tipos auxiliares ---------------------------------------------------------
enum EntrySignal { ENTRY_NONE=0, ENTRY_BUY, ENTRY_SELL };

//--- funciones públicas -------------------------------------------------------
void EntryInit()   { /* nada por ahora */ }
void EntryDeinit() { /* nada por ahora */ }

//--- lógica principal ---------------------------------------------------------
void CheckAndExecuteEntry()
{
   EntrySignal sig = ENTRY_NONE;

   // usa la variable TrendDir que mantiene TrendDetectionBlock
   if(TrendDir ==  1)                       sig = ENTRY_BUY;
   if(TrendDir == -1 && AllowCounterTrend)  sig = ENTRY_SELL;

   if(sig == ENTRY_NONE) return;            // nada que hacer

   double lot = 0.10;

   if(sig == ENTRY_BUY)
      trade.Buy (lot,_Symbol,SetSlippage,
                 Ask - TrendSLP*_Point,
                 Ask + TrendTPP*_Point);

   if(sig == ENTRY_SELL)
      trade.Sell(lot,_Symbol,SetSlippage,
                 Bid + TrendSLP*_Point,
                 Bid - TrendTPP*_Point);
}
#endif   // __ENTRYBLOCK_MODERNOV12_MQH__