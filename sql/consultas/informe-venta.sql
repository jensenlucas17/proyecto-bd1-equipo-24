/* ============================================================
   CONSULTA 2: Reporte de Rendimiento Mensual de Ventas
   
   Necesidad: Evaluar el desempeño de ventas del mes agrupado
   por categoría de producto (tipo), totalizando operaciones,
   unidades físicas e ingresos brutos.

   Tablas: VENTA, CONTIENE, PRODUCTO (INNER JOIN)
   Filtros: WHERE (período mensual parametrizado)
   Agrupamiento: GROUP BY P.tipo
   Ordenamiento: ORDER BY [Facturación Total] DESC
   ============================================================ */

-- Parámetros de entrada para el período mensual
DECLARE @mes  INT = 9;
DECLARE @anio INT = 2026;

-- Rango del período: [primer día del mes, primer día del mes siguiente)
-- Se evita usar MONTH() y YEAR() sobre la columna en el WHERE para
-- favorecer el uso de índices sobre VENTA.fecha_hora 
DECLARE @fecha_desde DATETIME = DATEFROMPARTS(@anio, @mes, 1);
DECLARE @fecha_hasta DATETIME = DATEADD(MONTH, 1, @fecha_desde);

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
WHERE V.fecha_hora >= @fecha_desde 
  AND V.fecha_hora <  @fecha_hasta
GROUP BY 
    P.tipo
ORDER BY 
    [Facturación Total] DESC;
GO

--Verificacion
DECLARE @mes_a  INT = 9;
DECLARE @anio_a INT = 2026;
DECLARE @desde_a DATETIME = DATEFROMPARTS(@anio_a, @mes_a, 1);
DECLARE @hasta_a DATETIME = DATEADD(MONTH, 1, @desde_a);

SELECT 
    COUNT(DISTINCT V.nro_venta)           AS [Total Ventas Mes],
    SUM(CO.cantidad)                      AS [Total Unidades Mes],
    SUM(CO.cantidad * CO.precio_unitario) AS [Total Facturado Mes]
FROM VENTA AS V
INNER JOIN CONTIENE AS CO 
    ON V.nro_venta = CO.nro_venta
WHERE V.fecha_hora >= @desde_a 
  AND V.fecha_hora <  @hasta_a;