
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

## 🛠 Archivos necesarios

- `TrendDetectionBlock.mqh` (Bloque 1)
- `EntryBlock.mqh` (Bloque 2)
- Un archivo `.mq5` de test llamado por ejemplo `RBQY_Test_B2.mq5`

Este `.mq5` debe contener el siguiente código mínimo:

```mql5
#include "TrendDetectionBlock.mqh"
#include "EntryBlock.mqh"

int OnInit()
{
   return INIT_SUCCEEDED;
}

void OnTick()
{
   CheckAndExecuteEntry();  // Ejecuta el Bloque 2
}
```

---

## 🧭 Cómo guardar, importar y compilar correctamente

1. Abrí **MetaEditor** (desde MetaTrader 5 o con `F4`).
2. En el panel izquierdo, buscá la carpeta: `MQL5 > Experts`
3. Hacé clic derecho sobre `Experts` y seleccioná **"Nuevo archivo"**
4. Elegí "Expert Advisor (template)", poné el nombre: `RBQY_Test_B2` y hacé clic en siguiente hasta finalizar.
5. Pegá el código del bloque de prueba en lugar del código generado automáticamente.
6. Asegurate de tener los archivos `TrendDetectionBlock.mqh` y `EntryBlock.mqh` guardados en la carpeta `MQL5 > Include`.
7. Al comienzo del archivo agregá:
```mql5
#include <TrendDetectionBlock.mqh>
#include <EntryBlock.mqh>
```
8. Guardá el archivo (`Ctrl + S`).
9. Presioná **F7 o clic en “Compilar”**.
10. Verificá que diga: “0 errores, 0 advertencias”.

---

## ⚙️ Parámetros recomendados para el test

| Parámetro | Valor sugerido |
|-----------|----------------|
| `NumOrders` | 2 |
| `LotSize` | 0.1 |
| `TP_Percent` | 1.0 |
| `SL_Percent` | 0.5 |

---

## ▶️ Cómo correr el test en el Strategy Tester

1. Abrí MetaTrader 5 → presioná `Ctrl + R` para abrir el **Strategy Tester**.
2. Elegí el EA compilado: `RBQY_Test_B2`.
3. Seleccioná un símbolo con tendencia clara: XAUUSD, NAS100, BTCUSD, etc.
4. Timeframe recomendado: M5 o M15.
5. Activá el **modo visual**.
6. En "Modelo", elegí: **Every tick based on real ticks**.
7. Presioná **Start** para iniciar el test.

---

## 🔍 Qué observar

- ¿Opera solo si hay una vela cerrada a favor?
- ¿Evita operar más de una vez por vela?
- ¿Respeta el número de órdenes y su tamaño?
- ¿TP y SL se colocan correctamente como % del balance?
- ¿Evita operar si ya hay una operación en contra?

---

## 📸 Capturas útiles

- Ejecución de operación con confirmación clara
- Escenarios donde **NO opera** por falta de validación
- TP y SL colocados correctamente
- Evitación de duplicación

---

## 📌 Notas finales

- Este test **no incluye trailing, equity targets ni filtros de spread**.
- Solo se valida **entrada disciplinada** según lógica del Bloque 2.

---

## ✅ Resultado esperado

- El robot actúa solo si:
  - Hay una tendencia activa detectada
  - La vela anterior cerró a favor
  - No hay operaciones en contra
- Se ejecutan las operaciones configuradas con parámetros válidos.
