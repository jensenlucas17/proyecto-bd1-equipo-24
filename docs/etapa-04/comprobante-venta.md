/* ============================================================
   ETAPA 4 - CONSULTA 1: FACTURA / COMPROBANTE DE VENTA
   Motor: T-SQL (SQL Server)

   Muestra encabezado + detalle de una venta, con subtotal por
   renglón, total acumulado y total de la venta.
   Cambiar el valor de @nro_venta para emitir otro comprobante.
   ============================================================ */

DECLARE @nro_venta INT = 1;

SELECT
    v.nro_venta,
    v.fecha_hora,
    v.canal_venta,
    v.metodo_pago,
    c.dni_cliente,
    c.apellido + ', ' + c.nombre                  AS cliente,

    ROW_NUMBER() OVER (ORDER BY p.cod_producto)   AS renglon,
    p.descripcion                                 AS producto,
    ct.cantidad,
    ct.precio_unitario,
    ct.cantidad * ct.precio_unitario              AS subtotal,

    -- Suma progresiva: renglón 1, 1+2, 1+2+3...
    SUM(ct.cantidad * ct.precio_unitario) OVER (
        ORDER BY p.cod_producto
        ROWS UNBOUNDED PRECEDING
    )                                             AS total_acumulado,

    -- Total final de la venta, repetido en cada renglón
    SUM(ct.cantidad * ct.precio_unitario) OVER (
        PARTITION BY v.nro_venta
    )                                             AS total_venta
FROM VENTA v
INNER JOIN CLIENTE  c  ON c.dni_cliente  = v.dni_cliente
INNER JOIN CONTIENE ct ON ct.nro_venta   = v.nro_venta
INNER JOIN PRODUCTO p  ON p.cod_producto = ct.cod_producto
WHERE v.nro_venta = @nro_venta
ORDER BY renglon;
GO