
# 🧠 Anatomía del Bloque 2 – R&B Quantum Yield  
**Confirmación de vela + ejecución de operaciones**

---

## 🎯 ¿Qué hace este bloque?

Este bloque se ejecuta en cada tick, pero **solo actúa una vez por vela cerrada**.  
Y **solo opera si hay confirmación completa**:

1. Hay una **tendencia activa** detectada por el Bloque 1.
2. La **vela anterior cierra en dirección de la tendencia**.
3. No hay **órdenes abiertas en contra de la tendencia**.
4. Entonces, ejecuta la cantidad de órdenes definida, con **TP y SL como % del balance**.

---

## 🧩 Estructura del código

### 1. Incluir el bloque de tendencia

```mql5
#include "TrendDetectionBlock.mqh"
```

Importa el Bloque 1 como librería externa para usar `GetTrendState()`.

---

### 2. Inputs configurables

```mql5
input int    NumOrders   = 1;
input double LotSize     = 0.1;
input double TP_Percent  = 1.0;
input double SL_Percent  = 0.5;
```

Definidos por el usuario desde el panel del EA:

| Input | Significado |
|-------|-------------|
| `NumOrders` | Cantidad de operaciones a abrir |
| `LotSize` | Tamaño de cada operación |
| `TP_Percent` | % del balance usado como Take Profit |
| `SL_Percent` | % del balance usado como Stop Loss |

---

### 3. Detección de nueva vela

```mql5
static datetime lastBarTime = 0;
datetime currentBarTime = iTime(_Symbol, _Period, 0);
if (currentBarTime == lastBarTime) return;
lastBarTime = currentBarTime;
```

Usa `iTime()` para detectar si hay una **vela nueva** comparando el tiempo actual con el anterior.

---

### 4. Obtener el estado de la tendencia

```mql5
int trend = GetTrendState();
if (trend == 0 || NumOrders <= 0) return;
```

Evita operar si no hay tendencia clara o si `NumOrders = 0`.

---

### 5. Confirmar que la vela anterior va a favor

```mql5
double open  = iOpen(_Symbol, _Period, 1);
double close = iClose(_Symbol, _Period, 1);
bool validCandle = (trend == 1 && close > open) || (trend == -1 && close < open);
```

Verifica que la vela cerrada fue alcista o bajista según la tendencia.

---

### 6. Verificar que no haya órdenes en contra

```mql5
for (int i = 0; i < OrdersTotal(); i++) {
  if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
    if (OrderSymbol() == _Symbol) {
      if ((trend == 1 && OrderType() == ORDER_SELL) || (trend == -1 && OrderType() == ORDER_BUY))
        return;
    }
  }
}
```

Evita abrir una orden si ya hay una en la dirección opuesta.

---

### 7. Calcular TP y SL como % del balance

```mql5
double tpPoints = (TP_Percent / 100.0) * balance / (LotSize * TickValue);
```

Convierte el porcentaje a puntos, y luego a precios usando el `onePoint`.

---

### 8. Ejecutar operaciones

```mql5
for (int n = 0; n < NumOrders; n++) {
  OrderSend(...);
}
```

Abre la cantidad exacta de órdenes con los precios y parámetros ya calculados.

---

## 🧮 ¿Cómo se conecta con el EA completo?

- El archivo `.mq5` principal contiene este código dentro del `OnTick()`.
- El Bloque 1 ya debe estar incluido con `#include "TrendDetectionBlock.mqh"`.
- Este bloque solo se encarga de ejecutar entradas: **no gestiona salidas ni trailing** (eso vendrá en bloques futuros).

---

## ✅ Conclusión

Este bloque es el **corazón de la lógica de entrada del robot**.  
Opera con disciplina, claridad y bajo riesgo, solo cuando hay alineación total entre:

- Tendencia multitemporal
- Confirmación de vela
- Configuración del usuario
- Validación de condiciones operativas

