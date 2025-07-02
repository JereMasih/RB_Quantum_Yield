
# 🧪 Test Visual – Bloque 2: Confirmación de Vela + Entrada  
**Actualización FINAL con uso de CTrade (MT5 API moderna)**  
**Proyecto: R&B Quantum Yield**

---

## 🎯 Objetivo del test

Verificar visualmente que el **Bloque 2**:

1. Opera **solo cuando hay cierre de vela en dirección de la tendencia**.
2. Respeta la cantidad de órdenes configuradas (`NumOrders`).
3. Calcula TP y SL como **porcentaje del balance**, en puntos.
4. **Evita duplicar entradas por vela**.
5. **No opera si hay una operación en contra abierta**.

---

## 🔁 ACTUALIZACIÓN IMPORTANTE

### ✅ Migramos a la API moderna `CTrade` de MetaTrader 5

Se reemplazó el uso de:

- `OrderSend()` → por `trade.Buy()` y `trade.Sell()`
- `OrderSelect()`, `OrderType`, `ORDER_BUY`, etc. → por `PositionSelect()` y `PositionGetInteger(...)`

### 📌 ¿Por qué hicimos este cambio?

- MetaTrader 5 ya no soporta bien funciones como `OrderSend()` y `OrderSelect()` en builds actuales.
- `CTrade` es más robusto, compatible, moderno y recomendado por MetaQuotes.
- Permite una estructura limpia, mantenible y profesional.
- Es necesario para que compile sin errores y funcione correctamente en 2025.

---

## 🧠 ¿Qué es `CTrade`?

Es una clase integrada en MQL5 que facilita operaciones como:

```mql5
CTrade trade;
trade.Buy(lotes, símbolo, precio, SL, TP, comentario);
trade.Sell(lotes, símbolo, precio, SL, TP, comentario);
```

Viene incluida automáticamente con:

```mql5
#include <Trade\Trade.mqh>
```

---

## 📦 Archivos necesarios

- `TrendDetectionBlock.mqh` → Bloque 1
- `EntryBlock_Moderno.mqh` → Bloque 2 actualizado con `CTrade`
- `RBQY_Test_B2.mq5` → archivo principal de prueba con:

```mql5
#include "TrendDetectionBlock.mqh"
#include "EntryBlock_Moderno.mqh"

int OnInit() { return INIT_SUCCEEDED; }

void OnTick()
{
   CheckAndExecuteEntry();  // Ejecuta el bloque 2 con API moderna
}
```

---

## 🛠 Cómo guardar e importar correctamente

1. Abrí **MetaEditor**.
2. En `MQL5 > Experts`, creá un nuevo EA: `RBQY_Test_B2.mq5`.
3. Pegá el código anterior.
4. Asegurate de tener los archivos `.mqh` en la **misma carpeta** que el `.mq5`.
5. Compilá (`F7`). Debería decir: `0 errors, 0 warnings`.

---

## ⚙️ Parámetros sugeridos para testear

| Parámetro     | Valor sugerido |
|---------------|----------------|
| `NumOrders`   | 2              |
| `LotSize`     | 0.1            |
| `TP_Percent`  | 1.0            |
| `SL_Percent`  | 0.5            |

---

## ▶️ Instrucciones del Strategy Tester

1. Abrí MT5 → `Ctrl + R` → Strategy Tester.
2. Elegí el EA: `RBQY_Test_B2`.
3. Activo con tendencia clara: XAUUSD, NAS100, BTCUSD.
4. Timeframe: M5 o M15.
5. Activá **modo visual**.
6. Modelo: **Every tick based on real ticks**.
7. Presioná **Start**.

---

## 🔍 Qué verificar

- ¿Opera solo si hay tendencia + vela confirmada?
- ¿Evita duplicar operaciones?
- ¿TP y SL se colocan correctamente?
- ¿Respeta `NumOrders`?
- ¿No opera si ya hay operación contraria?

---

## ✅ Resultado esperado

- Comportamiento alineado con el diseño del bloque 2.
- Compatibilidad total con builds modernos de MetaTrader 5.
- Modo de entrada profesional usando `CTrade`.

---

