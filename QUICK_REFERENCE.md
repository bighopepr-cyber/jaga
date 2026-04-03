# Military Attendance System - Quick Reference Card

## 🚀 Installation (First Time)

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Download and run installer
mkdir -p /opt && cd /opt
curl -L https://raw.githubusercontent.com/bighopepr-cyber/jaga/main/install.sh -o install.sh
chmod +x install.sh
sudo bash install.sh
```

**Time**: 5-10 minutes | **Result**: Full production system ready

---

## 📋 Essential Commands

### Check Status
```bash
cd /opt/military-attendance
docker-compose ps              # View all services
docker-compose logs -f api     # View API logs
bash health-check.sh           # Full system health check
```

### Manage Services
```bash
docker-compose up -d           # Start all services
docker-compose down            # Stop all services
docker-compose restart         # Restart all
docker-compose restart api     # Restart specific service
```

### Database
```bash
bash backup.sh                 # Create backup
docker-compose exec postgres psql -U mas_user -d military_attendance  # Database shell
docker-compose exec api npx prisma migrate deploy  # Run migrations
```

### Deploy Updates
```bash
bash deploy.sh                 # Deploy latest code (recommended)
# or manually:
git pull && docker-compose build && docker-compose up -d
```

### SSL/HTTPS
```bash
sudo bash setup-ssl.sh         # Setup Let's Encrypt certificate
```

---

## 🔧 Common Issues Quick Fixes

### "Connection refused"
```bash
docker-compose ps             # Check if running
docker-compose logs           # Check for errors
docker-compose restart        # Restart all services
```

### "502 Bad Gateway"
```bash
# API not responding
docker-compose logs api       # Check API logs
curl http://localhost:3001/health  # Test API
docker-compose restart api    # Restart API
```

### "Database connection failed"
```bash
# Database issues
docker-compose logs postgres  # Check database logs
docker-compose restart postgres  # Restart database
docker-compose exec postgres psql -U mas_user -d military_attendance -c "SELECT 1"  # Test
```

### Out of disk space
```bash
df -h                          # Check size
docker system prune -a         # Clean unused Docker objects
docker volume prune            # Remove unused volumes
```

---

## 📁 Important Files & Paths

| Path | Purpose |
|------|---------|
| `/opt/military-attendance/.env` | Configuration & secrets |
| `/opt/military-attendance/docker-compose.yml` | Service definitions |
| `/opt/military-attendance/nginx/default.conf` | Web server config |
| `/opt/military-attendance/.deploy-backups/` | Auto backups on deploy |
| `/opt/military-attendance/backups/` | Database backups |

---

## 🎯 Performance Metrics

| Metric | Target | Check |
|--------|--------|-------|
| Startup Time | < 30s | Check logs |
| Response Time | < 200ms | `curl -w "@-" ...` |
| Memory (API) | < 300MB | `docker stats` |
| Disk (all) | < 5GB | `du -sh .` |
| Error Rate | < 0.1% | Check logs |

---

## 🔐 Security Quick Checks

```bash
# 1. Verify secrets aren't default
grep JWT_SECRET .env | grep -v "CHANGE_THIS"

# 2. Check firewall is configured
sudo ufw status

# 3. Verify HTTPS is enabled (if configured)
curl -I https://your-domain.com

# 4. Check for exposed ports
sudo netstat -tlnp | grep LISTEN
```

---

## 📊 Useful Makefile Targets

```bash
make help              # Show all available targets
make install           # Run installer
make build             # Build images
make up                # Start services
make logs              # View all logs
make health            # Health check
make shell-db          # Database shell
make deploy            # Deploy updates
make backup            # Backup database
make clean             # Stop and remove everything
```

---

## 🆘 Emergency Procedures

### Complete Service Restart
```bash
# Nuclear option - stops and restarts everything
docker-compose down -v      # ⚠️ REMOVES ALL DATA
docker-compose up -d
docker-compose exec api npx prisma migrate deploy
```

### Restore from Backup
```bash
# Find backup
ls -la backups/

# Restore database
docker-compose exec -T postgres psql -U mas_user -d military_attendance < backups/backup_YYYYMMDD_HHMMSS.sql.gz
```

### Rollback Deployment
```bash
# Deploy script creates automatic backups in .deploy-backups/
ls -la .deploy-backups/

# If deploy.sh is running, it will offer automatic rollback on failure
```

---

## 📈 Monitoring Setup (Optional)

### Simple: Check manually
```bash
docker stats                   # CPU/Memory usage
df -h                         # Disk space
free -h                       # RAM usage
docker-compose logs           # Application logs
```

### Better: Setup cron job
```bash
# Add health check to crontab
(crontab -l 2>/dev/null; echo "*/5 * * * * cd /opt/military-attendance && bash health-check.sh > /tmp/health.log 2>&1") | crontab -
```

### Best: Use monitoring service
- Prometheus + Grafana
- Datadog
- New Relic
- CloudWatch (if on AWS)

---

## 📞 Quick Links

| Resource | URL |
|----------|-----|
| Full Documentation | [DEPLOYMENT.md](DEPLOYMENT.md) |
| Troubleshooting | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| GitHub Repository | https://github.com/bighopepr-cyber/jaga |
| API Health | http://your-vps-ip/api/health |
| Web Dashboard | http://your-vps-ip |

---

## ⏱️ Time Requirements

| Task | Time |
|------|------|
| Initial Installation | 5-10 min |
| Deploy Updates | 3-5 min |
| Database Backup | 1-2 min |
| SSL Certificate Setup | 5-10 min |
| System Health Check | 1 min |

---

## 📝 Checklist for Going Live

- [ ] System installed and running
- [ ] All services healthy (`health-check.sh`)
- [ ] Database backups working
- [ ] Custom domain configured
- [ ] SSL certificate installed
- [ ] CORS origins updated
- [ ] JWT secrets changed from defaults
- [ ] Firewall configured
- [ ] Monitoring enabled
- [ ] Team trained on operations

---

**Remember**: When in doubt, check the logs! 🔍

```bash
docker-compose logs -f --tail=100
```
