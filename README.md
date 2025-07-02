# R&B Quantum Yield – Expert Advisor para MetaTrader 5

> **Repositorio oficial – Última actualización: 26/06/2025**

---

## 🟢 Estado actual del desarrollo

- **Robot funcional y modular:**  
  El sistema opera en modo backtest y real sin errores de compilación ni advertencias. Arquitectura lista para agregar y ajustar bloques fácilmente.
- **Repositorio limpio y versionado:**  
  Solo se mantienen en la raíz los archivos activos; versiones anteriores se archivan en `/docs/versiones anteriores/`.
- **Documentación y pruebas en progreso:**  
  Los módulos, inputs y salidas están documentados para facilitar la continuidad, debug y colaboración.

---

## 🎯 Objetivo técnico del proyecto

Desarrollar un **Expert Advisor profesional para MetaTrader 5** capaz de:

1. **Detectar la tendencia dominante multitemporal** usando cruces de EMAs en 6 timeframes (M1, M5, M15, H1, H4, D1), requiriendo mínimo 3 marcos alineados y que el "marco de peso" elegido esté incluido.
2. **Confirmar y ejecutar operaciones** solo ante cierre de vela a favor de la tendencia, con opción de permitir o no entradas contrarias según configuración.
3. **Gestionar TP/SL** por porcentaje de balance o monto fijo, a elección del usuario.
4. **Ofrecer un panel visual (HUD)** en el gráfico con información clave: dirección de la tendencia, marco de peso, cantidad de coincidencias, balance y equity.
5. **Permitir integración y registro en Notion** para documentación, logs y bitácora educativa.

---

## 📁 Estructura del repo y archivos principales
/GitHub REPO
├── RBQY_Test_B3.mq5                      # EA principal (poné este en Experts)
├── TrendDetectionBlock_v1.6.mqh          # Bloque 1: Detección multitemporal
├── EntryBlock_Modernov1.4.mqh            # Bloque 2: Confirmación y entradas
├── Trade.mqh, Object.mqh, …            # Archivos estándar de MQL5
├── /docs/
│    └── versiones anteriores/            # MQ5/MQH de etapas previas, para rollback

- **Ubicación recomendada:**  
  - *.mq5* en `MQL5/Experts/`
  - *.mqh* en `MQL5/Include/RBQY/`
  - `/docs` solo para almacenamiento y consulta, no afecta el build.

---

## 🧩 Descripción técnica de los bloques

### Bloque 1 – Detección de Tendencia Multitemporal

- Evalúa cruces EMA rápida/lenta en 6 timeframes.
- Parámetros clave:
  - `WeightTF`: timeframe "de peso" (obligatorio en coincidencia)
  - `FastPeriod`, `SlowPeriod`: periodos de EMAs
  - Todos configurables como *input*
- Lógica:
  - Suma coincidencias alcistas/bajistas, verifica si el marco de peso coincide.
  - Devuelve `TrendDir = 1` (alcista), `-1` (bajista) o `0` (sin señal).
- **Incluye HUD/Panel:**  
  - Visualización con `Comment()`: tendencia, marco de peso, balance, equity.
- **Archivo:**  
  - `TrendDetectionBlock_v1.6.mqh`

---

### Bloque 2 – Confirmación de Vela y Ejecución de Entradas

- Confirma entrada solo al cierre de vela a favor de la tendencia.
- Inputs principales:
  - `AllowCounterTrend`: permite o no señales opuestas
  - `NumOrders`, `LotSize`: cantidad y tamaño de órdenes
  - `SLTP_Mode`, `TP_Value`, `SL_Value`: gestión dinámica TP/SL (% o monto fijo)
- Seguridad:
  - No abre posiciones si existen abiertas en contra.
  - Llama a la función de cálculo de puntos según el modo de gestión.
- **Archivo:**  
  - `EntryBlock_Modernov1.4.mqh`

---

### EA principal – Integración y gestión

- Llama a ambos bloques y orquesta el flujo del robot.
- Estructura: `OnInit()`, `OnDeinit()`, `OnTick()`
- Sin lógica duplicada, solo llamadas limpias.

---

## 🚦 Gestión y buenas prácticas

- Solo los archivos activos van en la raíz.
- Cada versión funcional se archiva en `/docs/versiones anteriores/` antes de cada cambio mayor.
- Cambios y mejoras deben versionarse con mensajes de commit claros.
- Pruebas visuales y logs deben analizarse antes de cambios en la lógica base.
- El HUD puede expandirse a objetos gráficos o paneles según necesidad futura.

---
“Las especificaciones funcionales residen en documentos/Documento_Tecnico_RB_Quantum_Yield_Bot.md”.
---

## 📌 Próximos pasos y roadmap

- Validar con más backtesting los casos límite y escenarios de error.
- Incorporar filtros adicionales (spread, horario, volatilidad) si la estrategia lo requiere.
- Mejorar panel visual y agregar reportes automáticos.
- Automatizar la integración de logs y bitácora educativa en Notion.
- Estandarizar la plantilla para futuros robots y releases.

---

## 📞 Contacto y colaboración

- Autor: Jeremías Abdelmasih
- Mail: jeremias.masih@gmail.com
- Repo: [https://github.com/JereMasih/RB_Quantum_Yield](https://github.com/JereMasih/RB_Quantum_Yield)

---

> **Este README es tu hoja de ruta técnica.**
> Si recuperás archivos viejos o hacés cambios, documentá la razón y subí la versión anterior a `/docs/versiones anteriores/`.

**Actualizado por Jere & ChatGPT — 26/06/2025**