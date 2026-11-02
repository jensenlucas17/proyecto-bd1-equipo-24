-- SCRIPT 1: Transacción Simple con Manejo de Errores y Prueba de Fallo

-- =============================================================================
-- PARTE A: Transacción Exitosa (Flujo Normal)
-- =============================================================================

PRINT '==================================================';
PRINT '>>> 1. PRUEBA DE TRANSACCIÓN EXITOSA <<<';
PRINT '==================================================';

-- Verificación de estado previo (Producto 101)
SELECT cod_producto, descripcion, stock_actual, precio_actual 
FROM dbo.PRODUCTO 
WHERE cod_producto = 101;
GO

BEGIN TRY
    BEGIN TRANSACTION TrxVentaExitosa;

    -- 1. Obtenemos el próximo nro_venta manualmente
    DECLARE @id_venta_ok INT;
    SELECT @id_venta_ok = ISNULL(MAX(nro_venta), 0) + 1 FROM dbo.VENTA;

    -- 2. Insertamos la cabecera indicando explícitamente el nro_venta
    INSERT INTO dbo.VENTA (nro_venta, fecha_hora, metodo_pago, canal_venta, dni_cliente, cod_seguimiento)
    VALUES (@id_venta_ok, GETDATE(), 'Transferencia', 'Online', 40123456, NULL);

    -- 3. Insertamos el renglón de detalle en CONTIENE
    INSERT INTO dbo.CONTIENE (nro_venta, cod_producto, cantidad, precio_unitario)
    VALUES (@id_venta_ok, 101, 2, 8500.00);

    -- 4. Actualizamos el stock en PRODUCTO
    UPDATE dbo.PRODUCTO
    SET stock_actual = stock_actual - 2
    WHERE cod_producto = 101;

    COMMIT TRANSACTION TrxVentaExitosa;
    PRINT 'Resultado: Transacción confirmada exitosamente (COMMIT).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Error detectado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Verificación de cambios persistidos
SELECT cod_producto, descripcion, stock_actual, precio_actual 
FROM dbo.PRODUCTO 
WHERE cod_producto = 101;

SELECT TOP 1 * FROM dbo.VENTA ORDER BY nro_venta DESC;
SELECT TOP 1 * FROM dbo.CONTIENE WHERE cod_producto = 101 ORDER BY nro_venta DESC;
GO
-- =============================================================================
-- PARTE B: Transacción con Fallo Intencional (Violación de Clave Primaria)
-- =============================================================================
USE [proyecto]; -- O USE [NexusMobile] según el nombre de tu BD
GO

PRINT '==================================================';
PRINT '>>> 2. PRUEBA DE FALLO INTENCIONAL (PK DUPLICADA) <<<';
PRINT '==================================================';

-- 1. Verificamos el stock inicial del Producto 102 (Cargador USB-C 25W)
SELECT cod_producto, descripcion, stock_actual, precio_actual 
FROM dbo.PRODUCTO 
WHERE cod_producto = 102;

BEGIN TRY
    BEGIN TRANSACTION TrxFalloPK;

    -- Obtenemos el próximo nro_venta disponible
    DECLARE @id_venta_fallo INT;
    SELECT @id_venta_fallo = ISNULL(MAX(nro_venta), 0) + 1 FROM dbo.VENTA;

    -- PASO 1 (Inserción exitosa en Tabla 1): Cabecera de la venta
    INSERT INTO dbo.VENTA (nro_venta, fecha_hora, metodo_pago, canal_venta, dni_cliente, cod_seguimiento)
    VALUES (@id_venta_fallo, GETDATE(), 'Efectivo', 'Local', 40123456, NULL);
    PRINT 'Paso 1: Cabecera insertada temporalmente con nro_venta = ' + CAST(@id_venta_fallo AS VARCHAR(10));

    -- PASO 2 (Inserción exitosa en Tabla 2): Primer renglón válido de detalle en CONTIENE
    INSERT INTO dbo.CONTIENE (nro_venta, cod_producto, cantidad, precio_unitario)
    VALUES (@id_venta_fallo, 102, 1, 18500.00);
    PRINT 'Paso 2: Renglón inicial insertado en CONTIENE.';

    -- PASO 2.1: ERROR INTENCIONAL PROVOCADO LUEGO DEL INSERT
    -- Intentamos insertar otra vez exactamente la misma tupla (nro_venta, cod_producto)
    -- Provoca el Error 2627 de SQL Server (Violación de la Clave Primaria compuesta)
    PRINT 'Provocando error forzado de PK duplicada...';
    INSERT INTO dbo.CONTIENE (nro_venta, cod_producto, cantidad, precio_unitario)
    VALUES (@id_venta_fallo, 102, 1, 18500.00); -- <-- FALLO AQUÍ

    -- PASO 3: Actualización en Tabla 3 (PRODUCTO)
    -- Esta sentencia NUNCA debe alcanzarse
    UPDATE dbo.PRODUCTO
    SET stock_actual = stock_actual - 1
    WHERE cod_producto = 102;

    COMMIT TRANSACTION TrxFalloPK;
    PRINT 'Alerta: Transacción confirmada indebidamente.';
END TRY
BEGIN CATCH
    -- Captura del error y reversión total
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '-------------------------------------------------------';
    PRINT '*** EXCEPCIÓN DETECTADA POR EL BLOQUE CATCH ***';
    PRINT 'Número de Error : ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Línea de Error  : ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Descripción     : ' + ERROR_MESSAGE();
    PRINT 'Acción aplicada : Se ejecutó ROLLBACK. Base de datos consistente e intacta.';
    PRINT '-------------------------------------------------------';
END CATCH;
GO

-- COMPROBACIONES DE CONSISTENCIA POST-FALLO (Evidencias):
-- 1. El stock del Producto 102 debe mantenerse intacto (sigue en 25)
SELECT cod_producto, descripcion, stock_actual, precio_actual 
FROM dbo.PRODUCTO 
WHERE cod_producto = 102;

-- 2. No deben quedar registros huérfanos en CONTIENE
SELECT * 
FROM dbo.CONTIENE 
WHERE nro_venta NOT IN (SELECT nro_venta FROM dbo.VENTA);
GO

-- 

-- SCRIPT 2: Transacciones Anidadas y Monitoreo de @@TRANCOUNT
PRINT '==================================================';
PRINT '>>> 3. DEMOSTRACIÓN DE TRANSACCIONES ANIDADAS <<<';
PRINT '==================================================';

-- Verificación de stock previo del Producto 103 (Auriculares inalámbricos)
SELECT cod_producto, descripcion, stock_actual, precio_actual 
FROM dbo.PRODUCTO 
WHERE cod_producto = 103;
GO

BEGIN TRY
    -- Nivel 1: Transacción Externa (Cabecera de Comprobante de Venta)
    BEGIN TRANSACTION TrxExterna;
    PRINT 'Nivel 1 abierto (TrxExterna). @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR(5));

    -- Obtenemos el próximo nro_venta manualmente
    DECLARE @nro_venta_anidada INT;
    SELECT @nro_venta_anidada = ISNULL(MAX(nro_venta), 0) + 1 FROM dbo.VENTA;

    -- Inserción de cabecera en VENTA indicando nro_venta
    INSERT INTO dbo.VENTA (nro_venta, fecha_hora, metodo_pago, canal_venta, dni_cliente, cod_seguimiento)
    VALUES (@nro_venta_anidada, GETDATE(), 'Transferencia', 'Online', 40111222, NULL);
    PRINT 'Paso 1 (Nivel 1): Venta cabecera creada con nro_venta = ' + CAST(@nro_venta_anidada AS VARCHAR(10));

    -- Nivel 2: Transacción Interna / Anidada (Detalle de Venta y Ajuste de Inventario)
    BEGIN TRANSACTION TrxInterna;
    PRINT 'Nivel 2 abierto (TrxInterna). @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR(5));

    -- Inserción en CONTIENE (Producto 103, 1 unidad)
    INSERT INTO dbo.CONTIENE (nro_venta, cod_producto, cantidad, precio_unitario)
    VALUES (@nro_venta_anidada, 103, 1, 42000.00);
    PRINT 'Paso 2 (Nivel 2): Detalle insertado en CONTIENE.';

    -- Actualización de inventario en PRODUCTO
    UPDATE dbo.PRODUCTO
    SET stock_actual = stock_actual - 1
    WHERE cod_producto = 103;
    PRINT 'Paso 3 (Nivel 2): Stock actualizado en PRODUCTO.';

    -- Cierre del nivel interno: solo decrementa @@TRANCOUNT de 2 a 1 (no confirma en disco aún)
    COMMIT TRANSACTION TrxInterna;
    PRINT 'COMMIT TrxInterna ejecutado. @@TRANCOUNT decrementado a: ' + CAST(@@TRANCOUNT AS VARCHAR(5));

    -- Cierre del nivel externo: decrementa @@TRANCOUNT de 1 a 0 y consolida definitivamente en el archivo MDF
    COMMIT TRANSACTION TrxExterna;
    PRINT 'COMMIT TrxExterna ejecutado. @@TRANCOUNT final = ' + CAST(@@TRANCOUNT AS VARCHAR(5));
    PRINT 'Operación jerárquica completada y persistida exitosamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Excepción capturada en bloque jerárquico. ROLLBACK ejecutado; @@TRANCOUNT = 0.';
    END
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Verificación de persistencia post-ejecución
SELECT cod_producto, descripcion, stock_actual, precio_actual 
FROM dbo.PRODUCTO 
WHERE cod_producto = 103;

SELECT TOP 1 * FROM dbo.VENTA ORDER BY nro_venta DESC;
SELECT TOP 1 * FROM dbo.CONTIENE WHERE cod_producto = 103 ORDER BY nro_venta DESC;
GO
