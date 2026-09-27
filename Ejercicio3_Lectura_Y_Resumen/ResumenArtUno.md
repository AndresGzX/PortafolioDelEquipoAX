# Resumen Analítico de Artículo de Investigación 1.Datos Sismicos

**Referencia Bibliográfica:**
> Villa Vargas, J. M., Hurtado Avilés, G., & Climent Hernández, J. A. (2026). Cuando México tiembla: la historia contada por los datos. *AZCATL Revista de Divulgación en Ciencias, Ingeniería e Innovación*, 4(6), 28–33. https://doi.org/10.24275/AZC2026E1004

---

### 1. Qué problema aborda y por qué importa
El artículo aborda la complejidad y la falta de accesibilidad en la comprensión de los datos sísmicos en México. Aunque el Servicio Sismológico Nacional (SSN) recopila una gran cantidad de registros históricos detallados sobre la actividad telúrica del país, esta información se presenta en un lenguaje y formato técnico que resulta difícil de interpretar de forma integral para el público no especializado, tomadores de decisiones o investigadores que buscan análisis multidisciplinarios.

La relevancia de este problema radica en que México se sitúa en una zona de alta actividad sísmica (debido a la interacción de cinco placas tectónicas). Por ello, transformar los registros sísmicos crudos en representaciones visuales e interactivas permite democratizar el conocimiento sobre la sismicidad, evaluar el riesgo territorial y comprender mejor el impacto que estos fenómenos naturales tienen en la sociedad y la infraestructura del país.

### 2. De dónde provienen los datos, en qué formato estaban y qué tuvo que hacerse para poder usarlos
Los datos analizados e integrados en el sistema provienen de dos fuentes principales:
* **Servicio Sismológico Nacional (SSN):** Catálogo histórico de sismos de México.
* **Instituto Nacional de Estadística y Geografía (INEGI):** Datos provenientes del Censo de Población y Vivienda (CPV) 2020 y los Censos Económicos (CE) 2024.

**Formato original y procesamiento:**
Los datos originales se encontraban en formatos heterogéneos, tabulares y planos (como archivos CSV/archivos de catálogo técnico del SSN y tablas censales del INEGI) que carecían de una estructura unificada para la consulta analítica rápida. Para poder utilizarlos, los autores llevaron a cabo un proceso de **ETL (Extracción, Transformación y Carga)** e integración dentro de un **Almacén de Datos (Data Warehouse)**:
1. **Extracción y Limpieza:** Filtrado de campos nulos o inconsistencias en coordenadas geográficas, fechas y magnitudes sísmicas.
2. **Estandarización Geográfica:** Homologación de claves geoestadísticas (estados, municipios/alcaldías) para vincular de manera precisa las coordenadas epicentrales del SSN con las áreas geográficas del INEGI.
3. **Carga y Modelado:** Almacenamiento optimizado de las variables en una base de datos utilizando tecnologías de software libre (PHP, bases de datos relacionales/dimensionales) para permitir consultas interactivas eficientes desde la plataforma web (*MUTVI 3*).

### 3. Cómo se modeló la información: entidades/dimensiones y hechos
La arquitectura de información se estructuró siguiendo un modelado dimensional propio de un Data Warehouse para facilitar el análisis multidimensional (OLAP) y la visualización:

* **Hechos (Tabla de Hechos):**
  * **Ocurrencia Sísmica / Evento Sísmico:** Mide variables cuantitativas continuas como la *magnitud* (escala de Richter/momento), *profundidad del epicentro (km)*, *coordenadas geográficas exactas (latitud y longitud)* y *duración o afectación calculada*.
  * **Indicadores Socioeconómicos:** Mide hechos como el *total de población expuesta*, *número de viviendas en zonas de riesgo* y *unidades económicas / infraestructura expuesta*.

* **Entidades y Dimensiones:**
  * **Dimensión Tiempo:** Permite análisis por año, mes, día, hora o rangos temporales históricos.
  * **Dimensión Ubicación Geográfica:** Entidades federativas, municipios, regiones sísmicas y límites de placas tectónicas.
  * **Dimensión Tectónica / Clasificación:** Clasificación del sismo según su origen (subducción, intraplaca, fallas superficiales) y profundidad (superficial, intermedia, profunda).
  * **Dimensión Demográfica y Económica (INEGI):** Población total, densidad poblacional, tipo de vivienda y sector económico por región.

**Relación entre elementos:** Las tablas de hechos se relacionan con las dimensiones mediante llaves foráneas (IDs de ubicación, fecha y clasificación), lo que permite cruzar un evento sísmico específico con el contexto sociodemográfico y económico de la zona geográfica afectada en ese momento del tiempo.

### 4. Qué preguntas concretas puede responder el sistema resultante
El sistema (*MUTVI 3 / Sistema de Visualización de Datos Sísmicos*) está diseñado para responder interrogantes clave como:
* ¿Cuáles son las regiones o estados de México con mayor concentración e intensidad de sismos en las últimas décadas?
* ¿Existe alguna correlación visual o estadística entre la profundidad de un sismo y su magnitud en regiones específicas del país?
* ¿Cuánta población y cuántas unidades económicas se localizan en las zonas con mayor recurrencia sísmica de alta magnitud?
* ¿Cómo ha evolucionado la frecuencia sísmica a lo largo del tiempo en un estado o municipio en particular?
* ¿Cuáles han sido los sismos históricamente más severos en una zona geográfica determinada e integrando el perfil demográfico actual de esa área?

### 5. Qué limitaciones reconocen los autores y qué trabajo futuro proponen
* **Limitaciones reconocidas:**
  * Dependencia de la precisión y continuidad de los datos abiertos proporcionados por las fuentes primarias (SSN e INEGI).
  * El sistema actúa como una herramienta de exploración, análisis histórico y visualización, por lo que **no es un sistema de predicción sísmica** (dada la naturaleza física e impredecible del fenómeno).
  * La granularidad de los datos demográficos está limitada a los períodos de actualización de los censos del INEGI (que no son en tiempo real).

* **Trabajo futuro propuesto:**
  * Incorporar capas adicionales de información espacial, tales como tipos de suelo (geotecnia), mapas de aceleración sísmica y redes de infraestructura crítica (hospitales, escuelas, vías de transporte).
  * Implementar modelos avanzados de analítica predictiva o de aprendizaje automático (*Machine Learning*) para la estimación automatizada de escenarios de riesgo o pérdidas ante sismos de gran magnitud.
  * Optimizar el rendimiento de la plataforma de software libre para la manipulación e interacción en tiempo real con volúmenes de datos aún más masivos (*Big Data*).
