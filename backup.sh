#!/bin/bash

################################################################################
# Database Backup Script
# ============================================================================
# Automated backup of PostgreSQL database
# 
# Usage: bash backup.sh
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

# Configuration
INSTALL_DIR="${INSTALL_DIR:-.}"
BACKUP_DIR="${INSTALL_DIR}/backups"
RETENTION_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

create_backup_dir() {
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"  # Only owner can read/write
}

backup_database() {
    log_info "Creating database backup..."
    
    cd "$INSTALL_DIR"
    
    # Get database credentials from .env
    local db_user=$(grep "^DB_USER=" .env | cut -d= -f2 | tr -d '"')
    local db_name=$(grep "^DB_NAME=" .env | cut -d= -f2 | tr -d '"')
    
    # Create backup
    if docker-compose exec -T postgres pg_dump \
        -U "$db_user" \
        -d "$db_name" \
        --no-password \
        > "$BACKUP_FILE" 2>/dev/null; then
        
        log_success "Backup created: $BACKUP_FILE"
        log_info "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
        return 0
    else
        log_error "Failed to create backup"
        return 1
    fi
}

cleanup_old_backups() {
    log_info "Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
    
    find "$BACKUP_DIR" -type f -name "backup_*.sql" -mtime "+$RETENTION_DAYS" -delete
    
    log_success "Cleanup completed"
    log_info "Recent backups:"
    ls -lh "$BACKUP_DIR" | tail -10
}

compress_backup() {
    if command -v gzip &> /dev/null; then
        log_info "Compressing backup..."
        gzip "$BACKUP_FILE"
        log_success "Backup compressed: ${BACKUP_FILE}.gz"
    fi
}

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║  Military Attendance System - Database Backup                  ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    create_backup_dir
    backup_database || exit 1
    compress_backup
    cleanup_old_backups
    
    log_success "Backup process completed successfully!"
}

main "$@"
