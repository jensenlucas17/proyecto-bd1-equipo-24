# Decisiones de Diseño — Etapa 2 (Modelo relacional y normalización)

Este documento justifica las decisiones estructurales tomadas al pasar del DER al modelo relacional y al normalizarlo hasta 3FN. Complementa a `docs/etapa-01/decisiones-diseno.md`, que cubre las decisiones conceptuales.

## 1. La dirección se normaliza en una tabla aparte (`DIRECCION`)

**Decisión.** La dirección no se guarda como columnas dentro de `CLIENTE` ni de `PROVEEDOR`: vive en la tabla independiente `DIRECCION`, referenciada por clave foránea (`codigo_direccion`).

**Justificación.**
- **1FN:** "dirección" es un atributo compuesto (calle, altura, código postal...); debe descomponerse en atributos atómicos.
- **3FN / no redundancia:** los datos de domicilio describen a la dirección, no al cliente. Mantenerlos en `CLIENTE` duplica información y genera dependencia transitiva.
- **Reutilización:** cliente, proveedor y envío manejan direcciones con la misma estructura (`ENVIO` referencia `DIRECCION` para origen y destino). Una única tabla evita repetir columnas y permite que un cliente tenga más de un domicilio sin cambiar el esquema.
- **Integridad:** un cambio de domicilio se realiza en un solo lugar.

**Costo asumido.** Obtener el domicilio de un cliente requiere un JOIN adicional; se considera aceptable frente a la consistencia ganada.

## 2. `LOCALIDAD` separada de `DIRECCION`

**Decisión.** `ciudad` y `provincia` se movieron a la tabla `LOCALIDAD` (PK `CP`), referenciada desde `DIRECCION`.

**Justificación.** El código postal determina ciudad y provincia (`CP → ciudad, provincia`), una dependencia transitiva respecto de la clave de `DIRECCION`. Separarla cumple la 3FN y evita repetir y desincronizar esos datos en cada dirección de una misma localidad.

## 3. Clave primaria compuesta en el detalle de venta (`CONTIENE`)

**Decisión.** `CONTIENE` usa como PK la combinación (`nro_venta`, `cod_producto`).

**Justificación.**
- Resuelve la relación **N:M** entre `VENTA` y `PRODUCTO` (RN02): una venta incluye varios productos y un producto aparece en varias ventas.
- La pareja (venta, producto) identifica de forma **única y natural** cada renglón: un mismo producto no puede repetirse dos veces en la misma venta; si se compran varias unidades, se incrementa `cantidad`. La PK compuesta hace cumplir esa regla en la propia base.
- Evita una clave sustituta artificial (`id_detalle`) que no aporta información y permitiría renglones duplicados del mismo producto.
- Ambas columnas son a la vez FK (hacia `VENTA` y `PRODUCTO`), lo que garantiza integridad referencial.

**Consecuencia para la normalización.** Al ser compuesta, obliga a verificar la 2FN: `cantidad` y `precio_unitario` deben depender de la clave completa. Se cumple, una vez eliminado el atributo derivado `monto`.

## 4. El precio unitario se guarda en el detalle y no se lee del catálogo

**Decisión.** `CONTIENE.precio_unitario` almacena el precio pactado al momento de la venta. Las ventas pasadas no se calculan a partir de `PRODUCTO.precio_actual`.

**Justificación.**
- **RN06** y pauta de la cátedra: conservar el precio al momento de la venta para evitar cambios retroactivos.
- `PRODUCTO.precio_actual` cambia con el tiempo (inflación, promociones, actualización de la tienda online). Si el historial leyera de ese campo, cada actualización **alteraría facturas y reportes ya cerrados**.
- No es redundancia: son **dos hechos distintos** (el precio vigente hoy y el precio al que se vendió en una operación concreta), por lo que no viola la 3FN.

**Por qué no se guarda `monto`.** El subtotal (`cantidad × precio_unitario`) es un valor derivado; se calcula por consulta para no arriesgar inconsistencias. Se guarda el dato base histórico y se deriva el resto.

## 5. El catálogo de productos es independiente del servicio técnico

**Decisión.** Se eliminó la FK `nro_orden` de `PRODUCTO`.

**Justificación.** El catálogo (celulares y accesorios a la venta) no depende de las reparaciones. El servicio técnico se vincula con `EQUIPO` y `CLIENTE` (RN04, RN10), no con `PRODUCTO`.

## 6. Descomposición y tipificación de medios de contacto (`TELEFONO`)

**Decisión.** El teléfono no se almacena como un atributo escalar dentro de `CLIENTE`, sino en una relación propia `TELEFONO(codigo_telefono [PK], numero_area, numero)`.

**Justificación.**
* **1FN:** Descompone el número telefónico en unidades atómicas (código de área y número local), evitando cadenas heterogéneas que dificulten validaciones de discado, filtrado por región o mensajería automatizada.

## 7. Claves alternativas('ENVIO')
**Decisión.** En la tabla `ENVIO`, se adopta `cod_seguimiento` como Clave Primaria (PK) y se define `id_envio` como clave candidata alternativa (`UNIQUE NOT NULL`).

**Justificación.**
* `cod_seguimiento` es el identificador operacional real utilizado tanto por el cliente como por las plataformas de logística externa para consultar el estado del paquete.