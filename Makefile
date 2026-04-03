# Makefile for Military Attendance System
# Convenient shortcuts for common Docker operations
# 
# Usage: make [target]
# Example: make up, make logs, make backup

.PHONY: help install build up down restart logs shell-api shell-db clean health deploy backup

DOCKER_COMPOSE := docker-compose
INSTALL_DIR ?= .
COMPOSE_FILE := $(INSTALL_DIR)/docker-compose.yml

help:
	@echo "Military Attendance System - Makefile"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make install           - Run automated installer"
	@echo "  make build             - Build Docker images"
	@echo ""
	@echo "Service Management:"
	@echo "  make up                - Start all services"
	@echo "  make down              - Stop all services"
	@echo "  make restart           - Restart all services"
	@echo "  make restart-api       - Restart API service"
	@echo "  make restart-web       - Restart Web service"
	@echo ""
	@echo "Monitoring:"
	@echo "  make logs              - View logs from all services"
	@echo "  make logs-api          - View API logs"
	@echo "  make logs-web          - View Web logs"
	@echo "  make logs-db           - View Database logs"
	@echo "  make health            - Run health check"
	@echo "  make ps                - Show running services"
	@echo ""
	@echo "Database:"
	@echo "  make shell-db          - Open PostgreSQL shell"
	@echo "  make migrate           - Run database migrations"
	@echo "  make seed              - Seed database with sample data"
	@echo "  make backup            - Create database backup"
	@echo ""
	@echo "Development:"
	@echo "  make shell-api         - Open container shell (API)"
	@echo "  make shell-web         - Open container shell (Web)"
	@echo "  make lint              - Run linter"
	@echo "  make format            - Format code"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy            - Deploy latest changes"
	@echo "  make clean             - Remove containers, volumes, and images"
	@echo ""

# Setup & Installation
install:
	@bash install.sh

build:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build

install-systemd:
	@echo "Installing systemd service..."
	@sudo cp mas.service /etc/systemd/system/
	@sudo systemctl daemon-reload
	@sudo systemctl enable mas.service
	@echo "To start the service, run: sudo systemctl start mas.service"

# Service Management
up:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d
	@echo "✓ Services started"

down:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down
	@echo "✓ Services stopped"

restart:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) restart
	@echo "✓ Services restarted"

restart-api:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) restart api
	@echo "✓ API restarted"

restart-web:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) restart web
	@echo "✓ Web restarted"

ps:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

# Monitoring
logs:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f

logs-api:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f api

logs-web:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f web

logs-db:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f postgres

logs-nginx:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f nginx

health:
	@bash health-check.sh

# Database Operations
shell-db:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec postgres psql -U $$(grep DB_USER .env | cut -d= -f2 | tr -d '"') -d $$(grep DB_NAME .env | cut -d= -f2 | tr -d '"')

migrate:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec -T api npx prisma migrate deploy

seed:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec -T api npx prisma db seed

backup:
	@bash backup.sh

# Development
shell-api:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec api sh

shell-web:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec web sh

lint:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec -T api pnpm lint
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec -T web pnpm lint

format:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec -T api pnpm format
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec -T web pnpm format

# Deployment
deploy:
	@bash deploy.sh

# Cleanup
clean:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v
	@echo "✓ Containers, volumes, and networks removed"

clean-images:
	docker system prune -a
	@echo "✓ Unused images removed"

full-clean: clean clean-images
	@echo "✓ Full cleanup completed"

.DEFAULT_GOAL := help
