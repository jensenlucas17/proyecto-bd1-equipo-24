/* ============================================================
   ETAPA 3 - IMPLEMENTACIÓN FÍSICA
   1. Script DDL (Data Definition Language)
   Motor: T-SQL (SQL Server)

   Criterio general de integridad referencial:
   - ON DELETE NO ACTION  -> se usa quiy no se debe perder
     historial ni permitir borrados en cascada accidentales
     (ventas, órdenes de servicio, direcciones en uso, etc.).
   - ON DELETE CASCADE    -> se usa en tablas de detalle/
     asociación que no tienen sentido sin su "dueño"
     (líneas de una venta, relaciones producto-proveedor).
   - ON DELETE SET NULL   -> se usa cuando la relación es
     opcional y la FK admite NULL (envío de una venta).
   - ON UPDATE            -> se deja en NO ACTION para claves
     subrogadas (INT/IDENTITY), ya que no se espera que
     cambien. Se usa CASCADE únicamente sobre LOCALIDAD.CP,
     que es un código natural que podría normalizarse.
   ============================================================ */

-- 1. LOCALIDAD
CREATE TABLE LOCALIDAD (
    CP        VARCHAR(10) NOT NULL,
    provincia VARCHAR(50) NOT NULL,
    ciudad    VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Localidad PRIMARY KEY (CP)
);
GO

-- 2. DIRECCION
CREATE TABLE Direccion (
    codigo_direccion INT           IDENTITY(1,1) NOT NULL,
    calle            VARCHAR(100)  NOT NULL,
    altura           INT           NOT NULL,
    CP               VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_Direccion PRIMARY KEY (codigo_direccion),
    CONSTRAINT CK_Direccion_Altura CHECK (altura >= 0),
    CONSTRAINT FK_Direccion_Localidad FOREIGN KEY (CP)
        REFERENCES LOCALIDAD (CP)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- 3. CLIENTE
CREATE TABLE CLIENTE (
    dni_cliente      INT           NOT NULL,
    nombre           VARCHAR(50)   NOT NULL,
    apellido         VARCHAR(50)   NOT NULL,
    telefono         VARCHAR(20)   NOT NULL,
    codigo_direccion INT           NOT NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (dni_cliente),
    CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (codigo_direccion)
        REFERENCES Direccion (codigo_direccion)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- 4. EQUIPO
CREATE TABLE EQUIPO (
    id_equipo   INT           IDENTITY(1,1) NOT NULL,
    nombre      VARCHAR(50)   NOT NULL,
    descripcion VARCHAR(200)  NOT NULL,
    dni_cliente INT           NOT NULL,
    CONSTRAINT PK_Equipo PRIMARY KEY (id_equipo),
    CONSTRAINT FK_Equipo_Cliente FOREIGN KEY (dni_cliente)
        REFERENCES CLIENTE (dni_cliente)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

GO

-- 5. SERVICIO_TECNICO
CREATE TABLE SERVICIO_TECNICO (
    nro_orden       INT            IDENTITY(1,1) NOT NULL,
    falla_reportada VARCHAR(255)   NOT NULL,
    precio_arreglo  DECIMAL(10,2)  NOT NULL,
    fecha_ingreso   DATETIME       NOT NULL DEFAULT GETDATE(), -- Registra la fecha/hora actual por defecto
    fecha_entrega   DATETIME       NULL,     -- Permite valores nulos para órdenes en proceso
    id_equipo       INT            NOT NULL,
    CONSTRAINT PK_ServicioTecnico PRIMARY KEY (nro_orden),
    CONSTRAINT CK_ServicioTecnico_Precio CHECK (precio_arreglo >= 0),
    CONSTRAINT CK_ServicioTecnico_Fechas CHECK (fecha_entrega IS NULL OR fecha_entrega >= fecha_ingreso),
    CONSTRAINT FK_ServicioTecnico_Equipo FOREIGN KEY (id_equipo)
        REFERENCES EQUIPO (id_equipo)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

GO

-- 6. PRODUCTO
CREATE TABLE PRODUCTO (
    cod_producto  INT            IDENTITY(1,1) NOT NULL,
    descripcion   VARCHAR(150)   NOT NULL,
    tipo          VARCHAR(50)    NOT NULL,
    stock_actual  INT            NOT NULL,
    precio_actual DECIMAL(10,2)  NOT NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (cod_producto),
    CONSTRAINT CK_Producto_Stock CHECK (stock_actual >= 0),
    CONSTRAINT CK_Producto_Precio CHECK (precio_actual >= 0)
);

GO

-- 7. ENVIO
CREATE TABLE ENVIO (
    cod_seguimiento  VARCHAR(50)  NOT NULL,
    id_envio         VARCHAR(20)  NOT NULL,
    direccion_origen INT          NOT NULL,
    direccion_envio  INT          NOT NULL,
    estado_envio     VARCHAR(30)  NOT NULL,
    CONSTRAINT PK_Envio PRIMARY KEY (cod_seguimiento),
    CONSTRAINT UQ_Envio_IdEnvio UNIQUE (id_envio),
    CONSTRAINT CK_Envio_Estado CHECK (estado_envio IN ('Pendiente', 'En Transito', 'Entregado', 'Cancelado')),
    CONSTRAINT FK_Envio_DireccionOrigen FOREIGN KEY (direccion_origen)
        REFERENCES Direccion (codigo_direccion)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Envio_DireccionDestino FOREIGN KEY (direccion_envio)
        REFERENCES Direccion (codigo_direccion)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

GO

-- 8. VENTA
CREATE TABLE VENTA (
    nro_venta       INT           IDENTITY(1,1) NOT NULL,
    fecha_hora      DATETIME      NOT NULL DEFAULT GETDATE(),
    metodo_pago     VARCHAR(50)   NOT NULL,
    canal_venta     VARCHAR(50)   NOT NULL,
    dni_cliente     INT           NOT NULL,
    cod_seguimiento VARCHAR(50)   NULL,     -- Opcional para ventas presenciales
    CONSTRAINT PK_Venta PRIMARY KEY (nro_venta),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (dni_cliente)
        REFERENCES CLIENTE (dni_cliente)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Venta_Envio FOREIGN KEY (cod_seguimiento)
        REFERENCES ENVIO (cod_seguimiento)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);

GO

-- 9. PROVEEDOR
CREATE TABLE PROVEEDOR (
    cuit_proveedor   VARCHAR(15)   NOT NULL,
    nombre           VARCHAR(100)  NOT NULL,
    telefono         VARCHAR(20)   NOT NULL,
    email            VARCHAR(100)  NOT NULL,
    codigo_direccion INT           NOT NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (cuit_proveedor),
    CONSTRAINT UQ_Proveedor_Email UNIQUE (email),
    CONSTRAINT FK_Proveedor_Direccion FOREIGN KEY (codigo_direccion)
        REFERENCES Direccion (codigo_direccion)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- 10. ABASTECE (Tabla intermedia M:N)
CREATE TABLE ABASTECE (
    cod_producto   INT          NOT NULL,
    cuit_proveedor VARCHAR(15)  NOT NULL,
    CONSTRAINT PK_Abastece PRIMARY KEY (cod_producto, cuit_proveedor),
    CONSTRAINT FK_Abastece_Producto FOREIGN KEY (cod_producto)
        REFERENCES PRODUCTO (cod_producto)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Abastece_Proveedor FOREIGN KEY (cuit_proveedor)
        REFERENCES PROVEEDOR (cuit_proveedor)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);
GO

-- 11. CONTIENE (Tabla intermedia M:N)
CREATE TABLE CONTIENE (
    nro_venta       INT            NOT NULL,
    cod_producto    INT            NOT NULL,
    cantidad        INT            NOT NULL,
    precio_unitario DECIMAL(10,2)  NOT NULL,
    CONSTRAINT PK_Contiene PRIMARY KEY (nro_venta, cod_producto),
    CONSTRAINT CK_Contiene_Cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_Contiene_PrecioUnitario CHECK (precio_unitario >= 0),
    CONSTRAINT FK_Contiene_Venta FOREIGN KEY (nro_venta)
        REFERENCES VENTA (nro_venta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Contiene_Producto FOREIGN KEY (cod_producto)
        REFERENCES PRODUCTO (cod_producto)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO