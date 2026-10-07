# Ejercicio 4. Modelo EER del Proyecto Propio

---

## 4.1 Requisitos Ampliados: StreamVerse

### Descripción del Problema

La plataforma de streaming **StreamVerse** presenta fallas críticas debido a la dispersión de su información. El modelo diseñado centraliza de forma relacional el control de cuentas de accesos (**Usuario**), la subdivisión de perfiles personalizados (**Perfil**), el registro de transacciones de facturación (**Pago**) mapeados a un catálogo de tarifas de mercado (**PlanSuscripcion**), la categorización taxonómica del catálogo (**Contenido**, **Genero**, **Contenido_Genero**) y el control minucioso de visualizaciones multimedia mediante marcas de tiempo (**Historial**, **Episodio**).

### Restricciones de Cardinalidad Específicas

* **PlanSuscripcion – Pago**: Un **PlanSuscripcion** puede estar asociado a cero o muchos `(0,N)` **Pagos** históricos. Un **Pago** se efectúa obligatoriamente bajo un único `(1,1)` **PlanSuscripcion**.

* **Usuario – Perfil**: Un **Usuario** puede gestionar desde uno hasta muchos `(1,N)` **Perfiles** en su cuenta (límite parametrizado por el negocio mediante la columna `max_perfiles`). Un **Perfil** pertenece estricta y únicamente a un `(1,1)` **Usuario**.

* **Perfil – Historial**: Un **Perfil** acumula de cero a muchos `(0,N)` registros de reproducción en el tiempo. Cada fila del **Historial** es propiedad exclusiva de un `(1,1)` **Perfil**.

* **Contenido – Episodio**: Un **Contenido** (cuya categoría sea de tipo serie) puede estructurarse en cero o muchos `(0,N)` **Episodios**. Un **Episodio** se asocia de forma mandatoria a un único `(1,1)` **Contenido** padre.

### Entidades que Dependen de Otras (Entidades Débiles)

* **Perfil**: Es una **entidad débil por existencia e identificación** dependiente de **Usuario**. Su clave primaria conceptual se hereda compuestos por el identificador de la cuenta principal (`id_usuario`). Carece de sentido de negocio almacenar las preferencias de un perfil si la cuenta raíz del cliente es dada de baja.

* **Episodio**: Es una **entidad débil por identificación** respecto a **Contenido**. El número de episodio o temporada no posee unicidad global en la plataforma si se desvincula del identificador del show principal (`id_contenido`).

* **Contenido_Genero**: Es una **entidad asociativa débil** que depende enteramente de la existencia en paralelo de un registro en **Contenido** y un registro en **Genero** para romper la relación de muchos a muchos (N:M).

### Jerarquías de Especialización (Categorías y Tipos)

* La entidad **Contenido** implementa una jerarquía implícita mediante una estrategia de **Single Table Inheritance (STI)** utilizando la columna discriminadora **`tipo`** (cuyos valores válidos son 'Película' o 'Serie'). 

* En el modelo extendido, representa una especialización **disjunta y total**: un registro en catálogo debe ser obligatoriamente uno de los dos formatos multimedia y, en caso de discriminarse como 'Serie', gatilla la existencia obligatoria de entidades débiles hijas en la tabla **Episodio**.

### Relaciones que Involucran Más de Dos Entidades (Relación Ternaria)

* **Historial**: Actúa conceptualmente como una relación compleja/ternaria indirecta. Para consolidar el estado de reproducción, la base de datos intercepta en un instante del tiempo (`fecha_ultima_reproduccion`) los identificadores de un **Perfil** activo, un **Contenido** global (para largometrajes planos) y un **Episodio** específico (para el seguimiento secuencial de series).

---
