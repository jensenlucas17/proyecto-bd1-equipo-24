# Reglas de Negocio

A continuación se detallan las reglas de negocio explícitas relevadas para el
sistema Nexus Mobile. Cada regla incluye una breve explicación de su impacto en el
modelo de datos, para facilitar su trazabilidad hacia el modelo entidad-relación y
el modelo relacional desarrollados en la Etapa 2.

---

### RN01 — Relación Cliente–Venta
**Un cliente puede realizar varias compras, pero la compra corresponde a un
solo cliente.**

Impacto en el modelo: relación de cardinalidad 1:N entre `Cliente` y `Venta`. La
entidad `Venta` debe contener obligatoriamente una referencia (clave foránea) al
cliente que la realizó.

---

### RN02 — Relación Venta–Producto
**Una venta puede contener uno o varios productos, y un producto puede estar
incluido en varias ventas.**

Impacto en el modelo: relación N:M entre `Venta` y `Producto`, que se resuelve
mediante una entidad intermedia (`Detalle_Venta`) que registra, además del vínculo,
la cantidad y el monto correspondientes a cada producto dentro de una venta
particular.

---

### RN03 — Atributos obligatorios de producto
**Cada celular y accesorio debe contener un precio, descripción y cantidad de
stock disponible.**

Impacto en el modelo: estos tres atributos (`precio_actual`, `descripcion`,
`stock_actual`) se definen como obligatorios (NOT NULL) en la entidad `Producto`.

---

### RN04 — Relación Cliente–Servicio Técnico
**Un cliente puede ingresar uno o varios productos al servicio técnico, y cada
servicio técnico debe quedar asociado a un cliente correspondiente con su
estado.**

Impacto en el modelo: relación 1:N entre `Cliente` y `Servicio_Tecnico`. Cada
registro de servicio técnico incluye un atributo de `estado` que permite hacer
seguimiento del proceso de reparación (por ejemplo: ingresado, en diagnóstico, en
reparación, listo para retirar, entregado).

---

### RN05 — Atributos obligatorios del servicio técnico
**Un servicio técnico debe contener un estado, precio del arreglo, fecha de
ingreso y fecha de salida.**

Impacto en el modelo: la entidad `Servicio_Tecnico` incluye como atributos
obligatorios `estado`, `precio_arreglo`, `fecha_ingreso` y `fecha_entrega`, además
de la falla reportada por el cliente, que sirve como diagnóstico inicial.

---

### RN06 — Trazabilidad del precio y método de pago en la venta
**Cada venta debe registrar el método de pago utilizado y conservar el precio del
producto correspondiente al momento de realizar la venta.**

Impacto en el modelo: el atributo `metodo_pago` se almacena en la entidad `Venta`,
mientras que el precio pactado se almacena en `Detalle_Venta` (no se toma
directamente del precio actual de `Producto`), de modo que un cambio futuro en el
precio de lista no afecte el historial de ventas ya concretadas. Este es uno de los
motivos por los cuales `Detalle_Venta` conserva su propio atributo de `monto`.

---

### RN07 — Stock unificado entre canales
**Todo producto publicado en la tienda digital debe estar vinculado al mismo stock
centralizado al comercio físico para evitar sobreventas.**

Impacto en el modelo: no existen dos entidades de stock separadas por canal; el
atributo `stock_actual` de `Producto` es único y se actualiza sin importar el canal
de venta (`canal_venta`, atributo de `Venta`) por el que se originó la operación.
Esta regla es central para la integridad del sistema y motivó que el canal de venta
se modele como un atributo de la venta y no como una partición del stock.

---

### RN08 — Registro obligatorio de envío en ventas digitales con despacho
**Las ventas realizadas a través de la tienda digital que requieran despacho deben
registrar obligatoriamente los datos de envío y el código de seguimiento asignado
por Correo Argentino.**

Impacto en el modelo: relación entre `Venta` y `Envio`. No toda venta genera un
envío (por ejemplo, una venta del local físico con retiro en el momento no lo
requiere), por lo que la relación se modela con cardinalidad opcional del lado de
`Venta` hacia `Envio`, pero se vuelve obligatoria cuando el `canal_venta` es digital
y corresponde despacho a domicilio. `Envio` almacena `direccion_origen`,
`direccion_envio`, `estado_envio` y `cod_seguimiento`.

---

## Reglas de negocio implícitas identificadas

Además de las reglas explícitas relevadas, el equipo identificó las siguientes
reglas implícitas, necesarias para sostener la coherencia del modelo:

- **RN09 (implícita):** Un proveedor puede abastecer varios productos, y un producto
  puede ser abastecido por varios proveedores (relación N:M resuelta mediante la
  entidad `Abastece`).
- **RN10 (implícita):** Un equipo (`Equipo`) pertenece a un único cliente, y un
  cliente puede tener registrados varios equipos a lo largo del tiempo, lo cual
  permite asociar más de un servicio técnico al mismo equipo si el cliente lo trae a
  reparar en distintas ocasiones.
- **RN11 (implícita):** La dirección y el teléfono de un cliente o proveedor no son
  atributos atómicos por sí mismos (están compuestos por varios datos), por lo que se
  normalizan en entidades independientes (`Direccion` y `Telefono`) desde el propio
  modelo relacional, según se detalla en `docs/etapa-02/normalizacion.md`.
