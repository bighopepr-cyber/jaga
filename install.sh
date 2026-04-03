#!/bin/bash

################################################################################
# Military Attendance System - Automated Production Installer
# ============================================================================
# This script will install the entire application on a fresh Ubuntu VPS
# 
# Usage: bash install.sh
# 
# Requirements:
#   - Ubuntu 20.04 LTS or newer
#   - Minimum 2GB RAM
#   - 20GB disk space
#   - Root or sudo access
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="${REPO_URL:-https://github.com/bighopepr-cyber/jaga.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"
INSTALL_DIR="${INSTALL_DIR:-/opt/military-attendance}"
LOG_FILE="/var/log/mas-install.log"

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
        log_error "This script must be run as root or with sudo."
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "Cannot detect OS. This script requires Ubuntu."
        exit 1
    fi
    
    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        log_warning "This script is tested on Ubuntu. Your OS: $PRETTY_NAME"
    fi
    
    log_success "Detected OS: $PRETTY_NAME"
}

check_disk_space() {
    local required_space=20  # GB
    local available_space=$(df /opt 2>/dev/null | awk 'NR==2 {print int($4/1024/1024)}')
    
    if [[ -z "$available_space" ]]; then
        available_space=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
    fi
    
    if [[ $available_space -lt $required_space ]]; then
        log_error "Insufficient disk space. Required: ${required_space}GB, Available: ${available_space}GB"
        exit 1
    fi
    
    log_success "Disk space check passed (${available_space}GB available)"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

generate_secret() {
    openssl rand -base64 32
}

generate_db_password() {
    openssl rand -base64 24 | tr -d "=+/" | cut -c1-20
}

################################################################################
# Main Installation Steps
################################################################################

install_docker() {
    log_info "Installing Docker..."
    
    if check_command docker; then
        log_success "Docker is already installed"
        return
    fi
    
    # Update package list
    apt-get update -qq
    
    # Install required packages
    apt-get install -y -qq \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Enable Docker daemon
    systemctl enable docker
    systemctl start docker
    
    log_success "Docker installed successfully"
}

install_docker_compose() {
    log_info "Installing Docker Compose..."
    
    if check_command docker-compose; then
        log_success "Docker Compose is already installed"
        return
    fi
    
    # Docker Compose v2 is included with docker-compose-plugin
    # Install standalone docker-compose as well for compatibility
    DOCKER_COMPOSE_VERSION="v2.20.2"
    DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
    
    curl -L "$DOCKER_COMPOSE_URL" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    log_success "Docker Compose installed successfully"
}

install_git() {
    log_info "Installing Git..."
    
    if check_command git; then
        log_success "Git is already installed"
        return
    fi
    
    apt-get update -qq
    apt-get install -y -qq git
    
    log_success "Git installed successfully"
}

clone_repository() {
    log_info "Cloning repository..."
    
    if [[ -d "$INSTALL_DIR" ]]; then
        log_warning "Installation directory already exists: $INSTALL_DIR"
        read -p "Do you want to update existing installation? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping repository clone"
            return
        fi
        
        cd "$INSTALL_DIR"
        git pull origin "$REPO_BRANCH"
    else
        mkdir -p "$INSTALL_DIR"
        git clone -b "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
    fi
    
    cd "$INSTALL_DIR"
    log_success "Repository ready at $INSTALL_DIR"
}

setup_environment() {
    log_info "Setting up environment variables..."
    
    cd "$INSTALL_DIR"
    
    # Check if .env already exists
    if [[ -f .env ]]; then
        log_warning ".env file already exists"
        read -p "Do you want to reconfigure? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping environment setup"
            return
        fi
    fi
    
    # Copy production env as template
    cp .env.production .env
    
    # User input with defaults
    read -p "Enter database user (default: mas_user): " db_user
    db_user="${db_user:-mas_user}"
    
    read -p "Enter server domain/IP (default: localhost): " domain
    domain="${domain:-localhost}"
    
    # Generate secure passwords and secrets
    log_info "Generating secure passwords and secrets..."
    db_password=$(generate_db_password)
    redis_password=$(generate_db_password)
    jwt_secret=$(generate_secret)
    jwt_refresh_secret=$(generate_secret)
    
    log_info "Updating .env file..."
    
    # Update .env with actual values
    sed -i "s|DB_USER=.*|DB_USER=$db_user|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$db_password|" .env
    sed -i "s|CHANGE_THIS_PASSWORD|$db_password|g" .env
    sed -i "s|REDIS_PASSWORD=.*|REDIS_PASSWORD=$redis_password|" .env
    sed -i "s|JWT_SECRET=.*|JWT_SECRET=$jwt_secret|" .env
    sed -i "s|JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=$jwt_refresh_secret|" .env
    
    # Update URLs
    sed -i "s|your-domain.com|$domain|g" .env
    
    # Update database URL
    db_url="postgresql://$db_user:$db_password@postgres:5432/military_attendance"
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=\"$db_url\"|" .env
    
    # Update Redis URL
    redis_url="redis://:$redis_password@redis:6379/0"
    sed -i "s|REDIS_URL=.*|REDIS_URL=\"$redis_url\"|" .env
    
    # Set file permissions (sensitive data)
    chmod 600 .env
    
    log_success "Environment configured"
    log_warning "Database password: $db_password (saved in .env)"
    log_warning "Redis password: $redis_password (saved in .env)"
}

build_containers() {
    log_info "Building Docker containers (this may take 5-10 minutes)..."
    
    cd "$INSTALL_DIR"
    
    docker-compose build --no-cache
    
    log_success "Containers built successfully"
}

start_services() {
    log_info "Starting services..."
    
    cd "$INSTALL_DIR"
    
    docker-compose up -d
    
    log_info "Waiting for services to be ready..."
    sleep 10
    
    # Check service health
    if docker-compose ps --services --filter "status=running" | grep -q "postgres"; then
        log_success "PostgreSQL is running"
    else
        log_error "PostgreSQL failed to start"
        exit 1
    fi
    
    if docker-compose ps --services --filter "status=running" | grep -q "redis"; then
        log_success "Redis is running"
    else
        log_error "Redis failed to start"
        exit 1
    fi
    
    if docker-compose ps --services --filter "status=running" | grep -q "api"; then
        log_success "API is running"
    else
        log_error "API failed to start"
        exit 1
    fi
    
    if docker-compose ps --services --filter "status=running" | grep -q "web"; then
        log_success "Web is running"
    else
        log_error "Web failed to start"
        exit 1
    fi
}

run_migrations() {
    log_info "Running database migrations..."
    
    cd "$INSTALL_DIR"
    
    # Run Prisma migrate
    docker-compose exec -T api npx prisma migrate deploy
    
    log_success "Database migrations completed"
}

setup_ssl() {
    log_info ""
    log_warning "HTTPS/SSL Setup"
    log_info "To enable HTTPS with Let's Encrypt:"
    log_info ""
    log_info "1. Install Certbot:"
    log_info "   sudo apt-get install -y certbot python3-certbot-nginx"
    log_info ""
    log_info "2. Generate certificate:"
    log_info "   sudo certbot certonly --standalone -d your-domain.com"
    log_info ""
    log_info "3. Copy certificate:"
    log_info "   sudo mkdir -p $INSTALL_DIR/certs"
    log_info "   sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem $INSTALL_DIR/certs/"
    log_info "   sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem $INSTALL_DIR/certs/"
    log_info "   sudo chown 100:101 $INSTALL_DIR/certs/*"
    log_info ""
    log_info "4. Uncomment HTTPS section in nginx/default.conf"
    log_info ""
    log_info "5. Restart NGINX:"
    log_info "   cd $INSTALL_DIR && docker-compose restart nginx"
    log_info ""
}

show_summary() {
    log_info ""
    log_success "=========================================="
    log_success "Installation Complete!"
    log_success "=========================================="
    log_info ""
    log_info "Installation Directory: $INSTALL_DIR"
    log_info "Application URL: http://$domain"
    log_info "API Endpoint: http://$domain/api"
    log_info ""
    log_info "Environment file: .env"
    log_info "Docker Compose file: docker-compose.yml"
    log_info "Installation log: $LOG_FILE"
    log_info ""
    log_success "Useful Commands:"
    log_info "  View logs:              cd $INSTALL_DIR && docker-compose logs -f api"
    log_info "  Restart services:       cd $INSTALL_DIR && docker-compose restart"
    log_info "  Stop services:          cd $INSTALL_DIR && docker-compose down"
    log_info "  Database shell:         cd $INSTALL_DIR && docker-compose exec postgres psql -U mas_user -d military_attendance"
    log_info "  Deploy updates:         cd $INSTALL_DIR && bash deploy.sh"
    log_info ""
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║  Military Attendance System - Automated VPS Installer          ║
║  ============================================================  ║
║  This script will set up a production-ready environment        ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Initialize log file
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "Installation started at $(date)" > "$LOG_FILE"
    
    # Run checks
    check_root
    check_os
    check_disk_space
    
    # Install dependencies
    install_docker
    install_docker_compose
    install_git
    
    # Setup application
    clone_repository
    setup_environment
    build_containers
    start_services
    run_migrations
    
    # Setup SSL
    setup_ssl
    
    # Show summary
    show_summary
    
    log_success "Setup completed successfully at $(date)" 
    log_info "Full log: $LOG_FILE"
}

# Run main function
main "$@"
