
# RB Quantum Yield 🪙🤖  
*Versión 1.0 — 25 Jun 2025*

> Robot de trading algorítmico para **MetaTrader 5** con enfoque modular y educativo.  
> Este repositorio contiene el código fuente, recursos educativos y bitácora de desarrollo.

---

## 🚀 Resumen rápido
| Bloque | Módulo | Estado | Descripción |
|--------|--------|--------|-------------|
| 1 | `TrendDetectionBlock.mqh` | ✅ | Detección de tendencia multitemporal (EMA‑Cross en M1 → D1). |
| 2 | `EntryBlock_Moderno.mqh` | ✅ | Confirmación de vela + aperturas con `CTrade`. |
| 3 | _Exit & Trailing_ | 🔜 | Gestión de salidas, trailing‑stop y BE. |

---

## 📂 Estructura mínima del repo
```
RB_Quantum_Yield/
├── src/                  # Código .mq5 y .mqh
│   ├── TrendDetectionBlock.mqh
│   ├── EntryBlock_Moderno.mqh
│   └── ...
├── docs/                 # PDF, imágenes y notas de estrategia
│   └── ...
├── tests/                # Scripts de backtest, sets, logs
├── CHANGELOG.md
└── README.md             # ¡Este archivo!
```

---

## 🔧 Instalación rápida
1. **Clonar** el repo  
   ```bash
   git clone https://github.com/TU_USUARIO/RB_Quantum_Yield.git
   ```
2. **Copiar** `src/*.mqh` y el EA final `.mq5` en la carpeta _MQL5/Experts_ de tu MetaTrader.
3. Compilar en MetaEditor → probar en el Strategy Tester.

---

## 🎓 Ruta educativa
| Checkpoint | Tema | Recursos |
|------------|------|----------|
| 1 | Conceptos MT5 + MQL5 | `/docs/Bloque_1_*` |
| 2 | Estructura modular + CTrade | `/docs/B2_*` |
| 3 | Funciones reutilizables & arrays | _en progreso_ |

> La bitácora detallada de avances vive en **Notion** y se sincroniza manualmente cada semana.

---

## 🗒️ Uso básico
```mql5
#include <TrendDetectionBlock.mqh>
#include <EntryBlock_Moderno.mqh>

void OnTick()
{
   int trend = TrendDetect();
   if(trend!=0)
      TryEntry(trend);
}
```

---

## 🛠️ Contribuir
1. Crea una rama: `git checkout -b feat/nombre‑claro`
2. Commits atómicos siguiendo _Conventional Commits_.
3. Pull Request hacia `main`.

---

## 🗃️ Versionado
Usamos **Semantic Versioning**: `MAJOR.MINOR.PATCH`

- **MAJOR** — cambios incompatibles  
- **MINOR** — funciones retro‑compatibles  
- **PATCH** — correcciones menores  

---

## ⚖️ Licencia
MIT © 2025 Jere Masih
