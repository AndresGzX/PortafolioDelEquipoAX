# Análisis de Entidad Débil — Seismic Data Visualization System

## ¿Existe una entidad débil en el modelo?

**No existe una entidad débil en este modelo.**

---

## Revisión de las entidades del modelo

El modelo está compuesto por las siguientes entidades:

| Entidad | Clave Primaria | Tipo |
|---|---|---|
| `dim_sismos` | `id_sismo` (INT, PK) | Entidad fuerte |
| `dim_tiempo` | `id_tiempo` (INT, PK) | Entidad fuerte |
| `dim_zonas` | `id_zonas` (INT, PK) | Entidad fuerte |
| `dim_economia` | `id_economia` (INT, PK) | Entidad fuerte |
| `fact_impacto_sismos_imputed` | `id_sismo + id_zonas + id_economia + id_tiempo` (FK compuesta) | Tabla de hechos |

---

## Conclusión

Una **entidad débil** es aquella que:

1. **No posee una clave primaria propia** que la identifique de manera única por sí sola.
2. **Depende existencialmente** de otra entidad (su entidad propietaria o dominante) para existir.
3. Se identifica mediante una **clave parcial** combinada con la clave de su entidad dominante.

En este modelo, **todas las entidades dimensionales** (`dim_sismos`, `dim_tiempo`, `dim_zonas`, `dim_economia`) cuentan con su propia clave primaria entera (`INT PRIMARY KEY`) que las identifica de forma independiente. Ninguna necesita de otra entidad para existir o para ser identificada.

En cuanto a `fact_impacto_sismos_imputed`, aunque depende de las cuatro dimensiones a través de llaves foráneas, **no es una entidad débil** en el sentido estricto del modelo Chen. Es una **tabla de hechos** propia del diseño de *Data Warehouse* (esquema estrella), cuya clave es la combinación de sus cuatro FK. Esta dependencia es de **integridad referencial**, no de identidad existencial.

Por lo tanto, el modelo **no presenta jerarquías de entidades débiles**. Todos los objetos del esquema son entidades fuertes con identidad propia, conectadas entre sí a través de relaciones 1:N hacia la tabla de hechos central.
