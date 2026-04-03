# Military Attendance System - Production Deployment Guide

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Configuration](#configuration)
- [Security](#security)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Troubleshooting](#troubleshooting)
- [Advanced Topics](#advanced-topics)

---

## Overview

This is a comprehensive guide for deploying the **Military Attendance System** on a production Ubuntu VPS. The deployment is fully automated using Docker and Docker Compose.

### What's Included

- **NestJS API** running on port 3001
- **Next.js Web Dashboard** running on port 3000
- **PostgreSQL Database** for persistent data
- **Redis Cache** for session/cache management
- **NGINX Reverse Proxy** for load balancing and security
- **Automated Installation & Deployment Scripts**
- **Health Checks & Monitoring**

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        NGINX (Port 80/443)              │
│              (Reverse Proxy + Load Balancer)             │
└──────────────────────────────────────────────────────────┘
            │                               │
            ▼                               ▼
    ┌─────────────────┐           ┌─────────────────┐
    │   Next.js Web   │           │    NestJS API   │
    │  (Port 3000)    │           │   (Port 3001)   │
    └─────────────────┘           └─────────────────┘
            │                               │
            └───────────────┬───────────────┘
                            ▼
                        ┌──────────────┐
                        │ PostgreSQL   │
                        │ (Port 5432)  │
                        └──────────────┘
                            │
                            ├─────────────┐
                            │             │
                            ▼             ▼
                        (Data)       (Cache) Redis
```

---

## Prerequisites

### System Requirements

- **OS**: Ubuntu 20.04 LTS or newer
- **CPU**: Minimum 2 cores (4+ recommended)
- **RAM**: Minimum 2GB (4GB+ recommended)
- **Disk**: Minimum 20GB (SSD recommended)
- **Network**: Public IP address or domain name

### Software Requirements

The installer automatically installs:

- Docker & Docker Compose
- Git
- curl

### Access Requirements

- SSH access to the VPS
- Root or sudo privileges
- Git repository access (if private)

---

## Quick Start

### 1️⃣ SSH into Your VPS

```bash
ssh root@your-vps-ip
# or
ssh ubuntu@your-vps-ip
```

### 2️⃣ Download and Run the Installer

```bash
# Create installation directory
mkdir -p /opt
cd /opt

# Download the installer script
curl -L https://raw.githubusercontent.com/bighopepr-cyber/jaga/main/install.sh -o install.sh

# Make it executable
chmod +x install.sh

# Run the installer
sudo bash install.sh
```

The installer will:

✅ Check system requirements  
✅ Install Docker & Docker Compose  
✅ Clone the repository  
✅ Prompt for configuration (database, domain, secrets)  
✅ Generate secure passwords  
✅ Build Docker images  
✅ Start all services  
✅ Run database migrations  

**Installation time**: ~5-10 minutes (depending on internet speed)

### 3️⃣ Access Your Application

After successful installation:

- **Web Dashboard**: `http://your-vps-ip`
- **API Endpoint**: `http://your-vps-ip/api`
- **Health Check**: `http://your-vps-ip/api/health`

---

## Detailed Setup

### Step 1: Prepare Your VPS

```bash
# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Set timezone (optional, default: UTC)
sudo timedatectl set-timezone Asia/Jakarta
```

### Step 2: Run the Automated Installer

```bash
sudo bash install.sh
```

**The installer will ask for:**

1. **Database Username** (default: `mas_user`)
2. **Database Password** - auto-generated, saved in `.env`
3. **Server Domain/IP** (default: `localhost`)

**You will NOT need to manually:**

- Generate passwords
- Configure Docker Compose
- Set up NGINX
- Run migrations

### Step 3: Verify Installation

```bash
# Check if all services are running
sudo docker-compose ps

# View API logs
sudo docker-compose logs -f api

# Test health endpoint
curl http://localhost/api/health
```

---

## Configuration

### Environment Variables

All configuration is controlled via the `.env` file located at `/opt/military-attendance/.env`.

#### Critical Variables to Update

**Domain/IP Configuration:**

```bash
NEXT_PUBLIC_API_URL=http://your-domain.com/api  # Frontend URL to API
CORS_ORIGIN=http://your-domain.com               # Allowed origin for CORS
```

**Security - Secrets:**

```bash
JWT_SECRET=your-super-secret-key-here
JWT_REFRESH_SECRET=your-refresh-secret-here
```

**Database:**

```bash
DATABASE_URL=postgresql://mas_user:password@postgres:5432/military_attendance
```

**Redis:**

```bash
REDIS_URL=redis://:password@redis:6379/0
```

### Update Configuration

```bash
# SSH into VPS
ssh root@your-vps-ip

# Navigate to installation directory
cd /opt/military-attendance

# Edit .env file
sudo nano .env

# Restart services to apply changes
sudo docker-compose restart
```

---

## Security

### ✅ Security Features Included

1. **Helmet.js** - HTTP security headers
2. **CORS** - Cross-origin request protection
3. **Rate Limiting** - DDoS protection
4. **Password Hashing** - Bcrypt for stored passwords
5. **JWT Authentication** - Secure token-based auth
6. **HTTPS/SSL** - TLS encryption (optional)

### 🔒 Enable HTTPS with Let's Encrypt

#### Step 1: Install Certbot

```bash
sudo apt-get install -y certbot python3-certbot-nginx
```

#### Step 2: Generate SSL Certificate

```bash
sudo certbot certonly --standalone -d your-domain.com
```

#### Step 3: Copy Certificates to Docker Volume

```bash
cd /opt/military-attendance

sudo mkdir -p certs

sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem certs/

sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem certs/

sudo chown 100:101 certs/*
```

#### Step 4: Enable HTTPS in NGINX Config

```bash
# Edit NGINX config
sudo nano nginx/default.conf

# Uncomment the HTTPS server block at the bottom

# Restart NGINX
sudo docker-compose restart nginx
```

#### Step 5: Auto-Renew Certificates

```bash
# Add cron job for auto-renewal
sudo crontab -e

# Add this line (renew at 2 AM daily)
0 2 * * * certbot renew --quiet && docker-compose -f /opt/military-attendance/docker-compose.yml restart nginx
```

### 🛡️ Security Best Practices

1. **Change Default Secrets**

   ```bash
   # Generate new secrets
   openssl rand -base64 32
   
   # Update in .env
   JWT_SECRET=<generated-value>
   JWT_REFRESH_SECRET=<generated-value>
   ```

2. **Secure Database Access**

   - Database only accessible from API container
   - No external database access
   - Strong passwords (auto-generated by installer)

3. **Firewall Configuration** (Optional)

   ```bash
   # Allow only necessary ports
   sudo ufw enable
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 80/tcp    # HTTP
   sudo ufw allow 443/tcp   # HTTPS
   ```

4. **Regular Backups**

   - Database backups on every deploy
   - Kept in `.deploy-backups/` directory
   - Consider offsite backups

---

## Monitoring & Maintenance

### 🏥 Health Checks

The application has three health check endpoints:

```bash
# Liveness check (is service running?)
curl http://localhost/api/health/live

# Readiness check (is database ready?)
curl http://localhost/api/health/ready

# Full health check (with version info)
curl http://localhost/api/health
```

### 📊 View Logs

```bash
# All services
sudo docker-compose logs

# Specific service (API)
sudo docker-compose logs -f api

# Web service
sudo docker-compose logs -f web

# NGINX
sudo docker-compose logs -f nginx

# Last 50 lines
sudo docker-compose logs --tail=50 api
```

### 💾 Database Backup

```bash
# Manual backup
sudo docker-compose exec postgres pg_dump \
  -U mas_user \
  -d military_attendance > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
sudo docker-compose exec -T postgres psql \
  -U mas_user \
  -d military_attendance < backup_file.sql
```

### 🔄 Service Management

```bash
# Start services
sudo docker-compose up -d

# Stop services
sudo docker-compose down

# Restart services
sudo docker-compose restart

# Restart specific service
sudo docker-compose restart api

# View running services
sudo docker-compose ps
```

### 📈 System Resources

```bash
# View container resource usage
sudo docker stats

# View disk usage
sudo du -sh /opt/military-attendance

# View Docker volumes size
sudo docker system df
```

### 🗑️ Clean Up

```bash
cd /opt/military-attendance

# Remove unused images
sudo docker image prune -a

# Remove unused volumes
sudo docker volume prune

# Remove stopped containers
sudo docker container prune

# Full cleanup (warning: destructive)
sudo docker system prune -a
```

---

## Deploying Updates

### Automated Deployment Script

The project includes a safe deployment script that handles:

- Code updates via Git
- Container rebuilds
- Database migrations
- Service restarts
- Automatic rollback on failure

### 🚀 Deploy Latest Changes

```bash
cd /opt/military-attendance

# Run deployment script
sudo bash deploy.sh
```

**The script will:**

1. ✅ Check system requirements
2. ✅ Create backup of current state
3. ✅ Pull latest code from GitHub
4. ✅ Build new Docker images
5. ✅ Migrate database (if needed)
6. ✅ Restart services
7. ✅ Run smoke tests
8. ✅ Rollback if anything fails

**Deployment time**: ~3-5 minutes

### 🔙 Rollback Failed Deployment

```bash
# Deployments create timestamped backups
ls -la .deploy-backups/

# Restore from specific backup
# (deploy.sh will offer rollback option automatically)
```

---

## Troubleshooting

### 🔴 Services Won't Start

**Check logs:**

```bash
# View detailed logs
sudo docker-compose logs

# View only errors
sudo docker-compose logs | grep -i error
```

**Common issues:**

1. **Port already in use**

   ```bash
   # Find process using port 80
   sudo lsof -i :80
   
   # Kill the process
   sudo kill -9 <PID>
   ```

2. **Disk space full**

   ```bash
   # Check disk space
   df -h
   
   # Clean up Docker
   sudo docker system prune -a
   ```

3. **Memory issues**

   ```bash
   # Check available memory
   free -h
   
   # Increase swap (if running low on RAM)
   ```

### 🔴 Database Connection Errors

**Test database connection:**

```bash
# Connect to PostgreSQL container
sudo docker-compose exec postgres psql -U mas_user -d military_attendance

# If successful, you'll see the PostgreSQL prompt
```

**Common issues:**

1. **Wrong database password**

   ```bash
   # Check .env file
   sudo cat .env | grep DATABASE_URL
   
   # Update if needed and restart
   sudo docker-compose restart
   ```

2. **Database not running**

   ```bash
   # Check if postgres container is running
   sudo docker-compose ps postgres
   
   # Restart database
   sudo docker-compose restart postgres
   ```

### 🔴 Application Crashing

**Check API logs:**

```bash
# View last 100 lines of API logs
sudo docker-compose logs -f --tail=100 api
```

**Restart API:**

```bash
sudo docker-compose restart api
```

**Check application logs for errors:**

```bash
# Search for ERROR in logs
sudo docker-compose logs api | grep ERROR
```

### 🔴 NGINX 502 Bad Gateway

**Means backend services are not responding**

```bash
# Check if API is running
curl http://localhost:3001/health

# Check NGINX logs
sudo docker-compose logs nginx

# Restart all services
sudo docker-compose down
sudo docker-compose up -d
```

### 🔴 High Memory/CPU Usage

```bash
# Monitor resource usage in real-time
sudo docker stats

# Check for memory leaks
sudo docker-compose logs api | tail -100

# Restart affected service
sudo docker-compose restart api

# Consider: Increase server resources or optimize code
```

### 📝 Getting Help

1. **Check logs**

   ```bash
   sudo docker-compose logs -f [service_name]
   ```

2. **Check system resources**

   ```bash
   docker stats
   free -h
   df -h
   ```

3. **View installation log**

   ```bash
   sudo cat /var/log/mas-install.log
   ```

4. **View deployment log**

   ```bash
   sudo ls -la /opt/military-attendance/deploy-*.log
   ```

---

## Advanced Topics

### Custom Domain Setup

#### 1. Update DNS Records

Point your domain to your VPS IP:

```
A Record:
  Name: @
  Value: your-vps-ip
  TTL: 3600
```

#### 2. Update Application Configuration

```bash
cd /opt/military-attendance

# Edit .env
sudo nano .env

# Update these lines:
NEXT_PUBLIC_API_URL=https://your-domain.com/api
CORS_ORIGIN=https://your-domain.com
```

#### 3. Restart Services

```bash
sudo docker-compose restart
```

### Database Replication & Backup

For high-availability setups:

```bash
# Enable PostgreSQL streaming replication
# (requires additional configuration)

# Regular backup cron job
sudo crontab -e

# Add this line (daily at 3 AM)
0 3 * * * docker-compose -f /opt/military-attendance/docker-compose.yml exec -T postgres pg_dump -U mas_user -d military_attendance > /backups/db_$(date +\%Y\%m\%d).sql
```

### Horizontal Scaling

To run multiple API instances:

```bash
# Edit docker-compose.yml
sudo nano docker-compose.yml

# Change API to use scale:
# api:
#   deploy:
#     replicas: 3

# Or use Docker Swarm for advanced orchestration
```

### External Monitoring (Prometheus/Grafana)

For production monitoring, add Prometheus + Grafana to docker-compose.yml.

### Database Connection Pooling

The application uses PgBouncer through environment variables:

```bash
DB_POOL_MIN=5
DB_POOL_MAX=20
```

Adjust based on your server resources.

---

## 📞 Support & Documentation

- **Repository**: https://github.com/bighopepr-cyber/jaga
- **Issues**: Report bugs on GitHub
- **Documentation**: Check docs/ directory for API docs and architecture

---

## 📋 Checklist for First Production Deployment

- [ ] VPS with Ubuntu 20.04+ created
- [ ] SSH access verified
- [ ] Installer downloaded and executed
- [ ] Domain name configured
- [ ] SSL certificate installed
- [ ] All services running and healthy
- [ ] Database backups configured
- [ ] Monitoring setup (optional)
- [ ] CORS origins updated
- [ ] JWT secrets changed from defaults
- [ ] Firewall configured
- [ ] Regular backup schedule created

---

## 🎉 You're Ready!

Your Military Attendance System is now running on production!

**Next Steps:**

1. Access your dashboard: `http://your-domain.com`
2. Configure system settings
3. Import user data
4. Set up monitoring & alerts
5. Train users on the system

**Questions?** Check the troubleshooting section or review logs.

Good luck! 🚀
