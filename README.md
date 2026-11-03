# NexusMobile — Sistema de Gestión Comercial y Servicio Técnico

![SQL Server](https://img.shields.io/badge/RDBMS-SQL%20Server%20Express-red?style=flat-square&logo=microsoftsqlserver)
![Licenciatura en Sistemas de Información](https://img.shields.io/badge/Carrera-LSI%20--%20FaCENA%20--%20UNNE-blue?style=flat-square)
![Comisión](https://img.shields.io/badge/Comisi%C3%B3n-2%20--%20Grupo%2024-green?style=flat-square)
![Estado](https://img.shields.io/badge/Estado-Completado%20(Etapas%20I%20a%20V)-brightgreen?style=flat-square)

Trabajo Práctico Integrador de la asignatura **Bases de Datos I**, perteneciente a la **Licenciatura en Sistemas de Información** de la Facultad de Ciencias Exactas y Naturales y Agrimensura (**FaCENA - UNNE**).

---

## 👥 Integrantes del Grupo (Grupo 24 — Comisión 2)

* **Fernández Casado, Guido Sebastián**
* **Gonzales Thomas, Federico José**
* **Jensen, Lucas Nahuel**
* **Romero Lencinas, Santiago Joaquín**
* **Scher Emily, Giuliana**

### 👨‍🏫 Equipo Docente de Cátedra
* **Prof. Walter O. Vallejos**
* **Prof. Carlos Romero**

---

## 📌 Descripción del Proyecto

**NexusMobile** es un sistema de bases de datos relacional diseñado para modelar, gestionar y optimizar el circuito comercial y operativo de una empresa dedicada a la venta de dispositivos móviles, accesorios informáticos y prestación de servicio técnico integral con seguimiento de envíos.

El sistema garantiza:
1. **Control integral de ventas multicanal** (`Online` y `Local`), detallando las transacciones de ítems con congelamiento histórico del precio pactado.
2. **Administración de reparaciones técnicas**, registrando el historial del equipo, diagnóstico, presupuesto y fechas de entrega.
3. **Trazabilidad logística de envíos** asociados a cada operación comercial.
4. **Gestión de catálogo, existencias y proveedores**, cumpliendo con normalización hasta Cuarta Forma Normal (4FN).

---

## 🗂️ Estructura del Repositorio

El repositorio se encuentra estructurado en carpetas modulares que separan la documentación técnica analítica del código SQL ejecutable:

```text
.
├── README.md                           # Portada y documentación general del repositorio
├── docs/                               # Documentación conceptual por etapas
│   ├── etapa-01/                       # Relevamiento y especificación funcional
│   │   ├── alcance.md                  # Alcance y límites del sistema
│   │   ├── decisiones-diseno.md        # Justificación de entidades iniciales
│   │   ├── descripcion-caso.md         # Narrativa del negocio NexusMobile
│   │   └── reglas-de-negocio.md        # Restricciones semánticas y operativas (RN)
│   ├── etapa-02/                       # Modelado conceptual, lógico y normalización
│   │   ├── decisiones-diseno.md        # Transformación MER a Modelo Relacional
│   │   ├── modelo-relacional.md        # Esquema de tablas, PK y FK
│   │   ├── normalizacion.md            # Análisis riguroso (1FN, 2FN, 3FN y 4FN)
│   │   └── der/
│   │       └── der.png                 # Diagrama Entidad-Relación formal
│   ├── etapa-03/                       # Definición física e integridad
│   │   ├── implementacion.md           # Estructura del DDL físico
│   │   ├── pruebas-validacion.md       # Casos de prueba de carga de datos
│   │   └── restriciones-integridad.md  # CHECK, UNIQUE, NOT NULL y FOREIGN KEY
│   ├── etapa-04/                       # Explotación de datos y reportería
│   │   ├── casos-uso.md                # Requerimientos analíticos de consulta
│   │   ├── comprobante-venta.md        # Emisión de comprobante individual con JOINs
│   │   ├── consulta-avanzada.md        # Consulta de negocio con filtros complejos
│   │   └── informe-venta.md            # Reporte agregado mensual por categoría
│   └── etapa-05/                       # Temas técnicos avanzados
│       ├── indices-optimizacion.md     # Planes de ejecución y tuning con índices
│       ├── procedimiento-funciones.md  # SPs y UDFs de lógica encapsulada
│       ├── seguridad.md                # Roles, usuarios y permisos granulares (DCL)
│       ├── transacciones.md            # Atomicidad, ACID y transacciones anidadas
│       ├── triggers-auditoria.md       # Disparadores de auditoría y stock automático
│       └── imagenes/Indices/           # Evidencias de planes de ejecución
└── sql/                                # Scripts Transact-SQL ejecutables
    ├── ddl/
    │   └── crear_bd.sql                # Creación de BD, tablas y restricciones
    ├── dml/
    │   └── datos_prueba.sql            # Carga de datos inicial consistente
    ├── consultas/
    │   ├── comprobante_venta.sql       # Script de facturación individual
    │   ├── consulta_avanzada.sql       # Consulta analítica avanzada
    │   └── informe-venta.sql           # Reporte mensual por categoría (GROUP BY)
    └── tecnico/                        # Implementaciones avanzadas en T-SQL
        ├── funciones/funciones.sql
        ├── indices/indices.sql
        ├── procedimientos/procedimientos.sql
        ├── seguridad/seguridad.sql
        ├── transacciones/transaciones.sql
        └── triggers/triggers.sql
```

---

## 📐 Modelo Relacional y Esquema Físico

El diseño físico está normalizado en **Tercera y Cuarta Forma Normal**, compuesto por 11 tablas relacionales:

* **Geografía:** `LOCALIDAD (CP, provincia, ciudad)` y `Direccion (codigo_direccion, calle, altura, CP)`.
* **Actores:** `CLIENTE (dni_cliente, nombre, apellido, telefono, codigo_direccion)` y `PROVEEDOR (cuit_proveedor, nombre, telefono, email, codigo_direccion)`.
* **Catálogo e Inventario:** `PRODUCTO (cod_producto, descripcion, tipo, stock_actual, precio_actual)`.
* **Abastecimiento (M:N descompuesta):** `ABASTECE (cod_producto, cuit_proveedor)`.
* **Servicio Técnico:** `EQUIPO (id_equipo, nombre, descripcion, dni_cliente)` y `SERVICIO_TECNICO (nro_orden, falla_reportada, precio_arreglo, fecha_ingreso, fecha_entrega, id_equipo)`.
* **Ventas y Envíos:** `ENVIO (cod_seguimiento, id_envio, direccion_origen, direccion_envio, estado_envio)`, `VENTA (nro_venta, fecha_hora, metodo_pago, canal_venta, dni_cliente, cod_seguimiento)` y la relación de detalle `CONTIENE (nro_venta, cod_producto, cantidad, precio_unitario)`.

El diagrama de esquema relacional completo se encuentra en [`docs/etapa-02/der/der.png`](docs/etapa-02/der/der.png).

---

## 🚀 Guía de Ejecución

### 1. Crear la Estructura de Tablas (DDL)
1. Abrir **SQL Server Management Studio (SSMS)** y conectarse a la instancia local.
2. Abrir y ejecutar el script:
   [`sql/ddl/crear_bd.sql`](sql/ddl/crear_bd.sql)
   *Este script inicializa la base de datos `[NexusMobile]` con todas sus claves primarias, foráneas, restricciones de nulidad y chequeos semánticos.*

### 2. Cargar el Set de Datos de Prueba (DML)
1. Abrir y ejecutar en SSMS el script:
   [`sql/dml/datos_prueba.sql`](sql/dml/datos_prueba.sql)
   *Realiza una carga transaccional atómica de clientes, direcciones, catálogo de productos, órdenes de servicio y ventas de prueba.*

### 3. Ejecución de Consultas y Reportes
* **Comprobante de Venta:** [`sql/consultas/comprobante_venta.sql`](sql/consultas/comprobante_venta.sql)
* **Reporte Mensual Agregado:** [`sql/consultas/informe-venta.sql`](sql/consultas/informe-venta.sql)
* **Consulta Avanzada:** [`sql/consultas/consulta_avanzada.sql`](sql/consultas/consulta_avanzada.sql)

### 4. Objetos Técnicos y Pruebas Avanzadas
Los componentes de la Etapa V se encuentran organizados por especialidad:
* **Transacciones y Atomicidad:** [`sql/tecnico/transacciones/transaciones.sql`](sql/tecnico/transacciones/transaciones.sql)
* **Índices y Optimización:** [`sql/tecnico/indices/indices.sql`](sql/tecnico/indices/indices.sql)
* **Triggers de Auditoría:** [`sql/tecnico/triggers/triggers.sql`](sql/tecnico/triggers/triggers.sql)
* **Procedimientos Almacenados:** [`sql/tecnico/procedimientos/procedimientos.sql`](sql/tecnico/procedimientos/procedimientos.sql)
* **Funciones Definidas por el Usuario:** [`sql/tecnico/funciones/funciones.sql`](sql/tecnico/funciones/funciones.sql)
* **Seguridad y Permisos:** [`sql/tecnico/seguridad/seguridad.sql`](sql/tecnico/seguridad/seguridad.sql)

---

## 🧪 Resumen de las Etapas del Proyecto

| Etapa | Descripción Principal | Enlace a Documentación |
| :---: | :--- | :---: |
| **I** | Descripción del caso, alcance operativo, decisiones de diseño y matriz de Reglas de Negocio (RN). | [`docs/etapa-01/`](docs/etapa-01/) |
| **II** | Modelo Conceptual DER, traducción a Modelo Relacional y normalización formal hasta 4FN. | [`docs/etapa-02/`](docs/etapa-02/) |
| **III** | Implementación del esquema DDL en SQL Server, validaciones de integridad referencial y semántica. | [`docs/etapa-03/`](docs/etapa-03/) |
| **IV** | Consultas analíticas de negocio con `JOIN`, agrupamiento (`GROUP BY`, `SUM`, `COUNT`) y emisión de comprobantes. | [`docs/etapa-04/`](docs/etapa-04/) |
| **V** | Manejo de transacciones ACID y anidadas (`@@TRANCOUNT`), índices con análisis de plan de ejecución, triggers, SP, UDF y DCL. | [`docs/etapa-05/`](docs/etapa-05/) |

---

## 📚 Tecnologías Utilizadas

* **Motor de Base de Datos:** Microsoft SQL Server Express (T-SQL)
* **Administrador / IDE:** SQL Server Management Studio (SSMS)
* **Control de Versiones:** Git & GitHub
* **Metodología de Modelado:** Modelo Entidad-Relación de Peter Chen & Álgebra Relacional de E. F. Codd