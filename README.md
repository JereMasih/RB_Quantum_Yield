# R&B - Quantum Yield Bot

Bienvenido al repositorio oficial de **R&B - Quantum Yield Bot**, el Expert Advisor profesional para MetaTrader 5 desarrollado por Jere Masih & ChatGPT.

---

## Descripción

Este robot ejecuta una estrategia de **seguimiento de tendencia multitemporal** utilizando cruces de medias móviles exponenciales, confirmación de velas y un sistema de gestión de riesgo avanzado.

> **Este repositorio implementa la Fase 2 del proyecto:**  
> Archivo único `.mq5`, documentación profesional, y toda la lógica consolidada y testeada.

---

## Estructura del repositorio

RB_Quantum_Yield/
├── RB_Quantum_Yield_Bot.mq5 # EA principal (versión única)
├── CHANGELOG.md
├── README.md
├── documentos/ # Documento Técnico (última versión en .txt)
├── documentos_previos/ # Documentación histórica y versiones antiguas
├── tests/ # Sets y reportes de backtest
├── versiones_anteriores/ # Código viejo, pruebas, archivos desactualizados


---

## Documento Técnico

La **fuente única de verdad (SSOT)** para la lógica y parámetros está en:  
`documentos/Documento_Tecnico_RB_Quantum_Yield_Bot.txt`

Siempre que modifiques la lógica, **debes actualizar primero este documento** antes de cambiar el código.

---

## Principales características

- Estrategia multitemporal de cruce de EMAs (M1, M5, M15, H1, H4, D1)
- Confirmación de entrada por cierre de vela
- Gestión de riesgo avanzada: SL/TP global e individual, trailing, filtros operativos
- **Inputs configurables:**
  - Tamaño de lote por operación (`TradeLotSize`)
  - Cantidad de operaciones por señal (`TradesPerSignal`)
- Panel visual simple en gráfico (versión básica)
- Compatible con backtesting y forward-testing en MetaTrader 5
- Trailing Stop individual por trade configurable en USD, con activación y paso fácil de entender.
- Lógica alineada con documento técnico y panel robusto en gráfico.

---

## Flujo de trabajo recomendado

1. Actualizar **Documento Técnico** (`documentos/Documento_Tecnico_RB_Quantum_Yield_Bot.txt`)
2. Modificar el código en `RB_Quantum_Yield_Bot.mq5`
3. Ejecutar pruebas en la carpeta `/tests/`
4. Actualizar `CHANGELOG.md`
5. Commit y push en rama `main`

---

## Créditos

Desarrollado por **Jere Masih** junto a **ChatGPT**  
© 2025

---

