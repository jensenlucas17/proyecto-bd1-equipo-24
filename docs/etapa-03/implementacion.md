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

