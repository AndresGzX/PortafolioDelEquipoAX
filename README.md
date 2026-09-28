### Integrantes del Equipo
* **Alvarez Cariño, Jonathan Xavier**
* **Ramírez Rodríguez, Andrés**

---

###  Repositorios del Proyecto

| Tipo de Repositorio | Integrante / Autor | Enlace de Acceso |
| :--- | :--- | :--- |
| **Repositorio Original Asignado** | Gabriel Hurtado Avilés (`gabrielhuav`) | [Seismic-Data-Visualization-System](https://github.com) |
| **Fork 1** | Andrés Ramírez Rodríguez (`AndresGzX`) | [Seismic-Data-Visualization-System (AndresGzX)](https://github.com) |
| **Fork 2** | Jonathan Xavier Alvarez Cariño (`Xavxd`) | [Seismic-Data-Visualization-System-A-X (Xavxd)](https://github.com) |

---

###   Confirmacion puesta en funcionamiento
<img width="1917" height="1197" alt="image" src="https://github.com/user-attachments/assets/50d5fbcd-6280-4cd8-a8f1-8ce2c349d9c9" />

### Detalles de las Propuestas de Mejora (Issues)

#### LINK AL ISSUE 1 ---> (https://github.com/AndresGzX/bdPracticaDos/issues/4)
* **Propuesta por:** Andrés Ramírez Rodríguez
* **Problema y solución:** Los datos actuales son estáticos y requieren importación manual a PostgreSQL. La propuesta automatiza la consulta de eventos recientes mediante un pipeline ETL para evitar desfasajes.
* **Modelo y Dificultad:** Añade la entidad `bitacora_etl` e incorpora el atributo `creado_el` en sismos. Su dificultad es **Media** al requerir un script en Python integrado en Docker.

---

#### LINK AL ISSUE 2 ---> (https://github.com/AndresGzX/bdPracticaDos/issues/3)
* **Propuesta por:** Andrés Ramírez Rodríguez / Equipo
* **Problema y solución:** Atiende barreras de usabilidad como interacciones accidentales de *scroll*, falta de filtros avanzados por estado y ausencia de indicadores económicos del INEGI. Implementa mejoras visuales, *scroll-lock*, buscador con zoom y fichas económicas.
* **Modelo y Dificultad:** Modifica `dim_clasificacion`, añade la dimensión `dim_economia_inegi` y vincula `fact_eventos_sismicos`. Su dificultad estimada es **Baja - Media**.
