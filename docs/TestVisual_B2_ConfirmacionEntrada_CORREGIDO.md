
# 🧪 Test Visual – Bloque 2: Confirmación de Vela + Entrada  
**Proyecto: R&B Quantum Yield**

---

## 🎯 Objetivo del test

Verificar visualmente que el **Bloque 2**:

1. Opera **solo cuando hay cierre de vela en dirección de la tendencia**.
2. Respeta la cantidad de órdenes configuradas (`NumOrders`).
3. Aplica correctamente el cálculo de TP y SL como **porcentaje del balance**.
4. **No ejecuta múltiples entradas en la misma vela**.
5. **No opera si hay órdenes abiertas en contra**.

---

## 🛠 Preparación

### Archivos necesarios:
- `TrendDetectionBlock.mqh` (Bloque 1)
- `EntryBlock.mqh` (Bloque 2)
- Un archivo `.mq5` de test que contenga el siguiente código:

```mql5
#include "TrendDetectionBlock.mqh"
#include "EntryBlock.mqh"

int OnInit()
{
   return INIT_SUCCEEDED;
}

void OnTick()
{
   CheckAndExecuteEntry();  // Bloque 2
}
```

📌 **Este archivo lo vas a guardar como por ejemplo: `RBQY_Test_B2.mq5` y compilarlo en MetaEditor.**

---

## ⚙️ Parámetros sugeridos para el test

| Parámetro | Valor recomendado |
|-----------|-------------------|
| `NumOrders` | 2 |
| `LotSize` | 0.1 |
| `TP_Percent` | 1.0 |
| `SL_Percent` | 0.5 |

---

## 🧭 Instrucciones para el test

1. Abrí MetaTrader 5 y pulsá `Ctrl + R` para abrir el **Strategy Tester**.
2. Seleccioná tu archivo compilado: **`RBQY_Test_B2.ex5`**.
3. Elegí un activo con tendencia clara (XAUUSD, NAS100, BTCUSD...).
4. Elegí un timeframe de ejecución corto (M5 o M15).
5. Activá modo **Visual**.
6. En "Modo de modelado", seleccioná: **Every tick based on real ticks**.
7. Hacé clic en **Start** para ejecutar el test.

🔍 Observá lo siguiente:
- ¿Opera solo cuando hay vela en dirección de la tendencia?
- ¿Evita operar si ya hay una operación abierta en contra?
- ¿Opera solo una vez por vela?
- ¿TP y SL están bien colocados como % del balance?

---

## 📸 Capturas recomendadas

Tomá screenshots cuando:

- Se abre una operación con confirmación visual
- El robot decide no operar por falta de vela confirmada
- Se ven claramente TP y SL en pantalla
- Hay señales, pero ya hay operaciones abiertas (y no duplica)

---

## 📌 Notas importantes

- Este test **no evalúa trailing stop, equity targets ni filtros de spread/slippage**.
- Solo evalúa el **comportamiento de entrada disciplinada**.

---

## ✅ Resultado esperado

- Las órdenes se abren solo cuando hay:
  - Tendencia activa
  - Cierre de vela a favor
  - Ausencia de órdenes abiertas en contra
- Se respeta `NumOrders` y `LotSize`
- TP y SL reflejan los porcentajes definidos

---

