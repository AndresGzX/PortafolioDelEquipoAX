## 4.4 Justificación del Modelo EER

### 1. Dependencia de las Entidades Débiles

* **Perfil**: La dependencia es de **identificación**. Un perfil como "Hijo" o "Papá" no tiene un identificador universal único en una plataforma global; su ciclo de vida y persistencia en disco está indexada directamente a la existencia de la cuenta de suscripción del **Usuario** que paga el servicio.

* **Episodio**: Su dependencia es de **existencia e identificación**. No es posible subir un "Episodio 3, Temporada 1" al servidor de manera aislada si no se encuentra amarrado jerárquicamente a una serie matriz de **Contenido** previamente licenciada en el catálogo.

### 2. Elección del Tipo de Especialización

* Se seleccionó una **Especialización por Atributo Discriminador (`tipo`)** integrada directamente en la tabla **Contenido**. Esta decisión se justifica bajo un criterio estricto de **rendimiento y minimización de JOINs**. Al agrupar propiedades universales (`titulo`, `descripcion`, `anio_estreno`) en una sola entidad y delegar la variación estructural de capítulos únicamente a la tabla externa **Episodio**, optimizamos la velocidad de respuesta del catálogo cuando miles de usuarios consultan la pantalla de inicio simultáneamente.

### 3. Reflejo de las Reglas de Negocio en las Cardinalidades

* Las cardinalidades de muchos a muchos resueltas a través de **Contenido_Genero** permiten que una misma serie o película pertenezca a múltiples categorías taxonómicas (ej. "Acción" y "Ciencia Ficción") simultáneamente, enriqueciendo los algoritmos de búsqueda. 

* Por otro lado, la cardinalidad de la tabla **Pago** hacia **Usuario** e **id_plan** permite que el sistema almacene un registro histórico inalterable de auditoría financiera, capturando los diferentes flujos de caja del cliente en el tiempo sin perder la trazabilidad de qué tarifa estaba vigente en cada mes cobrado.

### 4. Tres Consultas Complejas que Resuelve el Modelo Extendido

Gracias al modelado extendido implementado en el esquema, se pueden responder preguntas críticas de analítica de negocio que un modelo relacional plano no podría resolver:

1. **Control Parental Dinámico por Perfil:**
   * *Pregunta que resuelve*: ¿Qué títulos del catálogo de un género específico deben ser excluidos del menú visual de navegación cuando el usuario inicia sesión desde un **Perfil** que tiene la bandera de restricción `es_infantil = TRUE`?

2. **Embudo de Abandono Crítico de Contenidos (Churn por Capítulo):**
   * *Pregunta que resuelve*: ¿Cuál es el **Episodio** específico de una serie donde se registra el mayor índice de abandono de reproducción, identificado por filas en el **Historial** cuyo `minuto_pausa` no supera el 10% del tiempo total establecido en la columna `duracion_minutos` de dicho episodio?
   
3. **Detección de Fraude por Uso de Pantallas Simultáneas:**
   * *Pregunta que resuelve*: ¿Qué cuentas de **Usuario** presentan registros concurrentes en la tabla **Historial** con la misma `fecha_ultima_reproduccion` en perfiles distintos, cuyo conteo totalizado supera el límite físico de pantallas permitidas en la columna `max_perfiles` de su tabla **PlanSuscripcion**?
