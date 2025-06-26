//+------------------------------------------------------------------+
//| RBQY – Confirmación de vela y ejecución de entrada               |
//+------------------------------------------------------------------+
#property strict
#include <Trade/Trade.mqh>
#include "TrendDetectionBlock_v1.6.mqh"

//--- enums y params
enum SLTP_MODE { MODE_PERCENT=0, MODE_MONEY=1 };
input bool       AllowCounterTrend =  false;
input int        NumOrders         =  1;
input double     LotSize           =  0.10;
input SLTP_MODE  SLTP_Mode         =  MODE_PERCENT;
input double     TP_Value          =  1.0;
input double     SL_Value          =  0.5;

//--- internas
static datetime  lastBarTime=0;
CTrade           trade;

//--- Lógica principal (solo aquí, llama TrendUpdate y usa TrendDir global)
void CheckAndExecuteEntry()
{
   datetime barTime = iTime(_Symbol,_Period,0);
   if(barTime==lastBarTime) return;
   lastBarTime = barTime;

   int d = TrendUpdate();        // Siempre actualizar y guardar global
   if(d==0)            return;

   // Vela previa a favor
   double openPrev  = iOpen (_Symbol,_Period,1);
   double closePrev = iClose(_Symbol,_Period,1);
   bool   candleOK  =(d== 1 && closePrev>openPrev) ||
                     (d==-1 && closePrev<openPrev);
   if(!candleOK && !AllowCounterTrend) return;

   // Posiciones opuestas
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if( (d== 1 && type==POSITION_TYPE_SELL) ||
          (d==-1 && type==POSITION_TYPE_BUY ) ) return;
     }

   // TP/SL en puntos
   double bal      = AccountInfoDouble(ACCOUNT_BALANCE);
   double tickVal  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double onePoint = SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   double tpPts,slPts;
   if(SLTP_Mode==MODE_PERCENT)
     {
      tpPts = (TP_Value/100.0)*bal/(LotSize*tickVal)/onePoint;
      slPts = (SL_Value/100.0)*bal/(LotSize*tickVal)/onePoint;
     }
   else
     {
      tpPts = (TP_Value)/(LotSize*tickVal)/onePoint;
      slPts = (SL_Value)/(LotSize*tickVal)/onePoint;
     }

   for(int n=0;n<NumOrders;n++)
     {
      double price = (d==1)? SymbolInfoDouble(_Symbol,SYMBOL_ASK)
                           : SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double tp = (d==1)? price+tpPts*onePoint : price-tpPts*onePoint;
      double sl = (d==1)? price-slPts*onePoint : price+slPts*onePoint;
      trade.SetDeviationInPoints(5);
      if(d==1)
           trade.Buy (LotSize,_Symbol,price,sl,tp,"RBQY");
      else trade.Sell(LotSize,_Symbol,price,sl,tp,"RBQY");
     }
}
