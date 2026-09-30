# Restricciones de Integridad — Etapa 3

Este documento detalla las restricciones de integridad definidas en el script DDL
(`implementacion1.sql`) para cada tabla del modelo físico, agrupadas por tipo:
integridad de entidad (PK), integridad de dominio (NOT NULL, CHECK, tipos de
datos), integridad de unicidad (UNIQUE) e integridad referencial (FK).

---

## 1. LOCALIDAD

| Tipo | Restricción |
|---|---|
| Clave primaria | `CP` (código postal) — clave natural, no subrogada. |
| Dominio | `provincia` y `ciudad` obligatorios (`NOT NULL`). |

`LOCALIDAD` es la tabla base de la jerarquía de direcciones: no depende de ninguna
otra tabla, por lo que no tiene restricciones referenciales propias.

---

## 2. Direccion

| Tipo | Restricción |
|---|---|
| Clave primaria | `codigo_direccion` (subrogada, `IDENTITY`). |
| Dominio | `calle`, `altura` y `CP` obligatorios. |
| Chequeo | `CK_Direccion_Altura`: `altura >= 0`, evita valores negativos sin sentido físico. |
| Referencial | `FK_Direccion_Localidad` → `LOCALIDAD(CP)`. `ON DELETE NO ACTION` / `ON UPDATE CASCADE`. |

**Por qué `ON UPDATE CASCADE` en esta FK particular:** es la única excepción al
criterio general de `NO ACTION` en actualizaciones. Como `CP` es una clave natural
(no subrogada), existe la posibilidad de que un código postal se corrija o se
renumere administrativamente; en ese caso, la corrección debe propagarse
automáticamente a todas las direcciones que lo referencian, en vez de bloquear la
actualización o dejar direcciones con un CP inexistente.

---

## 3. CLIENTE

| Tipo | Restricción |
|---|---|
| Clave primaria | `dni_cliente` — clave natural. |
| Dominio | `nombre`, `apellido`, `telefono` y `codigo_direccion` obligatorios. |
| Referencial | `FK_Cliente_Direccion` → `Direccion(codigo_direccion)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |

**Por qué `NO ACTION` en el borrado:** no se debe poder eliminar una dirección
mientras exista un cliente que la esté usando, para no dejar clientes con una
referencia inválida ni perder trazabilidad de domicilios históricos.

---

## 4. EQUIPO

| Tipo | Restricción |
|---|---|
| Clave primaria | `id_equipo` (subrogada, `IDENTITY`). |
| Dominio | `nombre`, `descripcion` y `dni_cliente` obligatorios. |
| Referencial | `FK_Equipo_Cliente` → `CLIENTE(dni_cliente)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |

**Por qué `NO ACTION`:** un equipo no puede quedar "huérfano". Si se intentara
borrar un cliente que tiene equipos registrados, el borrado debe bloquearse, ya que
eliminar en cascada implicaría perder el historial de equipos y, por consiguiente,
de servicios técnicos asociados.

---

## 5. SERVICIO_TECNICO

| Tipo | Restricción |
|---|---|
| Clave primaria | `nro_orden` (subrogada, `IDENTITY`). |
| Dominio | `falla_reportada`, `precio_arreglo`, `fecha_ingreso` e `id_equipo` obligatorios. `fecha_entrega` admite `NULL` (orden aún en proceso). |
| Default | `fecha_ingreso` toma `GETDATE()` si no se especifica. |
| Chequeo | `CK_ServicioTecnico_Precio`: `precio_arreglo >= 0`. |
| Chequeo | `CK_ServicioTecnico_Fechas`: `fecha_entrega IS NULL OR fecha_entrega >= fecha_ingreso` — impide registrar una entrega anterior al ingreso. |
| Referencial | `FK_ServicioTecnico_Equipo` → `EQUIPO(id_equipo)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |

Esta tabla es la que más restricciones de dominio concentra, dado que modela un
proceso con estados temporales (ingreso/entrega) que debe mantenerse coherente.

---

## 6. PRODUCTO

| Tipo | Restricción |
|---|---|
| Clave primaria | `cod_producto` (subrogada, `IDENTITY`). |
| Dominio | `descripcion`, `tipo`, `stock_actual` y `precio_actual` obligatorios. |
| Chequeo | `CK_Producto_Stock`: `stock_actual >= 0` — evita stock negativo (venta por encima de lo disponible). |
| Chequeo | `CK_Producto_Precio`: `precio_actual >= 0`. |

`PRODUCTO` no tiene restricciones referenciales propias (es referenciada por otras
tablas, no referencia a ninguna).

---

## 7. ENVIO

| Tipo | Restricción |
|---|---|
| Clave primaria | `cod_seguimiento` — clave natural (código asignado por Correo Argentino). |
| Unicidad | `UQ_Envio_IdEnvio`: `id_envio` único, como identificador interno alternativo. |
| Dominio | `id_envio`, `direccion_origen`, `direccion_envio` y `estado_envio` obligatorios. |
| Chequeo | `CK_Envio_Estado`: `estado_envio IN ('Pendiente', 'En Transito', 'Entregado', 'Cancelado')` — restringe el campo a un conjunto cerrado de valores válidos. |
| Referencial | `FK_Envio_DireccionOrigen` → `Direccion(codigo_direccion)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |
| Referencial | `FK_Envio_DireccionDestino` → `Direccion(codigo_direccion)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |

`ENVIO` referencia dos veces a `Direccion` (origen y destino), ambas con `NO
ACTION`, ya que un envío no debe quedar con una dirección inexistente en ninguno de
los dos extremos.

---

## 8. VENTA

| Tipo | Restricción |
|---|---|
| Clave primaria | `nro_venta` (subrogada, `IDENTITY`). |
| Dominio | `fecha_hora`, `metodo_pago`, `canal_venta` y `dni_cliente` obligatorios. `cod_seguimiento` admite `NULL` (venta presencial sin envío). |
| Default | `fecha_hora` toma `GETDATE()` si no se especifica. |
| Referencial | `FK_Venta_Cliente` → `CLIENTE(dni_cliente)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |
| Referencial | `FK_Venta_Envio` → `ENVIO(cod_seguimiento)`. `ON DELETE SET NULL` / `ON UPDATE NO ACTION`. |

**Por qué `ON DELETE SET NULL` en `FK_Venta_Envio` y no `NO ACTION`:** esta es la
única FK del modelo con `SET NULL`, justamente porque `cod_seguimiento` en `VENTA`
es opcional (`NULL`able) y refleja RN08 (solo las ventas digitales con despacho
tienen envío). Si un registro de envío se eliminara (por ejemplo, un envío
cancelado y depurado), la venta no debe bloquearse ni borrarse: simplemente pierde
la referencia al envío, quedando como una venta sin envío asociado.

**Por qué `NO ACTION` en `FK_Venta_Cliente`:** una venta nunca puede quedar sin
cliente asociado (a diferencia del envío, que sí es opcional), por eso aquí no se
usa `SET NULL` sino que se bloquea el borrado del cliente si tiene ventas
registradas — esto preserva el historial de ventas.

## 9. PROVEEDOR

| Tipo | Restricción |
|---|---|
| Clave primaria | `cuit_proveedor` — clave natural. |
| Unicidad | `UQ_Proveedor_Email`: `email` único. |
| Dominio | `nombre`, `telefono`, `email` y `codigo_direccion` obligatorios. |
| Referencial | `FK_Proveedor_Direccion` → `Direccion(codigo_direccion)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |

---

## 10. ABASTECE (tabla intermedia N:M)

| Tipo | Restricción |
|---|---|
| Clave primaria | Compuesta: `(cod_producto, cuit_proveedor)`. |
| Referencial | `FK_Abastece_Producto` → `PRODUCTO(cod_producto)`. `ON DELETE CASCADE` / `ON UPDATE NO ACTION`. |
| Referencial | `FK_Abastece_Proveedor` → `PROVEEDOR(cuit_proveedor)`. `ON DELETE CASCADE` / `ON UPDATE NO ACTION`. |

**Por qué `CASCADE`:** `ABASTECE` es una tabla puramente asociativa que no tiene
sentido de existir sin ambos extremos de la relación. Si se elimina un producto o
un proveedor, las filas de `ABASTECE` que los vinculaban deben eliminarse
automáticamente, ya que no representan información propia más allá del vínculo
mismo.

---

## 11. CONTIENE (tabla intermedia N:M — detalle de venta)

| Tipo | Restricción |
|---|---|
| Clave primaria | Compuesta: `(nro_venta, cod_producto)`. |
| Dominio | `cantidad` y `precio_unitario` obligatorios. |
| Chequeo | `CK_Contiene_Cantidad`: `cantidad > 0` — no se permite registrar una línea de venta con cantidad cero o negativa. |
| Chequeo | `CK_Contiene_PrecioUnitario`: `precio_unitario >= 0`. |
| Referencial | `FK_Contiene_Venta` → `VENTA(nro_venta)`. `ON DELETE CASCADE` / `ON UPDATE NO ACTION`. |
| Referencial | `FK_Contiene_Producto` → `PRODUCTO(cod_producto)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |

**Por qué `CASCADE` hacia `VENTA` pero `NO ACTION` hacia `PRODUCTO`:** una línea de
`CONTIENE` no tiene sentido sin la venta que la contiene, por lo que si se elimina
la venta, sus líneas de detalle deben eliminarse con ella. En cambio, no se debe
poder borrar un producto mientras exista al menos una venta histórica que lo
incluya, porque eso destruiría el historial de ventas — de ahí que hacia
`PRODUCTO` se use `NO ACTION` en lugar de `CASCADE`.

> Nota de nomenclatura: esta tabla corresponde a lo que en `docs/etapa-02` se
> documentó como `Detalle_Venta`; en el script DDL se implementó con el nombre
> `CONTIENE`, y el atributo `monto` de la etapa de modelado pasó a llamarse
> `precio_unitario`. Conviene unificar el nombre en la documentación de esta etapa
> para evitar confusiones entre el modelo relacional y la implementación física.

---

## Resumen de políticas de borrado (`ON DELETE`) aplicadas

| Política | Tablas donde se aplica | Justificación |
|---|---|---|
| `NO ACTION` | Direccion→Localidad, Cliente→Direccion, Equipo→Cliente, ServicioTecnico→Equipo, Envio→Direccion (x2), Venta→Cliente, Proveedor→Direccion, Contiene→Producto | Preserva historial; el "dueño" de la relación no debe desaparecer mientras existan registros dependientes. |
| `CASCADE` | Abastece→Producto, Abastece→Proveedor, Contiene→Venta | Tablas puramente asociativas o de detalle que no tienen sentido sin su "dueño" directo. |
| `SET NULL` | Venta→Envio | Relación opcional (FK nullable); el borrado del envío no debe afectar la existencia de la venta. |

## Resumen de políticas de actualización (`ON UPDATE`) aplicadas

Se aplica `NO ACTION` en todas las claves foráneas, excepto `Direccion→Localidad`,
donde se usa `CASCADE`. El criterio general es que las claves subrogadas
(`IDENTITY`) no deberían cambiar nunca una vez generadas, por lo que propagar
actualizaciones no tiene sentido práctico; la única excepción es `CP`, por tratarse
de una clave natural potencialmente sujeta a corrección administrativa.
