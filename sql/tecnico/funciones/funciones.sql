-- =========================================================================
-- PROYECTO: Nexus Mobile (Grupo 24) - Etapa V
-- TEMA 1: Funciones Almacenadas
-- ARCHIVO: sql/tecnico/funciones/fn_calcular_descuento_cliente.sql
-- MOTOR: SQL Server Express (T-SQL)
-- =========================================================================

-- =========================================================================
-- 1. IMPLEMENTACIÓN DE LA FUNCIÓN ESCALAR (Ítem 3)
-- =========================================================================
-- Problema de negocio: Otorgar descuentos según el monto acumulado de 
-- compras históricas de un cliente en Nexus Mobile:
--   * Más de $500.000 acumulados -> 10% de descuento.
--   * Más de $200.000 acumulados -> 5% de descuento.
--   * Caso contrario             -> 0% de descuento.
-- =========================================================================

CREATE OR ALTER FUNCTION dbo.fn_CalcularDescuentoCliente
(
    @dni_cliente INT
)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @monto_acumulado DECIMAL(12, 2);
    DECLARE @porcentaje_descuento DECIMAL(5, 2);

    -- Calcular el total histórico gastado por el cliente en ventas previas.
    -- Se utiliza ISNULL para retornar 0.00 si el cliente no registra compras.
    SELECT @monto_acumulado = ISNULL(SUM(CO.cantidad * CO.precio_unitario), 0.00)
    FROM VENTA V
    INNER JOIN CONTIENE CO ON V.nro_venta = CO.nro_venta
    WHERE V.dni_cliente = @dni_cliente;

    -- Determinación del porcentaje según escala comercial
    IF @monto_acumulado > 500000.00
        SET @porcentaje_descuento = 10.00;
    ELSE IF @monto_acumulado > 200000.00
        SET @porcentaje_descuento = 5.00;
    ELSE
        SET @porcentaje_descuento = 0.00;

    RETURN @porcentaje_descuento;
END;
GO

-- =========================================================================
-- 2. SCRIPT DE DEMOSTRACIÓN Y PRUEBAS (Ítem 5)
-- =========================================================================

-- Prueba A: Invocación de la función sobre todos los clientes de Nexus Mobile
SELECT 
    C.dni_cliente,
    C.nombre + ' ' + C.apellido                         AS cliente,
    ISNULL(SUM(CO.cantidad * CO.precio_unitario), 0.00) AS monto_acumulado_historico,
    dbo.fn_CalcularDescuentoCliente(C.dni_cliente)      AS porcentaje_descuento
FROM CLIENTE C
LEFT JOIN VENTA V ON C.dni_cliente = V.dni_cliente
LEFT JOIN CONTIENE CO ON V.nro_venta = CO.nro_venta
GROUP BY C.dni_cliente, C.nombre, C.apellido
ORDER BY monto_acumulado_historico DESC;
GO

-- Prueba B: Evaluación individual por cada tramo de descuento
SELECT 
    dbo.fn_CalcularDescuentoCliente(39876543) AS dto_cliente_mayor_500k, -- Santiago Romero (10%)
    dbo.fn_CalcularDescuentoCliente(41555666) AS dto_cliente_mayor_200k, -- Emily Scher (5%)
    dbo.fn_CalcularDescuentoCliente(38111222) AS dto_cliente_menor_200k; -- Federico Gonzalez (0%)
GO