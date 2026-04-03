# SSL/HTTPS Setup Helper Script
# Automates Let's Encrypt certificate setup and renewal
# 
# Usage: bash setup-ssl.sh

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

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

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run with sudo"
        exit 1
    fi
}

install_certbot() {
    log_info "Installing Certbot..."
    
    apt-get update -qq
    apt-get install -y -qq certbot python3-certbot-dns-cloudflare
    
    log_success "Certbot installed"
}

get_domain() {
    read -p "Enter your domain name (e.g., example.com): " domain
    
    if [[ -z "$domain" ]]; then
        log_error "Domain cannot be empty"
        exit 1
    fi
    
    echo "$domain"
}

verify_dns() {
    local domain=$1
    
    log_info "Verifying DNS for $domain..."
    
    if nslookup "$domain" 2>/dev/null | grep -q "Address:"; then
        log_success "DNS verified for $domain"
        return 0
    else
        log_error "DNS not resolving for $domain"
        log_warning "Please ensure DNS is pointed to your server IP before continuing"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

generate_certificate() {
    local domain=$1
    
    log_info "Generating SSL certificate for $domain..."
    
    certbot certonly --standalone \
        -d "$domain" \
        -d "www.$domain" \
        --agree-tos \
        --email admin@"$domain" \
        --non-interactive
    
    if [[ $? -eq 0 ]]; then
        log_success "Certificate generated successfully"
        return 0
    else
        log_error "Certificate generation failed"
        return 1
    fi
}

copy_certificates() {
    local domain=$1
    local install_dir="${2:-.}"
    
    log_info "Copying certificates to Docker volume..."
    
    mkdir -p "$install_dir/certs"
    
    cp "/etc/letsencrypt/live/$domain/fullchain.pem" "$install_dir/certs/"
    cp "/etc/letsencrypt/live/$domain/privkey.pem" "$install_dir/certs/"
    
    # Make readable by Docker
    chmod 644 "$install_dir/certs/"*.pem
    
    log_success "Certificates copied to $install_dir/certs"
}

enable_https_nginx() {
    local install_dir="${1:-.}"
    
    log_info "Enabling HTTPS in NGINX configuration..."
    
    cd "$install_dir"
    
    # Check if HTTPS block is commented
    if grep -q "# server {" nginx/default.conf; then
        log_warning "Uncomment the HTTPS server block in nginx/default.conf"
        echo ""
        echo "Steps:"
        echo "1. Open: $install_dir/nginx/default.conf"
        echo "2. Find the HTTPS server block (commented)"
        echo "3. Uncomment all lines of the HTTPS block"
        echo "4. Update server_name if needed"
        echo "5. Restart NGINX: docker-compose restart nginx"
        return
    fi
    
    docker-compose restart nginx
    log_success "NGINX restarted with HTTPS enabled"
}

setup_auto_renewal() {
    local install_dir="${1:-.}"
    
    log_info "Setting up automatic certificate renewal..."
    
    # Create renewal script
    cat > /usr/local/bin/renew-mas-ssl.sh << 'EOF'
#!/bin/bash
cd /opt/military-attendance
certbot renew --quiet
cp /etc/letsencrypt/live/*/fullchain.pem certs/ 2>/dev/null || true
cp /etc/letsencrypt/live/*/privkey.pem certs/ 2>/dev/null || true
docker-compose restart nginx
EOF
    
    chmod +x /usr/local/bin/renew-mas-ssl.sh
    
    # Add to crontab
    (crontab -l 2>/dev/null | grep -v renew-mas-ssl.sh; echo "0 2 * * * /usr/local/bin/renew-mas-ssl.sh") | crontab -
    
    log_success "Auto-renewal configured (daily at 2 AM)"
}

test_ssl() {
    local domain=$1
    
    log_info "Testing SSL configuration..."
    
    # Wait for NGINX to be ready
    sleep 5
    
    if curl -sf "https://$domain" > /dev/null 2>&1; then
        log_success "HTTPS is working!"
        return 0
    else
        log_warning "HTTPS test failed. Check NGINX logs: docker-compose logs nginx"
        return 1
    fi
}

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║  Military Attendance System - SSL/HTTPS Setup                  ║
║  Using Let's Encrypt                                           ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    check_root
    
    # Get domain
    domain=$(get_domain)
    
    # Verify DNS
    verify_dns "$domain"
    
    # Install Certbot if needed
    if ! command -v certbot &> /dev/null; then
        install_certbot
    fi
    
    # Generate certificate
    if ! generate_certificate "$domain"; then
        log_error "Failed to generate certificate"
        exit 1
    fi
    
    # Copy certificates
    copy_certificates "$domain"
    
    # Enable HTTPS in NGINX
    enable_https_nginx
    
    # Setup auto-renewal
    setup_auto_renewal
    
    # Test SSL
    if test_ssl "$domain"; then
        echo ""
        log_success "=========================================="
        log_success "SSL/HTTPS Setup Complete!"
        log_success "=========================================="
        echo ""
        log_info "Your site is now accessible at:"
        log_info "  https://$domain"
        log_info ""
        log_info "Certificate will auto-renew daily"
    else
        log_warning "Check NGINX logs for issues"
        echo ""
        echo "Useful commands:"
        echo "  View logs: docker-compose logs -f nginx"
        echo "  Restart NGINX: docker-compose restart nginx"
        echo "  Check cert: certbot certificates"
    fi
}

main "$@"
