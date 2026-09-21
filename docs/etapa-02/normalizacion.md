# NORMALIZACION 1FN

**Eliminación de grupos repetitivos y garantía de atomicidad**

Para que el modelo relacional alcance la **Primera Forma Normal (1FN)**, se analizó la estructura inicial de los requerimientos y se aplicaron los siguientes pasos para asegurar la integridad básica de los datos:

---

### **Paso 1: Garantizar la atomicidad de los atributos**
Se estructuraron las tablas de modo que cada columna contenga un único valor indivisible.
* **Datos del cliente:** En lugar de utilizar un atributo combinado como `nombre_completo`, se separó en `nombre` y `apellido`.
* **Ubicación geográfica:** Para los clientes y proveedores, se evitó el uso de un campo genérico `direccion_completa`. En su lugar, se creó la entidad independiente **Direccion** con atributos completamente atómicos: `calle`, `altura`, `CP`, `provincia` y `ciudad`.

---

### **Paso 2: Eliminación de grupos repetitivos**
Se identificó que una misma venta (comprobante) puede contener múltiples productos. Si esta relación se mantenía en una única tabla de `VENTA`, se generaría un grupo repetitivo (por ejemplo, columnas como `producto_1`, `producto_2`, `cantidad_1`, etc.), lo cual viola los principios de la 1FN.

* **Solución:** Se aisló este grupo repetitivo creando una tabla independiente llamada **`CONTIENE`** (que funciona como el detalle de la venta). Cada renglón del comprobante de venta pasa a ser un registro único en esta nueva tabla, logrando que la tabla cabecera (`VENTA`) quede libre de repeticiones.

---

### **Paso 3: Identificación unívoca (Claves Primarias)**
Se dotó a cada tabla de una **Clave Primaria (PK)** para garantizar que no existan filas duplicadas idénticas.
* **Tablas fuertes:** Se definieron identificadores únicos (como `dni_cliente`, `nro_orden`, `cod_producto`).
* **Tabla `CONTIENE`:** Para la tabla generada al resolver los grupos repetitivos, se estableció una **clave primaria compuesta** (`nro_venta`, `cod_producto`). Esto asegura de forma estricta que no se pueda registrar exactamente el mismo artículo dos veces en la misma venta, garantizando la unicidad de los registros.

---

# NORMALIZACION 2FN

Una relación está en **Segunda Forma Normal (2FN)** si está en 1FN y todo atributo no clave depende funcionalmente de la clave primaria **completa**, no de una parte de ella. Como una dependencia parcial solo puede existir cuando la clave es compuesta, el análisis se concentra en las tablas con PK compuesta: `CONTIENE` y `ABASTECE`.

### `CONTIENE` (PK: `nro_venta`, `cod_producto`)

Dependencias funcionales:

- (`nro_venta`, `cod_producto`) → `cantidad`: la cantidad vendida es propia de ese producto en esa venta.
- (`nro_venta`, `cod_producto`) → `precio_unitario`: el precio pactado es propio de ese producto en esa venta (ver RN06).

Ningún atributo depende solo de `nro_venta` ni solo de `cod_producto`, por lo que **no hay dependencias parciales**.

**Corrección aplicada: eliminación de `monto`.** Una versión previa del modelo incluía un campo `monto` en el detalle. Se eliminó porque es un atributo **derivado** (`monto = cantidad × precio_unitario`): almacenarlo genera redundancia y riesgo de inconsistencia (si cambia la cantidad y no el monto, la base se contradice). En su lugar se conservan únicamente `cantidad` y `precio_unitario`, y el subtotal de cada renglón y el total de la venta se obtienen por consulta (`SUM(cantidad * precio_unitario)`).

`precio_unitario` no es redundante respecto de `PRODUCTO.precio_actual`: son dos hechos distintos (el precio vigente hoy vs. el precio al que se vendió), y conservarlo evita cambios retroactivos en el historial de ventas.

### `ABASTECE` (PK: `cod_producto`, `cuit_proveedor`)

No tiene atributos no clave, por lo que no hay nada que pueda depender parcialmente de la clave.

### Resto de las tablas

Todas las demás tienen clave primaria simple, por lo que cumplen la 2FN automáticamente.

**Resultado:** el esquema cumple la 2FN.

---

# NORMALIZACION 3FN

Una relación está en **Tercera Forma Normal (3FN)** si está en 2FN y no existen **dependencias transitivas**: ningún atributo no clave depende de otro atributo no clave (X → Y → Z, con Y no clave). Se revisó cada tabla y se detectaron tres situaciones, ya corregidas en el modelo relacional:

### 1. `DIRECCION` y `LOCALIDAD`: dependencia transitiva por el código postal

En `DIRECCION`, los atributos `provincia` y `ciudad` dependen del `CP`, y el `CP` (atributo no clave) depende de `codigo_direccion`:

`codigo_direccion → CP → (ciudad, provincia)`

Es una dependencia transitiva. Además, repetir ciudad y provincia en cada dirección de una misma localidad genera redundancia y anomalías de actualización.

**Corrección:** se creó la tabla `LOCALIDAD` (PK `CP`; atributos `ciudad` y `provincia`) y `DIRECCION` la referencia mediante la FK `CP`.

### 2. `CLIENTE`: datos de dirección duplicados

`calle` y `altura` ya residen en la tabla independiente `DIRECCION`, por lo que mantenerlos también en `CLIENTE` duplicaba información y creaba la dependencia transitiva `dni_cliente → codigo_direccion → (calle, altura)`.

**Corrección:** se eliminaron `calle` y `altura` de `CLIENTE`, que ahora solo conserva la FK `codigo_direccion`.

### 3. `PRODUCTO`: FK `nro_orden` improcedente

`PRODUCTO` contenía la clave foránea `nro_orden` (perteneciente a `SERVICIO_TECNICO`). El catálogo de artículos no depende de las reparaciones: un producto existe y se vende aunque nunca sea reparado, y el servicio técnico se vincula con `EQUIPO` y, a través de él, con `CLIENTE`.

**Corrección:** se eliminó `nro_orden` de `PRODUCTO`.

### Revisión del resto de las tablas

- `PRODUCTO`: `descripcion`, `tipo`, `precio_actual` y `stock_actual` dependen directamente de `cod_producto`.
- `SERVICIO_TECNICO`: `falla_reportada`, `precio_arreglo`, `fecha_ingreso` y `fecha_entrega` son propios de la orden y dependen de `nro_orden`.
- `VENTA`: `fecha_hora`, `metodo_pago`, `canal_venta` y las FK dependen de `nro_venta`.
- `ENVIO`, `PROVEEDOR`, `EQUIPO`, `CONTIENE` y `ABASTECE`: sin dependencias transitivas.
