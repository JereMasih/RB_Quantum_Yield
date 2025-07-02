
//+------------------------------------------------------------------+
//| Bloque 1 - Detección de Tendencia Multitemporal                  |
//| R&B Quantum Yield                                                |
//+------------------------------------------------------------------+

//--- Parámetros de entrada
input ENUM_TIMEFRAMES WeightTF   = PERIOD_H1;
input int             FastPeriod = 50;
input int             SlowPeriod = 200;

//--- Timeframes analizados
ENUM_TIMEFRAMES timeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};

//--- Handles EMA
int fastEMAHandles[6];
int slowEMAHandles[6];

//+------------------------------------------------------------------+
//| Inicialización                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  for (int i = 0; i < ArraySize(timeframes); i++)
  {
    fastEMAHandles[i] = iMA(_Symbol, timeframes[i], FastPeriod, 0, MODE_EMA, PRICE_CLOSE);
    slowEMAHandles[i] = iMA(_Symbol, timeframes[i], SlowPeriod, 0, MODE_EMA, PRICE_CLOSE);

    if (fastEMAHandles[i] == INVALID_HANDLE || slowEMAHandles[i] == INVALID_HANDLE)
    {
      Print("❌ Error al inicializar EMA en ", EnumToString(timeframes[i]));
      return INIT_FAILED;
    }
  }
  return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Función externa: devuelve el estado de tendencia                 |
//+------------------------------------------------------------------+
int GetTrendState()
{
  int bullishCount = 0;
  int bearishCount = 0;
  bool weightAlignedBullish = false;
  bool weightAlignedBearish = false;
  double fastBuffer[1], slowBuffer[1];

  for (int i = 0; i < ArraySize(timeframes); i++)
  {
    if (CopyBuffer(fastEMAHandles[i], 0, 0, 1, fastBuffer) <= 0 ||
        CopyBuffer(slowEMAHandles[i], 0, 0, 1, slowBuffer) <= 0)
      continue;

    if (fastBuffer[0] > slowBuffer[0])
    {
      bullishCount++;
      if (timeframes[i] == WeightTF) weightAlignedBullish = true;
    }
    else if (fastBuffer[0] < slowBuffer[0])
    {
      bearishCount++;
      if (timeframes[i] == WeightTF) weightAlignedBearish = true;
    }
  }

  if (bullishCount >= 3 && weightAlignedBullish)
    return 1;
  else if (bearishCount >= 3 && weightAlignedBearish)
    return -1;
  else
    return 0;
}
