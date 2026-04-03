#!/bin/bash

################################################################################
# Health Check Script
# ============================================================================
# Comprehensive health check for all services
# 
# Usage: bash health-check.sh
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

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

check_service_running() {
    local service=$1
    if docker-compose -f "$INSTALL_DIR/docker-compose.yml" ps "$service" | grep -q "running"; then
        log_success "$service is running"
        return 0
    else
        log_error "$service is NOT running"
        return 1
    fi
}

check_endpoint() {
    local service=$1
    local endpoint=$2
    local port=$3
    
    if curl -sf "http://localhost:${port}${endpoint}" > /dev/null 2>&1; then
        log_success "$service endpoint is responding"
        return 0
    else
        log_error "$service endpoint is NOT responding (${endpoint})"
        return 1
    fi
}

check_database() {
    log_info "Checking database..."
    if docker-compose -f "$INSTALL_DIR/docker-compose.yml" exec -T postgres psql -U $(grep DB_USER "$INSTALL_DIR/.env" | cut -d= -f2 | tr -d '"') -d $(grep DB_NAME "$INSTALL_DIR/.env" | cut -d= -f2 | tr -d '"') -c "SELECT 1" > /dev/null 2>&1; then
        log_success "Database is responsive"
        return 0
    else
        log_error "Database is NOT responsive"
        return 1
    fi
}

check_redis() {
    log_info "Checking Redis..."
    if docker-compose -f "$INSTALL_DIR/docker-compose.yml" exec -T redis redis-cli ping > /dev/null 2>&1; then
        log_success "Redis is responsive"
        return 0
    else
        log_error "Redis is NOT responsive"
        return 1
    fi
}

check_disk_space() {
    log_info "Checking disk space..."
    local available=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
    if [[ $available -lt 2 ]]; then
        log_error "Low disk space: ${available}GB available"
        return 1
    else
        log_success "Disk space OK: ${available}GB available"
        return 0
    fi
}

check_memory() {
    log_info "Checking memory..."
    local available=$(free -h | awk 'NR==2 {print $7}')
    log_success "Available memory: $available"
    return 0
}

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║  Military Attendance System - Health Check                    ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    local all_ok=true
    
    # Check services are running
    log_info "Checking if services are running..."
    echo ""
    
    check_service_running "postgres" || all_ok=false
    check_service_running "redis" || all_ok=false
    check_service_running "api" || all_ok=false
    check_service_running "web" || all_ok=false
    check_service_running "nginx" || all_ok=false
    
    echo ""
    
    # Check endpoints
    log_info "Checking endpoints..."
    echo ""
    
    check_endpoint "API Health" "/health" "3001" || all_ok=false
    check_endpoint "API Liveness" "/health/live" "3001" || all_ok=false
    check_endpoint "API Readiness" "/health/ready" "3001" || all_ok=false
    check_endpoint "Web" "/" "3000" || all_ok=false
    
    echo ""
    
    # Check databases
    log_info "Checking data systems..."
    echo ""
    
    check_database || all_ok=false
    check_redis || all_ok=false
    
    echo ""
    
    # Check system resources
    log_info "Checking system resources..."
    echo ""
    
    check_disk_space || all_ok=false
    check_memory
    
    echo ""
    
    # Summary
    if $all_ok; then
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        log_success "All systems operational!"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        exit 0
    else
        echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
        log_error "Some systems have issues!"
        echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
        exit 1
    fi
}

cd "$INSTALL_DIR"
main "$@"
