# Decisiones de Diseño — Etapa 1

Este documento resume las decisiones tomadas por el equipo durante el relevamiento
inicial y la definición conceptual del problema, previas a la construcción formal
del Diagrama Entidad-Relación (DER), que se desarrolla en la Etapa 2.

## 1. Unificación de canales de venta en una sola entidad `Venta`

En lugar de modelar la venta física y la venta digital como dos entidades
separadas, se decidió representarlas mediante una única entidad `Venta` con un
atributo `canal_venta` que distingue el origen de la operación (físico / digital).

**Motivo:** ambos canales comparten prácticamente todos los atributos relevantes
(cliente, productos, método de pago, fecha), y separarlos en dos entidades hubiese
duplicado estructura y dificultado los reportes consolidados de ventas. Esta
decisión está directamente alineada con RN07, que exige stock centralizado sin
distinción de canal.

## 2. Entidad intermedia `Detalle_Venta` en lugar de relación directa Venta–Producto

Dado que una venta puede incluir varios productos con distinta cantidad y que el
precio debe quedar fijado al momento de la operación (RN06), se decidió modelar
`Detalle_Venta` como entidad propia (no solo como tabla de resolución N:M
"vacía"), con atributos propios: `cantidad`, `monto` (precio unitario pactado) y
`monto_historico`.

**Motivo:** una relación N:M "pura" solo resuelve el vínculo, pero no permite
almacenar información propia de cada línea de venta, que en este caso es
imprescindible para la trazabilidad de precios.

## 3. Separación de `Equipo` como entidad independiente de `Servicio_Tecnico`

Se decidió modelar `Equipo` (el dispositivo físico del cliente) como una entidad
distinta de `Servicio_Tecnico` (el proceso de reparación en sí), relacionadas entre
sí y ambas vinculadas a `Cliente`.

**Motivo:** un mismo equipo puede pasar por más de un proceso de servicio técnico a
lo largo del tiempo (por ejemplo, distintas reparaciones en fechas diferentes), por
lo que separar ambos conceptos permite conservar el historial completo de cada
dispositivo sin duplicar sus datos identificatorios (marca, modelo, descripción)
en cada ingreso a reparación.

## 4. `Envio` como entidad opcional dependiente de `Venta`

Se decidió que no toda venta genere un registro de envío, sino solamente aquellas
ventas digitales que requieran despacho a domicilio (RN08).

**Motivo:** modelar el envío como una relación obligatoria hubiese forzado a
completar datos de envío incluso en ventas del local físico donde el cliente se
lleva el producto en el momento, generando atributos vacíos o inconsistentes.

## 5. Relación N:M entre `Producto` y `Proveedor` mediante `Abastece`

Se decidió que un proveedor pueda abastecer múltiples productos y que un producto
pueda ser abastecido por más de un proveedor, resuelto mediante una entidad
intermedia `Abastece`.

**Motivo:** en la práctica del rubro, es habitual que un mismo modelo de celular o
accesorio pueda conseguirse a través de más de un distribuidor, y que un mismo
proveedor ofrezca un catálogo amplio de productos distintos. Modelar esta relación
como N:M refleja fielmente esa realidad del negocio.

## 6. Priorización de atributos identificatorios claros

Se decidió utilizar identificadores propios del negocio como claves candidatas
donde correspondía (por ejemplo, `dni_cliente`, `cuit_proveedor`, `cod_producto`),
en lugar de depender únicamente de identificadores autogenerados sin significado
para el negocio. Esta decisión facilita la validación de datos y la
correspondencia con documentación externa (DNI, CUIT).

---

Las decisiones de diseño vinculadas específicamente al proceso de normalización del
modelo relacional (1FN, 2FN y 3FN) se documentan por separado en
`docs/etapa-02/decisiones-diseno.md`, ya que corresponden a una etapa posterior del
proyecto.
