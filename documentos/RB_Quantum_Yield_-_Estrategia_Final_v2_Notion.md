# 🧠 Estrategia del Robot R&B Quantum Yield

### 🔍 Visión General

El robot **R&B Quantum Yield** es un **Expert Advisor totalmente automatizado** para MetaTrader 5 que combina dos funciones clásicas (generador de señales y ejecutor) en **un solo archivo**. Su objetivo es detectar la **dirección del mercado** con alta confiabilidad antes de permitir cualquier operación.

Primero, analiza seis marcos temporales: **M1, M5, M15, H1, H4 y D1**. En cada uno, se evalúa el **cruce de medias móviles exponenciales (EMA)**: la **EMA de 50** y la **EMA de 200**.

Cuando **al menos tres** de los seis marcos temporales coinciden en la **misma dirección (alcista o bajista)**, se considera una **señal válida de tendencia**. **Importante**: dentro de esos tres marcos que coinciden, **obligatoriamente debe estar H1, H4 o D1**.

En ese momento, el robot lo mostrará en pantalla:
- Indicará visualmente cuál es la dirección del mercado.
- Mostrará el estado individual de cada uno de los seis marcos temporales.
- Confirmará si hay dirección válida y si la operativa está **habilitada**.

Recién cuando se confirma la tendencia, el robot está autorizado para operar.

---

### ✅ Ejecución de Trades

Una vez que la tendencia esté confirmada:

1. El usuario define en los inputs el **marco temporal de ejecución de operaciones** (por ejemplo, M1).
2. Cada vez que **una vela cierre a favor de la tendencia** (alcista si estamos en BUY, bajista si estamos en SELL), el robot:
   - Abre una cantidad de operaciones definida en `Número de operaciones por señal`.
   - Cada operación usa el lotaje indicado en `Tamaño por operación`.
3. Las operaciones se siguen abriendo mientras la condición de vela + señal siga cumpliéndose.
4. La operación se mantiene hasta alcanzar:
   - El `Take Profit` global (configurado en %).
   - El `Stop Loss` global (configurado en %).
   - O intervención manual del usuario.

---

### ⚙️ Inputs del Robot

- `Marco temporal de ejecución`: timeframe donde se ejecutan las operaciones (por ejemplo: M1, M5, M15).
- `Número de operaciones por señal`: cantidad de operaciones a abrir cada vez que se detecta una vela válida con señal.
- `Tamaño por operación`: lotaje fijo para cada operación.
- `Take Profit global (%)`: desde **1% hasta 10.000%**, en pasos de 1%.
- `Stop Loss global (%)`: configurable desde 0% hasta el límite permitido por el usuario.
- `Trailing Stop`: configurable (por porcentaje o pips).
- `Activar filtro de noticias`: sí/no.
- `Horario operativo permitido`: bloques horarios opcionales para activación.
- `Max operaciones por día`: límite diario de trades abiertos.
- `Modo prop firm`: activa lógica de control de drawdown según cuentas FTMO, MyForexFunds, etc.

---

¿Querés que ahora te lo entregue como archivo descargable o seguimos con otra sección del documento? También puedo construir el panel visual o los textos de ayuda para cada input si querés armarlo completo.

---

### 🔧 Mejoras Futuras y Filtros Avanzados

- 🔮 En futuras versiones se contempla **añadir un filtro adicional a la señal de dirección confirmada**, para mejorar la tasa de aciertos. Esto podría incluir indicadores complementarios, acción del precio o validaciones más robustas.
- 🚫 El robot **no puede abrir operaciones en ambas direcciones a la vez**. Solo abre trades **en la dirección detectada de la tendencia**.

---

### 🔁 Nuevas Configuraciones Añadidas

| **Parámetro** | **Descripción** |
|---------------|-----------------|
| `Salto de señal si spread mayor a X pips` | El robot ignorará la señal si el spread actual es mayor al valor definido por el usuario (en pips). |
| `Slippage máximo permitido (en puntos)` | Define el slippage máximo tolerado por el usuario para ejecutar una orden. Si se excede, la orden se cancela. |
| `Distancia del Trailing Stop (en puntos)` | Si `Trailing Stop` está activado, este campo define la distancia en puntos que debe respetarse desde el precio actual. |
| `Equity Close All (+)` | Si el equity total del usuario alcanza este valor POSITIVO, se cierran todas las operaciones. Si se deja en 0, está desactivado. |
| `Equity Close All (-)` | Si el equity cae a este valor NEGATIVO, se cierran todas las operaciones. Si se deja en 0, está desactivado. |

📌 **Aclaración sobre las unidades**:
- **Pips** = Unidades estándar para medir spread o distancias de precios (1 pip = 10 puntos en MT5).
- **Puntos** = Unidad mínima que usa MT5 para los inputs técnicos. Por ejemplo: 500 puntos = 50 pips.

---

