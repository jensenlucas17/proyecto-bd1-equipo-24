# Procedimientos y Funciones Almacenadas

**Proyecto:** Nexus Mobile — Grupo 24  
**Materia:** Base de Datos I — FaCENA - UNNE 2026  
**Motor de Base de Datos:** SQL Server Express (T-SQL)

---

## 1. Definición y objetivo

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

## 2. Ventajas y aplicaciones

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
