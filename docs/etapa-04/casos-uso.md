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
  - `total_acumulado`: `SUM(...) OVER (ORDER BY p.cod_producto ROWS UNBOUNDED PRECEDING)` suma los subtotales desde el primer renglón hasta el actual. En el último renglón coincide con el total de la venta.
  - `total_venta`: `SUM(...) OVER (PARTITION BY v.nro_venta)` repite el total final en todos los renglones.
- **`ROW_NUMBER()`** numera los renglones del comprobante.

## Resultado esperado

Para `@nro_venta = 1` (cliente Yanina Latorre, e-commerce, tarjeta de crédito, 20/09/2026):

| renglón | producto | cantidad | precio unitario | subtotal | total acumulado | total venta |
|---|---|---|---|---|---|---|
| 1 | Samsung Galaxy S23 FE 128GB | 1 | 850.000,00 | 850.000,00 | 850.000,00 | 860.000,00 |
| 2 | Vidrio Templado Samsung S23 | 2 | 5.000,00 | 10.000,00 | 860.000,00 | 860.000,00 |

Totales esperados para las 8 ventas de los datos de prueba (`docs/etapa-03/pruebas-validacion.md`):

| nro_venta | renglones | total |
|---|---|---|
| 1 | 2 | 860.000,00 |
| 2 | 2 | 1.215.000,00 |
| 3 | 1 | 25.500,00 |
| 4 | 2 | 468.000,00 |
| 5 | 1 | 40.000,00 |
| 6 | 1 | 95.000,00 |
| 7 | 1 | 50.000,00 |
| 8 | 2 | 890.000,00 |

## Cómo verificarlo

Ejecutar la consulta para cada una de las 8 ventas y comparar `total_venta` con la tabla de totales esperados. En cada venta, el `total_acumulado` del último renglón debe coincidir con `total_venta`.

### Consulta 2: Reporte de rendimiento mensual de ventas
**Script:** `sql/consultas/informe_ventas.sql`

**Necesidad de información**
El gerente de la sucursal necesita un informe para evaluar el rendimiento de las ventas del mes. El reporte debe agrupar los productos vendidos por categoría (tipo), mostrando la cantidad total de unidades vendidas y el volumen total de facturación (ingresos) generado por cada segmento en ese período.

**Estrategia SQL**
La consulta recibe el mes y el año en las variables `@mes` y `@anio` y combina tres tablas con `INNER JOIN`:

| Tabla | Aporta | Se une por |
| --- | --- | --- |
| `VENTA` | Filtro de fecha para evaluar el mes | tabla base |
| `CONTIENE` | Cantidad y precio unitario de cada renglón vendido | `nro_venta` |
| `PRODUCTO` | La categoría (`tipo`) para agrupar | `cod_producto` |

**Decisiones de diseño de la consulta:**
- Se utiliza `GROUP BY P.tipo` para colapsar todas las filas en categorías únicas ('Celular', 'Accesorio').
- Se emplean funciones de agregación obligatorias: `SUM(CO.cantidad)` para obtener el total de unidades y `SUM(CO.cantidad * CO.precio_unitario)` para la facturación total.
- El filtro temporal se aplica en la cláusula `WHERE` usando las funciones extractoras de fecha `MONTH(V.fecha_hora) = @mes` y `YEAR(V.fecha_hora) = @anio`.
- Se ordena el resultado de forma descendente (`ORDER BY TotalRecaudado DESC`) para que la categoría más rentable aparezca primero, facilitando la lectura gerencial.

**Resultado esperado**
Para `@mes = 9` y `@anio = 2026` (Septiembre 2026), según los datos de prueba ingresados en la Etapa 3:

| Categoría de Producto | Unidades Vendidas | Facturación Total |
| --- | --- | --- |
| Celular | 4 | $ 3.350.000,00 |
| Accesorio | 12 | $ 293.500,00 |

**Cómo verificarlo**
Ejecutar la consulta cambiando los valores de las variables `@mes` y `@anio`. La suma de la "Facturación Total" de ambas categorías ($3.643.500) debe coincidir matemáticamente con la suma de los totales de todas las ventas registradas en ese mes específico.

---

### Consulta 3: Detección de clientes frecuentes para envio de cupón de descuento
**Script:** `sql/consultas/consulta_avanzada.sql`

**Necesidad de información**
El área de marketing requiere identificar a los clientes que hayan comprado más de $100.000 en total durante un mismo mes. El objetivo es enviarles un cupón de descuento por mensaje de texto. El listado debe incluir el DNI, nombre, apellido, número de teléfono y el importe total gastado en el período.

**Estrategia SQL**
La consulta recibe el mes y el año (`@mes`, `@anio`) y combina tres tablas mediante `INNER JOIN`:

| Tabla | Aporta | Se une por |
| --- | --- | --- |
| `CLIENTE` | DNI, nombre, apellido y teléfono | tabla base |
| `VENTA` | Filtro de fecha para acotar las compras | `dni_cliente` |
| `CONTIENE` | Cantidad y precio para calcular el gasto | `nro_venta` |

**Decisiones de diseño de la consulta:**
- Como un cliente puede tener múltiples ventas en el mes (ej. Guido Casado tiene la venta 1 y la 3), se agrupan los resultados usando `GROUP BY` sobre todos los datos identificatorios del cliente.
- El cálculo del gasto mensual unificado se realiza con `SUM(CO.cantidad * CO.precio_unitario)`.
- El requerimiento de superar los $100.000 no se puede evaluar en el `WHERE` porque es un cálculo agregado. Por lo tanto, se aplica un filtro posterior mediante la cláusula `HAVING SUM(CO.cantidad * CO.precio_unitario) > 100000`.
- Los clientes que compraron menos de ese monto quedan excluidos automáticamente del listado.

**Resultado esperado**
Para `@mes = 9` y `@anio = 2026` (Septiembre 2026), clientes con gastos superiores a $100.000:

| DNI | Nombre y Apellido | Teléfono | Total Gastado en el Mes |
| --- | --- | --- | --- |
| 43999888 | Virginia Gomez | 1149998888 | $ 1.215.000,00 |
| 42333222 | Lucas Jensen | 3794333222 | $ 890.000,00 |
| 40123456 | Guido Casado | 3794123456 | $ 885.500,00 |
| 39876543 | Santiago Lencinas | 3794987654 | $ 468.000,00 |

**Cómo verificarlo**
Revisar que la salida no devuelva ningún registro cuyo `Total Gastado en el Mes` sea menor o igual a 100.000. Además, comprobar visualmente que clientes con múltiples compras en el mes (como Guido Casado, que gastó $860.000 en la venta 1 y $25.500 en la venta 3) aparezcan en una única fila unificada con la suma total.