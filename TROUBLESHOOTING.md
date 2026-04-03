# Military Attendance System - FAQ & Troubleshooting

## Quick Reference

### Service Ports
- **Web Dashboard**: Port 3000 (proxied by NGINX)
- **API**: Port 3001 (proxied by NGINX)
- **PostgreSQL**: Port 5432 (internal only)
- **Redis**: Port 6379 (internal only)
- **NGINX**: Ports 80/443 (public)

### Important Paths
- **Installation**: `/opt/military-attendance`
- **Configuration**: `.env` file
- **Backups**: `./.deploy-backups/`
- **Database backups**: `./backups/`
- **Logs**: View with `docker-compose logs`

---

## Frequently Asked Questions

### Q: How do I access the application?
**A:** Navigate to:
- `http://your-server-ip` for the web dashboard
- `http://your-server-ip/api` for the API

If you've set up HTTPS:
- `https://your-domain.com`

### Q: Where are configuration files?
**A:** Main configuration is in `.env` file in `/opt/military-attendance/`
```bash
cd /opt/military-attendance
cat .env
```

### Q: How do I change the database password?
**A:** **WARNING**: Changing passwords after deployment is complex.

If you must do it:
1. Edit `.env` file
2. Change `DB_PASSWORD` and `DATABASE_URL`
3. Reset database: `docker-compose down -v` (⚠️ DELETES ALL DATA)
4. Restart: `docker-compose up -d`

**Better approach**: Take regular backups instead.

### Q: How do I check if everything is working?
**A:** Run health check:
```bash
bash health-check.sh
```

Or manually:
```bash
# Check services are running
docker-compose ps

# Check API health
curl http://localhost/api/health

# Check database
docker-compose exec postgres psql -U mas_user -d military_attendance -c "SELECT 1"
```

### Q: How often should I backup?
**A:** At minimum:
- Daily automatic backups (included in deploy script)
- Manual backup before major changes
- Store offsite backups for critical data

Create manual backup:
```bash
bash backup.sh
```

### Q: Can I run this on lower specs?
**A:** Minimum:
- 1GB RAM + 1GB swap
- 10GB disk (minimum)
- Single core CPU

For production: 2GB RAM, 4GB+ disk, 2+ cores recommended.

### Q: How do I monitor resource usage?
**A:** 
```bash
# Real-time Docker stats
docker stats

# Disk usage
df -h

# Memory usage
free -h

# CPU usage
top
```

### Q: Can I use a different database?
**A:** Currently supports:
- **PostgreSQL** (recommended for production)
- **SQLite** (good for development)

To switch, update `DATABASE_URL` in `.env`:
```bash
# PostgreSQL
DATABASE_URL=postgresql://user:pass@host:5432/dbname

# SQLite
DATABASE_URL=file:./dev.db
```

### Q: How do I update the application?
**A:** Run deployment script:
```bash
cd /opt/military-attendance
bash deploy.sh
```

This will:
1. Pull latest code from GitHub
2. Build new images
3. Run migrations
4. Restart services
5. Rollback if anything fails

### Q: Can I run multiple replicas?
**A:** Yes, for high availability:

Edit `docker-compose.yml`:
```yaml
api:
  deploy:
    replicas: 3  # Run 3 instances
```

Then: `docker-compose up -d`

NGINX will load-balance between instances.

### Q: How do I add a custom domain?
**A:** 1. Point DNS to your server
2. Update `.env`:
```bash
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
CORS_ORIGIN=https://yourdomain.com
```
3. Run SSL setup:
```bash
sudo bash setup-ssl.sh
```
4. Restart services:
```bash
docker-compose restart
```

### Q: How do I view logs?
**A:**
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs api
docker-compose logs web
docker-compose logs postgres

# Last 100 lines
docker-compose logs --tail=100

# Follow logs in real-time
docker-compose logs -f
```

---

## Common Issues & Solutions

### 🔴 "Connection refused" on port 80

**Problem**: Cannot access the application

**Solutions**:
```bash
# Check if NGINX is running
docker-compose ps nginx

# Check if port 80 is in use
sudo lsof -i :80

# Kill conflicting process
sudo kill -9 <PID>

# Restart NGINX
docker-compose restart nginx
```

### 🔴 API returning 502 Bad Gateway

**Problem**: NGINX can't reach API

**Solutions**:
```bash
# Check if API is running
docker-compose ps api

# Check API logs
docker-compose logs api

# Check if API is responsive
curl http://localhost:3001/health

# Restart API
docker-compose restart api
```

### 🔴 Database connection failed

**Problem**: Cannot connect to PostgreSQL

**Solutions**:
```bash
# Check if database is running
docker-compose ps postgres

# Test database connection
docker-compose exec postgres psql -U $(grep DB_USER .env | cut -d= -f2) -d $(grep DB_NAME .env | cut -d= -f2) -c "SELECT 1"

# Check database logs
docker-compose logs postgres

# Verify credentials in .env
grep DATABASE_URL .env

# Restart database
docker-compose restart postgres
```

### 🔴 Out of disk space

**Problem**: Getting disk full errors

**Solutions**:
```bash
# Check disk usage
df -h

# Clean up Docker
docker system prune -a  # Remove unused images
docker volume prune     # Remove unused volumes

# Check what's taking space
du -sh /opt/military-attendance/*

# Remove old backups (keep recent ones)
ls -t .deploy-backups/ | tail -n +11 | xargs rm -rf
```

### 🔴 High memory usage

**Problem**: Services using too much RAM

**Solutions**:
```bash
# Monitor memory
docker stats

# Check which service is using it
docker-compose top api  # or web, postgres, etc

# Restart problematic service
docker-compose restart api

# Check logs for memory leaks
docker-compose logs api | grep -i memory
```

### 🔴 Slow response times

**Problem**: Application is slow

**Diagnosis**:
```bash
# Check system resources
docker stats

# Check API response time
time curl http://localhost:3001/health

# Check database query performance
docker-compose logs postgres | grep slow

# Monitor network
docker stats --no-stream
```

**Solutions**:
- Increase server resources
- Enable Redis caching
- Optimize database queries
- Add more API replicas

### 🔴 Migrations failing

**Problem**: Database migration errors

**Solutions**:
```bash
# Check migration status
docker-compose exec api npx prisma migrate status

# View pending migrations
docker-compose exec api npx prisma migrate resolve

# Manually reset (⚠️ DESTRUCTIVE)
docker-compose exec api npx prisma migrate reset

# Check database logs
docker-compose logs postgres
```

### 🔴 Services randomly crashing

**Problem**: Services restart unexpectedly

**Solutions**:
```bash
# Check service logs
docker-compose logs --tail=50

# Check if it's running out of memory
free -h

# Check disk space
df -h

# Check system logs
docker-compose logs | grep -i error

# Increase memory/resources
# Edit docker-compose.yml and adjust limits
```

### 🔴 SSL certificate issues

**Problem**: HTTPS not working or certificate errors

**Solutions**:
```bash
# Check certificate
certbot certificates

# Renew certificate
certbot renew

# Check NGINX SSL config
docker-compose exec nginx nginx -t

# View NGINX logs
docker-compose logs nginx

# Rebuild NGINX if changed
docker-compose up -d nginx
```

### 🔴 Getting "too many requests" errors

**Problem**: Rate limiting is kicking in

**Solutions**:
```bash
# This is normal if you're hammering the API
# Default is 100 requests per 15 minutes per IP

# Disable rate limiting for testing (not recommended for production):
# Edit apps/api/src/main.ts and comment out the rateLimit() middleware
```

---

## Advanced Troubleshooting

### Check Docker daemon is running
```bash
sudo systemctl status docker

# Start Docker if needed
sudo systemctl start docker
```

### Force restart everything
```bash
cd /opt/military-attendance

# Stop everything
docker-compose down

# Remove problematic volumes (⚠️ DELETES DATA)
docker volume ls
docker volume rm <volume-name>

# Start fresh
docker-compose up -d
```

### Rebuild from scratch
```bash
cd /opt/military-attendance

# Remove everything
docker-compose down -v

# Rebuild images
docker-compose build --no-cache

# Start
docker-compose up -d

# Run migrations
docker-compose exec api npx prisma migrate deploy
```

### Debug inside container
```bash
# Open shell in API container
docker-compose exec api sh

# Inside container, you can:
# - Check environment: env
# - Check files: ls -la
# - Test network: curl
# - View config: cat .env
```

### Network issues
```bash
# Check if services can reach each other
docker network ls
docker network inspect <network-name>

# Test connectivity from one service to another
docker-compose exec api curl http://web:3000
docker-compose exec api curl http://postgres:5432
```

---

## Performance Tuning

### Database Connection Pooling
Edit `.env`:
```bash
DB_POOL_MIN=5    # Minimum connections
DB_POOL_MAX=20   # Maximum connections
```

### Cache Tuning
```bash
REDIS_PASSWORD=your-secure-password
# Redis will cache sessions and frequently accessed data
```

### NGINX Caching
Edit `nginx/default.conf` to adjust:
```nginx
gzip_level 6;              # Compression level (1-9)
client_max_body_size 20M;  # Max file upload
proxy_cache_valid 200 30d; # Cache static files 30 days
```

---

## Getting More Help

### Useful Commands Reference
```bash
# Check status
docker-compose ps
docker-compose status

# View real-time logs
docker-compose logs -f

# Execute commands in container
docker-compose exec api npm run build

# Monitor resources
docker stats

# Backup and restore
bash backup.sh
docker-compose exec postgres psql < backup.sql

# Health check
bash health-check.sh

# Deploy updates
bash deploy.sh
```

### Documentation
- Full Deployment Guide: [DEPLOYMENT.md](DEPLOYMENT.md)
- API Documentation: [docs/api.md](docs/api.md)
- Architecture: [docs/architecture.md](docs/architecture.md)

### Getting Help
1. **Check logs** - 99% of issues are in logs
2. **Review this FAQ** - Common issues are documented
3. **Check installed backups** - Rollback if needed
4. **Report issues** - GitHub Issues (include logs)

---

## Emergency Contacts

If critical issues occur:

1. **Database corrupted**: Restore from backup
   ```bash
   bash backup.sh  # Create fresh backup
   docker-compose exec postgres psql < backup_file.sql
   ```

2. **Services won't start**: Check logs and rebuild
   ```bash
   docker-compose logs
   docker-compose down -v
   docker-compose up -d
   ```

3. **Security breach suspected**: 
   - Stop services: `docker-compose down`
   - Review logs: `docker-compose logs > full_logs.txt`
   - Regenerate secrets in `.env`
   - Rebuild and restart

---

**Last Updated**: 2024  
**Version**: 1.0.0
