## [1.17] – 2025-07-02
### Añadido
- Trailing Stop individual por trade configurable en dólares (inputs claros: TrailStartDollars y TrailStepDollars).
- Panel visual actualizado y explicaciones de inputs.
- Mejora general de robustez y visualización de prints de debug.


# Changelog – R&B Quantum Yield Bot

## [1.12] – 2025-07-02
### Añadido
- Input TradeLotSize: permite definir el tamaño de lote por operación.
- Input TradesPerSignal: permite definir cuántas operaciones abrir por señal.
- Primer panel visual simple en el gráfico (nombre, tendencia, TF, lote, trades/señal).
- Reorganización de documentos históricos a documentos_previos/
- Documento Técnico ahora disponible en formato .txt en documentos/

## [1.11] – 2025-07-02
### Corregido
- Nomenclatura de versión cambiada para cumplir con estándar MQL5 Market.
- Consolidación de toda la lógica en archivo único, sin includes extra.

## [1.10] – 2025-07-02
### Primera versión pública fase 2
- Migración a único archivo RB_Quantum_Yield_Bot.mq5
- Gestión de tendencia, filtro de confirmación de vela, entradas, SL/TP, trailing básico
- Inputs principales y estructura de repositorio profesional

## [20250729_0009] fix: restaura versión pública desde GitHub y guarda copia local anterior

- Se respaldó la versión local modificada en: versiones_anteriores/RB_Quantum_Yield_Bot_local_20250729_0009.mq5
- Se restauró la versión oficial del archivo 'RB_Quantum_Yield_Bot.mq5' desde el repositorio.


## [v1.22] feat: establece versión 1.22 como principal

- Se reemplazó la versión v1.17 por la nueva v1.22.
- La versión anterior fue respaldada como: versiones_anteriores/RB_Quantum_Yield_Bot_v1.17.mq5


## [v1.22] HUD PRO ESTABLE - versión unificada, visual y operativa

- Reemplazo completo del código base por la versión 1.22 final, autocontenida.
- HUD PRO funcional, sin includes, listo para próxima iteración.

