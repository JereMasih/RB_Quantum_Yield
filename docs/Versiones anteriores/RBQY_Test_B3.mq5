//+------------------------------------------------------------------+
//|                                              RBQY_Test_B3.mq5    |
//|      R&B Quantum Yield – versión de pruebas (B3, 2025-06-25)     |
//+------------------------------------------------------------------+
#property copyright "© 2025 JereMasih – All rights reserved"
#property version   "0.3"
#property strict
#property description "Robot de pruebas que combina detección de tendencia " \
                      "y lógica de entradas modulares."

#include "TrendDetectionBlock v1.3.mqh"
#include "EntryBlock_Modernov1.2.mqh"

//--- parámetros de usuario --------------------------------------------------
input double          InpRiskPercent       = 1.0;                // % de riesgo por operación
input bool            InpAllowCounterTrend = false;              // Permitir contra-tendencia
input ENUM_TIMEFRAMES InpTrendTF           = PERIOD_H1;          // TF para detectar tendencia
input int             InpTrendMode         = MODE_TREND_ONLY;    // MODE_TREND_ONLY o MODE_TREND_AND_COUNTER
//---------------------------------------------------------------------------

//--- variables globales -----------------------------------------------------
string          g_symbol;      // Símbolo a operar
ENUM_TIMEFRAMES g_chartTF;     // Marco de tiempo del gráfico
//---------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|  Inicialización                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_symbol  = _Symbol;
   g_chartTF = _Period;

   // 1) Inicializar módulo de tendencia
   if(!TrendInit(g_symbol, InpTrendTF, InpTrendMode))
     {
      Print(__FUNCTION__,": TrendInit falló → expert deshabilitado.");
      return(INIT_FAILED);
     }

   // 2) Inicializar módulo de entradas
   //    (dentro de EntryInit se guarda AllowCounterTrend para todo el bloque)
   if(!EntryInit(g_symbol, g_chartTF, InpRiskPercent, InpAllowCounterTrend))
     {
      Print(__FUNCTION__,": EntryInit falló → expert deshabilitado.");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|  Desinicialización                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EntryDeinit();
   TrendDeinit();
  }
//+------------------------------------------------------------------+
//|  Lógica principal (cada tick)                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   // 1) Actualizar estado de tendencia en el primer tick de nueva vela del TF elegido
   if(TrendUpdate())
     {
      // Aquí podrías registrar/loguear el nuevo estado si lo deseas
     }

   // 2) Comprobar condiciones de entrada / salida y ejecutar si procede
   CheckAndExecuteEntry();
  }
//+------------------------------------------------------------------+