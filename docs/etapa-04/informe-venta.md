# Consulta 2: Reporte de Rendimiento Mensual de Ventas por Categoría

**Script:** `sql/consultas/informe_ventas.sql`

## Necesidad de información
El gerente de la sucursal necesita un informe analítico para evaluar el rendimiento de las ventas del mes. El reporte debe agrupar los productos vendidos por categoría (`tipo` en `PRODUCTO`), consolidando en un único resultado
## Consulta SQL (T-SQL)

```sql
/* ============================================================
   CONSULTA 2: Reporte de Rendimiento Mensual de Ventas
   
   Necesidad: Evaluar el desempeño de ventas del mes agrupado
   por categoría de producto (tipo), totalizando operaciones,
   unidades físicas e ingresos brutos.

   Tablas: VENTA, CONTIENE, PRODUCTO (INNER JOIN)
   Filtros: WHERE (período mensual parametrizado)
   Agrupamiento: GROUP BY P.tipo
   Ordenamiento: ORDER BY [Facturación Total] DESC
   ============================================================ */

-- Parámetros de entrada para el período mensual
DECLARE @mes  INT = 9;
DECLARE @anio INT = 2026;

-- Rango del período: [primer día del mes, primer día del mes siguiente)
-- Se evita usar MONTH() y YEAR() sobre la columna en el WHERE para
-- favorecer el uso de índices sobre VENTA.fecha_hora 
DECLARE @fecha_desde DATETIME = DATEFROMPARTS(@anio, @mes, 1);
DECLARE @fecha_hasta DATETIME = DATEADD(MONTH, 1, @fecha_desde);

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
WHERE V.fecha_hora >= @fecha_desde 
  AND V.fecha_hora <  @fecha_hasta
GROUP BY 
    P.tipo
ORDER BY 
    [Facturación Total] DESC;
GO
```

---
## Estrategia SQL
La consulta recibe el mes y el año en las variables `@mes` y `@anio`. Para optimizar la búsqueda y permitir el uso de índices sobre la columna temporal sin aplicar funciones sobre el campo en el `WHERE`, se delimita el intervalo mensual mediante un rango semiabierto `[fecha_desde, fecha_hasta)`. 

La consulta combina tres tablas de la base de datos mediante `INNER JOIN`:

| Tabla | Aporta | Se une por |
| :--- | :--- | :--- |
| **`VENTA`** | Registro maestro de transacción y filtro de fecha del mes (`fecha_hora`) | Tabla base |
| **`CONTIENE`** | Cantidad vendida (`cantidad`) y precio pactado por renglón (`precio_unitario`) | `nro_venta` |
| **`PRODUCTO`** | La categoría del artículo (`tipo`) para segmentar y agrupar | `cod_producto` |

---
## Decisiones de diseño de la consulta

- **Eliminación de entidades inexistentes:** En estricta concordancia con el modelo físico de la base de datos (que no cuenta con tabla ni claves foráneas de empleados/vendedores), la agregación se centra exclusivamente en la entidad de catálogo `PRODUCTO` a través de su atributo `tipo`.
- **Agrupamiento estricto (`GROUP BY P.tipo`):** Colapsa los renglones individuales de cada comprobante en categorías únicas (`'Celular'`, `'Accesorio'`). Todas las columnas no agregadas de la lista del `SELECT` forman parte del agrupamiento.
- **Conteo exacto con `COUNT(DISTINCT V.nro_venta)`:** Una misma transacción comercial puede incluir múltiples artículos de una misma categoría. Utilizar un `COUNT(*)` simple contaría líneas de detalle vendidas en lugar de compras/facturas únicas. El modificador `DISTINCT` resuelve esta duplicidad.
- **Cálculo de ingresos derivado (2FN y RN06):** La tabla `CONTIENE` no almacena subtotales para evitar redundancia física. Se calcula dinámicamente `CO.cantidad * CO.precio_unitario` y se acumula con `SUM()`. Se toma el precio histórico congelado en `CONTIENE` y no el `precio_actual` de `PRODUCTO`.
- **Filtro temporal SARGable:** El cálculo `@fecha_desde` y `@fecha_hasta` mediante `DATEFROMPARTS` y `DATEADD` permite un escaneo eficiente de la tabla `VENTA` en el `WHERE`, contemplando correctamente cualquier hora del último día del mes.
- **Orden de lectura gerencial:** `ORDER BY [Facturación Total] DESC` garantiza que las unidades de negocio más rentables encabecen el reporte.

---
## Resultado esperado

Para `@mes = 9` y `@anio = 2026` (Septiembre de 2026), considerando las ventas 1 a 8 cargadas en las pruebas de validación:

| Categoría | Total Operaciones | Unidades Vendidas | Facturación Total |
| :--- | :---: | :---: | :---: |
| **Celular** | 4 | 4 | $ 3.350.000,00 |
| **Accesorio** | 8 | 12 | $ 293.500,00 |

*Desglose de datos:*
- **Celular:** Ventas 1, 2, 4 y 8 (4 ventas distintas, 4 unidades, total $3.350.000,00).
- **Accesorio:** Presente en las 8 ventas (12 unidades físicas en total, facturación de $293.500,00).

---
## Cómo verificarlo

1. **Cuadratura matemática de facturación:** La suma de la columna `[Facturación Total]` ($3.350.000,00 + $293.500,00 = $3.643.500,00) debe coincidir con la sumatoria de todos los subtotales de las ventas concretadas en dicho mes.
2. **Consulta de auditoría directa:** Ejecutar el siguiente script sin agrupaciones para contrastar las métricas de control:

```sql
DECLARE @mes_a  INT = 9;
DECLARE @anio_a INT = 2026;
DECLARE @desde_a DATETIME = DATEFROMPARTS(@anio_a, @mes_a, 1);
DECLARE @hasta_a DATETIME = DATEADD(MONTH, 1, @desde_a);

SELECT 
    COUNT(DISTINCT V.nro_venta)           AS [Total Ventas Mes],
    SUM(CO.cantidad)                      AS [Total Unidades Mes],
    SUM(CO.cantidad * CO.precio_unitario) AS [Total Facturado Mes]
FROM VENTA AS V
INNER JOIN CONTIENE AS CO 
    ON V.nro_venta = CO.nro_venta
WHERE V.fecha_hora >= @desde_a 
  AND V.fecha_hora <  @hasta_a;
```

*Resultado esperado de auditoría:*
- `Total Ventas Mes`: 8
- `Total Unidades Mes`: 16
- `Total Facturado Mes`: $ 3.643.500,00