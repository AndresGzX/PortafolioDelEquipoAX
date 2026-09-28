# Tabla de Correspondencia: Modelo EER Conceptual ↔ Esquema Físico (Data Warehouse)

**Proyecto:** Seismic Data Visualization System  
**Autores:** Jonathan Xavier Alvarez Cariño · Andrés Ramírez Rodríguez  
**Esquema publicado:** `00-datawarehouse_tables.sql` — arquitectura estrella (Star Schema)

---

## 1. Contexto del análisis

El modelo EER conceptual representa las entidades del dominio sísmico mexicano en su forma
semántica pura: qué cosas existen, qué propiedades tienen y cómo se relacionan entre sí.
El esquema físico publicado es un **Data Warehouse en estrella** orientado a consultas
analíticas (OLAP), donde las dimensiones descriptivas rodean una tabla de hechos central
que almacena métricas calculadas. El pasaje entre ambos niveles introduce transformaciones
que generan pérdidas de información semántica y adiciones de información derivada.

---

## 2. Tabla de correspondencia

| # | Entidad EER conceptual | Atributos clave del modelo conceptual | Tabla(s) física(s) equivalente(s) | Atributos presentes en el esquema físico | Información que **SE PIERDE** al pasar al físico | Información que **SE AGREGA** en el físico |
|---|---|---|---|---|---|---|
| 1 | **Sismo** | id, magnitud, latitud, longitud, profundidad, fecha\_ocurrencia, hora\_utc, referencia\_localización, entidad\_federativa | `dim_sismos` + `dim_tiempo` | `id_sismo`, `magnitud`, `latitud`, `longitud`, `profundidad`, `referencia_de_localizacion`, `estado`, `nombre_estado` / `id_tiempo`, `hora_utc`, `fecha`, `anio`, `mes`, `dia`, `trimestre` | La relación directa entre el sismo y su momento temporal queda **rota en dos tablas**. No existe FK directa `dim_sismos → dim_tiempo`; la unión solo ocurre a través de `fact_impacto_sismos_imputed`. Un sismo sin impacto registrado pierde su estampa temporal. | La dimensión temporal descompone la fecha en columnas analíticas redundantes (`anio`, `mes`, `dia`, `trimestre`) para acelerar GROUP BY sin funciones de fecha. |
| 2 | **Zona / Estado** | id, clave\_entidad\_INEGI, nombre\_estado, superficie\_km2, región\_geográfica, capital | `dim_zonas` | `id_zonas`, `entidad` (clave numérica), `nom_ent`, `pobtot`, `pobfem`, `pobmas` | Se pierde: **superficie**, **región geográfica**, **capital del estado** y cualquier atributo geoespacial (polígono, centroide). No hay distinción entre municipios o regiones internas del estado. | Se agregan tres métricas censales directamente en la dimensión: `pobtot`, `pobfem`, `pobmas` (datos INEGI Censo 2020), que en un modelo normalizado vivirían en una entidad separada `Censo`. |
| 3 | **Registro de Impacto / Evento** | id\_evento, fecha, sismo\_relacionado, zona\_afectada, daños\_estimados, fuente | `fact_impacto_sismos_imputed` | `id_sismo (FK)`, `id_zonas (FK)`, `id_economia (FK)`, `id_tiempo (FK)`, `poblacion_afectada`, `impacto_economico`, `determinante_de_riesgo`, `riesgo_proporcional`, `indice_zscore` | Se pierde la **fuente de información** del evento (SSN, CENAPRED, etc.) y la **fecha de captura del registro**. No existe distinción entre un impacto observado y uno **imputado** (el sufijo `_imputed` en el nombre de la tabla sugiere valores estimados, pero no hay columna que lo marque por fila). | Se agregan cinco **métricas analíticas derivadas** inexistentes en el dominio real: `poblacion_afectada` (calculada), `impacto_economico` (estimado), `determinante_de_riesgo`, `riesgo_proporcional` e `indice_zscore` (estadístico de normalización). Estas columnas **no existen en la realidad observada**; son el resultado de un modelo de riesgo aplicado sobre los datos. |
| 4 | **Economía / Indicador Económico** | id, entidad\_federativa, año\_censo, sector\_productivo, producción, insumos, valor\_agregado, inversión | `dim_economia` | `id_economia`, `nombre_entidad`, `entidad` (clave INEGI), `produccion_bruta_total`, `insumos_utilizados`, `consumo_intermedio`, `valor_agregado`, `formacion_capital`, `activos_fijos_adquiridos` | Se pierde el **año del censo económico** (no hay columna `anio` en `dim_economia`, por lo que no se puede saber a qué ejercicio fiscal corresponden los datos). Se pierde la **desagregación por sector** (SCIAN): todos los indicadores están colapsados al nivel de entidad federativa total, eliminando la granularidad sectorial (manufactura, comercio, servicios). | La dimensión une en una sola fila por entidad los ocho indicadores del Censo Económico INEGI, lo que permite JOIN directo con la tabla de hechos sin necesidad de sumar subregistros. |
| 5 | **Tiempo / Fecha** | id, timestamp\_completo, zona\_horaria, hora\_local, hora\_utc, fecha, año, mes, día, trimestre, día\_semana, es\_festivo | `dim_tiempo` | `id_tiempo`, `hora_utc`, `fecha`, `anio`, `mes`, `dia`, `trimestre` | Se pierde: **hora local** (solo se almacena UTC), **día de la semana**, **flag de día festivo**, **nombre del mes** y la **zona horaria** del epicentro (relevante para México que tiene 4 husos horarios). | Se agrega `trimestre` como columna precalculada (derivable desde `mes`), optimizando consultas trimestrales sin cómputo en tiempo de ejecución. |
| 6 | **Relación Sismo–Zona** *(asociación N:M conceptual)* | — relación entre Sismo y Zona con atributos propios: radio\_afectación\_km, intensidad\_local | `fact_impacto_sismos_imputed` (parcialmente) | `id_sismo`, `id_zonas` como FKs dentro de la tabla de hechos | La relación N:M conceptual queda **absorbida** dentro de la tabla de hechos junto con otras tres dimensiones, perdiendo su identidad semántica independiente. No se almacena el **radio de afectación** geográfico ni la **intensidad local** (escala Mercalli) por zona. | Al absorber la relación en la tabla de hechos se gana la posibilidad de cruzar directamente el impacto de un sismo en una zona con su contexto económico y temporal en una sola fila analítica. |

---

## 3. Resumen ejecutivo de pérdidas y ganancias

### Información que SE PIERDE en el paso al esquema físico

| Categoría | Detalle |
|---|---|
| **Temporalidad económica** | `dim_economia` no registra el año del censo; los datos económicos son estáticos y no versionados. |
| **Granularidad sectorial** | Los indicadores económicos están colapsados por estado, eliminando el desglose por sector productivo (SCIAN). |
| **Geoespacial** | No hay geometría (polígono, centroide, área) para estados ni epicentros. Se pierden superficie y región geográfica. |
| **Hora local / zona horaria** | Solo existe `hora_utc`; la hora local del epicentro (clave para alertas tempranas) no está modelada. |
| **Trazabilidad de imputación** | El nombre `_imputed` indica valores estimados, pero no hay columna que distinga qué filas son observadas vs. imputadas. |
| **Fuente del dato** | No se registra si el evento proviene del SSN, CENAPRED, USGS u otra fuente. |
| **Relación directa Sismo–Tiempo** | La estampa temporal de un sismo solo existe si hay un registro de impacto; un sismo sin impacto pierde su fecha. |
| **Día de la semana / festivos** | `dim_tiempo` no incluye atributos de calendario extendido útiles para análisis de respuesta civil. |

### Información que SE AGREGA en el esquema físico

| Categoría | Detalle |
|---|---|
| **Métricas de riesgo calculadas** | `determinante_de_riesgo`, `riesgo_proporcional`, `indice_zscore`: derivadas de un modelo estadístico, no observadas. |
| **Impacto estimado** | `poblacion_afectada` e `impacto_economico` son estimaciones modeladas, no registros directos de daño. |
| **Descomposición temporal** | `anio`, `mes`, `dia`, `trimestre` precalculados en `dim_tiempo` aceleran consultas analíticas. |
| **Datos censales en dimensión** | `pobtot`, `pobfem`, `pobmas` integrados directamente en `dim_zonas` evitan JOINs adicionales. |

---

## 4. Diagrama de correspondencia (visual)

```
MODELO EER CONCEPTUAL              ESQUEMA FÍSICO (Star Schema)
─────────────────────────          ──────────────────────────────────────
                                   
  [Sismo]          ──────────────► dim_sismos  (atributos físicos)
     │                          ► dim_tiempo   (fecha/hora descompuesta)
     │ (fecha/hora)                            
     │                                        
  [Zona/Estado]    ──────────────► dim_zonas   (+ datos censales INEGI)
                                              
  [Economía]       ──────────────► dim_economia (colapsada por estado)
                                              
  [Tiempo]         ──────────────► dim_tiempo   (sin hora local ni festivos)
                                              
  [Rel. Sismo–Zona]──────────────► fact_impacto_sismos_imputed
  [Evento/Impacto]                  (+ métricas derivadas: zscore, riesgo)
```

---

*Documento generado para el Ejercicio 5 — Práctica 2 · Bases de Datos*
