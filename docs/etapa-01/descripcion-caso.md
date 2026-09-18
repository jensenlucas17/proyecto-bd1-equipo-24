# Descripción del Caso

## Proyecto: Nexus Mobile

**Grupo 24**
Integrantes: Fernández Casado, Guido Sebastián · González Thomas, Federico · Scher, Emily Giuliana · Romero Lencinas, Santiago Joaquín · Jensen, Lucas

**Materia:** Base de Datos I — UNNE 2026

---

## Contexto del negocio

Nexus Mobile es un comercio dedicado a la venta de teléfonos celulares y accesorios
tecnológicos, que además presta servicios técnicos de reparación y mantenimiento de
dispositivos móviles. El negocio opera bajo una **modalidad mixta**:

- **Canal físico:** una tienda presencial donde se atiende al público cara a cara, se
  exhiben productos y se realizan ventas directas.
- **Canal digital (e-commerce):** una plataforma online que permite la venta a nivel
  nacional, con despacho de productos a domicilio a través de un servicio de correo
  externo (Correo Argentino).

Esta dualidad de canales es el punto central que motiva el desarrollo del sistema: la
empresa necesita una única fuente de verdad para el stock, los clientes y las ventas,
sin importar si la operación se originó en el mostrador o en la web. Actualmente,
manejar dos canales sin un sistema centralizado genera riesgos como sobreventa de
stock, inconsistencia en precios y dificultad para hacer seguimiento de envíos y
reparaciones.

## Objetivo del proyecto

El objetivo general es diseñar y desarrollar un **sistema de información** que permita
la gestión integral del comercio, centralizando en una única base de datos la
información de:

- Productos (celulares y accesorios)
- Clientes
- Ventas y medios de pago
- Proveedores y órdenes de compra
- Operación de la tienda digital
- Envíos y logística de despacho
- Servicio técnico de reparación y mantenimiento

## Problemática que resuelve el sistema

Antes de contar con este sistema, el negocio enfrenta (o enfrentaría, de seguir
creciendo sin una herramienta centralizada) los siguientes problemas:

1. **Duplicación e inconsistencia de datos**: el mismo cliente o producto podría
   registrarse de forma distinta según el canal de venta.
2. **Sobreventa de stock**: al no compartir un stock centralizado entre el local físico
   y la tienda online, se corre el riesgo de vender un producto que ya no está
   disponible.
3. **Falta de trazabilidad en el servicio técnico**: sin un registro estructurado, es
   difícil saber en qué estado se encuentra cada equipo ingresado a reparación.
4. **Dificultad para controlar pagos a proveedores** y seguimiento de pedidos
   realizados para reposición de stock.
5. **Ausencia de historial de precios**: al no registrar el precio de venta vigente en
   el momento de la operación, se pierde trazabilidad contable si el precio de un
   producto cambia con el tiempo.

## Actores del sistema

| Actor | Descripción |
|---|---|
| Cliente | Persona que compra productos o solicita servicio técnico, ya sea por el local físico o por la tienda digital. |
| Vendedor / Empleado | Usuario interno que registra ventas, gestiona el ingreso de equipos a servicio técnico y actualiza el stock. |
| Proveedor | Empresa o distribuidor que abastece al comercio de productos y repuestos. |
| Correo Argentino | Actor externo encargado del transporte físico de los envíos generados por la tienda digital. No forma parte del sistema, pero el sistema debe registrar los datos necesarios para interactuar con este servicio (dirección, código de seguimiento). |

## Justificación del modelo de datos

Dado que el negocio combina venta de productos físicos, un canal digital y un área de
servicios (reparaciones), el modelo de datos necesita representar entidades bien
diferenciadas (cliente, producto, venta, proveedor, envío, servicio técnico) pero
fuertemente relacionadas entre sí, ya que una misma venta puede involucrar varios
productos, un mismo cliente puede tener múltiples ventas y también ingresar equipos
a reparación, y cada producto vendido debe conservar su precio histórico al momento
de la operación. Estas particularidades fueron el punto de partida para el
relevamiento de reglas de negocio y el posterior modelado conceptual (ver
`alcance.md`, `reglas-negocio.md` y `decisiones-diseno.md`).
