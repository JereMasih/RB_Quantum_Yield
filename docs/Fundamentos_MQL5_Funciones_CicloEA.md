
# 🧠 Fundamentos de MQL5 – Funciones del Ciclo de Vida y Estructura del EA

---

## 🎯 ¿Qué es MQL5?

**MQL5** es el lenguaje de programación de MetaTrader 5.  
Sirve para crear:
- Expert Advisors (robots de trading)
- Indicadores personalizados
- Scripts y herramientas

Está basado en C++ pero adaptado al trading.

---

## 📂 Tipos de archivos principales

| Extensión | Uso |
|-----------|-----|
| `.mq5` | Archivo principal del robot (compilable y ejecutable) |
| `.mqh` | Módulo o librería reutilizable (se incluye con `#include`) |
| `.ex5` | Archivo compilado (no editable, listo para usar en MetaTrader) |

---

## 🧩 ¿Qué funciones debe tener un archivo `.mq5`?

Un archivo `.mq5` debe contener como mínimo una de estas funciones especiales:

### ✅ `OnInit()`
Se ejecuta **una vez al inicio**, cuando cargás el EA al gráfico.

```mql5
int OnInit()
{
    Print("Robot iniciado");
    return INIT_SUCCEEDED;
}
```

Uso típico:
- Crear handles
- Inicializar variables
- Mostrar bienvenida

---

### ✅ `OnTick()`
Se ejecuta **cada vez que llega un nuevo tick de precio**.

```mql5
void OnTick()
{
    // Lógica del robot en tiempo real
}
```

Uso típico:
- Análisis de mercado
- Detección de señales
- Ejecución de órdenes
- Trailing Stop y gestión de riesgo

---

### ✅ `OnDeinit()`
Se ejecuta **cuando se cierra el robot** (por cambio de símbolo, timeframe o manualmente).

```mql5
void OnDeinit(const int reason)
{
    Print("Cerrando robot");
}
```

Uso típico:
- Liberar recursos
- Cerrar archivos o handles
- Guardar estado

---

## 🔗 ¿Cómo se conectan `.mq5` y `.mqh`?

- El archivo `.mq5` es el **cerebro maestro**.
- Los archivos `.mqh` son **módulos funcionales** que contienen funciones auxiliares.
- Se conectan con:
```mql5
#include "TrendDetectionBlock.mqh"
#include "EntryBlock.mqh"
```

---

## 📦 ¿Puedo tener todo en un solo archivo `.mq5`?

**Sí.** Al final del desarrollo podés:

1. Copiar y pegar el contenido de todos los `.mqh` en el `.mq5`.
2. Eliminar los `#include`.
3. Compilar un único archivo `.mq5` con toda la lógica.
4. Esto genera un `.ex5` funcional, listo para entregar o vender.

---

## ✅ ¿Cuál es mejor?

| Método | Ventajas | Desventajas |
|--------|----------|-------------|
| **Modular (con `.mqh`)** | Fácil de mantener y escalar. Reutilizable. | Requiere mantener múltiples archivos. |
| **Consolidado (`.mq5` único)** | Fácil de entregar. Un solo archivo. | Más difícil de leer y depurar a futuro. |

👉 Para aprendizaje y testing: **Modular**  
👉 Para entrega final o venta: **Consolidado**

---

## 📌 Conclusión

Todo EA en MQL5 debe tener al menos una de estas funciones clave:

- `OnInit()` → se ejecuta al inicio
- `OnTick()` → se ejecuta en cada tick
- `OnDeinit()` → se ejecuta al finalizar

Estas funciones estructuran el comportamiento del robot. Los módulos `.mqh` te permiten **dividir y organizar** tu código, pero al final podés consolidarlo todo en un solo `.mq5`.

