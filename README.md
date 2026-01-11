markdown# 🗄️ Card Management Database

Repositorio centralizado de migraciones y schema de base de datos para el **Sistema de Gestión de Tarjetas**.

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://www.postgresql.org/)
[![Flyway](https://img.shields.io/badge/Flyway-11.1.0-red.svg)](https://flywaydb.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-Proprietary-yellow.svg)]()

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Tecnologías](#-tecnologías)
- [Arquitectura](#-arquitectura)
- [Quick Start](#-quick-start)
- [Comandos Disponibles](#-comandos-disponibles)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Migraciones](#-migraciones)
- [Schema de Base de Datos](#-schema-de-base-de-datos)
- [Validación](#-validación)
- [Convenciones](#-convenciones)
- [Ambientes](#-ambientes)
- [Backup & Restore](#-backup--restore)
- [Troubleshooting](#-troubleshooting)
- [Contribuir](#-contribuir)

---

## 📖 Descripción

Este repositorio contiene:

- ✅ **Migraciones de base de datos** versionadas con Flyway
- ✅ **Schema completo** para el sistema de gestión de tarjetas
- ✅ **Docker Compose** para levantar entorno completo
- ✅ **Scripts de automatización** con Makefile
- ✅ **Documentación** de todas las tablas, índices, constraints y triggers

**Separación de responsabilidades:** Este repositorio maneja **SOLO** el schema de base de datos. La aplicación Java está en el repositorio `card-management-service`.

---

## 🚀 Tecnologías

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **PostgreSQL** | 16-alpine | Base de datos relacional |
| **Flyway** | 11.1.0 | Migraciones versionadas |
| **Docker** | 20.10+ | Containerización |
| **Docker Compose** | 2.0+ | Orquestación de servicios |
| **PgAdmin 4** | latest | Interfaz web de gestión |
| **Make** | 4.0+ | Automatización de tareas |

---

## 🏗️ Arquitectura

### **Módulos del Sistema**

```
┌─────────────────────────────────────────────────────┐
│       card-management-database (PostgreSQL)         │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │  Schema: public                             │    │
│  │                                             │    │
│  │  TABLES (6):                                │    │
│  │  ├── cards (V1)                             │    │
│  │  ├── card_audit (V1)                        │    │
│  │  ├── credit_limits (V2)                     │    │
│  │  ├── credit_limit_history (V2)              │    │
│  │  ├── state_transitions (V3)                 │    │
│  │  └── flyway_schema_history                  │    │
│  │                                             │    │
│  │  INDEXES (56):                              │    │
│  │  ├── B-Tree indexes (54)                    │    │
│  │  └── GIN full-text search (2)               │    │
│  │                                             │    │
│  │  FOREIGN KEYS (4):                          │    │
│  │  ├── card_audit → cards                     │    │
│  │  ├── credit_limits → cards                  │    │
│  │  ├── credit_limit_history → credit_limits   │    │
│  │  └── state_transitions → cards              │    │
│  │                                             │    │
│  │  TRIGGERS (6):                              │    │
│  │  ├── update_cards_updated_at                │    │
│  │  ├── update_credit_limits_updated_at        │    │
│  │  ├── calculate_available_credit             │    │
│  │  ├── reset_daily_limit                      │    │
│  │  ├── reset_monthly_limit                    │    │
│  │  └── validate_state_transition              │    │
│  │                                             │    │
│  │  ️ VIEWS (3):                                │    │
│  │  ├── v_card_lifecycle_summary               │    │
│  │  ├── v_recent_failed_transitions            │    │
│  │  └── v_event_statistics                     │    │
│  │                                             │    │
│  │  FUNCTIONS (8):                             │    │
│  │  ├── get_card_lifecycle_history()           │    │
│  │  ├── count_transitions_by_period()          │    │
│  │  └── ... (+ 6 trigger functions)            │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### **Relaciones entre Tablas**
```mermaiderDiagram
CARDS ||--o{ CARD_AUDIT : "audits"
CARDS ||--o| CREDIT_LIMITS : "has"
CREDIT_LIMITS ||--o{ CREDIT_LIMIT_HISTORY : "tracks"
CARDS ||--o{ STATE_TRANSITIONS : "transitions"CARDS {
    varchar id PK
    varchar client_id
    varchar status
    text card_number_encrypted
    text cvv_encrypted
    varchar pin_hash
}CREDIT_LIMITS {
    varchar id PK
    varchar card_id FK
    decimal purchase_limit_amount
    decimal available_credit_amount
}STATE_TRANSITIONS {
    bigint id PK
    varchar card_id FK
    varchar from_state
    varchar to_state
    varchar event
    boolean successful
}

---

## ⚡ Quick Start

### **Requisitos Previos**
```powershellVerificar instalaciones
docker --version          # Docker 20.10+
docker-compose --version  # Docker Compose 2.0+
make --version           # GNU Make 4.0+ (opcional, pero recomendado)

### **Instalación Rápida**
```powershell1. Clonar repositorio
git clone https://github.com/unisono/card-management-database.git
cd card-management-database2. Levantar servicios
docker-compose up -d postgres pgadmin3. Ejecutar migraciones
docker-compose up flyway4. Verificar
docker exec -it card-db-postgres psql -U postgres -d card_management_db -c "\dt"

### **Con Make (Recomendado)**
```powershellLevantar todo
make upEjecutar migraciones
make migrate-dockerVerificar
make psql
card_management_db=# \dt

---

## 🛠️ Comandos Disponibles

### **Docker**
```powershellmake up              # Levantar PostgreSQL + PgAdmin
make up-all          # Levantar todos los servicios (incluye monitoring)
make down            # Detener servicios (mantiene datos)
make down-volumes    # Detener y eliminar volúmenes ⚠️
make restart         # Reiniciar servicios
make logs            # Ver logs de todos los servicios
make logs-postgres   # Ver logs solo de PostgreSQL
make logs-flyway     # Ver logs de Flyway
make ps              # Ver estado de servicios

### **Flyway (Migraciones)**
```powershellmake migrate         # Ejecutar migraciones pendientes
make migrate-docker  # Ejecutar migraciones con Docker
make info            # Ver estado de migraciones
make validate        # Validar migraciones
make repair          # Reparar historial de Flyway
make clean           # Limpiar BD ⚠️ (BORRA TODO)

### **Base de Datos**
```powershellmake psql            # Conectar a PostgreSQL con psql
make psql-root       # Conectar como usuario postgres
make create-db       # Crear base de datos
make drop-db         # Eliminar base de datos ⚠️
make reset-db        # Drop + Create + Migrate
make health          # Verificar salud de PostgreSQL
make stats           # Ver estadísticas de tablas
make connections     # Ver conexiones activas

### **Backup & Restore**
```powershellmake backup          # Crear backup (.dump)
make backup-sql      # Crear backup (.sql)
make restore BACKUP_FILE=path  # Restaurar backup
make list-backups    # Listar backups disponibles

### **Seeds (Datos de Prueba)**
```powershellmake seed-dev        # Cargar datos de prueba (DEV)
make seed-staging    # Cargar datos de staging

### **Mantenimiento**
```powershellmake vacuum          # Ejecutar VACUUM ANALYZE
make analyze         # Actualizar estadísticas
make clean-logs      # Limpiar logs de Docker
make prune           # Limpiar recursos Docker no usados

### **Desarrollo**
```powershellmake new-migration name=description    # Crear nueva migración
make lint-migrations                   # Validar sintaxis SQL

---

## 📂 Estructura del Proyectocard-management-database/
├── README.md                    # Este archivo
├── docker-compose.yml           # Orquestación de servicios
├── Makefile                     # Comandos de automatización
├── .gitignore                   # Archivos ignorados por Git
├── .env.example                 # Variables de entorno (template)
│
├── migrations/                  # ⭐ Migraciones de Flyway
│   ├── V1__create_cards_tables.sql
│   ├── V2__create_credit_limits_tables.sql
│   └── V3__create_state_transitions_table.sql
│
├── seeds/                       # Datos de prueba
│   ├── dev/
│   │   ├── 001_test_cards.sql
│   │   └── 002_test_limits.sql
│   └── staging/
│       └── 001_staging_data.sql
│
├── scripts/                     # Scripts útiles
│   ├── create_database.sh
│   ├── backup.sh
│   └── restore.sh
│
├── docs/                        # Documentación
│   ├── schema_diagram.png
│   ├── migration_guide.md
│   └── rollback_guide.md
│
└── backups/                     # Backups de BD
└── .gitkeep

---

## 🗂️ Migraciones

### **Estructura de Migraciones**migrations/
├── V1__create_cards_tables.sql              (10 KB)
│   ├── TABLE: cards
│   ├── TABLE: card_audit
│   ├── FK: card_audit → cards
│   ├── 16 índices
│   └── 1 trigger
│
├── V2__create_credit_limits_tables.sql      (12 KB)
│   ├── TABLE: credit_limits
│   ├── TABLE: credit_limit_history
│   ├── FK: credit_limits → cards
│   ├── FK: credit_limit_history → credit_limits
│   ├── 16 índices
│   └── 4 triggers
│
└── V3__create_state_transitions_table.sql   (8 KB)
├── TABLE: state_transitions
├── FK: state_transitions → cards
├── 16 índices
├── 3 views
├── 2 functions
└── 1 trigger

### **Convención de Nomenclatura**V{version}__{description}.sql✅ Ejemplos correctos:
V1__create_cards_tables.sql
V2__create_credit_limits_tables.sql
V3__create_state_transitions_table.sql
V4__add_benefits_table.sql
V5__alter_cards_add_indexes.sql❌ Ejemplos incorrectos:
V1_create_cards.sql              (solo un guión bajo)
create_cards.sql                 (sin versión)
V1.1__create_cards.sql           (versión decimal)
V1__Create_Cards_Tables.sql      (mayúsculas inconsistentes)

### **Orden de Ejecución**

Flyway ejecuta las migraciones en orden numérico:V1 → V2 → V3 → V4 → ...

Una vez ejecutada, **NUNCA** modificar una migración. Si necesitas cambios, crea una nueva:
```sql-- ❌ NO HACER: Modificar V1__create_cards_tables.sql-- ✅ HACER: Crear nueva migración
V4__alter_cards_add_column_rewards.sql

---

## 📊 Schema de Base de Datos

### **Tablas (6)**

| Tabla | Propósito | Módulo | Registros (estimado) |
|-------|-----------|--------|----------------------|
| `cards` | Tarjetas de crédito/débito | card-data | Alto (millones) |
| `card_audit` | Auditoría de cambios | card-data | Muy Alto |
| `credit_limits` | Límites de crédito | card-limits | Alto (1:1 con cards) |
| `credit_limit_history` | Historial de límites | card-limits | Alto |
| `state_transitions` | Transiciones de estado | card-lifecycle | Muy Alto |
| `flyway_schema_history` | Control de migraciones | Flyway | Bajo |

### **Índices (56)**

**Desglose por tabla:**

| Tabla | Índices | Detalles |
|-------|---------|----------|
| `cards` | 16 | B-Tree (15) + GIN full-text (1) |
| `state_transitions` | 16 | B-Tree (15) + GIN full-text (1) |
| `credit_limit_history` | 9 | B-Tree (9), incluye UNIQUE |
| `credit_limits` | 7 | B-Tree (7), incluye UNIQUE |
| `card_audit` | 4 | B-Tree (4) |
| `flyway_schema_history` | 2 | B-Tree (2) |
| **PKs** | 2 | Automáticos |

**Tipos de índices:**

- **B-Tree (54):** Índices estándar para búsquedas rápidas
- **GIN (2):** Full-text search en `cards.holder_*` y `state_transitions.error_message`

**Índices parciales (con WHERE):**
```sql-- Solo tarjetas activas
CREATE INDEX idx_cards_active
ON cards(client_id, created_at DESC)
WHERE status = 'ACTIVE' AND deleted = FALSE;-- Solo tarjetas bloqueadas
CREATE INDEX idx_cards_blocked
ON cards(blocked_at DESC)
WHERE status IN ('BLOCKED', 'BLOCKED_FRAUD') AND deleted = FALSE;-- Solo transiciones exitosas
CREATE INDEX idx_state_transition_successful_only
ON state_transitions(card_id, to_state, transitioned_at DESC)
WHERE successful = TRUE;

### **Foreign Keys (4)**
```sql-- card_audit → cards
ALTER TABLE card_audit
ADD CONSTRAINT fk_audit_card
FOREIGN KEY (card_id) REFERENCES cards(id)
ON DELETE CASCADE;-- credit_limits → cards
ALTER TABLE credit_limits
ADD CONSTRAINT fk_credit_limit_card
FOREIGN KEY (card_id) REFERENCES cards(id)
ON DELETE CASCADE;-- credit_limit_history → credit_limits
ALTER TABLE credit_limit_history
ADD CONSTRAINT fk_history_credit_limit
FOREIGN KEY (credit_limit_id) REFERENCES credit_limits(id)
ON DELETE CASCADE;-- state_transitions → cards
ALTER TABLE state_transitions
ADD CONSTRAINT fk_state_transition_card
FOREIGN KEY (card_id) REFERENCES cards(id)
ON DELETE CASCADE;

### **Triggers (6)**

| Trigger | Tabla | Función | Propósito |
|---------|-------|---------|-----------|
| `trigger_update_cards_updated_at` | cards | BEFORE UPDATE | Auto-actualizar `updated_at` |
| `trigger_update_credit_limits_updated_at` | credit_limits | BEFORE UPDATE | Auto-actualizar `updated_at` |
| `trigger_calculate_available_credit` | credit_limits | BEFORE INSERT/UPDATE | Calcular crédito disponible |
| `trigger_reset_daily_limit` | credit_limits | BEFORE UPDATE | Resetear límite diario |
| `trigger_reset_monthly_limit` | credit_limits | BEFORE UPDATE | Resetear límite mensual |
| `trigger_validate_state_transition` | state_transitions | BEFORE INSERT | Validar transición lógica |

### **Views (3)**
```sql-- Resumen del ciclo de vida por tarjeta
v_card_lifecycle_summary-- Transiciones fallidas recientes (últimos 30 días)
v_recent_failed_transitions-- Estadísticas de eventos
v_event_statistics

### **Functions (8)**
```sql-- Trigger functions (6)
update_cards_updated_at()
update_credit_limits_updated_at()
calculate_available_credit()
reset_daily_limit()
reset_monthly_limit()
validate_state_transition()-- Utility functions (2)
get_card_lifecycle_history(p_card_id VARCHAR)
count_transitions_by_period(p_start_date TIMESTAMP, p_end_date TIMESTAMP)

---

## ✅ Validación

### **Comandos de Validación**

#### **1. Ver todas las tablas**
```powershelldocker exec -it card-db-postgres psql -U postgres -d card_management_db -c "\dt"

**Output esperado:** 6 tablas

#### **2. Ver todos los índices**
```powershelldocker exec -it card-db-postgres psql -U postgres -d card_management_db -c "\di"

**Output esperado:** 56 índices

#### **3. Ver Foreign Keys**
```powershelldocker exec -it card-db-postgres psql -U postgres -d card_management_db -c "
SELECT
tc.table_name,
kcu.column_name,
ccu.table_name AS foreign_table_name,
tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;
"

**Output esperado:** 4 Foreign Keys

#### **4. Ver Triggers**
```powershelldocker exec -it card-db-postgres psql -U postgres -d card_management_db -c "
SELECT
trigger_name,
event_object_table AS table_name
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table;
"

**Output esperado:** 6 triggers

#### **5. Ver historial de Flyway**
```powershelldocker exec -it card-db-postgres psql -U postgres -d card_management_db -c "
SELECT version, description, success, installed_on
FROM flyway_schema_history
ORDER BY installed_rank;
"

**Output esperado:**version |          description           | success |     installed_on
---------+--------------------------------+---------+-----------------------
0       | << Flyway Baseline >>          | t       | 2025-12-28 14:50:00
1       | create cards tables            | t       | 2025-12-28 14:50:01
2       | create credit limits tables    | t       | 2025-12-28 14:50:01
3       | create state transitions table | t       | 2025-12-28 14:50:01

#### **6. Resumen completo de objetos**
```powershelldocker exec -it card-db-postgres psql -U postgres -d card_management_db -c "
SELECT
'Tables' AS object_type, COUNT()
FROM information_schema.tables WHERE table_schema = 'public'
UNION ALL
SELECT 'Indexes', COUNT()
FROM pg_indexes WHERE schemaname = 'public'
UNION ALL
SELECT 'Foreign Keys', COUNT()
FROM information_schema.table_constraints
WHERE constraint_schema = 'public' AND constraint_type = 'FOREIGN KEY'
UNION ALL
SELECT 'Triggers', COUNT()
FROM information_schema.triggers WHERE trigger_schema = 'public'
UNION ALL
SELECT 'Views', COUNT()
FROM information_schema.views WHERE table_schema = 'public'
UNION ALL
SELECT 'Functions', COUNT()
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public';
"

**Output esperado:**object_type  | count
--------------+-------
Tables       |     6
Indexes      |    56
Foreign Keys |     4
Triggers     |     6
Views        |     3
Functions    |     8

### **Checklist de Validación**

- [ ] 6 tablas creadas
- [ ] 56 índices funcionando
- [ ] 4 Foreign Keys activas
- [ ] 6 triggers configurados
- [ ] 3 views disponibles
- [ ] 8 functions creadas
- [ ] 3 migraciones exitosas (V1, V2, V3)
- [ ] Flyway baseline aplicado
- [ ] PostgreSQL 16 corriendo
- [ ] PgAdmin accesible en http://localhost:5050

---

## 📐 Convenciones

### **SQL**
```sql-- ✅ BUENAS PRÁCTICAS-- 1. Comentarios en español (para este proyecto)
COMMENT ON TABLE cards IS 'Tarjetas de crédito y débito';-- 2. NOT NULL explícito
CREATE TABLE cards (
id VARCHAR(36) NOT NULL,
status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED'
);-- 3. Constraints con nombre descriptivo
CONSTRAINT chk_card_status CHECK (status IN ('ACTIVE', 'BLOCKED'));-- 4. Índices con prefijo idx_
CREATE INDEX idx_cards_client_status ON cards(client_id, status);-- 5. Foreign Keys con ON DELETE/UPDATE
FOREIGN KEY (card_id) REFERENCES cards(id)
ON DELETE CASCADE
ON UPDATE CASCADE;-- 6. Usar IF NOT EXISTS / IF EXISTS
CREATE TABLE IF NOT EXISTS cards (...);
DROP TABLE IF EXISTS old_table CASCADE;-- 7. Triggers con prefijo trigger_
CREATE TRIGGER trigger_update_cards_updated_at ...-- 8. Functions con snake_case
CREATE FUNCTION update_cards_updated_at() ...-- 9. Views con prefijo v_
CREATE VIEW v_card_lifecycle_summary AS ...

### **Migraciones**

1. **Nunca modificar migraciones ejecutadas**
   - Si una migración ya está aplicada, crear una nueva con `ALTER`

2. **Nombres descriptivos**
   - ✅ `V4__add_card_benefits_table.sql`
   - ❌ `V4__changes.sql`

3. **Idempotencia**
   - Usar `IF NOT EXISTS` / `IF EXISTS`
   - Permitir re-ejecución sin errores

4. **Rollback manual**
   - Flyway NO soporta rollback automático
   - Documentar rollbacks en `docs/rollback_guide.md`

5. **Testing local**
   - Probar con `make migrate` antes de commit
   - Validar con `make validate`

6. **Evitar funciones no-inmutables en índices**
   - ❌ `WHERE transitioned_at > CURRENT_TIMESTAMP - INTERVAL '7 days'`
   - ✅ `WHERE successful = FALSE` (mover lógica de fecha a queries)

---

## 🌍 Ambientes

| Ambiente | Base de Datos | Host | Puerto | Usuario |
|----------|---------------|------|--------|---------|
| **Development** | card_management_db | localhost | 5432 | postgres |
| **Staging** | card_management_staging_db | TBD | 5432 | TBD |
| **Production** | card_management_prod_db | TBD | 5432 | TBD |

### **Variables de Entorno**

Crear archivo `.env`:
```bashDatabase
DB_NAME=card_management_db
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432PgAdmin
PGADMIN_EMAIL=admin@unisono.com
PGADMIN_PASSWORD=admin

---

## 💾 Backup & Restore

### **Crear Backup**
```powershellBackup en formato custom (.dump) - RECOMENDADO
make backupBackup en formato SQL (.sql)
make backup-sqlSe guardará en: backups/backup_YYYYMMDD_HHMMSS.dump

### **Restaurar Backup**
```powershellListar backups disponibles
make list-backupsRestaurar
make restore BACKUP_FILE=backups/backup_20251228_150000.dump

### **Backup Automático con Cron**
```bashEditar crontab
crontab -eAgregar línea (backup diario a las 2 AM)
0 2 * * * cd /path/to/card-management-database && make backup

### **Backup a S3 (AWS)**
```bashInstalar AWS CLI
Configurar credenciales: aws configureCrear backup y subir a S3
make backup
aws s3 cp backups/backup_$(date +%Y%m%d_%H%M%S).dump 
s3://mi-bucket/card-db-backups/

---

## 🔧 Troubleshooting

### **Problema: "Port 5432 already in use"**
```powershellVer qué está usando el puerto
netstat -an | findstr 5432Opción A: Detener PostgreSQL local
Windows: Servicios → PostgreSQL → DetenerOpción B: Cambiar puerto en docker-compose.yml
ports:

"5433:5432"  # Usar 5433 externamente


---

### **Problema: "Flyway migration failed"**
```powershell1. Ver logs detallados
docker logs card-db-flyway2. Verificar estado
make info3. Reparar si es necesario
make repair4. Si falla una migración específica
docker exec -it card-db-postgres psql -U postgres -d card_management_db
DELETE FROM flyway_schema_history WHERE version = 'X';
\q5. Volver a ejecutar
make migrate-docker

---

### **Problema: "Cannot connect to database"**
```powershell1. Verificar que PostgreSQL esté corriendo
docker ps | findstr card-db-postgres2. Ver logs
docker logs card-db-postgres3. Verificar health check
docker inspect card-db-postgres | findstr Health4. Reiniciar servicios
make restart

---

### **Problema: "Out of disk space"**
```powershell1. Ver uso de volúmenes
docker system df -v2. Limpiar recursos no usados
make prune3. Eliminar volúmenes antiguos
docker volume prune

---

### **Problema: "ERROR: functions in index predicate must be marked IMMUTABLE"**

Este error ocurre cuando se usan funciones como `CURRENT_DATE`, `CURRENT_TIMESTAMP`, o `EXTRACT()` en predicados `WHERE` de índices.

**Solución:**
```sql-- ❌ INCORRECTO
CREATE INDEX idx_example
ON table(column)
WHERE date_column > CURRENT_DATE - INTERVAL '7 days';-- ✅ CORRECTO
CREATE INDEX idx_example
ON table(column, date_column);
-- Mover la lógica de fecha a la query, no al índice

---

### **Problema: "constraint already exists"**

Ocurre cuando se intenta re-ejecutar una migración que ya creó constraints.

**Solución:**
```powershellResetear schema completo
docker exec -it card-db-postgres psql -U postgres -d card_management_db 
-c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"Ejecutar migraciones desde cero
make migrate-docker

---

## 🤝 Contribuir

### **Crear Nueva Migración**
```powershell1. Crear archivo de migración
make new-migration name=add_card_benefits_table2. Editar el archivo generado
migrations/V4__add_card_benefits_table.sql3. Probar localmente
make migrate4. Validar
make validate5. Commit
git add migrations/V4__add_card_benefits_table.sql
git commit -m "feat: add card benefits table"
git push

### **Workflow de Contribución**

1. Crear branch: `git checkout -b feature/nueva-funcionalidad`
2. Crear migración: `make new-migration name=descripcion`
3. Probar: `make reset-db && make migrate`
4. Validar: `make validate`
5. Commit: `git commit -m "feat: descripción"`
6. Push: `git push origin feature/nueva-funcionalidad`
7. Crear Pull Request

### **Convenciones de Commits**feat: Nueva funcionalidad
fix: Corrección de bug
docs: Cambios en documentación
refactor: Refactorización sin cambios funcionales
perf: Mejoras de performance
test: Agregar o modificar tests
chore: Cambios en build, CI, etc.

---

## 📞 Soporte

- **Email:** database@unisono.com
- **Slack:** #card-database
- **Docs:** https://docs.unisono.com/database
- **Issues:** https://github.com/unisono/card-management-database/issues

---

## 📊 Estadísticas del Proyecto📦 Tamaño del repositorio: ~2 MB
📄 Migraciones: 3 archivos SQL
🗄️ Tablas: 6
🔑 Índices: 56
🔗 Foreign Keys: 4
⚡ Triggers: 6
👁️ Views: 3
🔧 Functions: 8
📝 Líneas de SQL: ~1,200

---

## 📄 Licencia

Propietario - Unisono © 2025

**Confidencial:** Este código es propiedad de Unisono y no puede ser distribuido sin autorización.

---

## 🎯 Roadmap

### **Q1 2025**
- [x] Schema inicial (V1, V2, V3)
- [ ] Datos de prueba (seeds)
- [ ] CI/CD pipeline
- [ ] Monitoring con Prometheus

### **Q2 2025**
- [ ] Particionamiento de tablas grandes
- [ ] Replicación read-replica
- [ ] Backup automático a S3

### **Q3 2025**
- [ ] Migration a PostgreSQL 17
- [ ] Performance tuning
- [ ] Auditoría completa

---

## 📚 Recursos Adicionales

- [PostgreSQL 16 Documentation](https://www.postgresql.org/docs/16/)
- [Flyway Documentation](https://flywaydb.org/documentation/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [SQL Style Guide](https://www.sqlstyle.guide/)

---

**Última actualización:** 2025-12-28  
**Versión:** 1.0.0  
**Mantenedor:** Database Team - Unisono  
**Contributors:** Juan Pérez (Backend Lead)

---

## ⭐ Quick Links

- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Comandos Disponibles](#-comandos-disponibles)
- [Schema de Base de Datos](#-schema-de-base-de-datos)
- [Troubleshooting](#-troubleshooting)

---

<div align="center">
  <strong>🚀 Card Management Database - Built with ❤️ by Unisono</strong>
</div>
