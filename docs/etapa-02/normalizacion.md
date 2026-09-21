NORMALIZACION
1FN: Eliminación de grupos repetitivos y garantía de atomicidad
Para que el modelo relacional alcance la Primera Forma Normal (1FN), se analizó la estructura inicial de los requerimientos y se aplicaron los siguientes pasos para asegurar la integridad básica de los datos:

Paso 1: Garantizar la atomicidad de los atributos
Se estructuraron las tablas de modo que cada columna contenga un único valor indivisible.

En la información de los clientes, en lugar de utilizar un atributo combinado como nombre_completo, se separó en nombre y apellido.

Para la ubicación geográfica de clientes y proveedores, se evitó el uso de un campo genérico direccion_completa. En su lugar, se creó la entidad independiente Direccion con atributos completamente atómicos: calle, altura, CP, provincia y ciudad.

Paso 2: Eliminación de grupos repetitivos
Se identificó que una misma venta (comprobante) puede contener múltiples productos. Si esta relación se mantenía en una única tabla de VENTA, se generaría un grupo repetitivo (por ejemplo, columnas como producto_1, producto_2, cantidad_1, etc.), lo cual viola los principios de la 1FN.

Solución: Se aisló este grupo repetitivo creando una tabla independiente llamada CONTIENE (que funciona como el detalle de la venta). Cada renglón del comprobante de venta pasa a ser un registro único en esta nueva tabla, logrando que la tabla cabecera (VENTA) quede libre de repeticiones.

Paso 3: Identificación unívoca (Claves Primarias)
Se dotó a cada tabla de una Clave Primaria (PK) para garantizar que no existan filas duplicadas idénticas.

En las tablas fuertes se definieron identificadores únicos (como dni_cliente, nro_orden, cod_producto).

En la tabla generada para resolver los grupos repetitivos (CONTIENE), se estableció una clave primaria compuesta (nro_venta, cod_producto). Esto asegura de forma estricta que no se pueda registrar exactamente el mismo artículo dos veces en la misma venta, garantizando la unicidad de los registros.