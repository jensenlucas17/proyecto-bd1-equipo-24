# Restricciones de Integridad — Etapa 3

Este documento detalla las restricciones de integridad definidas en el script DDL
(`implementacion1.sql`) para cada tabla del modelo físico, agrupadas por tipo:
integridad de entidad (PK), integridad de dominio (NOT NULL, CHECK, tipos de
datos), integridad de unicidad (UNIQUE) e integridad referencial (FK).

---

## 1. LOCALIDAD

| Tipo | Restricción |
|---|---|
| Clave primaria | `CP` (código postal) — clave natural, no subrogada. |
| Dominio | `provincia` y `ciudad` obligatorios (`NOT NULL`). |

`LOCALIDAD` es la tabla base de la jerarquía de direcciones: no depende de ninguna
otra tabla, por lo que no tiene restricciones referenciales propias.

---

## 2. Direccion

| Tipo | Restricción |
|---|---|
| Clave primaria | `codigo_direccion` (subrogada, `IDENTITY`). |
| Dominio | `calle`, `altura` y `CP` obligatorios. |
| Chequeo | `CK_Direccion_Altura`: `altura >= 0`, evita valores negativos sin sentido físico. |
| Referencial | `FK_Direccion_Localidad` → `LOCALIDAD(CP)`. `ON DELETE NO ACTION` / `ON UPDATE CASCADE`. |

**Por qué `ON UPDATE CASCADE` en esta FK particular:** es la única excepción al
criterio general de `NO ACTION` en actualizaciones. Como `CP` es una clave natural
(no subrogada), existe la posibilidad de que un código postal se corrija o se
renumere administrativamente; en ese caso, la corrección debe propagarse
automáticamente a todas las direcciones que lo referencian, en vez de bloquear la
actualización o dejar direcciones con un CP inexistente.

---

## 3. CLIENTE

| Tipo | Restricción |
|---|---|
| Clave primaria | `dni_cliente` — clave natural. |
| Dominio | `nombre`, `apellido`, `telefono` y `codigo_direccion` obligatorios. |
| Referencial | `FK_Cliente_Direccion` → `Direccion(codigo_direccion)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |

**Por qué `NO ACTION` en el borrado:** no se debe poder eliminar una dirección
mientras exista un cliente que la esté usando, para no dejar clientes con una
referencia inválida ni perder trazabilidad de domicilios históricos.

---

## 4. EQUIPO

| Tipo | Restricción |
|---|---|
| Clave primaria | `id_equipo` (subrogada, `IDENTITY`). |
| Dominio | `nombre`, `descripcion` y `dni_cliente` obligatorios. |
| Referencial | `FK_Equipo_Cliente` → `CLIENTE(dni_cliente)`. `ON DELETE NO ACTION` / `ON UPDATE NO ACTION`. |

**Por qué `NO ACTION`:** un equipo no puede quedar "huérfano". Si se intentara
borrar un cliente que tiene equipos registrados, el borrado debe bloquearse, ya que
eliminar en cascada implicaría perder el historial de equipos y, por consiguiente,
de servicios técnicos asociados.
