
# 🧠 Ejercicio de Validación – Entrada por Vela Confirmada  
**Bloque 2 – R&B Quantum Yield**  
*Resuelto por: Jere Masih*

---

## ✅ Parte 1: Preguntas de comprensión

**1. ¿Qué hace exactamente esta línea de código?**  
```mql5
datetime currentBarTime = iTime(_Symbol, _Period, 0);
```

**Respuesta de Jere:**  
Determina el horario de la vela actual. Usa la función `iTime` que entrega el horario de apertura de la vela, y dentro tiene el símbolo (`_Symbol`), el marco temporal (`_Period`) y el índice `0` porque se refiere a la vela actual.

---

**2. ¿Por qué usamos una variable `static datetime lastBarTime = 0;`?**  
**Respuesta de Jere:**  
No sé exactamente por qué la usamos. Me parece que debería ser porque queremos fijar y guardar el horario actual de la vela, pero no estoy seguro.

---

**3. ¿Qué condición nos permite saber que hay una vela nueva?**  
**Respuesta de Jere:**  
No me acuerdo.

---

**4. ¿Qué devuelve esta línea?**  
```mql5
iClose(_Symbol, _Period, 1);
```

**Respuesta de Jere:**  
Devuelve el precio de cierre de la vela anterior, en el símbolo y timeframe especificado.

---

**5. ¿Por qué no deberíamos usar `iClose(..., 0)` para decidir si entrar al mercado?**  
**Respuesta de Jere:**  
Porque la vela actual todavía no ha cerrado, por eso estaríamos operando sin información confirmada.

---

## 🧩 Parte 2: Caso práctico mental

**6. ¿Qué condición usarías para confirmar que la vela anterior fue bajista?**  
**Respuesta de Jere:**  
Comparar el precio de apertura con el de cierre de la vela anterior. Si el cierre es menor que la apertura, entonces fue una vela bajista.  
Ejemplo: `if (iClose(..., 1) < iOpen(..., 1))`.

---

**7. ¿Cuáles son las dos condiciones completas que deben cumplirse antes de ejecutar la venta?**  
**Respuesta de Jere:**  
Primero, que estemos en tendencia bajista según el análisis de cruces de EMAs en al menos tres marcos temporales (y que incluya el marco de peso).  
Segundo, que la vela anterior haya cerrado con una dirección bajista, es decir, cierre < apertura.

---

**8. ¿Dónde colocarías la orden de venta en el código para asegurarte que se ejecute una sola vez por vela?**  
**Respuesta de Jere:**  
En el momento en que se detecta el cierre de la vela, en el bloque de código que se activa una vez por vela.

---

## 📌 Evaluación del mentor

Jere demostró una excelente comprensión en:
- La diferencia entre `iClose(0)` y `iClose(1)`
- La lógica de confirmación por cierre de vela
- El peligro de operar sin esperar el cierre
- El flujo general de condiciones previas a una operación

Puntos a reforzar:
- Comprensión profunda de `iTime(...)` y su uso para detectar **nueva vela**
- Relación entre `lastBarTime` y `iTime(..., 0)` como mecanismo para ejecutar solo una vez por vela

🟡 Lo trabajaremos una vez más con ejemplos visuales al iniciar la codificación del Bloque 2.

---

## ✅ Siguiente paso sugerido

Diseñar el **Prompt técnico del Bloque 2**, aplicando todo lo aprendido aquí.

