CREATE TABLE Direccion (
  codigo_direccion INT PRIMARY KEY,
  calle VARCHAR(100) NOT NULL,
  altura INT NOT NULL,
  CP VARCHAR(10) NOT NULL,
  provincia VARCHAR(50) NOT NULL,
  ciudad VARCHAR(50) NOT NULL
);

CREATE TABLE CLIENTE (
  dni_cliente INT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  codigo_direccion INT NOT NULL,
  FOREIGN KEY (codigo_direccion) REFERENCES Direccion(codigo_direccion)
);

CREATE TABLE EQUIPO (
  id_equipo INT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(200) NOT NULL,
  dni_cliente INT NOT NULL,
  FOREIGN KEY (dni_cliente) REFERENCES CLIENTE(dni_cliente)
);

CREATE TABLE SERVICIO_TECNICO (
  nro_orden INT PRIMARY KEY,
  falla_reportada VARCHAR(255) NOT NULL,
  precio_arreglo DECIMAL(10,2) NOT NULL,
  fecha_ingreso DATETIME NOT NULL,
  fecha_entrega DATETIME, 
  id_equipo INT NOT NULL,
  FOREIGN KEY (id_equipo) REFERENCES EQUIPO(id_equipo)
);

CREATE TABLE PRODUCTO (
  cod_producto INT PRIMARY KEY,
  descripcion VARCHAR(150) NOT NULL,
  tipo VARCHAR(50) NOT NULL,
  stock_actual INT NOT NULL CHECK (stock_actual >= 0),
  precio_actual DECIMAL(10,2) NOT NULL CHECK (precio_actual >= 0)
);

CREATE TABLE ENVIO (
  cod_seguimiento VARCHAR(50) PRIMARY KEY,
  direccion_origen INT NOT NULL,
  direccion_envio INT NOT NULL,
  estado_envio VARCHAR(30) NOT NULL,
  FOREIGN KEY (direccion_origen) REFERENCES Direccion(codigo_direccion),
  FOREIGN KEY (direccion_envio) REFERENCES Direccion(codigo_direccion)
);

CREATE TABLE VENTA (
  nro_venta INT PRIMARY KEY,
  fecha_hora DATETIME NOT NULL,
  metodo_pago VARCHAR(50) NOT NULL,
  canal_venta VARCHAR(50) NOT NULL,
  dni_cliente INT NOT NULL,
  cod_seguimiento VARCHAR(50), 
  FOREIGN KEY (dni_cliente) REFERENCES CLIENTE(dni_cliente),
  FOREIGN KEY (cod_seguimiento) REFERENCES ENVIO(cod_seguimiento)
);

CREATE TABLE PROVEEDOR (
  cuit_proveedor VARCHAR(15) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  codigo_direccion INT NOT NULL,
  FOREIGN KEY (codigo_direccion) REFERENCES Direccion(codigo_direccion)
);

CREATE TABLE ABASTECE (
  cod_producto INT NOT NULL,
  cuit_proveedor VARCHAR(15) NOT NULL,
  PRIMARY KEY (cod_producto, cuit_proveedor),
  FOREIGN KEY (cod_producto) REFERENCES PRODUCTO(cod_producto),
  FOREIGN KEY (cuit_proveedor) REFERENCES PROVEEDOR(cuit_proveedor)
);

CREATE TABLE CONTIENE (
  nro_venta INT NOT NULL,
  cod_producto INT NOT NULL,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
  PRIMARY KEY (nro_venta, cod_producto),
  FOREIGN KEY (nro_venta) REFERENCES VENTA(nro_venta),
  FOREIGN KEY (cod_producto) REFERENCES PRODUCTO(cod_producto)
);