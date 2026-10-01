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
