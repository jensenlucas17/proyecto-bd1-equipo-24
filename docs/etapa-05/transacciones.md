# ETAPA V: TEMAS TÉCNICOS AVANZADOS
## Manejo De Transacciones Y Transacciones Anidadas
**SISTEMA DE GESTIÓN: NEXUSMOBILE**
**Script:** [`sql/tecnico/transacciones/transacciones.sql`](../../sql/tecnico/transacciones.sql)  

## 1. DEFINICIÓN Y OBJETIVO
Una transacción en un Sistema de Gestión de Bases de Datos Relacionales (`RDBMS`)
es una unidad lógica e indivisible de ejecución que agrupa una o más sentencias
de manipulación de datos (`DML`: `INSERT`, `UPDATE`, `DELETE`).

- Atomicidad (Atomicity): 
Todas las operaciones que conforman la unidad de trabajo deben ejecutarse exitosamente 
o, en su defecto, ninguna debe tenerefecto en la base ("principio de todo o nada"). 
Si ocurre una excepción o corte en cualquier punto intermedio, el sistema retrotrae el 
estado al punto exacto anterior a su inicio.
- Consistencia (Consistency): 
La transacción transporta a la base de datos de un estado válido e íntegro a otro 
estado válido, respetando estrictamente todas las restricciones de integridad definidas 
en el catálogo físico (`PRIMARY KEY`,`FOREIGN KEY`, `CHECK`, `UNIQUE`).
- Aislamiento (Isolation): 
Las operaciones concurrentes ejecutadas por otros procesos o sesiones se ejecutan 
sin interferencias mutuas. Los datos modificados de forma preliminar no son visibles 
por otras transacciones hasta su confirmación definitiva.
- Durabilidad (Durability): 
Una vez consolidada la transacción mediante COMMIT, los cambios registrados persisten 
de manera irreversible en el almacenamiento secundario (archivos MDF y LDF), 
resistiendo caídas del servicio o fallos del sistema operativo.

## 2. VENTAJAS Y APLICACIONES
### Ventajas:
- Integridad ante anomalías operativas: 
Elimina la posibilidad de inconsistencias lógicas o datos truncos producidos por errores 
de aplicación, cortes de energía o violaciones imprevistas de restricciones relacionales.
- Reversión controlada y automática: 
Proporciona el mecanismo estructurado del comando `ROLLBACK` para anular modificaciones 
parciales sin necesidad de scripts compensatorios manuales.
- Modularidad y jerarquía: 
Habilita el anidamiento ordenado de rutinas de negocio mediante el monitoreo del contador 
@@TRANCOUNT y puntos de recuperación intermedios (`SAVE TRANSACTION`).

### Aplicaciones:
- Circuito de facturación comercial: 
Alta atómica del encabezado del comprobante (`VENTA`), de sus renglones de detalle 
asociados (`CONTIENE`) y del decremento en las existencias físicas de inventario (`PRODUCTO`).
- Servicio técnico y reparaciones: 
Creación simultánea del equipo recibido (`EQUIPO`) junto con la apertura de su orden de trabajo 
(`SERVICIO_TECNICO`).
- Gestión de despachos: 
Asignación de código de seguimiento y registro de envíos (`ENVIO`) asociado al comprobante de venta respectivo.

## 3. IMPLEMENTACIÓN EN SQL SERVER EXPRESS
En el dialecto Transact-SQL (`T-SQL`) de Microsoft `SQL Server Express`, el control
transaccional se sustenta en las siguientes instrucciones y mecanismos:

- BEGIN TRANSACTION [nombre]: Inicia formalmente una transacción explícita e
incrementa en una unidad (+1) la variable del sistema @@TRANCOUNT.
- COMMIT TRANSACTION [nombre]: Decrementa en una unidad (-1) @@TRANCOUNT. Cuando
@@TRANCOUNT llega a 0, las modificaciones se consolidan físicamente en el motor.
- ROLLBACK TRANSACTION: Revierte todas las operaciones pendientes realizadas desde
el `BEGIN TRANSACTION` más externo (nivel 1) y restablece @@TRANCOUNT a 0.
- SAVE TRANSACTION nombre_punto: Define un punto de guardado interno para permitir
reversiones parciales selectivas sin anular la transacción externa.
- Bloque BEGIN TRY ... BEGIN CATCH: Estructura moderna y robusta de gestión de
excepciones en tiempo de ejecución. Permite interceptar violaciones de reglas
(claves primarias duplicadas, claves foráneas inexistentes, errores de `CHECK`)
y ejecutar de forma automática e inmediata la sentencia `ROLLBACK` TRANSACTION
cuando @@TRANCOUNT > 0.

## 4. CASO CONCRETO APLICADO AL SISTEMA DE VENTAS DEL EQUIPO
En el modelo relacional de la tienda de componentes y accesorios informáticos
"NexusMobile", la concreción de una operación de venta involucra tres fases
operativas secuenciales y estrictamente dependientes:

## 1. INSERT en VENTA: Genera el registro de cabecera con fecha/hora actual, método
de pago ('Transferencia', 'Tarjeta', 'Efectivo'), canal de venta ('Online',
'Local') y el DNI de un cliente previamente validado en `CLIENTE`. Se recupera
el identificador autogenerado `nro_venta` mediante la función `SCOPE_IDENTITY`().
## 2. INSERT en CONTIENE: Asocia la cabecera recién creada con el producto vendido
(por ejemplo, `cod_producto` = 101, 'Funda protectora universal'), indicando la
cantidad de unidades y el precio unitario histórico convenido.
## 3. UPDATE en PRODUCTO: Ajusta el inventario físico disponible deduciendo las
unidades comercializadas del atributo `stock_actual`.

**Regla de consistencia:** Si el segundo paso genera una falla (por ejemplo, violación
de la clave primaria compuesta `nro_venta` + `cod_producto` en `CONTIENE`) o la
actualización de inventario se interrumpe, el encabezado en `VENTA` no debe
persistir en el sistema y el stock del producto debe conservarse inalterado,
demostrando la propiedad de atomicidad en su totalidad.

## Conclusiones técnicas

## 1. Comprobación de Atomicidad ante Fallo Intencional:
Al provocar la duplicación intencional de la clave primaria compuesta
(`nro_venta`, `cod_producto`) en la tabla `CONTIENE` con el producto 102, el motor
SQL Server abortó la instrucción arrojando el error número 2627.
El flujo de control se transfirió inmediatamente al bloque CATCH sin llegar a
ejecutar la actualización de inventario (`UPDATE` `PRODUCTO`).
La ejecución condicional de `ROLLBACK` TRANSACTION desarmó las operaciones
previas del bloque:
- El encabezado en VENTA fue revertido en su totalidad.
- La primera línea en CONTIENE fue descartada (sin registros huérfanos).
- El stock de existencias del producto 102 permaneció inalterado en 25 unidades.
Con ello se probó de manera concluyente la propiedad de ATOMICIDAD ("todo o nada").
