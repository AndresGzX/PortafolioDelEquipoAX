# Documentación del Modelo EER a Relacional: Reglas 8 y 9

Este documento complementa la transformación del modelo de base de datos ecológico (`Organización`, `Acción sostenible`, `Transacción puntos`, `Movimiento saldo` y `EcoCard`), aplicando las especificaciones de la **Regla 8 (Entidades Débiles)** y la **Regla 9 (Jerarquías)**.

---

## Regla 8. Entidades Débiles

### Marco Teórico de la Regla
* **Dependencia de Identificación:** La tabla resultante lleva una clave primaria compuesta por la clave foránea de la entidad propietaria (`FOREIGN KEY NOT NULL`) más el discriminador parcial. Se aplica normalmente `ON DELETE CASCADE`.
* **Dependencia de Existencia:** La tabla conserva su propia clave primaria autogestionada y agrega la clave foránea como `NOT NULL`.

---

### Aplicación al Modelo de Base de Datos

#### 1. Subtipos Específicos como Entidades Débiles de Identificación
En este modelo, las entidades hijas de las especializaciones dependen completamente de la existencia e identificación de su supertipo correspondiente.

* **Ejemplo: Subtipos de `EcoCard` (`Digital`, `Física`)**
  * **Tipo de Dependencia:** Dependencia de identificación respecto al supertipo `EcoCard`.
  * **Estructura Relacional:**
    * `EcoCard_Digital` (**`id_ecocard`** [PK, FK], `token_qr`, `app_version`)
    * `EcoCard_Fisica` (**`id_ecocard`** [PK, FK], `codigo_barras`, `chip_rfid`)
  * **Restricción:** `id_ecocard` es `FOREIGN KEY` referenciando a `EcoCard(id_ecocard)` con `NOT NULL` y `ON DELETE CASCADE`.

* **Ejemplo: Subtipos de `Acción sostenible` (`Reciclaje`, `Movilidad`, `Campaña`)**
  * **Tipo de Dependencia:** Dependencia de identificación respecto a `Acción sostenible`.
  * **Estructura Relacional:**
    * `Accion_Reciclaje` (**`id_accion`** [PK, FK], `tipo_material`, `peso_kg`)
    * `Accion_Movilidad` (**`id_accion`** [PK, FK], `distancia_km`, `tipo_transporte`)
    * `Accion_Campaña` (**`id_accion`** [PK, FK], `id_campana_ref`, `horas_acumuladas`)
  * **Restricción:** `id_accion` es `FOREIGN KEY` referenciando a `Accion_Sostenible(id_accion)` con `NOT NULL` y `ON DELETE CASCADE`.

---

## Regla 9. Jerarquías de Especialización

### Estrategias de Mapeo Disponibles

| Estrategia | Ventaja | Desventaja | Cuándo Conviene |
| :--- | :--- | :--- | :--- |
| **A. Tabla por supertipo y por subtipo** | Sin redundancia ni valores nulos. | Requiere combinaciones (`JOIN`) para consultar todo. | Subtipos con muchos atributos propios. |
| **B. Tabla única con discriminador** | Consultas simples y rápidas. | Muchos valores nulos. | Subtipos con pocos atributos propios. |
| **C. Tabla por subtipo, sin supertipo** | No requiere combinaciones (`JOIN`). | Repite los atributos comunes. | Especialización **total** y **disjunta**. |

---

### Análisis y Elección de Estrategia para cada Jerarquía del Modelo

#### 1. Jerarquía: `Organización`
1. **Restricciones del EER:** Solapada / Traslape (**`o`**), Total (doble línea).
2. **Estrategia Elegida:** **Estrategia A (Tabla por supertipo y por subtipo)**.
   * **Justificación:** Al ser una especialización con **traslape/solapada**, una misma entidad puede ser al mismo tiempo `Municipio` y `Transporte` o `Comercio`. Las estrategias B y C no son viables porque la B requeriría múltiples discriminadores/banderas de tipo o causaría redundancia masiva de nulos, y la C duplicaría los registros del supertipo.
3. **Diseño de Tablas Resultantes:**
   * `Organizacion` (**`id_organizacion`** [PK], `nombre`, `fecha_registro`, `estatus` [NOT NULL])
   * `Org_Municipio` (**`id_organizacion`** [PK, FK], `clave_inegi`, `poblacion_estimada`)
   * `Org_Reciclaje` (**`id_organizacion`** [PK, FK], `capacidad_toneladas`, `licencia_ambiental`)
   * `Org_Financiera` (**`id_organizacion`** [PK, FK], `clave_institucion`, `tipo_entidad`)
   * `Org_Transporte` (**`id_organizacion`** [PK, FK], `numero_concesion`, `flota_activa`)
   * `Org_Comercio` (**`id_organizacion`** [PK, FK], `rfc_comercial`, `giro_comercio`)
   * `Org_ONG_Univ` (**`id_organizacion`** [PK, FK], `registro_cluni`, `tipo_institucion`)
   * *Discriminador:* No requiere columna discriminadora única debido al traslape; la presencia del ID en cada tabla hija determina la pertenencia al subtipo.

---

#### 2. Jerarquía: `Acción sostenible`
1. **Restricciones del EER:** Disjunta (**`d`**), Total (doble línea).
2. **Estrategia Elegida:** **Estrategia A (Tabla por supertipo y por subtipo)** *(o alternativamente C si no hay relaciones directas dirigidas estrictamente al supertipo)*.
   * **Justificación:** Aunque la especialización es total y disjunta, los subtipos (`Reciclaje`, `Movilidad`, `Campaña`) poseen métricas y atributos específicos completamente distintos (`peso_kg`, `distancia_km`, `horas`). La Estrategia A evita campos `NULL` innecesarios y preserva la integridad del supertipo para historiales generales.
3. **Diseño de Tablas Resultantes:**
   * `Accion_Sostenible` (**`id_accion`** [PK], `tipo_accion` [Discriminador], `fecha_hora`, `impacto_estimado` [NOT NULL])
   * `Accion_Reciclaje` (**`id_accion`** [PK, FK], `material`, `peso_kg` [NOT NULL])
   * `Accion_Movilidad` (**`id_accion`** [PK, FK], `tipo_vehiculo`, `distancia_km` [NOT NULL])
   * `Accion_Campana` (**`id_accion`** [PK, FK], `nombre_campana`, `horas_participacion` [NOT NULL])
   * *Discriminador:* Columna `tipo_accion` en `Accion_Sostenible` (Valores: `'RECICLAJE'`, `'MOVILIDAD'`, `'CAMPANA'`).

---

#### 3. Jerarquía: `Transacción puntos`
1. **Restricciones del EER:** Disjunta (**`d`**), Total (doble línea).
2. **Estrategia Elegida:** **Estrategia B (Tabla única con discriminador)**.
   * **Justificación:** Los subtipos (`Ganancia`, `Gasto`, `Ajuste`) comparten casi todos sus atributos principales (`monto_puntos`, `fecha_hora`, `usuario_id`). Como los subtipos tienen muy pocos o ningún atributo propio diferenciador, esta estrategia minimiza la necesidad de `JOINs` complejos en operaciones de alto volumen como las transacciones.
3. **Diseño de Tablas Resultantes:**
   * `Transaccion_Puntos` (
     **`id_transaccion`** [PK], 
     `tipo_transaccion` [Discriminador, NOT NULL], 
     `monto_puntos` [NOT NULL], 
     `fecha_hora` [NOT NULL], 
     `motivo_ajuste` [NULL], 
     `referencia_origen` [NULL]
     )
   * *Discriminador:* Columna `tipo_transaccion` (Valores permitidos via `CHECK`: `'GANANCIA'`, `'GASTO'`, `'AJUSTE'`).

---

#### 4. Jerarquía: `Movimiento saldo`
1. **Restricciones del EER:** Disjunta (**`d`**), Total (doble línea).
2. **Estrategia Elegida:** **Estrategia B (Tabla única con discriminador)**.
   * **Justificación:** Al igual que en `Transacción puntos`, los movimientos de saldo (`Recarga`, `Pago`, `Reembolso`) manejan patrones de consulta idénticos y comparten la inmensa mayoría de atributos (monto, fecha, estado, cuenta origen/destino). Usar una sola tabla optimiza drásticamente las consultas de balances.
3. **Diseño de Tablas Resultantes:**
   * `Movimiento_Saldo` (
     **`id_movimiento`** [PK], 
     `tipo_movimiento` [Discriminador, NOT NULL], 
     `monto` [NOT NULL], 
     `fecha_hora` [NOT NULL], 
     `metodo_pago` [NULL], 
     `comercio_destino_id` [NULL], 
     `estado` [NOT NULL]
     )
   * *Discriminador:* Columna `tipo_movimiento` (Valores permitidos via `CHECK`: `'RECARGA'`, `'PAGO'`, `'REEMBOLSO'`).

---

#### 5. Jerarquía: `EcoCard`
1. **Restricciones del EER:** Disjunta (**`d`**), Total (doble línea).
2. **Estrategia Elegida:** **Estrategia A (Tabla por supertipo y por subtipo)**.
3. **Justificación:** Permite centralizar la información común del monedero del usuario (`saldo_actual`, `fecha_emision`, `estado`) en la tabla supertipo `EcoCard`, mientras que las particularidades técnicas de autenticación de cada formato (`token_qr` / `version_app` para `Digital`, y `codigo_barras` / `chip_rfid` para `Física`) se aíslan en sus respectivas tablas hijas.
4. **Diseño de Tablas Resultantes:**
   * `EcoCard` (**`id_ecocard`** [PK], `tipo_card` [Discriminador, NOT NULL], `saldo_actual` [NOT NULL], `fecha_emision` [NOT NULL])
   * `EcoCard_Digital` (**`id_ecocard`** [PK, FK], `token_qr` [UNIQUE, NOT NULL], `dispositivo_asociado`)
   * `EcoCard_Fisica` (**`id_ecocard`** [PK, FK], `codigo_barras` [UNIQUE, NOT NULL], `numero_chip_rfid` [UNIQUE, NOT NULL])
   * *Discriminador:* Columna `tipo_card` en `EcoCard` (Valores permitidos: `'DIGITAL'`, `'FISICA'`).