```
CREATE TABLE Direccion
(
  codigo_direccion INT NOT NULL,
  calle INT NOT NULL,
  altura INT NOT NULL,
  CP INT NOT NULL,
  provincia INT NOT NULL,
  ciudad INT NOT NULL,
  PRIMARY KEY (codigo_direccion)
);
CREATE TABLE CLIENTE
(
  dni_cliente INT NOT NULL,
  calle INT NOT NULL,
  altura INT NOT NULL,
  telefono INT NOT NULL,
  nombre INT NOT NULL,
  apellido INT NOT NULL,
  codigo_direccion INT NOT NULL,
  PRIMARY KEY (dni_cliente),
  FOREIGN KEY (codigo_direccion) REFERENCES Direccion(codigo_direccion)
);
CREATE TABLE EQUIPO
(
  id_equipo INT NOT NULL,
  nombre INT NOT NULL,
  Descripcion INT NOT NULL,
  dni_cliente INT NOT NULL,
  PRIMARY KEY (id_equipo),
  FOREIGN KEY (dni_cliente) REFERENCES CLIENTE(dni_cliente)
);
CREATE TABLE SERVICIO_TECNICO
(
  falla_reportada INT NOT NULL,
  precio_arreglo INT NOT NULL,
  nro_orden INT NOT NULL,
  Fecha_ingreso INT NOT NULL,
  Fecha_entrega INT NOT NULL,
  id_equipo INT NOT NULL,
  PRIMARY KEY (nro_orden),
  FOREIGN KEY (id_equipo) REFERENCES EQUIPO(id_equipo)
);
CREATE TABLE PRODUCTO
(
  descripcion INT NOT NULL,
  stock_Actual INT NOT NULL,
  precio_actual INT NOT NULL,
  cod_producto INT NOT NULL,
  Tipo INT NOT NULL,
  nro_orden INT NOT NULL,
  PRIMARY KEY (cod_producto),
  FOREIGN KEY (nro_orden) REFERENCES SERVICIO_TECNICO(nro_orden)
);
CREATE TABLE ENVIO
(
  direccion_envio INT NOT NULL,
  direccion_origen INT NOT NULL,
  estado_envio INT NOT NULL,
  cod_seguimiento INT NOT NULL,
```

```
  id_envio INT NOT NULL,
  PRIMARY KEY (cod_seguimiento)
);
CREATE TABLE VENTA
(
  nro_venta INT NOT NULL,
  metodo_pago INT NOT NULL,
  canal_venta INT NOT NULL,
  fecha_hora INT NOT NULL,
  dni_cliente INT NOT NULL,
  cod_seguimiento INT NOT NULL,
  PRIMARY KEY (nro_venta),
  FOREIGN KEY (dni_cliente) REFERENCES CLIENTE(dni_cliente),
  FOREIGN KEY (cod_seguimiento) REFERENCES ENVIO(cod_seguimiento)
);
```

```
CREATE TABLE PROVEEDOR
(
```

```
  cuit_proveedor INT NOT NULL,
  telefono INT NOT NULL,
  email INT NOT NULL,
  codigo_direccion INT NOT NULL,
  PRIMARY KEY (cuit_proveedor),
  FOREIGN KEY (codigo_direccion) REFERENCES Direccion(codigo_direccion)
);
```

```
CREATE TABLE ABASTECE
(
```

```
  cod_producto INT NOT NULL,
  cuit_proveedor INT NOT NULL,
  PRIMARY KEY (cod_producto, cuit_proveedor),
  FOREIGN KEY (cod_producto) REFERENCES PRODUCTO(cod_producto),
  FOREIGN KEY (cuit_proveedor) REFERENCES PROVEEDOR(cuit_proveedor)
);
```

```
CREATE TABLE CONTIENE
(
  cantidad INT NOT NULL,
  monto INT NOT NULL,
  New_Column INT NOT NULL,
  cod_producto INT NOT NULL,
  nro_venta INT NOT NULL,
  PRIMARY KEY (cod_producto),
  FOREIGN KEY (cod_producto) REFERENCES PRODUCTO(cod_producto),
  FOREIGN KEY (nro_venta) REFERENCES VENTA(nro_venta)
);
```

