# Justificación de Selección de Herramientas de Diagramación

Para la representación del modelo de base de datos se utilizaron tres herramientas distintas (**Figma**, **Mermaid** y **Draw.io**), seleccionando cada una en función de la notación gráfica requerida y el nivel de abstracción del diagrama.

---

## 1. Figma para el Modelo Relacional Extendido (EER)

El **Modelo Entidad-Relación Extendido (EER)** exige un alto nivel de flexibilidad visual para representar jerarquías de herencia (especialización/generalización), categorías, componentes agregados y restricciones específicas ($d/o$, $t/p$) sin atarse a las limitaciones de un diseño automático rígido.

* **Sólido control de diseño libre:** Al tratarse de un lienzo de diseño vectorial, Figma permite dibujar y alinear manualmente la notación precisa de especializaciones (conectores con subconjuntos, arcos de disyunción y líneas dobles de completitud).
* **Organización mediante componentes:** Permite crear componentes reutilizables para entidades, atributos y relaciones, garantizando consistencia visual (colores, grosores de línea y tipografía) a lo largo de todo el modelo.
* **Colaboración en tiempo real:** Facilita la revisión y retroalimentación interactiva en equipo durante las fases conceptuales del diseño.

---

## 2. Mermaid para la Notación Crow’s Feet (Pata de Cuervo)

La notación de **Pata de Cuervo** representa el nivel lógico/físico del modelo, centrándose en la estructura de tablas, claves primarias (**PK**), claves foráneas (**FK**) y cardinalidades exactas.

* **Paradigma *Diagrams as Code*:** Permitir definir la estructura lógica mediante código de texto plano simplifica la creación de entidades y sus campos sin perder tiempo alineando cajas o conectores de forma manual.
* **Integración y control de versiones (Git):** El código Mermaid se almacena directamente en el repositorio de Markdown del proyecto, lo que facilita rastrear cambios en el esquema (`git diff`) y revisar modificaciones en *Pull Requests*.
* **Standardization automática:** El motor de Mermaid aplica las reglas gráficas de Pata de Cuervo de forma estandarizada (`||--|{`, `||--o{`), evitando errores humanos de representación visual en las cardinalidades.

---

## 3. Draw.io para la Notación de Peter Chen

La notación clásica de **Peter Chen** exige primitivos geométricos estrictos y diferenciados (rectángulos para entidades, rectángulos dobles para entidades débiles, rombos para relaciones y óvalos para atributos).

* **Librerías nativas del estándar EER/Chen:** Draw.io incluye colecciones de formas prediseñadas específicamente para el modelo Entidad-Relación clásico, incluyendo el triángulo de especialización y conectores con atributos flotantes.
* **Soporte de importación y motores de grafos:** Permite importar directamente la sintaxis de **Graphviz / DOT**, lo que facilita generar la disposición exacta de óvalos, rombos y bordes dobles mediante código de grafos para luego ajustar afinar el diseño en el lienzo.
* **Compatibilidad de exportación:** Permite exportar en formatos vectoriales (`.svg`, `.pdf`) e integrarse sin costuras con suites de documentación como Google Docs, Notion o Microsoft Word.