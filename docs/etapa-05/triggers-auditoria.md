# Triggers de Auditoría

**Proyecto:** Nexus Mobile — Grupo 24  
**Materia:** Base de Datos I — FaCENA - UNNE 2026  
**Motor de Base de Datos:** SQL Server Express (T-SQL)  
**Script:** [`sql/tecnico/triggers/triggers.sql`](../../sql/tecnico/triggers/triggers.sql)

---

## Definición y objetivo

Un **trigger** (disparador) es un procedimiento almacenado especial que SQL Server ejecuta **automáticamente** cuando ocurre un evento sobre una tabla: un `INSERT`, un `UPDATE` o un `DELETE`. A diferencia de un procedimiento común, nadie lo invoca con `EXEC`: se dispara solo, y no se puede "olvidar" ejecutarlo.

Dentro de un trigger, SQL Server pone a disposición dos tablas temporales que contienen las filas afectadas por la sentencia:

| Tabla | Contenido según la operación |
| :--- | :--- |
| `inserted` | `INSERT`: las filas nuevas. `UPDATE`: las filas con los valores **nuevos**. |
| `deleted` | `DELETE`: las filas borradas. `UPDATE`: las filas con los valores **viejos**. |

Un `UPDATE` aparece en ambas tablas (antes y después); un `INSERT` solo en `inserted`; un `DELETE` solo en `deleted`. Comparando las dos se puede saber qué cambió.

* **`AFTER` trigger:** se ejecuta después de que la operación se realizó y de que se verificaron las restricciones (`CHECK`, `FOREIGN KEY`). Es el tipo que usamos.
* **`INSTEAD OF` trigger:** reemplaza a la operación original (no se utiliza en este proyecto).
* **Objetivo de un trigger de auditoría:** dejar un registro automático de *quién* cambió *qué*, *cuándo* y *con qué valor anterior*, para tener trazabilidad y control de cambios.

---

## Ventajas y aplicaciones

### Ventajas
1. **Trazabilidad automática:** el registro se genera aunque el cambio venga de la tienda web, del local, de un script o de alguien que ejecuta un `UPDATE` a mano en SSMS. La auditoría no depende de que cada aplicación se acuerde de hacerla.
2. **Consistencia:** vive en la base de datos, junto a los datos; no hay que replicar la lógica en cada sistema que se conecte.
3. **Respuesta a preguntas del negocio:** ¿quién modificó un precio?, ¿cuándo se eliminó un producto?, ¿qué valor tenía antes?
4. **Transaccionalidad:** el trigger forma parte de la misma transacción que la sentencia original. Si la operación se deshace (`ROLLBACK`), el registro de auditoría también.

### Aplicaciones habituales
* Historial de cambios de precios, stock o estados.
* Registro de altas y bajas de entidades sensibles (productos, clientes, usuarios).
* Control interno y detección de modificaciones no autorizadas.
* Mantener datos derivados o resumidos sincronizados.

### Consideraciones
* Cada trigger agrega trabajo a cada operación sobre la tabla, por eso se audita solo lo que aporta valor.
* Un trigger se ejecuta **una vez por sentencia**, no una vez por fila. Si un `UPDATE` modifica 50 filas, `inserted` y `deleted` tienen 50 filas y el código debe trabajar con conjuntos, no asumir una sola fila.
* `TRUNCATE TABLE` no dispara triggers `DELETE`. Un usuario con permisos de administración puede deshabilitar un trigger (`DISABLE TRIGGER`), por lo que la auditoría debe complementarse con una política de permisos.

---

## Implementación en SQL Server Express

La estructura general de un trigger en T-SQL es:

```sql
CREATE OR ALTER TRIGGER dbo.nombre_trigger
ON dbo.tabla
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- usar las tablas inserted y deleted
END;
```

Funciones del sistema que se usan para completar el registro automáticamente:

* `GETDATE()`: fecha y hora actuales del servidor.
* `SUSER_SNAME()`: nombre del inicio de sesión (*login*) que ejecuta la operación.

---

## Caso concreto aplicado al sistema de ventas de Nexus Mobile

### Problema de negocio
El precio de lista de un producto (`PRODUCTO.precio_actual`) cambia con el tiempo. Por la regla **RN06**, las ventas ya realizadas conservan su precio en `CONTIENE.precio_unitario`, pero el negocio también necesita saber **quién cambió el precio de lista, cuándo y desde qué valor**, y detectar altas o bajas de productos del catálogo. Esa información hoy se pierde en cuanto se hace el `UPDATE`.

### Solución
* **Tabla `AUDITORIA_PRODUCTO`:** guarda una fila por cada cambio auditado.

| Columna | Descripción |
| :--- | :--- |
| `auditoria_id` | Identificador autogenerado (PK). |
| `fecha_hora` | Fecha y hora del cambio (`DEFAULT GETDATE()`). |
| `usuario` | Usuario que lo realizó (`DEFAULT SUSER_SNAME()`). |
| `tipo_operacion` | `INSERT`, `UPDATE` o `DELETE` (con `CHECK`). |
| `cod_producto` | Producto afectado. |
| `descripcion` | Descripción del producto al momento del cambio. |
| `precio_anterior` | Precio antes del cambio (`NULL` en un `INSERT`). |
| `precio_nuevo` | Precio después del cambio (`NULL` en un `DELETE`). |

* **Trigger `dbo.trg_Producto_Auditoria`** sobre `PRODUCTO` (`AFTER INSERT, UPDATE, DELETE`).

### Decisiones de diseño
1. **Solo se audita el precio, no el stock.** Cada venta modifica `stock_actual`; auditarlo llenaría la tabla de registros sin valor para el negocio. El trigger revisa que `precio_actual` haya cambiado realmente (`i.precio_actual <> d.precio_actual`).
2. **Sin clave foránea hacia `PRODUCTO`.** Si un producto se elimina, su historial de auditoría debe sobrevivir; con una `FOREIGN KEY` el borrado sería rechazado o arrastraría la auditoría.
3. **Código por conjuntos.** Usa `INSERT ... SELECT` sobre `inserted` y `deleted`, por lo que audita correctamente un `UPDATE` masivo.
4. **Se guarda la descripción.** Así el registro es legible aunque el producto ya no exista.
5. **`fecha_hora` y `usuario` por `DEFAULT`.** El trigger no los calcula: la tabla los completa sola, lo que simplifica el código y evita que se puedan "inventar" desde el trigger.

### Orden de ejecución
1. `sql/ddl/crear_bd.sql`
2. `sql/dml/datos_prueba.sql`
3. `sql/tecnico/triggers/triggers.sql`

---

## Resultados obtenidos en la demostración

El script `sql/tecnico/triggers/triggers.sql` incluye la demostración (sección 3). Se ejecutó sobre el lote `datos_prueba.sql`, cuyo catálogo inicial es:

| cod_producto | descripcion | tipo | stock_actual | precio_actual |
| :--- | :--- | :--- | :--- | :--- |
| `101` | Funda protectora universal | Accesorio | `40` | `8500.00` |
| `102` | Cargador USB-C 25W | Accesorio | `25` | `18500.00` |
| `103` | Auriculares inalambricos | Audio | `15` | `42000.00` |
| `104` | Vidrio templado | Accesorio | `60` | `5000.00` |

### 3.2. Cambio de precio de un producto
`UPDATE dbo.PRODUCTO SET precio_actual = 20000.00 WHERE cod_producto = 102;`

Se consulta la tabla de auditoría y el cambio quedó registrado automáticamente:

| auditoria_id | tipo_operacion | cod_producto | descripcion | precio_anterior | precio_nuevo |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `1` | UPDATE | `102` | Cargador USB-C 25W | `18500.00` | `20000.00` |

### 3.3. Cambio de stock solamente (no debe auditarse)
`UPDATE dbo.PRODUCTO SET stock_actual = stock_actual - 1 WHERE cod_producto = 101;`

| filas_antes | filas_despues |
| :--- | :--- |
| `1` | `1` |

La cantidad de registros de auditoría no cambió: el trigger descartó la modificación porque el precio no varió.

### 3.4. Alta y baja de un producto

| auditoria_id | tipo_operacion | cod_producto | descripcion | precio_anterior | precio_nuevo |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `2` | INSERT | `1000` | Producto temporal de auditoria | `NULL` | `100.00` |
| `3` | DELETE | `1000` | Producto temporal de auditoria | `100.00` | `NULL` |

El historial del producto eliminado sigue disponible porque `AUDITORIA_PRODUCTO` no tiene clave foránea hacia `PRODUCTO`. El código `1000` lo asigna `IDENTITY`; puede variar según el estado de la base.

### 3.6. Trazabilidad del producto 102
Después de volver al precio original (ese cambio también quedó auditado), se consulta la historia del producto 102:

| fecha_hora | usuario | tipo_operacion | precio_anterior | precio_nuevo |
| :--- | :--- | :--- | :--- | :--- |
| `2026-10-29 19:16:40.470` | `GIULI-PC\Giuli` | UPDATE | `18500.00` | `20000.00` |
| `2026-10-29 19:16:40.513` | `GIULI-PC\Giuli` | UPDATE | `20000.00` | `18500.00` |

Se verifica que el trigger registra los cambios de precio, las altas y las bajas, ignora las modificaciones que no son de precio (como el stock) y permite reconstruir quién, cuándo y desde qué valor se modificó cada precio.
