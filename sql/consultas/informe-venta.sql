/* ============================================================
   CONSULTA: Reporte Agregado de Ventas en Rango de Fechas
   
   Necesidad: Consolidar el volumen de transacciones (COUNT),
   las unidades despachadas (SUM) y el total facturado (SUM)
   agrupado por categoría de producto y por vendedor dentro
   de un rango de fechas.

   Tablas: VENTA, CONTIENE, PRODUCTO, EMPLEADO (INNER JOIN)
   Filtros: WHERE (rango temporal)
   Agrupamiento: GROUP BY + ORDER BY
   ============================================================ */

-- Parámetros de rango de fechas
DECLARE @fecha_desde DATETIME = '2026-09-01 00:00:00';
DECLARE @fecha_hasta DATETIME = '2026-09-30 23:59:59';

-- 1. Totalización agregada por Categoría de Producto
SELECT 
    P.tipo                                          AS [Categoría],
    COUNT(DISTINCT V.nro_venta)                    AS [Total Operaciones],
    SUM(CO.cantidad)                               AS [Unidades Vendidas],
    SUM(CO.cantidad * CO.precio_unitario)          AS [Facturación Total]
FROM VENTA AS V
INNER JOIN CONTIENE AS CO 
    ON V.nro_venta = CO.nro_venta
INNER JOIN PRODUCTO AS P 
    ON CO.cod_producto = P.cod_producto
WHERE V.fecha_hora BETWEEN @fecha_desde AND @fecha_hasta
GROUP BY 
    P.tipo
ORDER BY 
    [Facturación Total] DESC;
GO

-- 2. Totalización agregada por Vendedor / Empleado
DECLARE @fecha_desde DATETIME = '2026-09-01 00:00:00';
DECLARE @fecha_hasta DATETIME = '2026-09-30 23:59:59';

SELECT 
    E.id                                            AS [ID Vendedor],
    E.nombre_completo                               AS [Vendedor],
    COUNT(DISTINCT V.nro_venta)                    AS [Ventas Concretadas],
    SUM(CO.cantidad)                               AS [Unidades Despachadas],
    SUM(CO.cantidad * CO.precio_unitario)          AS [Facturación Total]
FROM VENTA AS V
INNER JOIN EMPLEADO AS E 
    ON V.id_vendedor = E.id
INNER JOIN CONTIENE AS CO 
    ON V.nro_venta = CO.nro_venta
WHERE V.fecha_hora BETWEEN @fecha_desde AND @fecha_hasta
GROUP BY 
    E.id,
    E.nombre_completo
ORDER BY 
    [Facturación Total] DESC;
GO

/* ============================================================
   CONSULTA DE VERIFICACIÓN / AUDITORÍA
   Totalización general de facturación del período para contrastar 
   que la suma de las categorías y la de los vendedores cuadren 
   exactamente con el gran total facturado.
   ============================================================ */
DECLARE @desde_v DATETIME = '2026-09-01 00:00:00';
DECLARE @hasta_v DATETIME = '2026-09-30 23:59:59';

SELECT 
    COUNT(DISTINCT V.nro_venta)           AS [Total Ventas Período],
    SUM(CO.cantidad)                      AS [Total Unidades Período],
    SUM(CO.cantidad * CO.precio_unitario) AS [Facturación Total Período]
FROM VENTA AS V
INNER JOIN CONTIENE AS CO 
    ON V.nro_venta = CO.nro_venta
WHERE V.fecha_hora BETWEEN @desde_v AND @hasta_v;
GO