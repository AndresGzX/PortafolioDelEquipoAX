-- ============================================================
--  esquema.sql
--  Basado en el documento: Identidad y actores
--  Equipo: Alvarez Cariño Jonathan Xavier
--          Ramírez Rodríguez Andrés
-- ============================================================

-- ============================================================
--  IDENTIDAD Y ACTORES BASE
-- ============================================================

CREATE TABLE ACTOR (
    id          SERIAL          PRIMARY KEY,
    actor_tipo  VARCHAR(50)     NOT NULL
);

CREATE TABLE USUARIO (
    id              SERIAL          PRIMARY KEY,
    actor_id        INT             NOT NULL UNIQUE,
    nombre          VARCHAR(100)    NOT NULL,
    apellidos       VARCHAR(150)    NOT NULL,
    email           VARCHAR(255)    NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    estado_cuenta   VARCHAR(30)     NOT NULL,
    creacion_cuenta TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_usuario_actor FOREIGN KEY (actor_id) REFERENCES ACTOR(id)
);

CREATE TABLE DISPOSITIVO (
    id              SERIAL          PRIMARY KEY,
    usuario_id      INT             NOT NULL,
    tipo_disp       VARCHAR(50)     NOT NULL,
    identificador   VARCHAR(255)    NOT NULL,
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    ultimo_acceso   TIMESTAMP,

    CONSTRAINT fk_dispositivo_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id),
    CONSTRAINT uq_dispositivo_usuario UNIQUE (usuario_id, identificador)
);

CREATE TABLE BITACORA_EVENTO (
    id          SERIAL          PRIMARY KEY,
    actor_id    INT             NOT NULL,
    accion      VARCHAR(255)    NOT NULL,
    fecha       TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_bitacora_actor FOREIGN KEY (actor_id) REFERENCES ACTOR(id)
);

-- ============================================================
--  ORGANIZACIONES Y SUBTIPOS
-- ============================================================

CREATE TABLE ORGANIZACION (
    id          SERIAL          PRIMARY KEY,
    actor_id    INT             NOT NULL UNIQUE,
    nombre      VARCHAR(200)    NOT NULL,
    estado      VARCHAR(30)     NOT NULL,
    creado_en   TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_organizacion_actor FOREIGN KEY (actor_id) REFERENCES ACTOR(id)
);

CREATE TABLE MUNICIPIO (
    organizacion_id     INT             PRIMARY KEY,
    entidad_federativa  VARCHAR(100)    NOT NULL,
    clave_inegi         VARCHAR(20),

    CONSTRAINT fk_municipio_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE EMPRESA_RECICLAJE (
    organizacion_id         INT             PRIMARY KEY,
    materiales_aceptados    TEXT,
    capacidad_kg            NUMERIC(12, 2),

    CONSTRAINT fk_empresa_reciclaje_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE INSTITUCION_FINANCIERA (
    organizacion_id     INT             PRIMARY KEY,
    clave_regulatoria   VARCHAR(100),
    tipo_servicio       VARCHAR(100),

    CONSTRAINT fk_institucion_financiera_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE EMPRESA_TRANSPORTE (
    organizacion_id     INT             PRIMARY KEY,
    modo_transporte     VARCHAR(100)    NOT NULL,
    concesion           VARCHAR(150),

    CONSTRAINT fk_empresa_transporte_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE COMERCIO (
    organizacion_id INT             PRIMARY KEY,
    giro            VARCHAR(100),
    rfc             VARCHAR(20),

    CONSTRAINT fk_comercio_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE ONG_UNIVERSIDAD (
    organizacion_id     INT             PRIMARY KEY,
    tipo_institucion    VARCHAR(100),
    sector              VARCHAR(100),

    CONSTRAINT fk_ong_universidad_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE API_CREDENCIAL (
    id              SERIAL          PRIMARY KEY,
    organizacion_id INT             NOT NULL,
    api_key_hash    VARCHAR(512)    NOT NULL UNIQUE,
    activa          BOOLEAN         NOT NULL DEFAULT TRUE,
    expira_en       TIMESTAMP,

    CONSTRAINT fk_api_credencial_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE API_CREDENCIAL_PERMISO (
    credencial_id   INT             NOT NULL,
    permiso         VARCHAR(100)    NOT NULL,

    PRIMARY KEY (credencial_id, permiso),
    CONSTRAINT fk_api_credencial_permiso FOREIGN KEY (credencial_id) REFERENCES API_CREDENCIAL(id)
);

-- ============================================================
--  CATÁLOGO, CAMPAÑAS Y REGLAS
-- ============================================================

CREATE TABLE TIPO_ACCION (
    id              SERIAL          PRIMARY KEY,
    nombre          VARCHAR(150)    NOT NULL,
    categoria       VARCHAR(100),
    unidad          VARCHAR(50),
    factor_impacto  NUMERIC(10, 4)
);

CREATE TABLE CAMPANA (
    id              SERIAL          PRIMARY KEY,
    organizacion_id INT             NOT NULL,
    nombre          VARCHAR(200)    NOT NULL,
    fecha_inicio    DATE            NOT NULL,
    fecha_fin       DATE,

    CONSTRAINT fk_campana_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE REGLA_RECOMPENSA (
    id                  SERIAL          PRIMARY KEY,
    organizacion_id     INT             NOT NULL,
    tipo_accion_id      INT             NOT NULL,
    campana_id          INT,                          -- opcional
    puntos_por_unidad   NUMERIC(10, 4)  NOT NULL,
    vigente             BOOLEAN         NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_regla_organizacion    FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id),
    CONSTRAINT fk_regla_tipo_accion     FOREIGN KEY (tipo_accion_id)  REFERENCES TIPO_ACCION(id),
    CONSTRAINT fk_regla_campana         FOREIGN KEY (campana_id)      REFERENCES CAMPANA(id)
);

-- ============================================================
--  ECOCARD Y MOVILIDAD
-- ============================================================

CREATE TABLE ECOCARD (
    id              SERIAL          PRIMARY KEY,
    usuario_id      INT             NOT NULL,
    modalidad       VARCHAR(10)     NOT NULL CHECK (modalidad IN ('DIGITAL', 'FISICA')),
    estado          VARCHAR(30)     NOT NULL,
    emitida_en      TIMESTAMP       NOT NULL DEFAULT NOW(),
    desactivada_en  TIMESTAMP,
    -- Solo digital
    token           VARCHAR(512),
    dispositivo_id  INT,
    -- Solo física
    numero_serie    VARCHAR(100)    UNIQUE,
    uid_chip        VARCHAR(100)    UNIQUE,
    fecha_entrega   DATE,

    CONSTRAINT fk_ecocard_usuario       FOREIGN KEY (usuario_id)     REFERENCES USUARIO(id),
    CONSTRAINT fk_ecocard_dispositivo   FOREIGN KEY (dispositivo_id) REFERENCES DISPOSITIVO(id)
);

CREATE TABLE VIAJE (
    id          SERIAL      PRIMARY KEY,
    ecocard_id  INT         NOT NULL,
    inicio      TIMESTAMP   NOT NULL,
    fin         TIMESTAMP,
    es_sostenible BOOLEAN   NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_viaje_ecocard FOREIGN KEY (ecocard_id) REFERENCES ECOCARD(id)
);

CREATE TABLE TRAMO_VIAJE (
    viaje_id                INT             NOT NULL,
    orden                   SMALLINT        NOT NULL,
    empresa_transporte_id   INT             NOT NULL,
    modo_transporte         VARCHAR(100)    NOT NULL,
    tarifa                  NUMERIC(10, 2),
    es_transbordo           BOOLEAN         NOT NULL DEFAULT FALSE,

    PRIMARY KEY (viaje_id, orden),
    CONSTRAINT fk_tramo_viaje       FOREIGN KEY (viaje_id)              REFERENCES VIAJE(id),
    CONSTRAINT fk_tramo_empresa     FOREIGN KEY (empresa_transporte_id) REFERENCES EMPRESA_TRANSPORTE(organizacion_id)
);

-- ============================================================
--  ACCIONES SOSTENIBLES Y SUBTIPOS
-- ============================================================

CREATE TABLE ACCION_SOSTENIBLE (
    id                  SERIAL          PRIMARY KEY,
    usuario_id          INT             NOT NULL,
    organizacion_id     INT             NOT NULL,
    tipo_accion_id      INT             NOT NULL,
    cantidad            NUMERIC(12, 4)  NOT NULL,
    estado_verificacion VARCHAR(30)     NOT NULL,
    verificada_en       TIMESTAMP,
    fecha_accion        TIMESTAMP       NOT NULL,

    CONSTRAINT fk_accion_usuario        FOREIGN KEY (usuario_id)        REFERENCES USUARIO(id),
    CONSTRAINT fk_accion_organizacion   FOREIGN KEY (organizacion_id)   REFERENCES ORGANIZACION(id),
    CONSTRAINT fk_accion_tipo           FOREIGN KEY (tipo_accion_id)    REFERENCES TIPO_ACCION(id)
);

CREATE TABLE ACCION_RECICLAJE (
    accion_id   INT             PRIMARY KEY,
    material    VARCHAR(100)    NOT NULL,
    piezas      INT,
    peso_kg     NUMERIC(10, 4),

    CONSTRAINT fk_accion_reciclaje FOREIGN KEY (accion_id) REFERENCES ACCION_SOSTENIBLE(id)
);

CREATE TABLE ACCION_MOVILIDAD (
    accion_id   INT     PRIMARY KEY,
    viaje_id    INT     NOT NULL,

    CONSTRAINT fk_accion_movilidad_accion   FOREIGN KEY (accion_id) REFERENCES ACCION_SOSTENIBLE(id),
    CONSTRAINT fk_accion_movilidad_viaje    FOREIGN KEY (viaje_id)  REFERENCES VIAJE(id)
);

CREATE TABLE ACCION_CAMPANA (
    accion_id   INT     PRIMARY KEY,
    campana_id  INT     NOT NULL,

    CONSTRAINT fk_accion_campana_accion     FOREIGN KEY (accion_id)  REFERENCES ACCION_SOSTENIBLE(id),
    CONSTRAINT fk_accion_campana_campana    FOREIGN KEY (campana_id) REFERENCES CAMPANA(id)
);

-- ============================================================
--  ECOPOINTS, RECOMPENSAS Y CANJES
-- ============================================================

CREATE TABLE TRANSACCION_PUNTOS (
    id          SERIAL          PRIMARY KEY,
    usuario_id  INT             NOT NULL,
    puntos      INT             NOT NULL,   -- positivo = ganancia, negativo = gasto
    fecha       TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_transaccion_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id)
);

CREATE TABLE GANANCIA (
    transaccion_id  INT     PRIMARY KEY,
    accion_id       INT     NOT NULL UNIQUE,
    regla_id        INT     NOT NULL,

    CONSTRAINT fk_ganancia_transaccion  FOREIGN KEY (transaccion_id)   REFERENCES TRANSACCION_PUNTOS(id),
    CONSTRAINT fk_ganancia_accion       FOREIGN KEY (accion_id)        REFERENCES ACCION_SOSTENIBLE(id),
    CONSTRAINT fk_ganancia_regla        FOREIGN KEY (regla_id)         REFERENCES REGLA_RECOMPENSA(id)
);

CREATE TABLE RECOMPENSA (
    id              SERIAL          PRIMARY KEY,
    organizacion_id INT             NOT NULL,
    nombre          VARCHAR(200)    NOT NULL,
    categoria       VARCHAR(100),
    costo_puntos    INT             NOT NULL,
    stock           INT,
    vigente         BOOLEAN         NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_recompensa_organizacion FOREIGN KEY (organizacion_id) REFERENCES ORGANIZACION(id)
);

CREATE TABLE CANJE (
    id              SERIAL          PRIMARY KEY,
    usuario_id      INT             NOT NULL,
    recompensa_id   INT             NOT NULL,
    puntos_usados   INT             NOT NULL,
    estado_actual   VARCHAR(30)     NOT NULL,
    fecha           TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_canje_usuario     FOREIGN KEY (usuario_id)    REFERENCES USUARIO(id),
    CONSTRAINT fk_canje_recompensa  FOREIGN KEY (recompensa_id) REFERENCES RECOMPENSA(id)
);

CREATE TABLE GASTO (
    transaccion_id  INT     PRIMARY KEY,
    canje_id        INT     NOT NULL UNIQUE,

    CONSTRAINT fk_gasto_transaccion FOREIGN KEY (transaccion_id)    REFERENCES TRANSACCION_PUNTOS(id),
    CONSTRAINT fk_gasto_canje       FOREIGN KEY (canje_id)          REFERENCES CANJE(id)
);

CREATE TABLE AJUSTE (
    transaccion_id  INT             PRIMARY KEY,
    motivo          TEXT,
    autorizado_por  INT,            -- actor_id del autorizador

    CONSTRAINT fk_ajuste_transaccion    FOREIGN KEY (transaccion_id)   REFERENCES TRANSACCION_PUNTOS(id),
    CONSTRAINT fk_ajuste_actor          FOREIGN KEY (autorizado_por)   REFERENCES ACTOR(id)
);

-- ============================================================
--  SALDO Y MOVIMIENTOS
-- ============================================================

CREATE TABLE MONEDERO (
    id          SERIAL          PRIMARY KEY,
    usuario_id  INT             NOT NULL UNIQUE,
    saldo       NUMERIC(14, 2)  NOT NULL DEFAULT 0.00,
    moneda      VARCHAR(10)     NOT NULL DEFAULT 'MXN',

    CONSTRAINT fk_monedero_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id)
);

CREATE TABLE MOVIMIENTO_SALDO (
    id          SERIAL          PRIMARY KEY,
    monedero_id INT             NOT NULL,
    monto       NUMERIC(14, 2)  NOT NULL,
    fecha       TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_movimiento_monedero FOREIGN KEY (monedero_id) REFERENCES MONEDERO(id)
);

CREATE TABLE RECARGA (
    movimiento_id       INT             PRIMARY KEY,
    institucion_id      INT             NOT NULL,
    metodo_pago         VARCHAR(100),
    referencia_externa  VARCHAR(255),

    CONSTRAINT fk_recarga_movimiento    FOREIGN KEY (movimiento_id) REFERENCES MOVIMIENTO_SALDO(id),
    CONSTRAINT fk_recarga_institucion   FOREIGN KEY (institucion_id) REFERENCES INSTITUCION_FINANCIERA(organizacion_id)
);

CREATE TABLE PAGO (
    movimiento_id   INT         PRIMARY KEY,
    ecocard_id      INT         NOT NULL,
    viaje_id        INT         NOT NULL,
    tramo_orden     SMALLINT    NOT NULL,

    CONSTRAINT fk_pago_movimiento   FOREIGN KEY (movimiento_id)             REFERENCES MOVIMIENTO_SALDO(id),
    CONSTRAINT fk_pago_ecocard      FOREIGN KEY (ecocard_id)                REFERENCES ECOCARD(id),
    CONSTRAINT fk_pago_tramo        FOREIGN KEY (viaje_id, tramo_orden)     REFERENCES TRAMO_VIAJE(viaje_id, orden),
    CONSTRAINT uq_pago_tramo        UNIQUE (viaje_id, tramo_orden)
);

CREATE TABLE REEMBOLSO (
    movimiento_id   INT     PRIMARY KEY,
    pago_id         INT     NOT NULL UNIQUE,
    motivo          TEXT,

    CONSTRAINT fk_reembolso_movimiento  FOREIGN KEY (movimiento_id) REFERENCES MOVIMIENTO_SALDO(id),
    CONSTRAINT fk_reembolso_pago        FOREIGN KEY (pago_id)       REFERENCES PAGO(movimiento_id)
);
