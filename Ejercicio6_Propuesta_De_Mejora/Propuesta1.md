### Propuesta por: Andres Ramirez Rodriguez 

### 1.Automatización de Ingesta y Sincronización de Datos Sísmicos (Pipeline ETL)
* **Problema que atiende:** 
Actualmente, los datos sísmicos del proyecto son estáticos y requieren que un desarrollador descargue e importe manualmente los archivos en el contenedor de PostgreSQL. Esto hace que la plataforma se desfase rápidamente y dependa de la intervención humana para mostrar información reciente.

### 2. Descripción desde el punto de vista del usuario
*"Como usuario que consulta el mapa interactivo de sismos de México, quiero abrir la plataforma y ver los eventos sísmicos reales ocurridos el día de hoy o durante la última semana, sin necesidad de que un administrador tenga que programar o subir archivos manualmente al servidor"*.

### 3. Cambios que implica en el modelo de datos
* **Nueva entidad (Tabla):** 
`bitacora_etl` (Para auditar el estado de las actualizaciones automáticas).
  * Atributos nuevos: 
  `id` (Clave Primaria), 
  `fecha_ejecucion` (Timestamp), 
  `registros_nuevos` (Int), 
  `estado` (Varchar: Exitoso/Fallido), 
  `fuente` (Varchar: SSN/INEGI).
* **Entidades modificadas:** 
`sismos` (o la tabla principal donde guardas los sismos).
  * Atributo añadido: 
  `creado_el` (Timestamp por defecto 
  `NOW()`), útil para saber en qué lote de la automatización ingresó cada sismo al almacén de datos.

### 4. En qué se apoya
* **Sustento:** Se apoya en una necesidad que el equipo identificó al poner en funcionamiento el sistema. Al levantar el entorno con Docker, observamos que la aplicación depende exclusivamente de la importación inicial de un archivo local en la carpeta `data/`, careciendo de un mecanismo nativo para mantenerse al día con los reportes continuos del Servicio Sismológico Nacional.

### 5. Dificultad estimada y justificación
* **Dificultad:** **Media**.
* **Justificación:** 
Requiere programar un script independiente en Python (usando `requests` y `pandas`) e integrarlo al ecosistema Docker actual mediante una tarea programada (*cron job*) sin alterar las vistas del frontend.
