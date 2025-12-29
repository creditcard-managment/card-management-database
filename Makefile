# =============================================
# Card Management Database - Makefile
# Version: 1.0.0
# Description: Comandos útiles para gestión de BD
# =============================================

# Variables
DB_NAME := card_management_db
DB_USER := postgres
DB_PASSWORD := postgres
DB_HOST := localhost
DB_PORT := 5432
DB_URL := jdbc:postgresql://$(DB_HOST):$(DB_PORT)/$(DB_NAME)

# Docker
COMPOSE := docker-compose
COMPOSE_FILE := docker-compose.yml

# Flyway
FLYWAY := flyway
FLYWAY_LOCATIONS := filesystem:./migrations

# Colors para output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# =============================================
# DEFAULT TARGET
# =============================================

.DEFAULT_GOAL := help

# =============================================
# HELP
# =============================================

.PHONY: help
help: ## Muestra este mensaje de ayuda
	@echo "$(GREEN)Card Management Database - Comandos Disponibles$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""

# =============================================
# DOCKER COMMANDS
# =============================================

.PHONY: up
up: ## Levantar PostgreSQL y PgAdmin
	@echo "$(GREEN)Levantando servicios...$(NC)"
	$(COMPOSE) up -d postgres pgadmin
	@echo "$(GREEN)✅ Servicios levantados$(NC)"
	@echo "PostgreSQL: $(DB_HOST):$(DB_PORT)"
	@echo "PgAdmin: http://localhost:5050"

.PHONY: up-all
up-all: ## Levantar todos los servicios (incluye monitoring)
	@echo "$(GREEN)Levantando todos los servicios...$(NC)"
	$(COMPOSE) --profile monitoring up -d
	@echo "$(GREEN)✅ Todos los servicios levantados$(NC)"

.PHONY: down
down: ## Detener servicios (mantiene datos)
	@echo "$(YELLOW)Deteniendo servicios...$(NC)"
	$(COMPOSE) down
	@echo "$(GREEN)✅ Servicios detenidos$(NC)"

.PHONY: down-volumes
down-volumes: ## Detener servicios y eliminar volúmenes (⚠️  BORRA DATOS)
	@echo "$(RED)⚠️  CUIDADO: Esto eliminará TODOS los datos$(NC)"
	@read -p "¿Estás seguro? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(COMPOSE) down -v; \
		echo "$(GREEN)✅ Servicios y volúmenes eliminados$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada$(NC)"; \
	fi

.PHONY: restart
restart: ## Reiniciar servicios
	@echo "$(YELLOW)Reiniciando servicios...$(NC)"
	$(COMPOSE) restart
	@echo "$(GREEN)✅ Servicios reiniciados$(NC)"

.PHONY: logs
logs: ## Ver logs de todos los servicios
	$(COMPOSE) logs -f

.PHONY: logs-postgres
logs-postgres: ## Ver logs de PostgreSQL
	$(COMPOSE) logs -f postgres

.PHONY: logs-flyway
logs-flyway: ## Ver logs de Flyway
	$(COMPOSE) logs flyway

.PHONY: ps
ps: ## Ver estado de los servicios
	$(COMPOSE) ps

# =============================================
# FLYWAY COMMANDS
# =============================================

.PHONY: migrate
migrate: ## Ejecutar migraciones pendientes
	@echo "$(GREEN)Ejecutando migraciones...$(NC)"
	@if command -v $(FLYWAY) > /dev/null; then \
		$(FLYWAY) -url=$(DB_URL) -user=$(DB_USER) -password=$(DB_PASSWORD) \
			-locations=$(FLYWAY_LOCATIONS) migrate; \
	else \
		$(COMPOSE) up flyway; \
	fi
	@echo "$(GREEN)✅ Migraciones completadas$(NC)"

.PHONY: migrate-docker
migrate-docker: ## Ejecutar migraciones usando Docker
	@echo "$(GREEN)Ejecutando migraciones con Docker...$(NC)"
	$(COMPOSE) up flyway
	@echo "$(GREEN)✅ Migraciones completadas$(NC)"

.PHONY: info
info: ## Ver estado de las migraciones
	@echo "$(GREEN)Estado de migraciones:$(NC)"
	@if command -v $(FLYWAY) > /dev/null; then \
		$(FLYWAY) -url=$(DB_URL) -user=$(DB_USER) -password=$(DB_PASSWORD) \
			-locations=$(FLYWAY_LOCATIONS) info; \
	else \
		docker run --rm --network card-network \
			-v $(PWD)/migrations:/flyway/sql:ro \
			flyway/flyway:11.1.0-alpine \
			-url=jdbc:postgresql://postgres:5432/$(DB_NAME) \
			-user=$(DB_USER) -password=$(DB_PASSWORD) info; \
	fi

.PHONY: validate
validate: ## Validar migraciones
	@echo "$(GREEN)Validando migraciones...$(NC)"
	@if command -v $(FLYWAY) > /dev/null; then \
		$(FLYWAY) -url=$(DB_URL) -user=$(DB_USER) -password=$(DB_PASSWORD) \
			-locations=$(FLYWAY_LOCATIONS) validate; \
	else \
		docker run --rm --network card-network \
			-v $(PWD)/migrations:/flyway/sql:ro \
			flyway/flyway:11.1.0-alpine \
			-url=jdbc:postgresql://postgres:5432/$(DB_NAME) \
			-user=$(DB_USER) -password=$(DB_PASSWORD) validate; \
	fi
	@echo "$(GREEN)✅ Validación exitosa$(NC)"

.PHONY: repair
repair: ## Reparar tabla de historial de Flyway
	@echo "$(YELLOW)Reparando historial de Flyway...$(NC)"
	@if command -v $(FLYWAY) > /dev/null; then \
		$(FLYWAY) -url=$(DB_URL) -user=$(DB_USER) -password=$(DB_PASSWORD) \
			-locations=$(FLYWAY_LOCATIONS) repair; \
	else \
		docker run --rm --network card-network \
			flyway/flyway:11.1.0-alpine \
			-url=jdbc:postgresql://postgres:5432/$(DB_NAME) \
			-user=$(DB_USER) -password=$(DB_PASSWORD) repair; \
	fi
	@echo "$(GREEN)✅ Reparación completada$(NC)"

.PHONY: clean
clean: ## Limpiar base de datos (⚠️  BORRA TODO)
	@echo "$(RED)⚠️  CUIDADO: Esto eliminará TODAS las tablas$(NC)"
	@read -p "¿Estás seguro? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		if command -v $(FLYWAY) > /dev/null; then \
			$(FLYWAY) -url=$(DB_URL) -user=$(DB_USER) -password=$(DB_PASSWORD) clean; \
		else \
			docker run --rm --network card-network \
				flyway/flyway:11.1.0-alpine \
				-url=jdbc:postgresql://postgres:5432/$(DB_NAME) \
				-user=$(DB_USER) -password=$(DB_PASSWORD) clean; \
		fi; \
		echo "$(GREEN)✅ Base de datos limpiada$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada$(NC)"; \
	fi

# =============================================
# DATABASE COMMANDS
# =============================================

.PHONY: psql
psql: ## Conectar a PostgreSQL con psql
	@echo "$(GREEN)Conectando a PostgreSQL...$(NC)"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME)

.PHONY: psql-root
psql-root: ## Conectar como usuario postgres
	@echo "$(GREEN)Conectando a PostgreSQL como root...$(NC)"
	@docker exec -it card-db-postgres psql -U postgres

.PHONY: create-db
create-db: ## Crear base de datos
	@echo "$(GREEN)Creando base de datos...$(NC)"
	@docker exec -it card-db-postgres psql -U postgres -c "CREATE DATABASE $(DB_NAME);"
	@echo "$(GREEN)✅ Base de datos creada$(NC)"

.PHONY: drop-db
drop-db: ## Eliminar base de datos (⚠️  BORRA TODO)
	@echo "$(RED)⚠️  CUIDADO: Esto eliminará la base de datos completa$(NC)"
	@read -p "¿Estás seguro? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker exec -it card-db-postgres psql -U postgres -c "DROP DATABASE IF EXISTS $(DB_NAME);"; \
		echo "$(GREEN)✅ Base de datos eliminada$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada$(NC)"; \
	fi

.PHONY: reset-db
reset-db: drop-db create-db migrate ## Resetear BD (drop + create + migrate)
	@echo "$(GREEN)✅ Base de datos reseteada completamente$(NC)"

# =============================================
# BACKUP & RESTORE
# =============================================

.PHONY: backup
backup: ## Crear backup de la BD
	@echo "$(GREEN)Creando backup...$(NC)"
	@mkdir -p backups
	@docker exec card-db-postgres pg_dump -U $(DB_USER) -d $(DB_NAME) \
		-F c -f /tmp/backup.dump
	@docker cp card-db-postgres:/tmp/backup.dump \
		backups/backup_$(shell date +%Y%m%d_%H%M%S).dump
	@docker exec card-db-postgres rm /tmp/backup.dump
	@echo "$(GREEN)✅ Backup creado en backups/$(NC)"

.PHONY: backup-sql
backup-sql: ## Crear backup en formato SQL
	@echo "$(GREEN)Creando backup SQL...$(NC)"
	@mkdir -p backups
	@docker exec card-db-postgres pg_dump -U $(DB_USER) -d $(DB_NAME) \
		> backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✅ Backup SQL creado en backups/$(NC)"

.PHONY: restore
restore: ## Restaurar backup (requiere BACKUP_FILE=path)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "$(RED)Error: Especifica BACKUP_FILE=path$(NC)"; \
		echo "Ejemplo: make restore BACKUP_FILE=backups/backup_20250101_120000.dump"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Restaurando backup: $(BACKUP_FILE)$(NC)"
	@docker cp $(BACKUP_FILE) card-db-postgres:/tmp/restore.dump
	@docker exec card-db-postgres pg_restore -U $(DB_USER) -d $(DB_NAME) \
		-c /tmp/restore.dump
	@docker exec card-db-postgres rm /tmp/restore.dump
	@echo "$(GREEN)✅ Backup restaurado$(NC)"

.PHONY: list-backups
list-backups: ## Listar backups disponibles
	@echo "$(GREEN)Backups disponibles:$(NC)"
	@ls -lh backups/ 2>/dev/null || echo "No hay backups"

# =============================================
# SEEDS (datos de prueba)
# =============================================

.PHONY: seed-dev
seed-dev: ## Cargar datos de prueba (DEV)
	@echo "$(GREEN)Cargando datos de prueba...$(NC)"
	@docker exec -i card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) < seeds/dev/001_test_cards.sql
	@docker exec -i card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) < seeds/dev/002_test_credit_limits.sql
	@docker exec -i card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) < seeds/dev/003_test_state_transitions.sql
	@echo "$(GREEN)✅ Datos de prueba cargados$(NC)"

.PHONY: seed-staging
seed-staging: ## Cargar datos de staging
	@echo "$(GREEN)Cargando datos de staging...$(NC)"
	@docker exec -i card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) < seeds/staging/001_staging_data.sql || echo "$(YELLOW)No hay datos de staging$(NC)"
	@echo "$(GREEN)✅ Datos de staging cargados$(NC)"

.PHONY: clean-seeds
clean-seeds: ## Limpiar datos de seeds (mantiene schema)
	@echo "$(YELLOW)Limpiando datos de prueba...$(NC)"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "TRUNCATE TABLE state_transitions CASCADE;"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "TRUNCATE TABLE credit_limit_history CASCADE;"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "TRUNCATE TABLE credit_limits CASCADE;"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "TRUNCATE TABLE card_audit CASCADE;"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "TRUNCATE TABLE cards CASCADE;"
	@echo "$(GREEN)✅ Datos de prueba eliminados$(NC)"


# =============================================
# MONITORING & HEALTH
# =============================================

.PHONY: health
health: ## Verificar salud de PostgreSQL
	@echo "$(GREEN)Verificando salud de PostgreSQL...$(NC)"
	@docker exec card-db-postgres pg_isready -U $(DB_USER) -d $(DB_NAME)

.PHONY: stats
stats: ## Ver estadísticas de la BD
	@echo "$(GREEN)Estadísticas de la base de datos:$(NC)"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "\
		SELECT \
			schemaname, \
			tablename, \
			pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size, \
			n_tup_ins AS inserts, \
			n_tup_upd AS updates, \
			n_tup_del AS deletes \
		FROM pg_stat_user_tables \
		ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"

.PHONY: connections
connections: ## Ver conexiones activas
	@echo "$(GREEN)Conexiones activas:$(NC)"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "\
		SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;"

# =============================================
# MAINTENANCE
# =============================================

.PHONY: vacuum
vacuum: ## Ejecutar VACUUM en todas las tablas
	@echo "$(GREEN)Ejecutando VACUUM...$(NC)"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "VACUUM ANALYZE;"
	@echo "$(GREEN)✅ VACUUM completado$(NC)"

.PHONY: analyze
analyze: ## Actualizar estadísticas del query planner
	@echo "$(GREEN)Actualizando estadísticas...$(NC)"
	@docker exec -it card-db-postgres psql -U $(DB_USER) -d $(DB_NAME) -c "ANALYZE;"
	@echo "$(GREEN)✅ Estadísticas actualizadas$(NC)"

# =============================================
# DEVELOPMENT
# =============================================

.PHONY: new-migration
new-migration: ## Crear nueva migración (name=description)
	@if [ -z "$(name)" ]; then \
		echo "$(RED)Error: Especifica name=description$(NC)"; \
		echo "Ejemplo: make new-migration name=add_benefits_table"; \
		exit 1; \
	fi
	@NEXT_VERSION=$$(ls migrations/*.sql | sed 's/.*V\([0-9]*\)__.*/\1/' | sort -n | tail -1 | awk '{print $$1+1}'); \
	FILENAME="migrations/V$${NEXT_VERSION}__$(name).sql"; \
	echo "-- =============================================" > $$FILENAME; \
	echo "-- Migration: V$${NEXT_VERSION}" >> $$FILENAME; \
	echo "-- Date: $$(date +%Y-%m-%d)" >> $$FILENAME; \
	echo "-- Description: $(name)" >> $$FILENAME; \
	echo "-- =============================================" >> $$FILENAME; \
	echo "" >> $$FILENAME; \
	echo "-- TODO: Add your SQL here" >> $$FILENAME; \
	echo "" >> $$FILENAME; \
	echo "$(GREEN)✅ Migración creada: $$FILENAME$(NC)"

.PHONY: lint-migrations
lint-migrations: ## Validar sintaxis de migraciones
	@echo "$(GREEN)Validando sintaxis de migraciones...$(NC)"
	@for file in migrations/*.sql; do \
		echo "Validando $$file..."; \
		docker exec -i card-db-postgres psql -U $(DB_USER) -d postgres \
			--single-transaction --set ON_ERROR_STOP=on --dry-run < $$file > /dev/null 2>&1 \
			&& echo "  $(GREEN)✓$(NC) $$file" \
			|| echo "  $(RED)✗$(NC) $$file"; \
	done

# =============================================
# CLEANUP
# =============================================

.PHONY: clean-logs
clean-logs: ## Limpiar logs de Docker
	@echo "$(YELLOW)Limpiando logs...$(NC)"
	$(COMPOSE) logs --no-log-prefix > /dev/null 2>&1 || true
	@echo "$(GREEN)✅ Logs limpiados$(NC)"

.PHONY: prune
prune: ## Limpiar recursos Docker no utilizados
	@echo "$(YELLOW)Limpiando recursos Docker...$(NC)"
	docker system prune -f
	@echo "$(GREEN)✅ Limpieza completada$(NC)"
