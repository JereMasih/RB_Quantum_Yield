
# 🔧 Bloque 2 – Confirmación de Vela y Ejecución de Operaciones  
**Proyecto R&B Quantum Yield** | Registro y desarrollo de bloque

---

## 🧭 Estado actual del Plan Educativo (etapas cruzadas hasta ahora)

| Etapa | Nombre | Estado |
|-------|--------|--------|
| 1 | Fundamentos de trading algorítmico | ✅ Completado (Bloque 1) |
| 2 | Ecosistema MetaTrader 5 y fundamentos MQL5 | ✅ En curso |
| 3 | Requirements Engineering & diseño técnico | 🟡 Aquí profundizamos ahora |
| 4 | Ingeniería de prompts aplicada | ✅ Dominada y en práctica |
| 5 | Pruebas, backtesting y control de riesgo | 🟡 Iniciado en Bloque 1 |
| 6 | Deploy, monitoreo y mantenimiento | 🔒 Etapa final (aún no abordada) |

---

## 🎯 Objetivo técnico del Bloque 2

> Que el robot **abra operaciones** solo cuando:
> - Se haya confirmado una **tendencia** (resultado del Bloque 1), y
> - Se cierre una **vela a favor de la tendencia** en el marco de ejecución elegido.

---

## 🎓 Objetivos educativos de este bloque

| Tema | Qué aprenderé |
|------|----------------|
| 🧠 Lógica booleana | Cómo validar condiciones múltiples con precisión (`if` anidados y combinados) |
| 🧱 OnTick estructurado | Cómo definir el momento exacto para ejecutar una orden y evitar errores |
| 🧩 Modularidad en ejecución | Separar análisis de tendencia, validación de vela y ejecución en módulos |
| 💾 Control de estado | Cómo evitar que el robot entre dos veces en la misma vela (detección de nueva vela) |
| 🧪 Validación visual | Cómo testear correctamente un sistema basado en velas confirmadas |

---

## 🔧 Propuesta de trabajo para este bloque

### ✅ Paso 1 – Aprendizaje teórico guiado

- Qué significa **“vela confirmada”**
- Cómo detectar si **una vela fue alcista o bajista**
- Cómo evitar **entradas múltiples en la misma vela**
- Cuáles son los **errores comunes** y cómo evitarlos

📌 Este paso se desarrollará en una sección aparte dentro de esta misma página (bloque colapsable Notion).

---

### ✅ Paso 2 – Ingeniería de Prompt del Bloque 2

- Estructura del prompt profesional con:
  - Contexto del bloque
  - Objetivo exacto
  - Requisitos técnicos
  - Formato de salida esperado
  - Restricciones claras
- Esta sección te permitirá mejorar tu capacidad de diseñar software mediante prompts reutilizables.

---

### ✅ Paso 3 – Generación, prueba y documentación

- Crear el bloque de código basado en el prompt anterior
- Probarlo en MT5 en modo visual
- Validar comportamiento en gráficos
- Documentar resultados, errores y mejoras
- Generar bloque final para integración en el EA completo

---

## 🧾 Registro de progreso

> Aquí se irán incorporando las subsecciones del bloque:
> - 🧠 Enseñanza de concepto de vela confirmada
> - ✍️ Prompt diseñado
> - 🔧 Código generado
> - 🧪 Pruebas realizadas
> - 📋 Resultados y análisis
> - ✅ Versión final lista para integración

---

## 🚀 Siguiente paso

Cuando se confirme esta estructura, se procederá a iniciar el **Paso 1: Enseñanza teórica del concepto de “vela confirmada”**, con ejemplos, diagramas y preguntas guiadas.

