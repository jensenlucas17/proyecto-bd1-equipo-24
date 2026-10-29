-- =========================================================================
-- PROYECTO: Nexus Mobile (Grupo 24) - Etapa V
-- TEMA 3: Triggers de Auditoría
-- ARCHIVO: sql/tecnico/triggers/triggers.sql
-- MOTOR: SQL Server Express (T-SQL)
-- =========================================================================
-- Requisitos previos (en este orden):
--   1. sql/ddl/crear_bd.sql          (crea la base NexusMobile y sus tablas)
--   2. sql/dml/datos_prueba.sql      (carga los datos de prueba)
-- =========================================================================

USE NexusMobile;
GO

-- =========================================================================
-- 1. TABLA DE AUDITORÍA
-- =========================================================================
-- Guarda una fila por cada cambio auditado sobre PRODUCTO.
--   - cod_producto no tiene FOREIGN KEY: si un producto se elimina, su
--     historial de auditoría debe conservarse igual.
--   - fecha_hora y usuario se completan solos mediante DEFAULT.
-- =========================================================================
IF OBJECT_ID(N'dbo.AUDITORIA_PRODUCTO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AUDITORIA_PRODUCTO (
        auditoria_id    INT           IDENTITY(1,1) NOT NULL,
        fecha_hora      DATETIME      NOT NULL CONSTRAINT DF_AuditoriaProducto_Fecha   DEFAULT GETDATE(),
        usuario         SYSNAME       NOT NULL CONSTRAINT DF_AuditoriaProducto_Usuario DEFAULT SUSER_SNAME(),
        tipo_operacion  VARCHAR(10)   NOT NULL,
        cod_producto    INT           NOT NULL,
        descripcion     VARCHAR(150)  NOT NULL,
        precio_anterior DECIMAL(10,2) NULL,
        precio_nuevo    DECIMAL(10,2) NULL,
        CONSTRAINT PK_AuditoriaProducto PRIMARY KEY (auditoria_id),
        CONSTRAINT CK_AuditoriaProducto_Operacion
            CHECK (tipo_operacion IN ('INSERT', 'UPDATE', 'DELETE'))
    );
END;
GO

-- =========================================================================
-- 2. TRIGGER DE AUDITORÍA SOBRE PRODUCTO
-- =========================================================================
-- Se ejecuta automáticamente después de cada INSERT, UPDATE o DELETE.
-- Usa las dos tablas especiales que SQL Server crea dentro del trigger:
--   inserted -> filas nuevas (INSERT) o con los valores NUEVOS (UPDATE)
--   deleted  -> filas borradas (DELETE) o con los valores VIEJOS (UPDATE)
--
-- En un UPDATE solo se audita si cambió precio_actual: el stock cambia con
-- cada venta y registrarlo llenaría la tabla de ruido.
-- Se escribe con INSERT ... SELECT para registrar todas las filas afectadas
-- aunque una sola sentencia modifique varios productos.
-- =========================================================================
CREATE OR ALTER TRIGGER dbo.trg_Producto_Auditoria
ON dbo.PRODUCTO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- UPDATE: la fila está en inserted y en deleted, y el precio cambió
    INSERT INTO dbo.AUDITORIA_PRODUCTO
        (tipo_operacion, cod_producto, descripcion, precio_anterior, precio_nuevo)
    SELECT 'UPDATE', i.cod_producto, i.descripcion, d.precio_actual, i.precio_actual
    FROM inserted AS i
    INNER JOIN deleted AS d ON d.cod_producto = i.cod_producto
    WHERE i.precio_actual <> d.precio_actual;

    -- INSERT: la fila está en inserted pero no en deleted
    INSERT INTO dbo.AUDITORIA_PRODUCTO
        (tipo_operacion, cod_producto, descripcion, precio_anterior, precio_nuevo)
    SELECT 'INSERT', i.cod_producto, i.descripcion, NULL, i.precio_actual
    FROM inserted AS i
    WHERE NOT EXISTS (SELECT 1 FROM deleted AS d WHERE d.cod_producto = i.cod_producto);

    -- DELETE: la fila está en deleted pero no en inserted
    INSERT INTO dbo.AUDITORIA_PRODUCTO
        (tipo_operacion, cod_producto, descripcion, precio_anterior, precio_nuevo)
    SELECT 'DELETE', d.cod_producto, d.descripcion, d.precio_actual, NULL
    FROM deleted AS d
    WHERE NOT EXISTS (SELECT 1 FROM inserted AS i WHERE i.cod_producto = d.cod_producto);
END;
GO

-- =========================================================================
-- 3. SCRIPT DE DEMOSTRACIÓN
-- =========================================================================
-- Ejecutar de a un bloque por vez. Cada bloque muestra su resultado.
-- =========================================================================

-- 3.1 Estado inicial del catálogo
SELECT cod_producto, descripcion, tipo, stock_actual, precio_actual
FROM dbo.PRODUCTO
ORDER BY cod_producto;
GO

-- 3.2 Cambio de precio de un producto y consulta de la auditoría
UPDATE dbo.PRODUCTO SET precio_actual = 20000.00 WHERE cod_producto = 102;

SELECT auditoria_id, tipo_operacion, cod_producto, descripcion, precio_anterior, precio_nuevo
FROM dbo.AUDITORIA_PRODUCTO
ORDER BY auditoria_id;
GO

-- 3.3 Cambio de stock solamente: no debe generar ninguna fila de auditoría
DECLARE @filas_antes INT = (SELECT COUNT(*) FROM dbo.AUDITORIA_PRODUCTO);
UPDATE dbo.PRODUCTO SET stock_actual = stock_actual - 1 WHERE cod_producto = 101;
SELECT @filas_antes                                  AS filas_antes,
       (SELECT COUNT(*) FROM dbo.AUDITORIA_PRODUCTO) AS filas_despues;
GO

-- 3.4 Alta y baja de un producto
INSERT INTO dbo.PRODUCTO (descripcion, tipo, stock_actual, precio_actual)
VALUES ('Producto temporal de auditoria', 'Accesorio', 1, 100.00);

DELETE FROM dbo.PRODUCTO WHERE descripcion = 'Producto temporal de auditoria';

SELECT auditoria_id, tipo_operacion, cod_producto, descripcion, precio_anterior, precio_nuevo
FROM dbo.AUDITORIA_PRODUCTO
WHERE descripcion = 'Producto temporal de auditoria'
ORDER BY auditoria_id;
GO

-- 3.5 Se vuelve a los valores originales (el cambio de precio también queda auditado)
UPDATE dbo.PRODUCTO SET precio_actual = 18500.00 WHERE cod_producto = 102;
UPDATE dbo.PRODUCTO SET stock_actual  = 40       WHERE cod_producto = 101;
GO

-- 3.6 Trazabilidad: ¿quién, cuándo y cómo cambió el precio del producto 102?
SELECT fecha_hora, usuario, tipo_operacion, precio_anterior, precio_nuevo
FROM dbo.AUDITORIA_PRODUCTO
WHERE cod_producto = 102
ORDER BY auditoria_id;
GO
