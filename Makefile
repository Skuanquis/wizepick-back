# ============================================
# WizePick - Comandos Docker Make
# ============================================

.DEFAULT_GOAL := help

# ============================================
# Variables
# ============================================
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_DEV = docker-compose -f docker-compose.dev.yml
BACKEND_CONTAINER = wizepick-backend
POSTGRES_CONTAINER = wizepick-postgres

# ============================================
# Help
# ============================================
.PHONY: help
help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ============================================
# Development
# ============================================
.PHONY: dev-up
dev-up: ## Iniciar entorno de desarrollo (solo DB)
	$(DOCKER_COMPOSE_DEV) up -d
	@echo "✅ Entorno de desarrollo iniciado"
	@echo "PostgreSQL: localhost:5432"
	@echo "pgAdmin: http://localhost:5050"
	@echo "Redis: localhost:6379"

.PHONY: dev-down
dev-down: ## Detener entorno de desarrollo
	$(DOCKER_COMPOSE_DEV) down
	@echo "✅ Entorno de desarrollo detenido"

.PHONY: dev-logs
dev-logs: ## Ver logs del entorno de desarrollo
	$(DOCKER_COMPOSE_DEV) logs -f

# ============================================
# Production
# ============================================
.PHONY: build
build: ## Construir imagen de producción
	$(DOCKER_COMPOSE) build
	@echo "✅ Imagen construida"

.PHONY: up
up: ## Iniciar aplicación en producción
	$(DOCKER_COMPOSE) up -d
	@echo "✅ Aplicación iniciada"
	@echo "Backend: http://localhost:3000"
	@echo "Swagger: http://localhost:3000/api/docs"

.PHONY: down
down: ## Detener aplicación
	$(DOCKER_COMPOSE) down
	@echo "✅ Aplicación detenida"

.PHONY: restart
restart: down up ## Reiniciar aplicación

.PHONY: logs
logs: ## Ver logs de la aplicación
	$(DOCKER_COMPOSE) logs -f backend

.PHONY: logs-all
logs-all: ## Ver todos los logs
	$(DOCKER_COMPOSE) logs -f

# ============================================
# Database
# ============================================
.PHONY: db-shell
db-shell: ## Conectar a PostgreSQL shell
	docker exec -it $(POSTGRES_CONTAINER) psql -U postgres -d wizepick_db

.PHONY: db-backup
db-backup: ## Crear backup de la base de datos
	@mkdir -p backups
	docker exec $(POSTGRES_CONTAINER) pg_dump -U postgres wizepick_db > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Backup creado en backups/"

.PHONY: db-restore
db-restore: ## Restaurar backup (usar: make db-restore FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "❌ Error: Especificar archivo con FILE=backup.sql"; \
		exit 1; \
	fi
	docker exec -i $(POSTGRES_CONTAINER) psql -U postgres wizepick_db < $(FILE)
	@echo "✅ Backup restaurado"

# ============================================
# Application
# ============================================
.PHONY: shell
shell: ## Acceder al shell del backend
	docker exec -it $(BACKEND_CONTAINER) sh

.PHONY: install
install: ## Instalar dependencias en el contenedor
	docker exec $(BACKEND_CONTAINER) npm install

.PHONY: migration-run
migration-run: ## Ejecutar migraciones
	docker exec $(BACKEND_CONTAINER) npm run migration:run

.PHONY: migration-revert
migration-revert: ## Revertir última migración
	docker exec $(BACKEND_CONTAINER) npm run migration:revert

.PHONY: seed
seed: ## Ejecutar seeds
	docker exec $(BACKEND_CONTAINER) npm run seed:permissions
	docker exec $(BACKEND_CONTAINER) npm run seed:roles
	docker exec $(BACKEND_CONTAINER) npm run seed:superadmin

# ============================================
# Cleanup
# ============================================
.PHONY: clean
clean: ## Limpiar contenedores y volúmenes
	$(DOCKER_COMPOSE) down -v
	@echo "✅ Contenedores y volúmenes eliminados"

.PHONY: clean-dev
clean-dev: ## Limpiar entorno de desarrollo
	$(DOCKER_COMPOSE_DEV) down -v
	@echo "✅ Entorno de desarrollo limpiado"

.PHONY: prune
prune: ## Limpiar imágenes y contenedores no usados
	docker system prune -af
	@echo "✅ Sistema Docker limpiado"

# ============================================
# Status
# ============================================
.PHONY: status
status: ## Ver estado de los contenedores
	$(DOCKER_COMPOSE) ps

.PHONY: health
health: ## Verificar salud de los servicios
	@echo "Verificando salud de servicios..."
	@docker ps --filter "name=wizepick" --format "table {{.Names}}\t{{.Status}}"
