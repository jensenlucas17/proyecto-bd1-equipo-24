# Consulta 2: Reporte Agregado de Ventas por Período
**Script:** `sql/consultas/reporte_ventas_agregado.sql`

## Necesidad de información
La gerencia comercial requiere un reporte integral para evaluar el desempeño de las ventas dentro de un rango de fechas parametrizable. El reporte debe totalizar:
- La cantidad de transacciones únicas realizadas (`COUNT`).
- El volumen de unidades físicas comercializadas (`SUM`).
- La facturación total en pesos generada (`SUM`).

El análisis debe contemplar dos perspectivas de agregación:
1. **Por Categoría de Producto:** Para conocer los segmentos con mayor rotación e ingresos.
2. **Por Vendedor / Empleado:** Para medir el rendimiento comercial individual en dicho período.

---

## Consulta SQL (T-SQL)

```sql
-- ============================================================================
-- Consulta 2: Reporte Agregado de Ventas (Categoría y Vendedor)
-- Motor: Microsoft SQL Server (T-SQL)
-- ============================================================================

-- Parámetros del rango temporal evaluado
DECLARE @fecha_desde DATETIME = '2026-09-01 00:00:00';
DECLARE @fecha_hasta DATETIME = '2026-09-30 23:59:59';

-- ----------------------------------------------------------------------------
-- Reporte 1: Totalización agregada por Categoría de Producto
-- ----------------------------------------------------------------------------
SELECT 
    P.tipo                                          AS [Categoría],
    COUNT(DISTINCT V.nro_venta)                    AS [Total Operaciones],
    SUM(CO.cantidad)                               AS [Unidades Vendidas],
    SUM(CO.cantidad * CO.precio_unitario)          AS [Facturación Total]
FROM VENTA AS V
INNER JOIN CONTIENE AS CO 
    ON V.nro_venta = CO.nro_venta
INNER JOIN PRODUCTO AS P 
    ON CO.cod_producto = P.cod_producto
WHERE V.fecha_hora BETWEEN @fecha_desde AND @fecha_hasta
GROUP BY 
    P.tipo
ORDER BY 
    [Facturación Total] DESC;

-- ----------------------------------------------------------------------------
-- Reporte 2: Totalización agregada por Vendedor / Empleado
-- ----------------------------------------------------------------------------
SELECT 
    E.id                                            AS [ID Vendedor],
    E.nombre_completo                               AS [Vendedor],
    COUNT(DISTINCT V.nro_venta)                    AS [Ventas Concretadas],
    SUM(CO.cantidad)                               AS [Unidades Despachadas],
    SUM(CO.cantidad * CO.precio_unitario)          AS [Facturación Total]
FROM VENTA AS V
INNER JOIN EMPLEADO AS E 
    ON V.id_vendedor = E.id
INNER JOIN CONTIENE AS CO 
    ON V.nro_venta = CO.nro_venta
WHERE V.fecha_hora BETWEEN @fecha_desde AND @fecha_hasta
GROUP BY 
    E.id,
    E.nombre_completo
ORDER BY 
    [Facturación Total] DESC;
```

---

## Estrategia SQL
La consulta recibe los límites del rango temporal (`@fecha_desde`, `@fecha_hasta`) y combina las entidades mediante cláusulas `INNER JOIN`:

| Tabla | Aporta | Se une por |
| :--- | :--- | :--- |
| **VENTA** | Registro maestro de la transacción y filtro temporal (`fecha_hora`) | Tabla base |
| **CONTIENE** | Unidades vendidas (`cantidad`) y precio facturado por renglón (`precio_unitario`) | `nro_venta` |
| **PRODUCTO** | Categoría o tipo de artículo (`tipo`) | `cod_producto` |
| **EMPLEADO** | Identificador (`id`) y nombre del vendedor (`nombre_completo`) | `id_vendedor` / `id` |

---

## Decisiones de diseño de la consulta

- **Uso estricto de GROUP BY:** Se agrupan todas las columnas no calculadas del `SELECT` (`P.tipo` para el catálogo y `E.id, E.nombre_completo` para el personal).
- **Métricas agregadas diferenciadas:**
  - `COUNT(DISTINCT V.nro_venta)`: Previene sobreestimaciones en la cantidad de transacciones comerciales, dado que una misma venta puede contener múltiples líneas en la tabla `CONTIENE`.
  - `SUM(CO.cantidad)`: Calcula el total de unidades físicas despachadas.
  - `SUM(CO.cantidad * CO.precio_unitario)`: Calcula el importe monetario bruto total de los ítems involucrados.
- **Filtrado temporal en WHERE:** La evaluación `V.fecha_hora BETWEEN @fecha_desde AND @fecha_hasta` acota el escaneo de registros en la tabla transaccional antes de procesar las agregaciones.
- **Orden gerencial:** Se aplica `ORDER BY [Facturación Total] DESC` para priorizar los rubros y vendedores más rentables en las primeras filas.

---

## Resultado esperado

Para el período de septiembre de 2026 (`@fecha_desde = '2026-09-01 00:00:00'` y `@fecha_hasta = '2026-09-30 23:59:59'`):

### 1. Salida por Categoría de Producto:
| Categoría | Total Operaciones | Unidades Vendidas | Facturación Total |
| :--- | :---: | :---: | :---: |
| Celular | 4 | 4 | $ 3.350.000,00 |
| Accesorio | 6 | 12 | $ 293.500,00 |

### 2. Salida por Vendedor:
| ID Vendedor | Vendedor | Ventas Concretadas | Unidades Despachadas | Facturación Total |
| :---: | :--- | :---: | :---: | :---: |
| 30 | Medina, Inés | 4 | 9 | $ 2.140.000,00 |
| 34 | Silva, Esteban | 3 | 7 | $ 1.503.500,00 |

---

## Cómo verificarlo

1. **Control de balance cruzado:** La suma total de facturación en el reporte por categorías ($3.350.000,00 + $293.500,00 = $3.643.500,00) debe coincidir con la sumatoria del reporte por vendedor ($2.140.000,00 + $1.503.500,00 = $3.643.500,00).
2. **Script de auditoría directa:** Ejecutar la siguiente consulta de validación sin agrupaciones intermedias:

```sql
SELECT 
    COUNT(DISTINCT V.nro_venta)           AS TransaccionesTotales,
    SUM(CO.cantidad)                      AS UnidadesTotales,
    SUM(CO.cantidad * CO.precio_unitario) AS TotalAuditoria
FROM VENTA AS V
INNER JOIN CONTIENE AS CO 
    ON V.nro_venta = CO.nro_venta
WHERE V.fecha_hora BETWEEN '2026-09-01 00:00:00' AND '2026-09-30 23:59:59';
```
*Resultado esperado de auditoría:* 
- `TransaccionesTotales`: 7
- `UnidadesTotales`: 16
- `TotalAuditoria`: $ 3.643.500,00