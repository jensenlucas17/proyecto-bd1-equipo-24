# Consulta 1: Factura / Comprobante de venta

Script: [`sql/consultas/comprobante_venta.sql`](../../sql/consultas/comprobante_venta.sql)

## Necesidad de información

El vendedor necesita emitir el comprobante de una venta para entregárselo al cliente. Debe mostrar, en un solo resultado:

- el **encabezado**: número de venta, fecha y hora, canal de venta, método de pago y datos del cliente;
- el **detalle**: un renglón por producto, con cantidad y precio unitario;
- el **subtotal** de cada renglón y el **total acumulado** de la venta.

## Estrategia SQL

La consulta recibe el número de venta en la variable `@nro_venta` y combina cuatro tablas con `INNER JOIN`:

| Tabla | Aporta | Se une por |
|---|---|---|
| `VENTA` | fecha, canal y método de pago | tabla base |
| `CLIENTE` | DNI, nombre y apellido | `dni_cliente` |
| `CONTIENE` | cantidad y precio unitario de cada renglón | `nro_venta` |
| `PRODUCTO` | descripción del producto | `cod_producto` |

Decisiones de diseño de la consulta:

- **El subtotal se calcula, no se almacena.** `subtotal = cantidad * precio_unitario`. La tabla `CONTIENE` no tiene una columna `monto` porque sería un dato derivado (ver `docs/etapa-02/normalizacion.md`, 2FN).
- **Se usa `precio_unitario` de `CONTIENE`**, no `precio_actual` de `PRODUCTO`. Así el comprobante conserva el precio al que se vendió aunque el precio de lista cambie después (RN06).
- **Funciones de ventana en lugar de `GROUP BY`.** Un `GROUP BY` colapsaría los renglones en una sola fila y se perdería el detalle. Con `SUM(...) OVER (...)` se calcula la suma sin perder cada renglón:
  - `total_acumulado`: `SUM(...) OVER (PARTITION BY v.nro_venta ORDER BY p.cod_producto ROWS UNBOUNDED PRECEDING)` suma los subtotales desde el primer renglón hasta el actual. En el último renglón coincide con el total de la venta.
  - `total_venta`: `SUM(...) OVER (PARTITION BY v.nro_venta)` repite el total final en todos los renglones.
- **`ROW_NUMBER()`** numera los renglones del comprobante.

## Resultado esperado

Para `@nro_venta = 2001` (cliente Ana Gomez, canal Online, transferencia, 15/10/2026):

| renglón | producto | cantidad | precio unitario | subtotal | total acumulado | total venta |
|---|---|---:|---:|---:|---:|---:|
| 1 | Funda protectora universal | 2 | 8.500,00 | 17.000,00 | 17.000,00 | 27.000,00 |
| 2 | Vidrio templado | 2 | 5.000,00 | 10.000,00 | 27.000,00 | 27.000,00 |

Totales esperados para las 3 ventas de los datos de prueba:

| nro_venta | renglones | total |
|---|---:|---:|
| 2001 | 2 | 27.000,00 |
| 2002 | 2 | 60.500,00 |
| 2003 | 1 | 18.500,00 |

## Cómo verificarlo

Ejecutar la consulta para cada una de las 3 ventas y comparar `total_venta` con la tabla de totales esperados. En cada venta, el `total_acumulado` del último renglón debe coincidir con `total_venta`.

### Consulta 2: Reporte de rendimiento mensual de ventas

**Script:** `sql/consultas/informe_ventas.sql`

**Necesidad de información**

El gerente de la sucursal necesita un informe para evaluar el rendimiento de las ventas del mes. El reporte debe agrupar los productos vendidos por categoría (tipo), mostrando la cantidad total de unidades vendidas y el volumen total de facturación (ingresos) generado por cada segmento en ese período.

**Estrategia SQL**

La consulta recibe el mes y el año en las variables `@mes` y `@anio` y combina tres tablas con `INNER JOIN`:

| Tabla | Aporta | Se une por |
|---|---|---|
| `VENTA` | Filtro de fecha para evaluar el mes | tabla base |
| `CONTIENE` | Cantidad y precio unitario de cada renglón vendido | `nro_venta` |
| `PRODUCTO` | La categoría (`tipo`) para agrupar | `cod_producto` |

**Decisiones de diseño de la consulta:**

- Se utiliza `GROUP BY P.tipo` para agrupar las filas en categorías únicas (`Accesorio` y `Audio` en los datos actuales).
- Se emplean funciones de agregación: `SUM(CO.cantidad)` para obtener el total de unidades y `SUM(CO.cantidad * CO.precio_unitario)` para la facturación total.
- El filtro temporal se aplica en `WHERE` usando `MONTH(V.fecha_hora) = @mes` y `YEAR(V.fecha_hora) = @anio`.
- Se ordena el resultado de forma descendente (`ORDER BY TotalRecaudado DESC`) para que la categoría con mayor facturación aparezca primero.

**Resultado esperado**

Para `@mes = 10` y `@anio = 2026` (octubre de 2026), según los registros actuales:

| Categoría de Producto | Unidades Vendidas | Facturación Total |
|---|---:|---:|
| Accesorio | 6 | $ 64.000,00 |
| Audio | 1 | $ 42.000,00 |
| **Total** | **7** | **$ 106.000,00** |

**Cómo verificarlo**

Ejecutar la consulta con `@mes = 10` y `@anio = 2026`. La suma de la facturación de ambas categorías ($106.000) debe coincidir con los totales de las ventas 2001 ($27.000), 2002 ($60.500) y 2003 ($18.500). **Estos son resultados esperados calculados a partir de los registros verificados; la consulta específica del informe se encuentra pendiente de validación y corrección por separado.**

---

### Consulta 3: Detección de clientes frecuentes para envío de cupón de descuento

**Script:** `sql/consultas/consulta_avanzada.sql`

**Necesidad de información**

El área de marketing requiere identificar a los clientes que hayan comprado más de $20.000 en total durante un mismo mes. El objetivo es enviarles un cupón de descuento por mensaje de texto. El listado debe incluir el DNI, nombre, apellido, número de teléfono y el importe total gastado en el período.

**Estrategia SQL**

La consulta recibe el mes y el año (`@mes`, `@anio`) y combina tres tablas mediante `INNER JOIN`:

| Tabla | Aporta | Se une por |
|---|---|---|
| `CLIENTE` | DNI, nombre, apellido y teléfono | tabla base |
| `VENTA` | Filtro de fecha para acotar las compras | `dni_cliente` |
| `CONTIENE` | Cantidad y precio para calcular el gasto | `nro_venta` |

**Decisiones de diseño de la consulta:**

- Como un cliente puede tener múltiples ventas en el mes, se agrupan los resultados usando `GROUP BY` sobre todos los datos identificatorios del cliente.
- El cálculo del gasto mensual unificado se realiza con `SUM(CO.cantidad * CO.precio_unitario)`.
- El requerimiento de superar los $20.000 no se puede evaluar en el `WHERE` porque es un cálculo agregado. Por lo tanto, se aplica un filtro posterior mediante `HAVING SUM(CO.cantidad * CO.precio_unitario) > 20000`.
- Los clientes que compraron $20.000 o menos quedan excluidos automáticamente del listado.

**Resultado esperado**

Para `@mes = 10` y `@anio = 2026` (octubre de 2026), clientes con gastos superiores a $20.000:

| DNI | Nombre y Apellido | Teléfono | Total Gastado en el Mes |
|---|---|---|---:|
| 42123456 | Sofia Benitez | 3624000003 | $ 60.500,00 |
| 40111222 | Ana Gomez | 3794000001 | $ 27.000,00 |

Luis Fernandez ($18.500) no cumple el umbral y no aparece.

**Cómo verificarlo**

Revisar que la salida no devuelva ningún registro cuyo `Total Gastado en el Mes` sea menor o igual a 20.000. Comprobar que Sofia Benitez y Ana Gomez aparezcan una sola vez, con los importes indicados. Si se cargan varias ventas de un mismo cliente durante octubre, deben consolidarse en una única fila con el gasto total mensual. Para la consulta auxiliar de verificación puede utilizarse el DNI `42123456` (Sofia Benitez), en lugar del DNI de ejemplo anterior.
