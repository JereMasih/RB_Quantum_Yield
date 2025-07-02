//+------------------------------------------------------------------+
//| RBQY_Test_B3 – EA integrador, sin duplicados                     |
//+------------------------------------------------------------------+
#property strict
#include <RBQY/TrendDetectionBlock_v1.6.mqh>
#include <RBQY/EntryBlock_Moderno_v1.4.mqh>
int OnInit()
{
   if(!TrendInit()) return(INIT_FAILED);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){ TrendDeinit(); }
void OnTick()
{
   // Aquí solo se llaman funciones, no se definen
   DrawHUD();                // Única llamada (NO redefinir DrawHUD)
   CheckAndExecuteEntry();
}
