//+------------------------------------------------------------------+
//| TrendDetectionBlock v1.2                                         |
//| — Sólo funciones auxiliares: ¡NO declaramos OnInit/OnTick aquí!  |
//+------------------------------------------------------------------+
#property strict

//––– Parámetros -----------------------------------------------------+
enum TrendMode
  {
   MODE_TREND_ONLY        = 0,   // Sólo a favor de tendencia
   MODE_TREND_AND_COUNTER = 1    // Se permite contratrend
  };

input int       TrendPeriod = 200;            // Periodo de la MA
input TrendMode TrendBehavior = MODE_TREND_ONLY;

//––– Variables internas --------------------------------------------+
bool   gIsTrendUp = false;
double gLastMA    = 0.0;

//––– Inicialización: llámala 1 vez desde OnInit() del EA ----------+
void TrendInit()
  {
   gLastMA   = iMA(_Symbol,_Period,TrendPeriod,0,MODE_SMA,PRICE_CLOSE,0);
   gIsTrendUp = (Close[0] > gLastMA);
  }

//––– Actualización: llámala en cada tick desde OnTick() ------------+
void TrendUpdate()
  {
   double ma = iMA(_Symbol,_Period,TrendPeriod,0,MODE_SMA,PRICE_CLOSE,0);
   gIsTrendUp = (Close[0] > ma);
   gLastMA    = ma;
  }

//––– Filtro de dirección -------------------------------------------+
bool IsDirectionAllowed(bool signalIsBuy)
  {
   if(TrendBehavior == MODE_TREND_AND_COUNTER)   // Se permite todo
      return true;

   // MODE_TREND_ONLY → bloquear contra-tendencia
   bool trendIsUp = gIsTrendUp;
   return ( signalIsBuy &&  trendIsUp) ||
          (!signalIsBuy && !trendIsUp);
  }
//+------------------------------------------------------------------+