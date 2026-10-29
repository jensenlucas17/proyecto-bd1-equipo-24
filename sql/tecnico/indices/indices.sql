/* NexusMobile - Etapa V - Optimización mediante índices
   Ejecutar en SSMS 22, por bloques numerados y en orden.
   La tabla de demostración es independiente de dbo.VENTA.
   IMPORTANTE: activar Consulta > Incluir plan de ejecución real (Ctrl+M)
   ANTES de ejecutar los bloques 3, 5 y 7.
*/
USE NexusMobile;
GO

/* 1. Crear tabla de laboratorio SIN PK ni índices (heap).
   Se impide sobrescribir una prueba existente. */
IF OBJECT_ID(N'dbo.VENTA_INDICES_DEMO', N'U') IS NOT NULL
    THROW 51001, 'La tabla VENTA_INDICES_DEMO ya existe. No se modifico. Revisar antes de repetir.', 1;

CREATE TABLE dbo.VENTA_INDICES_DEMO
(
    id_venta BIGINT IDENTITY(1,1) NOT NULL,
    fecha_venta DATE NOT NULL,
    importe DECIMAL(12,2) NOT NULL
);
GO

/* 2. Carga automatizada de EXACTAMENTE 1.000.000 de filas.
   Fechas repartidas entre 2022-01-01 y los 1825 dias siguientes.
   No se insertan datos en las tablas operativas de NexusMobile. */
SET NOCOUNT ON;
;WITH D AS (SELECT v.n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n)),
N AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM D a CROSS JOIN D b CROSS JOIN D c
    CROSS JOIN D d CROSS JOIN D e CROSS JOIN D f
)
INSERT INTO dbo.VENTA_INDICES_DEMO (fecha_venta, importe)
SELECT DATEADD(DAY, CONVERT(INT, (n * 37) % 1826), CONVERT(date,'20220101',112)),
       CONVERT(DECIMAL(12,2), 100 + (n % 100000))
FROM N;
GO
SELECT COUNT_BIG(*) AS Registros,
       MIN(fecha_venta) AS FechaMinima,
       MAX(fecha_venta) AS FechaMaxima
FROM dbo.VENTA_INDICES_DEMO;
GO

/* 3. ESCENARIO A: sin indice. Registrar mensajes y plan REAL.
   Mismo SELECT y mismo periodo en los escenarios. */
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT id_venta, fecha_venta, importe
FROM dbo.VENTA_INDICES_DEMO
WHERE fecha_venta >= '20230501' AND fecha_venta < '20230508';
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* 4. Indice AGRUPADO sobre fecha. Una tabla admite uno solo. */
CREATE CLUSTERED INDEX IX_VENTA_INDICES_DEMO_Fecha
ON dbo.VENTA_INDICES_DEMO (fecha_venta);
GO

/* 5. ESCENARIO B: indice agrupado sobre fecha. */
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT id_venta, fecha_venta, importe
FROM dbo.VENTA_INDICES_DEMO
WHERE fecha_venta >= '20230501' AND fecha_venta < '20230508';
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* 6. Eliminar indice agrupado: vuelve a ser heap. */
DROP INDEX IX_VENTA_INDICES_DEMO_Fecha ON dbo.VENTA_INDICES_DEMO;
GO

/* 7. Indice de COBERTURA: NO AGRUPADO.
   SQL Server no admite INCLUDE en CREATE CLUSTERED INDEX.
   La fecha es clave de busqueda; las otras columnas se incluyen
   para cubrir exactamente el SELECT del escenario anterior. */
CREATE NONCLUSTERED INDEX IX_VENTA_INDICES_DEMO_Fecha_Cobertura
ON dbo.VENTA_INDICES_DEMO (fecha_venta)
INCLUDE (id_venta, importe);
GO

/* 8. ESCENARIO C: indice no agrupado con cobertura. */
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT id_venta, fecha_venta, importe
FROM dbo.VENTA_INDICES_DEMO
WHERE fecha_venta >= '20230501' AND fecha_venta < '20230508';
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* 9. Verificar el indice vigente (opcional). */
SELECT i.name, i.type_desc, i.is_primary_key
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID(N'dbo.VENTA_INDICES_DEMO');
GO

/* 10. LIMPIEZA OPCIONAL: Descomentar deliberadamente:
DROP TABLE dbo.VENTA_INDICES_DEMO;
GO
*/