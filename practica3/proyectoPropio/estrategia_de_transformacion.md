# Estrategia de Transformación del Modelo EER al Modelo Relacional

Este documento responde a las preguntas clave de análisis previo antes de transformar el Modelo Entidad-Relación Extendido (EER) al Modelo Relacional para el proyecto de bases de datos.

---

### 1. ¿Qué elementos van a requerir una tabla adicional?

En un modelo relacional, las jerarquías de generalización y especialización (superto-subtipo) requieren definir una estrategia de mapeo. Para este modelo, los elementos que requerirán tablas adicionales son **todos los subtipos** de las jerarquías representadas:

*   **Jerarquía Organización:** Se requerirán 6 tablas adicionales para los subtipos: `Municipio`, `Reciclaje_Org`, `Financiera`, `Transporte`, `Comercio` y `ONG_Univ`.
*   **Jerarquía Acción Sostenible:** Se requerirán 3 tablas adicionales para los subtipos: `Reciclaje_Accion`, `Movilidad` y `Campaña`.
*   **Jerarquía Transacción Puntos:** Se requerirán 3 tablas adicionales para los subtipos: `Ganancia`, `Gasto` y `Ajuste`.
*   **Jerarquía Movimiento Saldo:** Se requerirán 3 tablas adicionales para los subtipos: `Recarga`, `Pago` y `Reembolso`.
*   **Jerarquía EcoCard:** Se requerirán 2 tablas adicionales para los subtipos: `Digital` y `Física`.

*(Nota: Opcionalmente, las tablas de los supertipos principales también existirán como tablas independientes si se utiliza la estrategia de mapeo por "Tablas separadas para supertipos y subtipos").*

---

### 2. ¿Qué atributos se convertirán en claves foráneas?

Las claves primarias de las entidades supertipo se replicarán como **claves foráneas (Foreign Keys)** y, al mismo tiempo, actuarán como claves primarias en cada una de las tablas de los subtipos correspondientes para mantener la integridad referencial y la relación de herencia:

*   `id_organizacion` (proveniente de la tabla `Organización`) se convertirá en clave foránea en las 6 tablas hijas de organizaciones.
*   `id_accion` (proveniente de la tabla `Acción Sostenible`) se convertirá en clave foránea en las 3 tablas hijas de acciones sostenibles.
*   `id_transaccion` (proveniente de la tabla `Transacción Puntos`) se convertirá en clave foránea en las 3 tablas hijas de transacciones de puntos.
*   `id_movimiento` (proveniente de la tabla `Movimiento Saldo`) se convertirá en clave foránea en las 3 tablas hijas de movimientos de saldo.
*   `id_ecocard` (proveniente de la tabla `EcoCard`) se convertirá en clave foránea en las 2 tablas hijas de tarjetas (Digital y Física).

---

### 3. ¿Qué decisión tendrá que tomar en cada jerarquía?

Para transformar las jerarquías al modelo relacional, se debe decidir el enfoque de mapeo (por lo general, eligiendo entre *Tablas separadas para supertipos y subtipos*, *Solo tablas para subtipos con atributos duplicados*, o *Una sola tabla con indicadores de tipo*). Tomando en cuenta las restricciones del diagrama (completitud y disyunción), las decisiones son las siguientes:

*   **Jerarquía Organización (Participación total y Traslape `o`):** 
    *   *Decisión:* Como el traslape permite que una organización pertenezca a varios subtipos simultáneamente (ej. ser Municipio y Comercio a la vez), **no se puede** usar una sola tabla con un atributo discriminador único. La decisión obligatoria es implementar un modelo de **Tablas separadas (Supertipo y Subtipos independientes)** utilizando la clave primaria compartida (`id_organizacion`), permitiendo que un registro del supertipo se relacione con múltiples registros en diferentes tablas hijas mediante relaciones uno a cero/uno.
*   **Jerarquías de Acción Sostenible, Transacción Puntos, Movimiento Saldo y EcoCard (Participación total y Disjunción `d`):**
    *   *Decisión:* Al ser exclusivas (disjuntas, donde un elemento pertenece estrictamente a un solo subtipo), la decisión de diseño puede inclinarse hacia un esquema de **Tablas separadas** con herencia estricta (la clave primaria del supertipo pasa a ser PK y FK en el subtipo), o bien evaluar una tabla única combinada si los atributos específicos de los subtipos son pocos, aunque el estándar académico óptimo para este EER es mantener la estructura de supertipo y subtipos separados para evitar nulos masivos.