# Documentación del Modelo EER a Relacional: Ejercicios 3 y 4

## Documentación de Elementos y Relaciones (Aplicación de Reglas 1 a 7)

A continuación se documenta cada componente del modelo indicando la regla aplicada y la estructura de la tabla resultante:

### 1. Entidades Fuertes y Atributos Simples / Compuestos (Reglas 1 y 2)
* **Elemento:** Entidad fuerte `Organización`
  * *Regla Aplicada:* **Regla 1** (Entidad fuerte a tabla) y **Regla 2** (Desglose de atributos compuestos).
  * *Tabla Resultante:* `Organizacion` (`id_organizacion` [PK], `nombre_comercial`, `razon_social` [derivados del compuesto nombre], `fecha_registro`, `estatus` [NOT NULL]).
* **Elemento:** Entidad fuerte `Acción sostenible`
  * *Regla Aplicada:* **Regla 1**.
  * *Tabla Resultante:* `Accion_Sostenible` (`id_accion` [PK], `fecha_hora`, `impacto_estimado` [NOT NULL]).
* **Elemento:** Entidad fuerte `Transacción puntos`
  * *Regla Aplicada:* **Regla 1**.
  * *Tabla Resultante:* `Transaccion_Puntos` (`id_transaccion` [PK], `monto_puntos`, `fecha` [NOT NULL]).
* **Elemento:** Entidad fuerte `Movimiento saldo`
  * *Regla Aplicada:* **Regla 1**.
  * *Tabla Resultante:* `Movimiento_Saldo` (`id_movimiento` [PK], `monto`, `fecha_hora`, `estado` [NOT NULL]).
* **Elemento:** Entidad fuerte `EcoCard`
  * *Regla Aplicada:* **Regla 1**.
  * *Tabla Resultante:* `EcoCard` (`id_ecocard` [PK], `saldo_actual` [derivado/almacenado], `fecha_emision` [NOT NULL]).

### 2. Jerarquías de Especialización (Generalización)
* **Elemento:** Jerarquía de `Organización` hacia subtipos (`Municipio`, `Reciclaje`, `Financiera`, `Transporte`, `Comercio`, `ONG/Univ.`)
  * *Regla Aplicada:* Mapeo de supertipo/subtipo con participación total y traslape `o`.
  * *Tablas Resultantes:* 
    * `Municipio` (`id_organizacion` [PK/FK], atributos específicos de municipio).
    * `Reciclaje_Org` (`id_organizacion` [PK/FK], atributos específicos).
    * `Financiera` (`id_organizacion` [PK/FK], atributos específicos).
    * `Transporte` (`id_organizacion` [PK/FK], atributos específicos).
    * `Comercio` (`id_organizacion` [PK/FK], atributos específicos).
    * `ONG_Univ` (`id_organizacion` [PK/FK], atributos específicos).
* **Elemento:** Jerarquías Disjuntas (`Acción Sostenible`, `Transacción Puntos`, `Movimiento Saldo`, `EcoCard`)
  * *Regla Aplicada:* Mapeo de supertipo/subtipo con participación total y disyunción `d`.
  * *Tablas Resultantes:* 
    * Subtipos de Acción: `Reciclaje_Accion`, `Movilidad`, `Campaña` (cada una con `id_accion` [PK/FK]).
    * Subtipos de Transacción: `Ganancia`, `Gasto`, `Ajuste` (cada una con `id_transaccion` [PK/FK]).
    * Subtipos de Movimiento: `Recarga`, `Pago`, `Reembolso` (cada una con `id_movimiento` [PK/FK]).
    * Subtipos de EcoCard: `Digital`, `Física` (cada una con `id_ecocard` [PK/FK]).

### 3. Relaciones Operativas del Modelo (Reglas 4, 5, 6 y 7)
* **Elemento:** Relaciones Uno a Muchos (1:N) típicas de asignación (ej. EcoCard asociada a movimientos o acciones a usuario).
  * *Regla Aplicada:* **Regla 4** (Propagación de clave primaria del lado uno al lado muchos como `FOREIGN KEY`, evaluando cardinalidad mínima para restricciones `NOT NULL`).
  * *Tabla Resultante:* Inclusión de columnas foráneas en las tablas dependientes correspondientes.
* **Elemento:** Relaciones Muchos a Muchos (M:N) y Relaciones de Orden Superior (Ternarias) si aplican en la lógica de negocio extendida.
  * *Reglas Aplicadas:* **Regla 5** (Creación de tabla intermedia con claves primarias combinadas como PK compuesta y FKs) y **Regla 7** (Tabla propia con todas las PKs participantes para relaciones ternarias).
  * *Tabla Resultante:* Tablas asociativas intermedias para cruces complejos de múltiples entidades.