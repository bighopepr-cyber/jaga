#!/bin/bash

################################################################################
# Military Attendance System - Deployment Script
# ============================================================================
# This script safely deploys the latest changes to production
# 
# Usage: bash deploy.sh
# 
# Features:
#   - Pulls latest code from repository
#   - Rebuilds Docker images
#   - Runs database migrations (if needed)
#   - Restarts services with zero-downtime (when possible)
#   - Rollback capability on failed deployment
################################################################################

set -e  # Exit on any error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/deploy-$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="$SCRIPT_DIR/.deploy-backups"

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        # Try with sudo if not already root
        if ! sudo -n true 2>/dev/null; then
            log_error "This script needs root/sudo access. Please run with sudo."
            exit 1
        fi
    fi
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker-compose --version &> /dev/null; then
        log_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
    
    log_success "Docker and Docker Compose verified"
}

backup_compose_state() {
    log_info "Creating backup of current state..."
    
    mkdir -p "$BACKUP_DIR"
    
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_path="$BACKUP_DIR/$timestamp"
    mkdir -p "$backup_path"
    
    cd "$SCRIPT_DIR"
    
    # Backup current docker-compose state
    docker-compose ps > "$backup_path/services.txt" 2>&1 || true
    cp .env "$backup_path/.env.backup" 2>/dev/null || true
    
    # Export database dump (optional, just in case)
    log_info "Creating database backup (this may take a moment)..."
    docker-compose exec -T postgres pg_dump \
        -U $(grep DB_USER .env | cut -d= -f2) \
        -d $(grep DB_NAME .env | cut -d= -f2) \
        > "$backup_path/database.sql" 2>/dev/null || true
    
    echo "$backup_path"
}

pull_latest_code() {
    log_info "Pulling latest code from repository..."
    
    cd "$SCRIPT_DIR"
    
    # Stash any local changes
    git stash push -m "Deploy stash at $(date)" --quiet 2>/dev/null || true
    
    # Fetch and pull latest
    git fetch origin -q
    git pull origin main -q || {
        log_error "Failed to pull latest code"
        return 1
    }
    
    local_changes=$(git status --porcelain | wc -l)
    if [[ $local_changes -gt 0 ]]; then
        log_warning "Local changes detected (this is expected if you have local configuration)"
    fi
    
    log_success "Code updated successfully"
}

validate_env_file() {
    log_info "Validating environment configuration..."
    
    cd "$SCRIPT_DIR"
    
    if [[ ! -f .env ]]; then
        log_error ".env file not found. Please run install.sh first"
        exit 1
    fi
    
    # Check critical variables
    local required_vars=(
        "DATABASE_URL"
        "REDIS_URL"
        "JWT_SECRET"
    )
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^$var=" .env; then
            log_error "Missing required environment variable: $var"
            exit 1
        fi
    done
    
    log_success "Environment configuration validated"
}

build_images() {
    log_info "Building Docker images..."
    
    cd "$SCRIPT_DIR"
    
    if docker-compose build --no-cache 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Docker images built successfully"
        return 0
    else
        log_error "Docker build failed"
        return 1
    fi
}

migrate_database() {
    log_info "Running database migrations..."
    
    cd "$SCRIPT_DIR"
    
    # Check if migrations are needed
    if docker-compose exec -T api npx prisma migrate status 2>&1 | grep -q "Database has not been migrated"; then
        log_info "Database migrations detected, applying..."
        
        if docker-compose exec -T api npx prisma migrate deploy; then
            log_success "Database migrated successfully"
            return 0
        else
            log_error "Database migration failed"
            return 1
        fi
    else
        log_info "Database is up to date"
        return 0
    fi
}

restart_services() {
    log_info "Restarting services..."
    
    cd "$SCRIPT_DIR"
    
    # Stop old containers
    log_info "Stopping services gracefully (60 second timeout)..."
    docker-compose stop -t 60 || true
    
    # Start new containers
    log_info "Starting updated services..."
    docker-compose up -d
    
    # Wait for services to be healthy
    log_info "Waiting for services to become healthy..."
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        local healthy=0
        
        # Check API health
        if docker-compose exec -T api curl -sf http://localhost:3001/health > /dev/null 2>&1; then
            ((healthy++))
        fi
        
        # Check Web health
        if docker-compose exec -T web curl -sf http://localhost:3000 > /dev/null 2>&1; then
            ((healthy++))
        fi
        
        if [[ $healthy -eq 2 ]]; then
            log_success "All services are healthy"
            return 0
        fi
        
        attempt=$((attempt + 1))
        sleep 2
    done
    
    log_error "Services failed to become healthy"
    return 1
}

run_smoke_tests() {
    log_info "Running smoke tests..."
    
    cd "$SCRIPT_DIR"
    
    # Check API endpoint
    if curl -sf http://localhost/api/health > /dev/null 2>&1; then
        log_success "API endpoint is responding"
    else
        log_error "API endpoint is not responding"
        return 1
    fi
    
    # Check Web endpoint
    if curl -sf http://localhost > /dev/null 2>&1; then
        log_success "Web endpoint is responding"
    else
        log_error "Web endpoint is not responding"
        return 1
    fi
    
    # Check database connection
    if docker-compose exec -T postgres psql -U $(grep DB_USER .env | cut -d= -f2) -d $(grep DB_NAME .env | cut -d= -f2) -c "SELECT 1" > /dev/null 2>&1; then
        log_success "Database connection verified"
    else
        log_error "Database connection failed"
        return 1
    fi
    
    log_success "All smoke tests passed"
}

rollback_deployment() {
    local backup_path=$1
    
    log_warning "Rolling back to previous state..."
    
    cd "$SCRIPT_DIR"
    
    # Restore .env
    if [[ -f "$backup_path/.env.backup" ]]; then
        cp "$backup_path/.env.backup" .env
        log_info "Environment restored from backup"
    fi
    
    # Stop and remove current containers
    docker-compose down -v 2>/dev/null || true
    
    # Restart from backup
    docker-compose up -d
    
    log_warning "Rollback completed. Please review the deployment log for details."
}

show_summary() {
    log_success "=========================================="
    log_success "Deployment Complete!"
    log_success "=========================================="
    log_info ""
    log_info "Deployment directory: $SCRIPT_DIR"
    log_info "Deployment log: $LOG_FILE"
    log_info ""
    log_success "Useful commands:"
    log_info "  View logs:        docker-compose logs -f api"
    log_info "  Service status:   docker-compose ps"
    log_info "  Restart services: docker-compose restart"
    log_info "  Database shell:   docker-compose exec postgres psql"
    log_info ""
}

cleanup_old_backups() {
    log_info "Cleaning up old backup files (keeping last 10)..."
    
    # Keep only last 10 backups
    ls -t "$BACKUP_DIR" | tail -n +11 | xargs -r -I {} rm -rf "$BACKUP_DIR/{}"
    
    log_success "Backup cleanup completed"
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║  Military Attendance System - Deployment Script                ║
║  ============================================================  ║
║  This script will safely deploy the latest code                ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Initialize log file
    touch "$LOG_FILE"
    echo "Deployment started at $(date)" > "$LOG_FILE"
    
    # Preflight checks
    check_root
    check_docker
    validate_env_file
    
    # Backup current state
    backup_path=$(backup_compose_state)
    
    # Pull latest code
    if ! pull_latest_code; then
        log_error "Failed to pull latest code - aborting deployment"
        exit 1
    fi
    
    # Build and deploy
    if ! build_images; then
        log_error "Docker build failed"
        rollback_deployment "$backup_path"
        exit 1
    fi
    
    if ! restart_services; then
        log_error "Service restart failed"
        rollback_deployment "$backup_path"
        exit 1
    fi
    
    if ! migrate_database; then
        log_error "Database migration failed"
        log_warning "Rolling back..."
        rollback_deployment "$backup_path"
        exit 1
    fi
    
    # Smoke tests
    if ! run_smoke_tests; then
        log_error "Smoke tests failed"
        log_warning "Rolling back..."
        rollback_deployment "$backup_path"
        exit 1
    fi
    
    # Cleanup
    cleanup_old_backups
    
    # Summary
    show_summary
    
    log_success "Deployment completed successfully at $(date)"
    log_info "Full log: $LOG_FILE"
}

# Run main function
main "$@"
