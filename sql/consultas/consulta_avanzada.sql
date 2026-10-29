/* ============================================================
   CONSULTA 3: Detección de clientes frecuentes para envío de
   cupón de descuento

   Necesidad: identificar clientes que compraron más de $100.000
   en total durante un mismo mes.

   Tablas: CLIENTE, VENTA, CONTIENE (INNER JOIN)
   Filtros: WHERE (período) + HAVING (total acumulado)
   ============================================================ */

-- Parámetros de entrada
DECLARE @mes  INT = 10;
DECLARE @anio INT = 2026;

-- Rango del período: [primer día del mes, primer día del mes siguiente)
-- Se usa un rango en lugar de MONTH()/YEAR() sobre la columna para que
-- el motor pueda aprovechar un índice sobre VENTA.fecha_hora.
DECLARE @fecha_desde DATETIME = DATEFROMPARTS(@anio, @mes, 1);
DECLARE @fecha_hasta DATETIME = DATEADD(MONTH, 1, @fecha_desde);

SELECT
    C.dni_cliente                                   AS DNI,
    C.nombre + ' ' + C.apellido                     AS [Nombre y Apellido],
    C.telefono                                      AS [Teléfono],
    SUM(CO.cantidad * CO.precio_unitario)           AS [Total Gastado en el Mes]
FROM CLIENTE  AS C
INNER JOIN VENTA    AS V  ON V.dni_cliente = C.dni_cliente
INNER JOIN CONTIENE AS CO ON CO.nro_venta  = V.nro_venta
WHERE V.fecha_hora >= @fecha_desde
  AND V.fecha_hora <  @fecha_hasta
GROUP BY
    C.dni_cliente,
    C.nombre,
    C.apellido,
    C.telefono
HAVING SUM(CO.cantidad * CO.precio_unitario) > 20000
ORDER BY [Total Gastado en el Mes] DESC;
GO

/* ============================================================
   CONSULTA DE VERIFICACIÓN (opcional)
   Detalle por venta de un cliente con múltiples compras en el mes
   (ejemplo: Guido Casado, DNI 40123456). La suma de los importes
   por venta debe coincidir con el total de la consulta principal.
   ============================================================ */
DECLARE @mes_v  INT = 10;
DECLARE @anio_v INT = 2026;
DECLARE @desde_v DATETIME = DATEFROMPARTS(@anio_v, @mes_v, 1);
DECLARE @hasta_v DATETIME = DATEADD(MONTH, 1, @desde_v);

SELECT
    V.nro_venta,
    V.fecha_hora,
    SUM(CO.cantidad * CO.precio_unitario) AS [Importe de la venta]
FROM VENTA AS V
INNER JOIN CONTIENE AS CO ON CO.nro_venta = V.nro_venta
WHERE V.dni_cliente = 42123456
  AND V.fecha_hora >= @desde_v
  AND V.fecha_hora <  @hasta_v
GROUP BY V.nro_venta, V.fecha_hora
ORDER BY V.nro_venta;
GO
