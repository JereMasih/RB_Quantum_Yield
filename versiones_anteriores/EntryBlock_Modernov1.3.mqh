//+------------------------------------------------------------------+
//|  EntryBlock_Modernov1.3.mqh – Confirmación de vela + órdenes     |
//+------------------------------------------------------------------+
#property copyright "Jeremías Abdelmasih 2025"
#property version   "1.3"
#property strict
#include <Trade\Trade.mqh>
extern int  NumOrders         = 1;      // cantidad por señal
extern double LotSize         = 0.10;   // lotes
extern bool AllowCounterTrend = false;  // operar contra tendencia
//-- Modo riesgo
enum RiskMode {RISK_PERCENT=0,RISK_MONEY=1};
extern RiskMode SL_Mode = RISK_PERCENT;
extern double  SL_Value = 0.5;   // % o USD
extern RiskMode TP_Mode = RISK_PERCENT;
extern double  TP_Value = 1.0;   // % o USD
extern double  Slippage = 5;
//--- referencia a la variable global de tendencia
extern int TrendDir;
static datetime lastBar=0;
CTrade trade;
//-------------------------------------------------------------------
//  Cálculo puntos desde riesgo
//-------------------------------------------------------------------
double PointsFromRisk(RiskMode mode,double val)
{
   double money = (mode==RISK_PERCENT)?
                  (AccountInfoDouble(ACCOUNT_BALANCE)*val/100.0):val;
   double tickVal = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   return money/(LotSize*tickVal);
}
//-------------------------------------------------------------------
//  FUNCIÓN PRINCIPAL – se llama 1 vez por vela
//-------------------------------------------------------------------
void CheckAndExecuteEntry()
{
   datetime barTime=iTime(_Symbol,_Period,0);
   if(barTime==lastBar) return;
   lastBar=barTime;

   //-- señales
   int sig = TrendDir;
   if(sig==0) return;
   // vela confirmatoria
   double o=iOpen (_Symbol,_Period,1);
   double c=iClose(_Symbol,_Period,1);
   if((sig==1 && c<=o) || (sig==-1 && c>=o)) return;

   //-- posiciones opuestas
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!PositionSelectByIndex(i)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      int ptype=(int)PositionGetInteger(POSITION_TYPE);
      if((sig==1 && ptype==POSITION_TYPE_SELL) ||
         (sig==-1&& ptype==POSITION_TYPE_BUY )) return;
   }
   //-- cálculo TP / SL
   double tpPts = PointsFromRisk(TP_Mode,TP_Value);
   double slPts = PointsFromRisk(SL_Mode,SL_Value);
   double ask   = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid   = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   for(int n=0;n<NumOrders;n++)
   {
      if(sig==1) // BUY
      {
         double sl=ask-slPts*_Point;
         double tp=ask+tpPts*_Point;
         trade.Buy(LotSize,_Symbol,ask,sl,tp,"RBQY Buy",Slippage);
      }
      else      // SELL
      {
         double sl=bid+slPts*_Point;
         double tp=bid-tpPts*_Point;
         trade.Sell(LotSize,_Symbol,bid,sl,tp,"RBQY Sell",Slippage);
      }
   }
}