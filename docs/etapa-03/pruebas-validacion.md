/* ============================================================
   ETAPA 3 - SCRIPT DML (Poblado de datos de prueba)
   ============================================================ */

-- 1. LOCALIDAD (Tabla independiente)
INSERT INTO LOCALIDAD (CP, provincia, ciudad) VALUES 
('3400', 'Corrientes', 'Corrientes'),
('3500', 'Chaco', 'Resistencia'),
('1000', 'Buenos Aires', 'CABA'),
('3360', 'Misiones', 'Obera'),
('5000', 'Cordoba', 'Villa Carlos Paz'),
('2000', 'Santa Fe', 'Rosario'),
('3402', 'Corrientes', 'Paso de la Patria'),
('3418', 'Corrientes', 'Empedrado');
GO

-- 2. DIRECCION (Depende de LOCALIDAD. El codigo_direccion se genera solo del 1 al 10)
INSERT INTO Direccion (calle, altura, CP) VALUES 
('Av. 3 de Abril', 1250, '3400'),
('Junin', 850, '3400'),
('Av. Sarmiento', 900, '3500'),
('Av. Tte Ibanez', 1500, '1000'),
('Ruta 12', 150, '3360'),
('Salta', 440, '5000'),
('Pellegrini', 1100, '2000'),
('Belgrano', 100, '3402'),
('San Lorenzo', 1540, '3400'),
('Jujuy', 320, '3418');
GO

-- 3. CLIENTE (Depende de Direccion. Usamos IDs de dirección del 1 al 8)
INSERT INTO CLIENTE (dni_cliente, nombre, apellido, telefono, codigo_direccion) VALUES 
(40123456, 'Guido', 'Casado', '3794123456', 1),
(39876543, 'Santiago', 'Romero', '3794987654', 2),
(41555666, 'Emily', 'Scher', '3624555666', 3),
(42333222, 'Lucas', 'Jensen', '3794331232', 4),
(38111222, 'Federico', 'Gonzalez', '3794111222', 5),
(43999888, 'Lionel', 'Messi', '1149998888', 6),
(35444777, 'Juan', 'Foyth', '3756444777', 7),
(37666555, 'Cristian', 'Romero', '3752666555', 8);
GO

-- 4. PROVEEDOR (Depende de Direccion. El email tiene restricción UNIQUE)
INSERT INTO PROVEEDOR (cuit_proveedor, nombre, telefono, email, codigo_direccion) VALUES 
('30-77778888-1', 'Samsung Argentina', '1155554444', 'ventas@samsung.com.ar', 4),
('30-99991111-2', 'Apple Latam', '1155556666', 'distribucion@apple.com', 4),
('33-44445555-9', 'Accesorios Rosario', '3414445555', 'contacto@accros.com.ar', 7),
('30-22223333-5', 'Distribuidora Chaco', '3624222333', 'ventas@districhaco.com.ar', 3),
('33-11110000-3', 'Mundo Repuestos', '3794111000', 'repuestos@mundo.com.ar', 1),
('30-68909897-4', 'Motorola Solutions', '1155557777', 'ventas@motorola.com.ar', 4),
('33-88889999-6', 'Tech Import', '3541888999', 'importaciones@tech.com', 6),
('30-55554444-8', 'Baterias del Litoral', '3794555444', 'baterias@litoral.com.ar', 9);
GO

-- 5. EQUIPO (Depende de CLIENTE. El id_equipo se genera solo)
INSERT INTO EQUIPO (nombre, descripcion, dni_cliente) VALUES 
('Samsung Galaxy S22', 'Pantalla rota y pin de carga fallando', 40123456),
('iPhone 11', 'Bateria dura muy poco, se apaga al 20%', 39876543),
('Motorola G20', 'Modulo completo destruido', 41555666),
('Xiaomi Redmi Note 10', 'No enciende tras mojarse', 42333222),
('Samsung Galaxy A54', 'Camara trasera borrosa', 38111222),
('iPhone 13 Pro', 'Falla en el modulo de FaceID', 43999888),
('Motorola Edge 30', 'Se reinicia constantemente en el logo', 35444777),
('TCL 20 SE', 'Boton de encendido trabado', 37666555);
GO
-- 6. PRODUCTO (Tabla independiente. El cod_producto se genera solo del 1 al 10)
INSERT INTO PRODUCTO (descripcion, tipo, stock_actual, precio_actual) VALUES 
('Samsung Galaxy S23 FE 128GB', 'Celular', 15, 850000.00),
('iPhone 15 256GB', 'Celular', 8, 1200000.00),
('Motorola Moto G84', 'Celular', 20, 450000.00),
('Funda Silicona Earth Tone iPhone 15', 'Accesorio', 50, 15000.00),
('Vidrio Templado Samsung S23', 'Accesorio', 100, 5000.00),
('Cargador Carga Rapida 25W', 'Accesorio', 45, 25000.00),
('Auriculares Inalambricos Navy Blue', 'Accesorio', 30, 40000.00),
('Cable USB-C a USB-C 2mts', 'Accesorio', 80, 8500.00),
('Funda Reforzada Motorola G84', 'Accesorio', 40, 18000.00),
('Smartwatch Fit Serie 3', 'Accesorio', 12, 95000.00);
GO

-- 7. SERVICIO_TECNICO (Depende de EQUIPO. Respetamos que fecha_entrega pueda ser NULL)
INSERT INTO SERVICIO_TECNICO (falla_reportada, precio_arreglo, fecha_ingreso, fecha_entrega, id_equipo) VALUES 
('Cambio de modulo y pin de carga', 85000.00, '2026-09-10 10:00:00', '2026-09-12 18:00:00', 1),
('Reemplazo de bateria original', 45000.00, '2026-09-15 11:30:00', '2026-09-16 17:00:00', 2),
('Cambio de modulo generico', 60000.00, '2026-09-20 09:15:00', NULL, 3),
('Bano quimico placa sulfatada', 35000.00, '2026-09-22 16:45:00', '2026-09-25 10:00:00', 4),
('Reemplazo lente camara', 20000.00, '2026-09-25 10:20:00', NULL, 5),
('Microsoldadura flex FaceID', 120000.00, '2026-09-26 12:00:00', NULL, 6),
('Flasheo de sistema operativo', 15000.00, '2026-09-27 18:10:00', '2026-09-28 11:00:00', 7),
('Cambio flex encendido', 25000.00, '2026-09-28 09:00:00', NULL, 8);
GO

-- 8. ENVIO (Depende de Direccion. El estado debe ser uno de los permitidos por el CHECK)
INSERT INTO ENVIO (cod_seguimiento, id_envio, direccion_origen, direccion_envio, estado_envio) VALUES 
('TN123456789AR', 'ENV-001', 1, 5, 'Entregado'),
('TN987654321AR', 'ENV-002', 1, 6, 'En Transito'),
('TN555555555AR', 'ENV-003', 1, 7, 'Pendiente'),
('TN111111111AR', 'ENV-004', 1, 8, 'Cancelado'),
('TN222222222AR', 'ENV-005', 1, 4, 'Entregado'),
('TN333333333AR', 'ENV-006', 1, 2, 'En Transito'),
('TN444444444AR', 'ENV-007', 1, 3, 'Entregado'),
('TN777777777AR', 'ENV-008', 1, 5, 'Pendiente');
GO

-- 9. VENTA (Depende de CLIENTE y ENVIO. cod_seguimiento puede ser NULL)
INSERT INTO VENTA (fecha_hora, metodo_pago, canal_venta, dni_cliente, cod_seguimiento) VALUES 
('2026-09-20 10:00:00', 'Tarjeta de Credito', 'E-commerce', 41555666, 'TN123456789AR'),
('2026-09-21 15:30:00', 'Transferencia', 'E-commerce', 43999888, 'TN987654321AR'),
('2026-09-22 09:15:00', 'Efectivo', 'Presencial', 40123456, NULL),
('2026-09-23 11:45:00', 'Tarjeta de Debito', 'Presencial', 39876543, NULL),
('2026-09-24 16:20:00', 'MercadoPago', 'E-commerce', 35444777, 'TN555555555AR'),
('2026-09-25 10:10:00', 'Tarjeta de Credito', 'E-commerce', 37666555, 'TN111111111AR'),
('2026-09-26 18:30:00', 'Transferencia', 'E-commerce', 38111222, 'TN222222222AR'),
('2026-09-27 12:00:00', 'Efectivo', 'Presencial', 42333222, NULL);
GO

-- 10. ABASTECE (Tabla M:N. Relaciona PRODUCTO con PROVEEDOR)
INSERT INTO ABASTECE (cod_producto, cuit_proveedor) VALUES 
(1, '30-77778888-1'), 
(2, '30-99991111-2'), 
(3, '30-68909897-4'), 
(4, '33-44445555-9'), 
(5, '33-44445555-9'), 
(6, '30-22223333-5'), 
(7, '33-88889999-6'), 
(8, '33-11110000-3'), 
(9, '33-44445555-9'), 
(10, '33-88889999-6');
GO

-- 11. CONTIENE (Tabla M:N. Detalle de las ventas)
INSERT INTO CONTIENE (nro_venta, cod_producto, cantidad, precio_unitario) VALUES 
(1, 1, 1, 850000.00), 
(1, 5, 2, 5000.00),   
(2, 2, 1, 1200000.00),
(2, 4, 1, 15000.00),  
(3, 8, 3, 8500.00),   
(4, 3, 1, 450000.00), 
(4, 9, 1, 18000.00),  
(5, 7, 1, 40000.00),  
(6, 10, 1, 95000.00), 
(7, 6, 2, 25000.00),  
(8, 1, 1, 850000.00), 
(8, 7, 1, 40000.00);  
GO