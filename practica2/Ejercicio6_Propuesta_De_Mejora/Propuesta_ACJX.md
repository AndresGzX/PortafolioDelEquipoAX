# Propuesta de Mejora para el Sistema de Visualización Sísmica (*MUTVI*)

### 1. Título breve y necesidad o problema que atiende

* **Título:** Optimización de Usabilidad Interactiva (UX/UI), Filtro Geográfico de Estados, Descripciones Didácticas e Integración de Indicadores Económicos INEGI.
* **Necesidad/Problema:** El sistema actual presenta barreras de experiencia de usuario (interacciones accidentales con el mapa al deslizar en laptops y pérdida de orientación al cambiar de pantalla por falta de animaciones y navegación clara). Además, el filtrado es limitado para análisis por estado, faltan las descripciones didácticas sobre la clasificación sísmica y aún no se despliegan los datos de la dimensión económica del INEGI a pesar de ser parte de la propuesta original.

---

### 2. Descripción de la funcionalidad (Perspectiva del usuario)

Desde la perspectiva de un **usuario general o investigador**:
1. **Control del Mapa (Scroll-Lock):** Al explorar la plataforma desde una laptop con *touchpad*, el usuario dispone de un botón flotante para "Bloquear/Desbloquear navegación del mapa". Esto evita que el mapa se mueva o cambie de *zoom* por accidente mientras se desplaza verticalmente por la página.
2. **Búsqueda y Búsqueda Filtrada por Estado:** El usuario cuenta con un buscador desplegable para seleccionar un Estado en específico. Al elegirlo, el mapa realiza un enfoque automático (*smooth zoom/pan*) a esa entidad y filtra instantáneamente los sismos e indicadores en pantalla.
3. **Ficha Económica Integrada:** Al consultar un estado o región, el sistema muestra una pestaña de "Información Económica" que despliega gráficos y métricas del INEGI (unidades económicas activas, personal ocupado y sectores expuestos).
4. **Tooltips Didácticos y Animaciones de Navegación:** Al pasar el cursor o hacer clic en las categorías de clasificación sísmica (ej. *sismos de subducción, profundidad intermedia, falla normal*), se despliega un contenedor interactivo con una breve descripción explicativa. Asimismo, las transiciones entre pantallas incluyen animaciones fluidas de entrada/salida y mantienen un botón de "Regresar al Inicio" (*Home*) fijado en la barra superior para evitar la desorientación.

---

### 3. Cambios en el modelo de datos (Entidades, atributos y relaciones)

Tomando como base el modelo dimensional en estrella del Ejercicio 5 (con `fact_eventos_sismicos`, `dim_ubicacion_geografica`, `dim_clasificacion`, `dim_tiempo` y `dim_demografia_inegi`), se aplican los siguientes ajustes:

#### A. Nuevas Entidades y Atributos
* **`dim_clasificacion` (SCD Tipo 0 / Modificada):**
  * *Nuevos Atributos:* `descripcion_didactica` (Texto con la explicación conceptual del tipo de sismo/mecanismo focal) y `icono_categoria` (Ruta o identificador del recurso visual/animación).
* **`dim_economia_inegi` (SCD Tipo 1 / Nueva Entidad):**
  * *Atributos:* `id_economia` (PK), `total_unidades_economicas`, `personal_ocupado_total`, `produccion_bruta_total`, `sector_predominante`, `fk_ubicacion` (FK hacia `dim_ubicacion_geografica`).

#### B. Modificaciones en Tablas de Hechos y Relaciones
* **`fact_eventos_sismicos` (Modificada):**
  * *Nueva Relación:* Se añade la llave foránea `fk_economia` relacionando cada evento/zona con la nueva dimensión `dim_economia_inegi` (o se vincula mediante la relación existente con `dim_ubicacion_geografica` a nivel Estado/Municipio) para calcular métricas de unidades económicas expuestas por sismo.

---

### 4. En qué se apoya la propuesta

Esta mejora se apoya en una combinación de **hallazgos al poner en funcionamiento el sistema (pruebas de usuario)** y **una necesidad identificada por el equipo**:
* **Hallazgo de Usabilidad y UX:** Identificado directamente durante la interacción con la plataforma, donde el control gestual del *touchpad* interfería con el lienzo del mapa y la falta de animaciones de transición generaba desorientación espacial en la interfaz.
* **Línea Incompleta del Artículo:** Los autores del artículo mencionan la integración de los *Censos Económicos del INEGI*, pero en la versión actual del prototipo dicha información no se encuentra completamente modelada ni visible para el usuario final en las pantallas de análisis.

---

### 5. Dificultad estimada y justificación

* **Dificultad Estimada:** **Baja - Media**
* **Justificación de una línea:** La mayoría de las mejoras corresponden a la capa de interfaz de usuario (*frontend* con Leaflet/CSS/JS) y a la adición de una tabla dimensional estática (`dim_economia_inegi`), lo cual no altera radicalmente el motor principal de la base de datos.
