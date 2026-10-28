-- =========================================================================
-- PROYECTO: Nexus Mobile (Grupo 24) - Etapa V
-- TEMA 1: Procedimientos Almacenados
-- ARCHIVO: sql/tecnico/procedimientos/sp_registrar_venta_completa.sql
-- MOTOR: SQL Server Express (T-SQL)
-- =========================================================================
-- NOTA: Este procedimiento invoca a dbo.fn_CalcularDescuentoCliente.
-- Asegúrese de haber ejecutado previamente:
-- sql/tecnico/funciones/fn_calcular_descuento_cliente.sql
-- =========================================================================

-- =========================================================================
-- 1. IMPLEMENTACIÓN DEL PROCEDIMIENTO ALMACENADO (Ítem 3)
-- =========================================================================
-- Tareas que centraliza:
--   1. Validar existencia del cliente, producto y disponibilidad de stock.
--   2. Registrar el encabezado de la operación en VENTA.
--   3. Calcular y aplicar el descuento de cliente frecuente.
--   4. Insertar el detalle en CONTIENE guardando el precio histórico.
--   5. Descontar las unidades en el stock único de PRODUCTO.
--   6. Retornar el resumen de confirmación de la venta.
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarVentaCompleta
    @dni_cliente  INT,
    @metodo_pago  VARCHAR(50),
    @cod_producto INT,
    @cantidad     INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @stock_disponible INT;
    DECLARE @precio_lista     DECIMAL(10, 2);
    DECLARE @descuento_pct    DECIMAL(5, 2);
    DECLARE @precio_final     DECIMAL(10, 2);
    DECLARE @nuevo_nro_venta  INT;

    -- 1. Validar que el cliente exista en el padrón
    IF NOT EXISTS (SELECT 1 FROM CLIENTE WHERE dni_cliente = @dni_cliente)
    BEGIN
        RAISERROR('Error: El DNI del cliente no se encuentra registrado en Nexus Mobile.', 16, 1);
        RETURN;
    END;

    -- 2. Validar existencia del producto y obtener su stock y precio de lista actual
    SELECT 
        @stock_disponible = stock_actual,
        @precio_lista     = precio_actual
    FROM PRODUCTO
    WHERE cod_producto = @cod_producto;

    IF @stock_disponible IS NULL
    BEGIN
        RAISERROR('Error: El código de producto indicado no existe en el catálogo.', 16, 1);
        RETURN;
    END;

    -- 3. Validar cantidad positiva y stock suficiente (RN03 - Control de stock único)
    IF @cantidad <= 0
    BEGIN
        RAISERROR('Error: La cantidad de unidades a vender debe ser mayor a cero.', 16, 1);
        RETURN;
    END;

    IF @stock_disponible < @cantidad
    BEGIN
        RAISERROR('Error: Stock insuficiente en el inventario centralizado para realizar la venta.', 16, 1);
        RETURN;
    END;

    -- 4. Calcular descuento con la función almacenada y congelar el precio histórico
    SET @descuento_pct = dbo.fn_CalcularDescuentoCliente(@dni_cliente);
    SET @precio_final  = @precio_lista * (1.00 - (@descuento_pct / 100.00));

    -- 5. Registrar encabezado de la venta
    INSERT INTO VENTA (fecha, metodo_pago, dni_cliente)
    VALUES (CAST(GETDATE() AS DATE), @metodo_pago, @dni_cliente);

    -- Obtener el nro_venta generado por la propiedad IDENTITY
    SET @nuevo_nro_venta = SCOPE_IDENTITY();

    -- 6. Insertar el detalle en CONTIENE con el precio_unitario histórico
    INSERT INTO CONTIENE (nro_venta, cod_producto, cantidad, precio_unitario)
    VALUES (@nuevo_nro_venta, @cod_producto, @cantidad, @precio_final);

    -- 7. Actualizar el stock único en la tabla PRODUCTO
    UPDATE PRODUCTO
    SET stock_actual = stock_actual - @cantidad
    WHERE cod_producto = @cod_producto;

    -- 8. Devolver resumen de la operación confirmada
    SELECT 
        @nuevo_nro_venta            AS nro_venta_generada,
        @dni_cliente                AS dni_cliente,
        @cod_producto               AS cod_producto,
        @cantidad                   AS cantidad_vendida,
        @precio_lista               AS precio_lista_catalogo,
        @descuento_pct              AS descuento_pct,
        @precio_final               AS precio_unitario_historico,
        (@cantidad * @precio_final) AS total_operacion;
END;
GO

-- =========================================================================
-- 2. SCRIPT DE DEMOSTRACIÓN Y PRUEBAS (Ítem 5)
-- =========================================================================

-- A. Consultar estado inicial del producto 7 antes de la venta
SELECT cod_producto, descripcion, stock_actual, precio_actual 
FROM PRODUCTO 
WHERE cod_producto = 7;
GO

-- B. Ejecutar venta válida:
-- Cliente: 40123456 (Guido Casado -> registra compras > $500.000, recibe 10% dto.)
-- Producto: 7 (Auriculares Inalambricos Navy Blue -> Precio lista $40.000, Stock 30)
-- Cantidad: 2 unidades
EXEC dbo.sp_RegistrarVentaCompleta 
    @dni_cliente  = 40123456,
    @metodo_pago  = 'Transferencia',
    @cod_producto = 7,
    @cantidad     = 2;
GO

-- C. Verificar descuento de stock en PRODUCTO (pasa de 30 a 28 unidades)
SELECT cod_producto, descripcion, stock_actual, precio_actual 
FROM PRODUCTO 
WHERE cod_producto = 7;
GO

-- D. Verificar registros creados en VENTA y CONTIENE (precio histórico guardado a $36.000)
SELECT TOP 1 
    V.nro_venta,
    V.fecha,
    V.metodo_pago,
    V.dni_cliente,
    CO.cod_producto,
    CO.cantidad,
    CO.precio_unitario AS precio_historico_congelado
FROM VENTA V
INNER JOIN CONTIENE CO ON V.nro_venta = CO.nro_venta
ORDER BY V.nro_venta DESC;
GO