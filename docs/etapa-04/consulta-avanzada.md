# Consulta 3: Detección de clientes frecuentes para envío de cupón de descuento

**Script:** `sql/consultas/consulta_avanzada.sql`

## Necesidad de información

El área de marketing requiere identificar a los clientes que hayan comprado más de $100.000 en total durante un mismo mes. El objetivo es enviarles un cupón de descuento por mensaje de texto. El listado debe incluir el DNI, nombre, apellido, número de teléfono y el importe total gastado en el período.

## Consulta SQL (T-SQL)

```sql
-- Parámetros de entrada
DECLARE @mes  INT = 9;
DECLARE @anio INT = 2026;

-- Rango del período: [primer día del mes, primer día del mes siguiente)
DECLARE @fecha_desde DATETIME = DATEFROMPARTS(@anio, @mes, 1);
DECLARE @fecha_hasta DATETIME = DATEADD(MONTH, 1, @fecha_desde);

SELECT
    C.dni_cliente                                   AS DNI,
    C.nombre + ' ' + C.apellido                     AS [Nombre y Apellido],
    C.telefono                                      AS [Teléfono],
    SUM(CO.cantidad * CO.precio_unitario)           AS [Total Gastado en el Mes]
FROM CLIENTE  AS C
INNER JOIN VENTA    AS V  ON V.dni_cliente = C.dni_cliente
INNER JOIN CONTIENE AS CO ON CO.nro_venta  = V.nro_venta
WHERE V.fecha_hora >= @fecha_desde
  AND V.fecha_hora <  @fecha_hasta
GROUP BY
    C.dni_cliente,
    C.nombre,
    C.apellido,
    C.telefono
HAVING SUM(CO.cantidad * CO.precio_unitario) > 100000
ORDER BY [Total Gastado en el Mes] DESC;
```

## Estrategia SQL

La consulta recibe el mes y el año (`@mes`, `@anio`) y combina tres tablas mediante `INNER JOIN`:

| Tabla | Aporta | Se une por |
|---|---|---|
| `CLIENTE` | DNI, nombre, apellido y teléfono | tabla base |
| `VENTA` | Filtro de fecha para acotar las compras | `dni_cliente` |
| `CONTIENE` | Cantidad y precio para calcular el gasto | `nro_venta` |

## Decisiones de diseño de la consulta

- **Agrupación:** como un cliente puede tener múltiples ventas en el mes (ej. Guido Casado tiene la venta 1 y la 3), se agrupan los resultados con `GROUP BY` sobre todos los datos identificatorios del cliente (DNI, nombre, apellido y teléfono). Todas las columnas no agregadas del `SELECT` deben figurar en el `GROUP BY`.
- **Gasto mensual unificado:** se calcula con `SUM(CO.cantidad * CO.precio_unitario)`, sumando todas las líneas de todas las ventas del cliente en el período.
- **Filtro de monto con `HAVING`:** el requerimiento de superar los $100.000 no se puede evaluar en el `WHERE` porque es un cálculo agregado (el `WHERE` se ejecuta antes de agrupar). Por eso se aplica un filtro posterior con `HAVING SUM(CO.cantidad * CO.precio_unitario) > 100000`.
- **Filtro de período en `WHERE`:** se usa un rango semiabierto (`>= primer día del mes` y `< primer día del mes siguiente`) en lugar de `MONTH()` / `YEAR()` sobre la columna. Esto evita aplicar funciones a `fecha_hora`, permite aprovechar un índice sobre esa columna y contempla correctamente las ventas del último día del mes con cualquier hora.
- **Exclusión automática:** los clientes que compraron menos de ese monto quedan excluidos del listado sin necesidad de lógica adicional.
- **Orden:** el resultado se ordena de mayor a menor gasto, para priorizar a los clientes más frecuentes.

## Resultado esperado

Para `@mes = 9` y `@anio = 2026` (Septiembre 2026), clientes con gastos superiores a $100.000:

| DNI | Nombre y Apellido | Teléfono | Total Gastado en el Mes |
|---|---|---|---|
| 43999888 | Virginia Gomez | 1149998888 | $ 1.215.000,00 |
| 42333222 | Lucas Jensen | 3794333222 | $ 890.000,00 |
| 40123456 | Guido Casado | 3794123456 | $ 885.500,00 |
| 39876543 | Santiago Lencinas | 3794987654 | $ 468.000,00 |

## Cómo verificarlo

1. Revisar que la salida no devuelva ningún registro cuyo `Total Gastado en el Mes` sea menor o igual a 100.000.
2. Comprobar que los clientes con múltiples compras en el mes (como Guido Casado, que gastó $860.000 en la venta 1 y $25.500 en la venta 3) aparezcan en **una única fila** unificada con la suma total ($885.500).

Para facilitar el punto 2, el script incluye una consulta de verificación que muestra el importe por venta de un cliente:

```sql
DECLARE @mes_v  INT = 9;
DECLARE @anio_v INT = 2026;
DECLARE @desde_v DATETIME = DATEFROMPARTS(@anio_v, @mes_v, 1);
DECLARE @hasta_v DATETIME = DATEADD(MONTH, 1, @desde_v);

SELECT
    V.nro_venta,
    V.fecha_hora,
    SUM(CO.cantidad * CO.precio_unitario) AS [Importe de la venta]
FROM VENTA AS V
INNER JOIN CONTIENE AS CO ON CO.nro_venta = V.nro_venta
WHERE V.dni_cliente = 40123456
  AND V.fecha_hora >= @desde_v
  AND V.fecha_hora <  @hasta_v
GROUP BY V.nro_venta, V.fecha_hora
ORDER BY V.nro_venta;
```

Resultado esperado: venta 1 → $860.000,00 y venta 3 → $25.500,00, que suman los $885.500,00 de la consulta principal.
