# Procedimientos y Funciones Almacenadas

**Proyecto:** Nexus Mobile — Grupo 24  
**Materia:** Base de Datos I — FaCENA - UNNE 2026  
**Motor de Base de Datos:** SQL Server Express (T-SQL)

---

## Definición y objetivo

En un Sistema de Gestión de Bases de Datos Relacionales (SGBD) como **SQL Server**, los procedimientos y las funciones almacenadas son objetos de programación compuestos por bloques de código **Transact-SQL (T-SQL)** que se compilan y almacenan de forma persistente dentro del catálogo de la base de datos (en el archivo de datos primario `.mdf`).

### Procedimientos Almacenados (*Stored Procedures*)
Son subrutinas o programas almacenados que encapsulan una secuencia de instrucciones SQL y lógica procedimental (variables, condicionales `IF/ELSE`, bucles, manejo de errores `TRY/CATCH` y control de transacciones). 
* **Objetivo principal:** Ejecutar procesos de negocio complejos o secuencias de operaciones DML (`INSERT`, `UPDATE`, `DELETE`) sobre múltiples tablas como una única operación invocada mediante `EXEC`. Pueden recibir parámetros de entrada y devolver parámetros de salida (`OUTPUT`) o conjuntos de resultados.

### Funciones Almacenadas Definidas por el Usuario (*User-Defined Functions* - UDF)
Son rutinas que aceptan cero o más parámetros de entrada, ejecutan un cálculo o consulta de lectura y **obligatoriamente retornan un resultado** (ya sea un valor escalar único o una tabla) mediante la cláusula `RETURN`. A diferencia de los procedimientos, las funciones no pueden modificar el estado de la base de datos (no admiten `INSERT`, `UPDATE` ni `DELETE` sobre tablas permanentes).
* **Objetivo principal:** Encapsular cálculos comerciales, fórmulas o transformaciones de datos reutilizables que puedan integrarse directamente dentro de expresiones SQL (`SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`).

### Cuadro comparativo en SQL Server

| Característica | Procedimiento Almacenado (`PROCEDURE`) | Función Almacenada (`FUNCTION`) |
| :--- | :--- | :--- |
| **Valor de retorno** | Opcional (código de estado entero, parámetros `OUTPUT` o *resultsets*). | Obligatorio (valor escalar único o variable de tipo `TABLE`). |
| **Modificación de datos (DML)** | Permitida (`INSERT`, `UPDATE`, `DELETE`). | No permitida sobre tablas físicas (solo lectura). |
| **Manejo de transacciones** | Permite `BEGIN TRAN`, `COMMIT`, `ROLLBACK` y `TRY/CATCH`. | No permite gestionar transacciones ni bloques `TRY/CATCH`. |
| **Forma de invocación** | Sentencia independiente con `EXEC` / `EXECUTE`. | Dentro de consultas (`SELECT`, `WHERE`, `JOIN`). |

---

## Ventajas y aplicaciones

### Ventajas técnicas y de arquitectura
1. **Centralización y reutilización de la lógica de negocio:** Las reglas del negocio (como congelar precios históricos o calcular descuentos) se programan una única vez en el motor. Tanto la plataforma web de Nexus Mobile como el sistema de mostrador del local físico consumen exactamente el mismo objeto, evitando discrepancias.
2. **Mantenibilidad:** Si cambia la política comercial (por ejemplo, los umbrales de gasto para otorgar descuentos), solo se actualiza la definición de la función en la base de datos (`ALTER FUNCTION`) sin necesidad de recompilar ni redesplegar el software cliente.
3. **Rendimiento y optimización:** Al crearse y ejecutarse por primera vez, SQL Server analiza, compila y guarda el **plan de ejecución** en la memoria caché (*Buffer Pool / Plan Cache*). Las ejecuciones posteriores reutilizan dicho plan ahorrando tiempo de CPU. Además, reducen el tráfico de red al enviar una sola llamada (`EXEC`) en lugar de múltiples sentencias SQL individuales.
4. **Seguridad y control de acceso:** Permiten aplicar el principio de privilegio mínimo. Se puede otorgar permiso de ejecución (`GRANT EXECUTE`) a un vendedor sobre el procedimiento `sp_RegistrarVentaCompleta` sin concederle permisos directos de `UPDATE` o `DELETE` sobre las tablas críticas `PRODUCTO`, `VENTA` o `CONTIENE`. Previenen además ataques de inyección SQL gracias al tipado estricto de parámetros.

### Aplicaciones habituales
* Cálculos financieros y comerciales estandarizados (descuentos por volumen, recargos, subtotales).
* Operaciones transaccionales que afectan múltiples tablas (registro de ventas con actualización simultánea de inventario y congelamiento de precios).
* Generación de reportes parametrizados y validaciones previas a la persistencia de datos.

---

##  Caso concreto aplicado al sistema de ventas de Nexus Mobile

En el esquema relacional de **Nexus Mobile**, el proceso de facturación y fidelización de clientes involucra las tablas `CLIENTE`, `VENTA`, `CONTIENE` y `PRODUCTO`. Aplicamos ambos mecanismos para resolver dos requerimientos reales del negocio:

### Caso A — Función Almacenada: `dbo.fn_CalcularDescuentoCliente`
* **Problema de negocio:** Nexus Mobile premia a sus clientes frecuentes según su volumen histórico de compras acumuladas (calculado a partir de `CONTIENE.cantidad * CONTIENE.precio_unitario`). La consulta avanzada de la Etapa 3 identificaba clientes destacados; ahora se requiere una función que devuelva automáticamente el porcentaje de descuento aplicable a cualquier cliente dado su `dni_cliente`.
* **Regla de negocio:**
  * Monto histórico acumulado $> \$500.000 \rightarrow 10\%$ de descuento ($0.10$).
  * Monto histórico acumulado $> \$200.000 \rightarrow 5\%$ de descuento ($0.05$).
  * En caso contrario (o cliente sin compras previas, como quien solo usó servicio técnico) $\rightarrow 0\%$ de descuento ($0.00$).
* **Tablas involucradas:** `VENTA` y `CONTIENE`.

### Caso B — Procedimiento Almacenado: `dbo.sp_RegistrarVentaCompleta`
* **Problema de negocio:** Cuando se concreta una venta en el local físico o en la tienda digital, el sistema no debe obligar al usuario o aplicación a ejecutar consultas sueltas con riesgo de olvidar actualizar el stock centralizado o tomar mal el precio vigente.
* **Reglas de negocio de Nexus Mobile aplicadas:**
  * **RN03 y Stock Único Centralizado:** Verificar que exista stock suficiente en `PRODUCTO.stock_actual` antes de vender y descontar las unidades vendidas inmediatamente.
  * **Trazabilidad de Precio Histórico:** Obtener `PRODUCTO.precio_actual`, aplicar el descuento de cliente frecuente (invocando a `dbo.fn_CalcularDescuentoCliente`) y guardar el precio final congelado en `CONTIENE.precio_unitario`, de modo que cambios futuros de precios no alteren los comprobantes emitidos.
* **Tareas que ejecuta `dbo.sp_RegistrarVentaCompleta`:**
  1. Valida la existencia del producto y que `stock_actual >= @cantidad`.
  2. Obtiene el precio de lista actual (`precio_actual`) del catálogo `PRODUCTO`.
  3. Calcula el porcentaje de descuento del cliente invocando `dbo.fn_CalcularDescuentoCliente(@dni_cliente)`.
  4. Registra el encabezado de la operación en la tabla `VENTA` y captura el identificador autogenerado (`SCOPE_IDENTITY()`).
  5. Inserta el renglón del detalle en la tabla `CONTIENE` con el `precio_unitario` histórico (con descuento aplicado).
  6. Descuenta las unidades vendidas en `PRODUCTO.stock_actual`.
  7. Devuelve el resumen del comprobante generado.

---
