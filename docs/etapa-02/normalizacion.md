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
Establece que además de cumplir con la primera forma normal, todo atributo no clave debe depender de la clave primaria completa, no de una parte de ella. Esto solo aplica cuando la clave primaria es compuesta.

En nuestro caso se identifican dos tablas que contienen claves compuestas, que son, `CONTIENE` y `ABASTECE`.

En `CONTIENE`, tanto cantidad como precio_unitario_historico dependen de la combinación completa (`cod_producto`, `nro_venta`): la cantidad vendida y el precio aplicado son propios de esa línea de esa venta, no de un producto en abstracto ni de una venta en abstracto por separado.

Por su parte `ABASTECE` no tiene atributos no clave, por lo que no hay nada que pueda depender parcialmente de la clave.

Todas las demás tablas tienen clave primaria simple, así que 2FN se cumple automáticamente en ellas.

---

# NORMALIZACION 3FN
Se revisó cada tabla buscando atributos no clave que dependieran de otro atributo no clave en vez de depender directamente de la clave:

En `CLIENTE`, `calle` y `altura` dependen directamente de `dni_cliente`; no hay dependencia entre ellos (conocer la calle no determina la altura).

En `PRODUCTO`, `descripcion`, `tipo`, `precio_actual` y `stock_actual` dependen todos directamente de `cod_producto`.

En `SERVICIO_TECNICO`, tanto `Fecha_ingreso` como `Fecha_entrega` quedaron como atributos propios de la orden de servicio (no del equipo), dependiendo directamente de `nro_orden`.

En `DIRECCION`, notamos una dependencia transitiva entre `provincia` y `ciudad` con el `CP`, ya que el `CP` determina a los dos atributos. Por esto se decició crear una tabla localidad que contenga como **Clave Primaria (PK)**  a `CP` y atributos `ciudad` y `provincia`. Y esto relacionarlo con direccion mediante una **Clave Foranea (FK)** .