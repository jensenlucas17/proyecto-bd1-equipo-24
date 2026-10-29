-- NexusMobile | DML de prueba | SQL Server 2025
-- Datos ficticios. Ejecutar sobre las 11 tablas VACIAS.
-- Identificadores explicitos para permitir ejecutar las consultas originales
-- (comprobante @nro_venta=1 y consulta avanzada septiembre 2026).
USE [NexusMobile];
GO
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    IF EXISTS (SELECT 1 FROM dbo.LOCALIDAD) OR EXISTS (SELECT 1 FROM dbo.Direccion)
       OR EXISTS (SELECT 1 FROM dbo.CLIENTE) OR EXISTS (SELECT 1 FROM dbo.EQUIPO)
       OR EXISTS (SELECT 1 FROM dbo.SERVICIO_TECNICO) OR EXISTS (SELECT 1 FROM dbo.PRODUCTO)
       OR EXISTS (SELECT 1 FROM dbo.ENVIO) OR EXISTS (SELECT 1 FROM dbo.VENTA)
       OR EXISTS (SELECT 1 FROM dbo.PROVEEDOR) OR EXISTS (SELECT 1 FROM dbo.ABASTECE)
       OR EXISTS (SELECT 1 FROM dbo.CONTIENE)
       THROW 51001, 'Carga cancelada: hay registros en una o mas tablas.', 1;

    INSERT INTO dbo.LOCALIDAD (CP,provincia,ciudad) VALUES
    ('3400','Corrientes','Corrientes'),('3500','Chaco','Resistencia'),('3300','Misiones','Posadas');

    SET IDENTITY_INSERT dbo.Direccion ON;
    INSERT INTO dbo.Direccion (codigo_direccion,calle,altura,CP) VALUES
    (1,'Junin',1200,'3400'),(2,'San Martin',450,'3400'),(3,'Av. 9 de Julio',810,'3500'),
    (4,'Bolivar',550,'3300'),(5,'Catamarca',275,'3400'),(6,'Salta',920,'3400');
    SET IDENTITY_INSERT dbo.Direccion OFF;

    INSERT INTO dbo.CLIENTE (dni_cliente,nombre,apellido,telefono,codigo_direccion) VALUES
    (40111222,'Ana','Gomez','3794000001',1),
    (38999888,'Luis','Fernandez','3794000002',2),
    (42123456,'Sofia','Benitez','3624000003',3),
    (40123456,'Guido','Casado','3794000004',4);

    INSERT INTO dbo.PROVEEDOR (cuit_proveedor,nombre,telefono,email,codigo_direccion) VALUES
    ('30-71234567-8','Distribuidora Litoral','3794550001','ventas@litoral.example',4),
    ('30-70987654-2','Tecnologia NEA','3794550002','contacto@nea.example',5);

    SET IDENTITY_INSERT dbo.EQUIPO ON;
    INSERT INTO dbo.EQUIPO (id_equipo,nombre,descripcion,dni_cliente) VALUES
    (1,'Samsung Galaxy A54','Pantalla rota',40111222),
    (2,'Motorola Edge 40','No carga bateria',38999888),
    (3,'Xiaomi Redmi Note','Falla de parlante',42123456);
    SET IDENTITY_INSERT dbo.EQUIPO OFF;

    SET IDENTITY_INSERT dbo.SERVICIO_TECNICO ON;
    INSERT INTO dbo.SERVICIO_TECNICO (nro_orden,falla_reportada,precio_arreglo,fecha_ingreso,fecha_entrega,id_equipo) VALUES
    (1001,'Pantalla rota',65000,'2026-10-01','2026-10-05',1),
    (1002,'Problema en conector de carga',32000,'2026-10-08',NULL,2),
    (1003,'Parlante sin sonido',28000,'2026-10-10',NULL,3);
    SET IDENTITY_INSERT dbo.SERVICIO_TECNICO OFF;

    SET IDENTITY_INSERT dbo.PRODUCTO ON;
    INSERT INTO dbo.PRODUCTO (cod_producto,descripcion,tipo,stock_actual,precio_actual) VALUES
    (101,'Funda protectora universal','Accesorio',40,8500),
    (102,'Cargador USB-C 25W','Accesorio',25,18500),
    (103,'Auriculares inalambricos','Audio',15,42000),
    (104,'Vidrio templado','Accesorio',60,5000);
    SET IDENTITY_INSERT dbo.PRODUCTO OFF;

    INSERT INTO dbo.ENVIO (cod_seguimiento,id_envio,direccion_origen,direccion_envio,estado_envio) VALUES
    ('NX-0001','ENV-001',5,1,'Entregado'),
    ('NX-0002','ENV-002',5,3,'En Transito');

    SET IDENTITY_INSERT dbo.VENTA ON;
    INSERT INTO dbo.VENTA (nro_venta,fecha_hora,metodo_pago,canal_venta,dni_cliente,cod_seguimiento) VALUES
    (1,'2026-09-05T10:00:00','Transferencia','Online',40123456,'NX-0001'),
    (2,'2026-09-12T16:00:00','Tarjeta','Local',40123456,NULL),
    (3,'2026-09-18T12:00:00','Efectivo','Local',40111222,NULL),
    (4,'2026-09-22T11:00:00','Tarjeta','Online',42123456,'NX-0002'),
    (5,'2026-09-28T15:00:00','Transferencia','Local',38999888,NULL),
    (2001,'2026-10-15T10:30:00','Transferencia','Online',40111222,'NX-0001'),
    (2002,'2026-10-16T16:00:00','Tarjeta','Online',42123456,'NX-0002'),
    (2003,'2026-10-17T12:00:00','Efectivo','Local',38999888,NULL);
    SET IDENTITY_INSERT dbo.VENTA OFF;

    INSERT INTO dbo.ABASTECE (cod_producto,cuit_proveedor) VALUES
    (101,'30-71234567-8'),(102,'30-71234567-8'),(103,'30-70987654-2'),(104,'30-70987654-2');

    INSERT INTO dbo.CONTIENE (nro_venta,cod_producto,cantidad,precio_unitario) VALUES
    (1,103,2,42000),(1,102,1,18500),
    (2,103,1,42000),(2,101,1,8500),
    (3,104,2,5000),(4,102,2,18500),(5,101,1,8500),
    (2001,101,2,8500),(2001,104,2,5000),
    (2002,103,1,42000),(2002,102,1,18500),(2003,102,1,18500);

    -- UPDATE de demostracion: cambio temporal de stock y restauracion.
    UPDATE dbo.PRODUCTO SET stock_actual = stock_actual + 1 WHERE cod_producto = 101;
    UPDATE dbo.PRODUCTO SET stock_actual = stock_actual - 1 WHERE cod_producto = 101;

    -- INSERT y DELETE de demostracion: registro temporal sin dependencias.
    SET IDENTITY_INSERT dbo.PRODUCTO ON;
    INSERT INTO dbo.PRODUCTO (cod_producto,descripcion,tipo,stock_actual,precio_actual)
    VALUES (999,'Producto temporal de prueba','Accesorio',1,100);
    SET IDENTITY_INSERT dbo.PRODUCTO OFF;
    DELETE FROM dbo.PRODUCTO WHERE cod_producto = 999;

    COMMIT TRANSACTION;
    PRINT 'Carga DML completada correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    -- Asegurar que IDENTITY_INSERT quede apagado para la siguiente ejecucion.
    BEGIN TRY SET IDENTITY_INSERT dbo.Direccion OFF; END TRY BEGIN CATCH END CATCH;
    BEGIN TRY SET IDENTITY_INSERT dbo.EQUIPO OFF; END TRY BEGIN CATCH END CATCH;
    BEGIN TRY SET IDENTITY_INSERT dbo.SERVICIO_TECNICO OFF; END TRY BEGIN CATCH END CATCH;
    BEGIN TRY SET IDENTITY_INSERT dbo.PRODUCTO OFF; END TRY BEGIN CATCH END CATCH;
    BEGIN TRY SET IDENTITY_INSERT dbo.VENTA OFF; END TRY BEGIN CATCH END CATCH;
    THROW;
END CATCH;
GO
SELECT t.name AS Tabla, SUM(p.rows) AS Registros
FROM sys.tables t JOIN sys.partitions p ON p.object_id=t.object_id AND p.index_id IN (0,1)
WHERE t.name <> 'sysdiagrams'
GROUP BY t.name ORDER BY t.name;
GO
