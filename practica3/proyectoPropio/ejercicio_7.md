# Ejercicio 7. El esquema del proyecto asignado

**Proyecto asignado:** Seismic-Data-Visualization-System (almacén dimensional)

El esquema es una **estrella**: cuatro tablas de dimensión (`dim_sismos`, `dim_tiempo`, `dim_zonas`, `dim_economia`) y una tabla de hechos (`fact_impacto_sismos_imputed`). Las cifras citadas se obtuvieron revisando los archivos SQL de definición y carga (`00` a `05`).

> **Nota:** las reglas de transformación se nombran de forma genérica (entidad fuerte, relación n-aria, etc.). Deben ajustarse a la numeración de las reglas de los ejercicios 3 a 5 y al EER reconstruido en la Práctica 2.

---

## 7.1 Las reglas detrás del esquema

El almacén declara muy poco: solo PK en las dimensiones y 4 FK en el hecho. No hay `NOT NULL`, `UNIQUE`, `CHECK` ni PK en la tabla de hechos.

| Tabla | Regla de origen (a partir del EER) | PK | FK | Restricciones declaradas |
|---|---|---|---|---|
| `dim_sismos` | Entidad fuerte SISMO: una tabla, atributos simples como columnas | `id_sismo` | ninguna | solo la PK |
| `dim_tiempo` | Entidad fuerte (o atributos fecha/hora del sismo): una tabla | `id_tiempo` | ninguna | solo la PK |
| `dim_zonas` | Entidad fuerte ENTIDAD FEDERATIVA, parte demográfica | `id_zonas` | ninguna | solo la PK |
| `dim_economia` | La misma entidad federativa, parte económica | `id_economia` | ninguna | solo la PK |
| `fact_impacto_sismos_imputed` | Relación n-aria (sismo, zona, economía, tiempo) con atributos propios: tabla con las PK de los participantes como FK, más los atributos de la relación | **ninguna** | `id_sismo`, `id_zonas`, `id_economia`, `id_tiempo` | 4 FK declaradas |

Las reglas de entidad débil, jerarquía y atributo multivaluado **no aparecen** en este esquema: no hay tablas con PK compuesta heredada ni tablas de subtipo.

---

## 7.2 Dónde se aparta de las reglas

### 1. Atributos de otra entidad dentro de `dim_sismos`

`estado` y `nombre_estado` pertenecen a la entidad federativa, no al sismo.

- **Se gana:** filtrar sismos por estado sin unir con `dim_zonas`.
- **Se pierde:** hay dependencia transitiva y duplicación. **115,897 de 319,592 sismos (36%) tienen `nombre_estado` vacío**. Además no existe FK ni llave compartida con `dim_zonas`.

### 2. Una entidad dividida en dos dimensiones (`dim_zonas` y `dim_economia`)

Una transformación estricta produciría una sola tabla `ENTIDAD_FEDERATIVA`.

- **Se gana:** dimensiones separadas por tema (población vs. economía).
- **Se pierde:** los ids no coinciden. Colima es 5 en `dim_zonas` y 8 en `dim_economia`; Morelos es 16 y 15. En 9,534 filas del hecho `id_zonas ≠ id_economia` aunque se trata del mismo estado. Los nombres también difieren ("Mexico" vs "México") y no hay FK entre ambas.

### 3. `dim_tiempo` no es un calendario: es 1:1 con el sismo

Tiene 319,592 filas, igual que `dim_sismos`, y en las 196,576 filas del hecho `id_tiempo = id_sismo`. Un calendario de 1900 a 2025 tendría unas 46,000 filas (una por día).

- **Se gana:** un esquema estrella uniforme.
- **Se pierde:** es una relación 1:1 disfrazada de dimensión. Fecha y hora son atributos del sismo, y la tabla no permite comparar días sin sismos.

### 4. Datos derivados almacenados

- `anio`, `mes`, `dia` y `trimestre` se derivan de `fecha`.
- `poblacion_afectada` es **idéntica a `pobtot` en las 196,576 filas**, y `impacto_economico` es idéntico a `produccion_bruta_total`. Son copias, no mediciones del sismo.
- `indice_zscore` toma solo **16 valores distintos**, es decir, es constante por estado.

**Se gana:** consultas más rápidas y sin cálculos.
**Se pierde:** redundancia, riesgo de desincronización y medidas que no varían con el evento; el nombre "población afectada" resulta engañoso.

### 5. Claves subrogadas en lugar de claves naturales

Los `id_*` son enteros secuenciales.

- **Se gana:** llaves compactas e independientes de la fuente.
- **Se pierde:** no hay `UNIQUE` sobre la llave natural (`dim_zonas.entidad`, `nom_ent`), así que nada impide duplicados.

### 6. Hecho sin PK y claves foráneas no declaradas

La granularidad de facto es una fila por sismo (`id_sismo` no se repite), pero no está declarada. Tampoco hay FK entre `dim_sismos.estado` y `dim_zonas`, aunque la relación existe.

- **Se gana:** carga masiva más simple.
- **Se pierde:** integridad referencial y unicidad.

### Observaciones adicionales

- `dim_economia.entidad` es un `DOUBLE` con valores grandes (5797, 14730…), no el código de estado como en `dim_zonas.entidad`.
- El hecho tiene 196,576 filas contra 319,592 sismos: unos 123,000 sismos no tienen hecho.

---

## 7.3 Comparación entre modelos: EER vs relacional

| Concepto | Modelo EER | Modelo relacional | Qué se ganó | Qué se perdió |
|---|---|---|---|---|
| Entidades fuertes | Rectángulo con identidad propia (SISMO, ENTIDAD FEDERATIVA) | Una tabla con PK | Estructura ejecutable con PK/FK | La semántica del dominio: aquí una entidad quedó en dos tablas |
| Entidades débiles | Doble rectángulo, depende de otra | Tabla con PK compuesta (PK del dueño + discriminante) | Integridad en cascada | Ninguna aparece en el almacén: se aplanaron a dimensiones con claves subrogadas |
| Relaciones N:M | Rombo con cardinalidades | Tabla puente con PK compuesta | Admite atributos de la relación | La tabla de hechos no declara PK, así que se pierde la unicidad |
| Jerarquías (es-un) | Especialización con disjunción/solapamiento | Una tabla, o una por subtipo, con FK | Consultas simples sin joins | Aplanadas en `dim_sismos` (estado dentro del sismo); se pierde la restricción de tipo |
| Atributos multivaluados | Elipse doble | Tabla aparte con FK | Primera forma normal | No hay ninguno en este esquema |

> **Pendiente:** completar las columnas "ganó/perdió" con ejemplos del proyecto propio (Kaizen) y ajustar el 7.1 al EER de la Práctica 2.
