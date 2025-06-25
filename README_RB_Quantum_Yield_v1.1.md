# RB Quantum Yield – README v1.0

> *MetaTrader 5 Expert Advisor (EA) project*  
> *Author: **Jere Masih** · Technical mentor: **ChatGPT** (OpenAI o3)*

---

## 1 · Objetivo del robot

Crear un **EA modular** que detecte la tendencia multitemporal y, cuando exista confirmación por vela, ejecute entradas gestionadas con _take‑profit_ y _stop‑loss_ porcentuales sobre el **balance**.

| Bloque | Estado | Archivo | Descripción |
|--------|--------|---------|-------------|
| 1 – Detección de tendencia | ✅ Terminado | `TrendDetectionBlock.mqh` | Analiza cruces de EMA en M1, M5, M15, H1, H4, D1. |
| 2 – Confirmación + Entrada | 🛠️ **En curso** | `EntryBlock_Moderno.mqh` | Lanza órdenes con **CTrade** tras vela confirmada. <br/>Implementando `AllowOppositeDirectionTrading`. |
| 3 – Gestión de salidas | ⏳ Pendiente | _Próximo_ | Trailing‑stop, break‑even, etc. |

---

## 2 · Estructura del repositorio

```
RB_Quantum_Yield/
├── src/                  # Código fuente (.mq5 / .mqh)
│   ├── TrendDetectionBlock.mqh
│   └── EntryBlock_Moderno.mqh
├── docs/                 # Backtests, capturas, especificaciones
├── tests/                # Scripts de prueba
└── README_RB_Quantum_Yield_v1.0.md
```

> **Tip:** Usa ramas (`feature/…`) para desarrollos experimentales y deja `main` siempre estable.

---

## 3 · Trabajo realizado

* **Bloque 1 convertido a librería** reutilizable (`.mqh`).
* **Bloque 2** migrado a **CTrade**, compilado sin errores y testeado visualmente.
* Sistema de **versionado** acordado: `archivo_vMAJOR.MINOR.ext`.
* Repositorio GitHub configurado y primer _commit_ subido.

---

## 4 · Trabajo en curso

1. **Parámetro** `AllowOppositeDirectionTrading`  
   *Lógica: permitirse/no abrir posiciones contrarias cuando existen abiertas.*
2. **Renombrar inputs** para claridad:  
   `TP_Percent` → `TP_PercentOfBalance`  
   `SL_Percent` → `SL_PercentOfBalance`
3. Documentar ejemplos de uso en `/docs`.

---

## 5 · Próximos hitos

| Nº | Tarea | Responsable | Deadline (tentativo) |
|----|-------|-------------|-----------------------|
| 1 | Finalizar Bloque 2 + pruebas unitarias | ChatGPT + Jere | 30 Jun |
| 2 | Diseñar Bloque 3 (salidas) | ChatGPT | 02 Jul |
| 3 | Backtest integral 2022‑2024 | Jere | 05 Jul |

---

## 6 · Compilación y test

1. Copia `src/*.mqh` a la carpeta **Include** de MetaTrader 5.  
2. En el **Editor de MetaQuotes**, crea el `.mq5` principal e incluye los bloques:  

   ```cpp
   #include <TrendDetectionBlock.mqh>
   #include <EntryBlock_Moderno.mqh>
   ```
3. Compila (`F7`) y ejecuta **Estrategia** en el _Tester_.

---

## 7 · Versionado

> Formato **ArchivoProyecto_vMAJOR.MINOR.ext**  
> Ejemplo: `EntryBlock_Moderno_v1.2.mqh`

* `MAJOR` → Cambios de interfaz o lógica que rompen compatibilidad.  
* `MINOR` → Mejoras, refactors, _bugfixes_ compatibles.

---

## 8 · Licencia

MIT License – libre para uso y modificación con atribución.

---

_Feel free to open issues or pull requests!_