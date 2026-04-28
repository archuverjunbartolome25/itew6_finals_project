# Laravel Cloud Deployment Guide

This guide will help you deploy your Laravel application to Laravel Cloud.

## Prerequisites

1. **Laravel Cloud Account**: Sign up at [laravel.cloud](https://laravel.cloud)
2. **Laravel Cloud CLI**: Install the CLI tool
3. **Git Repository**: Your code should be in a Git repository
4. **Environment Variables**: Have your production environment variables ready

## Quick Start

### 1. Install Laravel Cloud CLI

```bash
curl -sSL https://laravel.cloud/install | bash
```

### 2. Authenticate

```bash
laravel-cloud login
```

### 3. Deploy

```bash
# Using the deployment script
chmod +x deploy.sh
./deploy.sh

# Or manually
laravel-cloud deploy
```

## Configuration Files

### `.cloud/deployment.yaml`

This is the main configuration file for your Laravel Cloud deployment. It defines:

- **Build settings**: PHP version, Node.js version, optimization
- **Environment variables**: Production configuration
- **Services**: Database, Redis, queue workers
- **Scaling**: Auto-scaling rules
- **Security**: SSL, firewall, encryption
- **Monitoring**: Health checks, metrics, error tracking

### `.env.production`

Production environment variables. Key variables include:

- `APP_ENV=production`
- `APP_DEBUG=false`
- Database configuration (provided by Laravel Cloud)
- Cache and session drivers
- Mail configuration
- AWS S3 configuration

## Deployment Methods

### Method 1: Automatic (GitHub Actions)

1. **Set up Secrets** in your GitHub repository:
   - `LARAVEL_CLOUD_TOKEN`: Your Laravel Cloud API token
   - `SLACK_WEBHOOK_URL`: Optional Slack notifications

2. **Push to main branch**:
   ```bash
   git push origin main
   ```

The workflow will:
- Run tests
- Build assets
- Deploy to Laravel Cloud
- Perform health checks
- Send notifications

### Method 2: Manual (CLI)

1. **Prepare the application**:
   ```bash
   ./deploy.sh prepare
   ```

2. **Deploy**:
   ```bash
   ./deploy.sh deploy
   ```

3. **Health check**:
   ```bash
   ./deploy.sh health
   ```

### Method 3: Full Process

Run the complete deployment script:
```bash
chmod +x deploy.sh
./deploy.sh
```

## Environment Setup

### Required Environment Variables

Create these in your Laravel Cloud dashboard or GitHub secrets:

#### Database (Provided by Laravel Cloud)
- `DB_HOST`
- `DB_PORT`
- `DB_DATABASE`
- `DB_USERNAME`
- `DB_PASSWORD`

#### Redis (Provided by Laravel Cloud)
- `REDIS_HOST`
- `REDIS_PASSWORD`
- `REDIS_PORT`

#### Mail Configuration
- `MAIL_HOST`
- `MAIL_PORT`
- `MAIL_USERNAME`
- `MAIL_PASSWORD`
- `MAIL_ENCRYPTION`
- `MAIL_FROM_ADDRESS`
- `MAIL_FROM_NAME`

#### AWS S3 (Optional)
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`
- `AWS_BUCKET`

#### Security
- `TRUSTED_PROXIES`
- `TRUSTED_HOSTS`
- `CORS_ALLOWED_ORIGINS`
- `CORS_ALLOWED_METHODS`
- `CORS_ALLOWED_HEADERS`

## Services Configuration

### Database
- **Type**: MySQL 8.0
- **Size**: Small (can be scaled)
- **Backups**: Daily with 30-day retention

### Cache
- **Type**: Redis 7.0
- **Size**: Small (can be scaled)
- **Uses**: Cache, sessions, queues

### Queue Worker
- **Type**: Worker
- **Command**: `php artisan queue:work --sleep=3 --tries=3 --max-time=300`

## Monitoring and Logging

### Health Checks
- **Path**: `/health`
- **Method**: GET
- **Expected Status**: 200

### Monitoring
- **Metrics**: Application performance metrics
- **Error Tracking**: Automatic error collection
- **Performance**: Response time and throughput monitoring

### Logs
View logs with:
```bash
laravel-cloud logs
```

## Scaling Configuration

### Auto-scaling
- **Min Instances**: 1
- **Max Instances**: 10
- **Target CPU**: 70%
- **Target Memory**: 80%

### Manual Scaling
```bash
# Scale up
laravel-cloud scale --instances=5

# Scale down
laravel-cloud scale --instances=2
```

## Security Features

### SSL/TLS
- Automatic SSL certificate generation
- HTTPS enforced by default
- Security headers included

### Firewall
- Only ports 80, 443, and 22 open
- DDoS protection included
- Web Application Firewall (WAF)

### Environment Security
- Environment variables encrypted
- Secrets management
- Access control

## Backup Strategy

### Database Backups
- **Frequency**: Daily at 2 AM
- **Retention**: 30 days
- **Location**: Cloud storage

### Storage Backups
- **Frequency**: Weekly on Sunday at 3 AM
- **Retention**: 4 weeks
- **Location**: Cloud storage

### Manual Backup
```bash
# Create manual backup
laravel-cloud backup create

# List backups
laravel-cloud backup list

# Restore backup
laravel-cloud backup restore <backup-id>
```

## Custom Domains

### Add Custom Domain
1. In Laravel Cloud dashboard, go to "Domains"
2. Add your domain (e.g., `your-domain.com`)
3. Configure DNS records:
   ```
   A    @    <laravel-cloud-ip>
   A    www  <laravel-cloud-ip>
   ```

### SSL Certificates
- Automatic SSL certificate generation
- Certificate renewal handled automatically
- Support for wildcard certificates

## Troubleshooting

### Common Issues

#### Deployment Fails
```bash
# Check deployment logs
laravel-cloud logs --deployment

# Check application logs
laravel-cloud logs --app
```

#### Health Check Fails
```bash
# Check application status
laravel-cloud info

# Manual health check
curl https://your-app.laravelcloud.com/health
```

#### Database Connection Issues
```bash
# Test database connection
laravel-cloud exec php artisan tinker
>>> DB::connection()->getPdo()
```

#### Performance Issues
```bash
# Check resource usage
laravel-cloud metrics

# Scale resources
laravel-cloud scale --instances=5
```

### Debug Commands

```bash
# Application info
laravel-cloud info

# Resource usage
laravel-cloud resources

# Recent deployments
laravel-cloud deployments

# Environment variables
laravel-cloud env

# Execute commands
laravel-cloud exec <command>
```

## Best Practices

### Before Deployment
1. **Run tests locally**: `php artisan test`
2. **Check code quality**: `composer lint`
3. **Backup current version**: `laravel-cloud backup create`
4. **Review environment variables**

### After Deployment
1. **Verify health check**: `curl /health`
2. **Check logs**: `laravel-cloud logs`
3. **Monitor metrics**: `laravel-cloud metrics`
4. **Test key functionality**

### Ongoing Maintenance
1. **Regular updates**: Keep dependencies updated
2. **Monitor performance**: Check metrics regularly
3. **Review logs**: Check for errors daily
4. **Backup strategy**: Ensure backups are working

## Support

### Laravel Cloud Documentation
- [Official Docs](https://laravel.cloud/docs)
- [API Reference](https://laravel.cloud/api)
- [Community Forums](https://laravel.cloud/community)

### Help Commands
```bash
# Get help
laravel-cloud --help

# Get specific command help
laravel-cloud deploy --help
```

### Contact Support
- Email: support@laravel.cloud
- Chat: Available in Laravel Cloud dashboard
- Status: [status.laravel.cloud](https://status.laravel.cloud)

## Cost Optimization

### Tips to Reduce Costs
1. **Right-size instances**: Don't over-provision
2. **Use auto-scaling**: Scale based on demand
3. **Optimize queries**: Reduce database load
4. **Use caching**: Reduce API calls
5. **Monitor usage**: Track resource consumption

### Billing
- **Pay-as-you-go**: Only pay for what you use
- **Free tier**: Available for small applications
- **Monthly billing**: Billed monthly based on usage
- **Usage alerts**: Set up billing alerts

## Advanced Configuration

### Custom Build Steps
Add custom build steps in `deployment.yaml`:
```yaml
build:
  custom_steps:
    - php artisan custom:command
    - npm run custom:build
```

### Environment-Specific Configs
Create multiple environment files:
- `.env.staging`
- `.env.production`
- `.env.testing`

### Custom Health Checks
Define custom health checks:
```yaml
health:
  custom_checks:
    - path: /api/health
      method: POST
      body: '{"check": "database"}'
      expected_status: 200
```

This deployment guide should help you successfully deploy your Laravel application to Laravel Cloud with confidence!
