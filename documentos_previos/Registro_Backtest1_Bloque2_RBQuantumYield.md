
# 📊 Registro del Primer Backtest – Bloque 2  
**R&B Quantum Yield – Confirmación de Vela + Entrada**

---

## 🧪 Resultado general

Se ejecutó un backtest visual exitoso del archivo `RBQY_Test_B2.ex5` usando:

- **Símbolo:** XAUUSD  
- **Timeframe:** M1  
- **Periodo:** 9 al 16 de junio de 2025  
- **Balance inicial:** $10.000  
- **Modelo:** Every tick based on real ticks  
- **Modo visual activado:** ✅

---

## 📷 Capturas cargadas

- MFE/MAE de operaciones  
- Profit por hora / día / mes  
- Distribución de entradas por sesión  
- Holding Time vs Profit  
- Visualización en gráfico: entradas bien distribuidas y coherentes  
- Parámetros utilizados visibles desde `.set`

---

## ⚙️ Parámetros usados (desde archivo `.set`)

| Parámetro           | Valor aplicado |
|---------------------|----------------|
| `WeightTF`          | H4             |
| `FastPeriod`        | 50             |
| `SlowPeriod`        | 200            |
| `NumOrders`         | 1              |
| `LotSize`           | 0.01           |
| `% del balance TP`  | 0.03           |
| `% del balance SL`  | 0.3            |

📌 Estos valores generaron resultados positivos y estables durante el testeo.

---

## 🧠 Observaciones de usabilidad y configuración

1. **Confusión en inputs:**  
   Los parámetros `TP_Percent` y `SL_Percent` no eran suficientemente descriptivos.  
   🔁 **Propuesta de mejora:**  
   Renombrarlos a `TP_PercentOfBalance` y `SL_PercentOfBalance` para dejar claro que son **por orden individual**.

2. **Falta de control de dirección en operaciones abiertas:**  
   El robot **restringe entradas cuando hay operaciones abiertas en contra**, pero no permite operar en la misma dirección de una posición abierta si ya existe una.

   🔁 **Propuesta de nuevo parámetro:**  
   ```mql5
   input bool AllowOppositeDirectionTrading = false;
   ```

   Este input permitirá al usuario decidir si:
   - ✅ El robot **puede operar en contra** de la posición abierta.
   - 🚫 El robot solo puede operar en **la misma dirección** de lo que ya está en el mercado.

---

## 📦 Archivos subidos

- HTML: `REPORTE PRIMER BACKTEST.html`  
- `.set`: plantilla de configuración usada  
- Capturas de todos los gráficos relevantes  
- Journal del Strategy Tester: `Journal del 1st test.txt`

---

## ✅ Estado actual

- Bloque 2 funcional ✅  
- Backtest visual y técnico completo ✅  
- Observaciones registradas ✅  
- Parámetro nuevo propuesto: pendiente de implementación 🔧

---

## 🚀 Próximo paso

1. Implementar el parámetro `AllowOppositeDirectionTrading`.
2. Ajustar el bloque 2 para que evalúe esta condición antes de decidir operar.
3. Ejecutar segundo test visual para validar el nuevo comportamiento.

