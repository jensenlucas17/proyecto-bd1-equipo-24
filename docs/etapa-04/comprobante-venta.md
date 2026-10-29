# Consulta 1: Factura / Comprobante de Venta

**Script:** `sql/consultas/comprobante_venta.sql`

## Necesidad de información

El vendedor requiere emitir el comprobante de una venta para entregar al cliente. Debe consolidar en un único resultado:

- **Encabezado:** Número de venta, fecha y hora, canal de venta, método de pago y datos identificatorios del cliente.
- **Detalle:** Un renglón correlativo por cada producto en la venta, con su descripción, cantidad y precio unitario guardado.
- **Subtotales y Totales:** El subtotal por renglón (`cantidad * precio_unitario`), el total acumulado paso a paso y el total final consolidado del comprobante.

## Consulta SQL (T-SQL)

```sql
-- Parámetro de entrada: Número de venta a consultar
DECLARE @nro_venta INT = 2001;

SELECT
    -- Encabezado de Venta y datos del Cliente
    V.nro_venta                                     AS [Nro Venta],
    V.fecha_hora                                    AS [Fecha y Hora],
    V.canal_venta                                   AS [Canal],
    V.metodo_pago                                   AS [Método Pago],
    C.dni_cliente                                   AS [DNI Cliente],
    C.nombre + ' ' + C.apellido                     AS [Cliente],

    -- Detalle de Renglón y Producto
    ROW_NUMBER() OVER (
        PARTITION BY V.nro_venta
        ORDER BY P.cod_producto
    )                                               AS [Renglón],
    P.descripcion                                   AS [Producto],
    CO.cantidad                                     AS [Cantidad],
    CO.precio_unitario                              AS [Precio Unitario],

    -- Cálculos de Subtotal, Acumulado y Total General
    (CO.cantidad * CO.precio_unitario)              AS [Subtotal],

    SUM(CO.cantidad * CO.precio_unitario) OVER (
        PARTITION BY V.nro_venta
        ORDER BY P.cod_producto
        ROWS UNBOUNDED PRECEDING
    )                                               AS [Total Acumulado],

    SUM(CO.cantidad * CO.precio_unitario) OVER (
        PARTITION BY V.nro_venta
    )                                               AS [Total Venta]

FROM VENTA AS V
INNER JOIN CLIENTE  AS C  ON V.dni_cliente  = C.dni_cliente
INNER JOIN CONTIENE AS CO ON CO.nro_venta   = V.nro_venta
INNER JOIN PRODUCTO AS P  ON CO.cod_producto = P.cod_producto
WHERE V.nro_venta = @nro_venta
ORDER BY [Renglón];
```
## Resultado verificado en SSMS

Se probó con la venta **2001** (15/10/2026, Ana Gomez, DNI 40111222, canal Online, pago por transferencia):

| Producto | Cantidad | Precio unitario | Subtotal |
|---|---:|---:|---:|
| Funda protectora universal | 2 | $8.500 | $17.000 |
| Vidrio templado | 2 | $5.000 | $10.000 |
| **Total** | **4** | | **$27.000** |

La consulta de verificación mostró los siguientes importes: venta 2001 = $27.000; venta 2002 = $60.500; venta 2003 = $18.500. Los valores son datos ficticios de prueba.
