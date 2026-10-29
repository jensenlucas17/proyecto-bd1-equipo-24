# Tema Técnico 4: Seguridad y Control de Acceso

## 1. Definición y Objetivo
La seguridad y autorización en una base de datos consiste en controlar qué usuarios tienen acceso al sistema y qué operaciones (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) pueden realizar sobre cada tabla.

En SQL Server se organiza en tres pasos básicos:
1. **Login:** Es la cuenta (usuario y contraseña) para conectarse al servidor SQL Server.
2. **User (Usuario):** Es el perfil dentro de nuestra base de datos asociado a ese Login.
3. **Role (Rol):** Es un grupo que representa un puesto de trabajo (por ejemplo, "Vendedor"). Los permisos se le dan al rol y luego se mete a los usuarios dentro de ese rol.

**Objetivo:** Aplicar el **Principio de Mínimo Privilegio**, que significa darle a cada usuario únicamente los permisos mínimos e indispensables que necesita para hacer su trabajo diario.

---

## 2. Ventajas y Aplicaciones
* **Protección de datos:** Evita que cualquier empleado vea información que no corresponde a su área (por ejemplo, costos de proveedores).
* **Prevención de borrados accidentales:** Al prohibir el comando `DELETE` a los empleados operativos, nadie puede borrar ventas ni clientes por error.
* **Fácil administración:** Si entra un vendedor nuevo a la tienda, no hay que cargarle los permisos tabla por tabla; simplemente se lo agrega al rol de vendedores.

---

## 3. Implementación en SQL Server Express
Para configurar la seguridad en T-SQL se utilizan los siguientes comandos:
* `CREATE LOGIN`: Crea el acceso al servidor con contraseña.
* `CREATE USER`: Crea el usuario dentro de la base de datos del proyecto.
* `CREATE ROLE`: Crea el rol o perfil de trabajo.
* `ALTER ROLE ... ADD MEMBER`: Mete al usuario adentro del rol.
* `GRANT`: Otorga un permiso específico (por ejemplo, permitir leer o insertar).
* `DENY`: Prohíbe explícitamente una acción (por ejemplo, prohibir borrar).
* `REVOKE`: Quita un permiso que se había otorgado antes.

---

## 4. Caso Concreto Aplicado a Nexus Mobile
En el sistema de **Nexus Mobile** dividimos el trabajo en dos roles para que las áreas de la tienda no se pisen entre sí:

1. **Rol Vendedor (`rol_vendedor`):**
   * **Qué puede hacer (`GRANT`):** Consultar el catálogo (`PRODUCTO`), ver y registrar clientes (`CLIENTE`), y cargar nuevas ventas con su detalle (`VENTA` y `CONTIENE`).
   * **Qué tiene prohibido:** No puede borrar ventas (`DENY DELETE`) y no tiene permiso para ver ni tocar las tablas del taller (`EQUIPO` y `SERVICIO_TECNICO`).

2. **Rol Técnico (`rol_tecnico`):**
   * **Qué puede hacer (`GRANT`):** Consultar datos del cliente (`CLIENTE`), registrar equipos que ingresan al taller (`EQUIPO`) y cargar o actualizar arreglos (`SERVICIO_TECNICO`).
   * **Qué tiene prohibido:** No puede borrar órdenes de arreglo (`DENY DELETE`) y no tiene acceso a las ventas de la tienda (`VENTA` y `CONTIENE`).

---

## 5. Resultados Obtenidos en la Demostración
Para probar que la seguridad funciona sin cerrar sesión, se usa el comando `EXECUTE AS USER` (que simula ser ese empleado) y `REVERT` (para volver a ser administrador):

1. **Prueba con el Vendedor (`usr_vendedor`):**
   * Al hacer `SELECT * FROM PRODUCTO`, muestra la tabla normalmente porque tiene permiso.
   * Al intentar ver `SERVICIO_TECNICO` o hacer un `DELETE` en `VENTA`, SQL Server bloquea la acción y devuelve el error `Msg 229 (Permission was denied)`.
2. **Prueba con el Técnico (`usr_tecnico`):**
   * Al hacer un `UPDATE` en `SERVICIO_TECNICO` para actualizar el precio de un arreglo, modifica la fila sin problemas.
   * Al intentar hacer `SELECT * FROM VENTA`, el motor le niega el acceso.