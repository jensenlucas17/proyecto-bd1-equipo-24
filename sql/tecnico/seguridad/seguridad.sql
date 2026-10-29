/* ============================================================
   ETAPA 5 - TEMA TÉCNICO: SEGURIDAD
   Parte 1: Implementación de Logins, Usuarios, Roles y Permisos
   ============================================================ */

USE master;
GO

-- 1. Crear los Logins (acceso al servidor)
CREATE LOGIN login_vendedor WITH PASSWORD = 'Password123!', CHECK_POLICY = OFF;
CREATE LOGIN login_tecnico WITH PASSWORD = 'Password123!', CHECK_POLICY = OFF;
GO

USE proyecto;
GO

-- 2. Crear los Usuarios dentro de nuestra base de datos
CREATE USER usr_vendedor FOR LOGIN login_vendedor;
CREATE USER usr_tecnico FOR LOGIN login_tecnico;
GO

-- 3. Crear los Roles (puestos de trabajo)
CREATE ROLE rol_vendedor;
CREATE ROLE rol_tecnico;
GO

-- 4. Asignar cada usuario a su rol correspondiente
ALTER ROLE rol_vendedor ADD MEMBER usr_vendedor;
ALTER ROLE rol_tecnico ADD MEMBER usr_tecnico;
GO

-- 5. Permisos para el Vendedor (GRANT y DENY)
GRANT SELECT ON PRODUCTO TO rol_vendedor;
GRANT SELECT, INSERT ON CLIENTE TO rol_vendedor;
GRANT SELECT, INSERT ON VENTA TO rol_vendedor;
GRANT SELECT, INSERT ON CONTIENE TO rol_vendedor;

DENY DELETE ON VENTA TO rol_vendedor;
GO

-- 6. Permisos para el Técnico (GRANT y DENY)
GRANT SELECT ON CLIENTE TO rol_tecnico;
GRANT SELECT, INSERT, UPDATE ON EQUIPO TO rol_tecnico;
GRANT SELECT, INSERT, UPDATE ON SERVICIO_TECNICO TO rol_tecnico;

DENY DELETE ON SERVICIO_TECNICO TO rol_tecnico;
GO


/* ============================================================
   Parte 2: Script de Demostración
   ============================================================ */

-- ------------------------------------------------------------
-- PRUEBA 1: Simulamos ser el Vendedor
-- ------------------------------------------------------------
EXECUTE AS USER = 'usr_vendedor';

-- A) Permitido: Ver los productos (Funciona bien)
SELECT * FROM PRODUCTO;

-- B) No permitido: Ver órdenes del taller (Tira error porque no tiene GRANT)
SELECT * FROM SERVICIO_TECNICO;

-- C) Prohibido: Intentar borrar una venta (Tira error por el DENY DELETE)
DELETE FROM VENTA WHERE nro_venta = 1;

-- Volvemos a ser el usuario Administrador
REVERT;
GO


-- ------------------------------------------------------------
-- PRUEBA 2: Simulamos ser el Técnico
-- ------------------------------------------------------------
EXECUTE AS USER = 'usr_tecnico';

-- A) Permitido: Actualizar el precio de un arreglo (Funciona bien)
UPDATE SERVICIO_TECNICO 
SET precio_arreglo = 90000.00 
WHERE nro_orden = 1;

-- B) No permitido: Ver las ventas del local (Tira error porque no tiene permiso)
SELECT * FROM VENTA;

-- C) Prohibido: Intentar borrar una orden del taller (Tira error por el DENY DELETE)
DELETE FROM SERVICIO_TECNICO WHERE nro_orden = 1;

-- Volvemos a ser el usuario Administrador
REVERT;
GO


-- ------------------------------------------------------------
-- PRUEBA 3: Ejemplo de cómo quitar un permiso con REVOKE
-- ------------------------------------------------------------
-- Si ya no queremos que el técnico pueda agregar equipos nuevos:
REVOKE INSERT ON EQUIPO FROM rol_tecnico;
GO