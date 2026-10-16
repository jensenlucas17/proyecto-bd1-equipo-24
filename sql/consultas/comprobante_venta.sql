/* ============================================================
   CONSULTA 1: Factura / Comprobante de venta
   Motor: T-SQL (SQL Server)

   Necesidad: emitir el comprobante de una venta consolidando
   el encabezado (cliente y venta) y el detalle (renglones de
   productos, subtotales, total acumulado y total de venta).

   Tablas: VENTA, CLIENTE, CONTIENE, PRODUCTO (INNER JOIN)
   Cálculos: Subtotal por renglón y Funciones de Ventana (OVER)
   ============================================================ */

-- Parámetro de entrada: Número de venta a consultar
DECLARE @nro_venta INT = 1;

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
    
    -- Subtotal por renglón (calculado)
    (CO.cantidad * CO.precio_unitario)              AS [Subtotal],
    
    -- Total acumulado renglón a renglón
    SUM(CO.cantidad * CO.precio_unitario) OVER (
        PARTITION BY V.nro_venta 
        ORDER BY P.cod_producto 
        ROWS UNBOUNDED PRECEDING
    )                                               AS [Total Acumulado],
    
    -- Total consolidado general de la venta
    SUM(CO.cantidad * CO.precio_unitario) OVER (
        PARTITION BY V.nro_venta
    )                                               AS [Total Venta]

FROM VENTA AS V
INNER JOIN CLIENTE  AS C  ON V.dni_cliente   = C.dni_cliente
INNER JOIN CONTIENE AS CO ON CO.nro_venta    = V.nro_venta
INNER JOIN PRODUCTO AS P  ON CO.cod_producto = P.cod_producto
WHERE V.nro_venta = @nro_venta
ORDER BY [Renglón];
GO

/* ============================================================
   CONSULTA DE VERIFICACIÓN (opcional)
   Valida que los renglones y el total general coincidan con la
   tabla de datos de prueba para las 8 ventas registradas.
   ============================================================ */
SELECT 
    V.nro_venta,
    COUNT(CO.cod_producto)                 AS [Renglones],
    SUM(CO.cantidad * CO.precio_unitario)  AS [Total Esperado]
FROM VENTA AS V
INNER JOIN CONTIENE AS CO ON CO.nro_venta = V.nro_venta
GROUP BY V.nro_venta
ORDER BY V.nro_venta;
GO
