# Alcance del Sistema

## Módulos funcionales incluidos

El sistema contempla la gestión integral de las siguientes áreas del negocio:

### 1. Gestión de productos
Registrar y administrar celulares y accesorios tecnológicos, incluyendo su
descripción, tipo, precio actual y stock disponible. El stock debe ser único y
centralizado, sin distinción entre lo que se vende por el local físico o por la
tienda digital, para evitar sobreventas.

### 2. Gestión de clientes
Registrar y administrar la información de los clientes, tanto de quienes compran en
el local físico como de quienes lo hacen a través de la tienda digital. Un mismo
cliente debe poder identificarse sin importar el canal por el que interactúa con el
comercio.

### 3. Gestión de ventas y pagos
Registrar las ventas realizadas, los productos vendidos, las cantidades, los precios
correspondientes al momento de la operación y los distintos métodos de pago
utilizados por los clientes (efectivo, tarjeta de débito/crédito, transferencia,
billeteras virtuales, etc.).

### 4. Gestión de proveedores
Registrar la información de las empresas o distribuidores que abastecen al comercio
con productos y repuestos, así como las órdenes de compra o pedidos realizados y el
control de los pagos efectuados a cada proveedor.

### 5. Gestión de la tienda digital
Administrar la plataforma de comercio electrónico: visualización del catálogo de
productos, actualización de precios online y correcto funcionamiento de las
transacciones realizadas por ese canal, garantizando que reflejen el mismo stock e
información que el canal físico.

### 6. Gestión de envíos
Registrar y administrar los datos logísticos necesarios (dirección de origen,
dirección de envío, código de seguimiento, estado del envío) para que los productos
vendidos de forma digital lleguen correctamente a destino a través de Correo
Argentino.

### 7. Gestión de servicio técnico
Registrar el ingreso de equipos para reparación o mantenimiento, la falla reportada,
el estado del proceso, el precio del arreglo y las fechas de ingreso y entrega, con
seguimiento hasta la devolución del equipo al cliente.

## Límites del sistema (fuera de alcance)

Es igual de importante delimitar qué **no** cubre el sistema, para evitar
ambigüedades en etapas posteriores de diseño:

- **Gestión logística interna de Correo Argentino**: el sistema no administra rutas,
  flotas ni operaciones internas del correo. Solo almacena los datos mínimos
  necesarios para el seguimiento del envío desde la perspectiva del comercio
  (dirección y código de seguimiento).
- **Gestión contable e impositiva completa**: el sistema registra los montos de venta
  y pago necesarios para la operación comercial, pero no reemplaza un sistema
  contable/impositivo (liquidación de impuestos, libros contables, balances, etc.).
- **Gestión de recursos humanos**: no se contempla legajos, liquidación de sueldos ni
  administración de personal más allá de lo necesario para vincular a un empleado con
  una venta o un servicio técnico, si correspondiera en etapas futuras.
- **Marketing y campañas publicitarias** de la tienda digital.
- **Pasarela de pago propia**: el sistema registra qué método de pago se usó, pero no
  implementa el procesamiento de pagos en sí (eso se asume delegado a un proveedor de
  pagos externo).

## Supuestos considerados

- Todo producto vendido, se venda por el canal que se venda, descuenta del mismo
  stock centralizado.
- Un cliente puede existir en el sistema sin haber realizado ninguna compra todavía
  (por ejemplo, si solo ingresó un equipo a servicio técnico).
- Los envíos solo aplican a ventas realizadas por el canal digital que requieran
  despacho a domicilio (RN08); una venta del local físico no genera un registro de
  envío.
- El precio de un producto puede variar en el tiempo, por lo que toda venta debe
  conservar el precio vigente al momento en que se concretó, independientemente de
  cambios futuros en el precio de lista del producto.

## Alcance temporal del proyecto

Este documento corresponde a la **Etapa 1** del proyecto integrador, centrada en el
relevamiento del caso de negocio, la definición del alcance y las reglas de negocio.
Las etapas siguientes (2 a 5) profundizan en el modelo relacional, la normalización,
la implementación física de la base de datos y las consultas SQL correspondientes.
