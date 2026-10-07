# Resumen Analítico de Artículo de Investigación 3.Obra publica municipal

**Referencia Bibliográfica:**
> González Casiano, U., Maldonado Mejía, M. T., & Hurtado Avilés, G. (2026). *A Dimensional Data Warehouse for Geospatial Monitoring of Municipal Public Works, with an Evolution Path Toward a Lakehouse Architecture*. Escuela Superior de Cómputo (ESCOM), Instituto Politécnico Nacional. https://github.org/Gabrielhuav/PublicMunicipalWorks_DWH

---

### 1. Qué problema aborda y por qué importa
El artículo aborda la fragmentación, la falta de transparencia y la dificultad para auditar la gestión de obras públicas a nivel municipal en México. Las secretarías de obras públicas municipales gestionan simultáneamente presupuestos, contratistas, supervisores de campo, fotografías de avance y reportes en formatos heterogéneos; sin embargo, la mayoría opera con hojas de cálculo aisladas o sistemas transaccionales que impiden el análisis histórico, la detección temprana de sobrecostos/retrasos y la participación ciudadana informada.

Este problema es sumamente relevante porque la gestión transparente de la infraestructura pública municipal es uno de los mayores desafíos de gobernanza digital. Además, las plataformas empresariales de análisis de datos (*Big Data* / *Lakehouse* comerciales) resultan económicamente inviables para el presupuesto de gobiernos municipales pequeños o rurales.

### 2. De dónde provienen los datos, en qué formato estaban y qué tuvo que hacerse para poder usarlos
Los datos procesados provienen de dos tipos de fuentes:
1. **Datos estructurados:** Registros de obras, presupuestos, contratistas, personal, geolocalización y votos/propuestas ciudadanas de 55 comunidades del municipio de Temascaltepec, Estado de México (evaluados mediante un dataset sintético poblado de 1,247 obras públicas por $127.4 millones de pesos).
2. **Evidencia no estructurada:** Archivos binarios de reportes fotográficos de campo (formatos JPG/PNG) y expedientes técnicos en documentos PDF.

**Procesamiento y Transformación:**
* **Sincronización mediante Triggers:** A diferencia de los procesos ETL tradicionales basados en lotes periódicos, los datos estructurados se ingieren desde el sistema operacional (OLTP) y se sincronizan hacia el Data Warehouse analítico en tiempo real mediante *triggers* de base de datos.
* **Almacenamiento de Objetos en la Nube:** Para la evidencia no estructurada (imágenes y PDFs), se utilizó un almacenamiento de objetos S3 (*Cloudflare R2*) con particionamiento tipo *Hive* (`works/{work_id}/reports/{year}-{month}/{ts}_{slug}.{ext}`).
* **Vincular Datos y Evidencia:** Los metadatos de los archivos (URL pública, tamaño, MIME type, fecha) se persisten en tablas del Data Warehouse, creando un vínculo bidireccional entre la evidencia fotográfica y los registros numéricos.

### 3. Cómo se modeló la información: entidades/dimensiones y hechos
La información se estructuró bajo un modelo dimensional en estrella (*Star Schema*) optimizado para OLAP, compuesto por **2 tablas de hechos** y **10 tablas de dimensión**:

* **Tablas de Hechos (Fact Tables):**
  * `fact_audit_events`: Grano de *un evento atómico e inmutable de auditoría* (17 tipos de eventos: creación de obra, modificación de presupuesto, carga de imagen, voto ciudadano, etc.), particionada por año.
  * `fact_work_monthly`: Grano de *una obra por cada mes calendario* (snapshot periódico que almacena costo acumulado, saldo restante, % de avance físico, % financiado y días de retraso).

* **Entidades y Dimensiones (Dimensions):**
  * **SCD Tipo 2 (Slowly Changing Dimension - Mantiene Historial Completo):** 5 dimensiones clave que requieren trazabilidad histórica auditables (`dim_work`, `dim_region`, `dim_company`, `dim_staff`, `dim_budget`). Usan rango de fechas de validez (`effective_date`, `expiration_date`, `is_current`) para reconstruir el estado exacto de una obra en cualquier momento del tiempo.
  * **SCD Tipo 1 (Sobrescribe Cambios):** 3 dimensiones de estado actual (`dim_source` para fuentes de financiamiento, `dim_citizen` y `dim_proposal` para participación ciudadana).
  * **SCD Tipo 0 (Catálogos Fijos):** 2 dimensiones estáticas (`dim_time` y `dim_event_type`).

**Relación entre elementos:** Las tablas de hechos se relacionan con las dimensiones mediante llaves subrogadas (*surrogate keys*). Esto permite evaluar simultáneamente los eventos de cambio y las fotos de avance con las dimensiones territoriales y presupuestales a lo largo del tiempo.

### 4. Qué preguntas concretas puede responder el sistema resultante
El sistema expuesto a través de una API REST y un visor geoespacial interactivo permite responder:
* ¿Cuál era el presupuesto exacto autorizado de una obra en una fecha específica en el pasado cuando se aprobó un pago (auditoría temporal SCD 2)?
* ¿Qué obras públicas presentan anomalías extremas de retraso (más de 120 días de desvío sobre el cronograma) o incongruencias entre avance financiero alto (>80%) y avance físico bajo (<30%)?
* ¿Cuál es el nivel de inversión pública por habitante en cada comunidad en relación con su índice de desarrollo?
* ¿Qué contratistas o supervisores acumulan el mayor número de alertas presupuestales o retrasos recurrentes?
* ¿Cómo se distribuyen geográficamente las propuestas y votos de la ciudadanía respecto a las obras ejecutadas en sus regiones?

### 5. Qué limitaciones reconocen los autores y qué trabajo futuro proponen

* **Limitaciones reconocidas:**
  * **Arquitectura aún no fully-Lakehouse:** El almacenamiento de objetos guarda imágenes/PDFs pero no es ejecutable analíticamente (falta un formato de tabla abierta como Iceberg/Delta).
  * **Falta de Transacción Atómica en Archivos:** Si falla la base de datos tras subir una imagen a R2, el archivo queda huérfano (utiliza compensación básica en lugar de transacciones distribuidas).
  * **Desempeño del Detector de Anomalías:** La regla de detección simple (C1–C3) fue eficaz detectando obras paralizadas o "fantasmas", pero tuvo bajo desempeño (.09 precisión) detectando sobreprecios, ya que no compara costos por tipo de obra similar.
  * **Seguridad de la API:** La autenticación de roles viaja en encabezados HTTP y los tokens de sesión no tienen expiración automática aún.

* **Trabajo futuro propuesto:**
  1. Evolucionar hacia una **arquitectura Lakehouse completa** mediante formatos de tabla abierta (*Apache Iceberg* o *Parquet*) consultables directamente en el almacenamiento de objetos mediante motores ligeros como *DuckDB* o *Trino*.
  2. Implementar un pipeline de **Visión por Computadora (IA)** para clasificar e identificar automáticamente el porcentaje de avance físico a partir de las fotos subidas.
  3. Mapear el esquema a vocabulario OWL / Datos Enlazados y exponer un endpoint compatible con el estándar internacional **OC4IDS** (*Open Contracting for Infrastructure Data Standard*).
  4. Recalcular el criterio de anomalía presupuestal ajustándolo por tipo de obra y validar la herramienta con registros municipales reales en otros ayuntamientos.
