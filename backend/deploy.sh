#!/bin/bash

# Laravel Cloud Deployment Script
# This script helps deploy your Laravel application to Laravel Cloud

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Laravel Cloud CLI is installed
check_laravel_cloud_cli() {
    if ! command -v laravel-cloud &> /dev/null; then
        log_warning "Laravel Cloud CLI not found. Installing..."
        curl -sSL https://laravel.cloud/install | bash
        if command -v laravel-cloud &> /dev/null; then
            log_success "Laravel Cloud CLI installed successfully"
        else
            log_error "Failed to install Laravel Cloud CLI"
            exit 1
        fi
    else
        log_success "Laravel Cloud CLI is already installed"
    fi
}

# Check if we're logged in to Laravel Cloud
check_auth() {
    log_info "Checking Laravel Cloud authentication..."
    if laravel-cloud whoami &> /dev/null; then
        log_success "Already authenticated with Laravel Cloud"
    else
        log_warning "Not authenticated with Laravel Cloud"
        log_info "Please run: laravel-cloud login"
        exit 1
    fi
}

# Prepare the application for deployment
prepare_app() {
    log_info "Preparing application for deployment..."
    
    # Install Composer dependencies
    log_info "Installing Composer dependencies..."
    composer install --no-dev --optimize-autoloader --prefer-dist
    
    # Install NPM dependencies and build assets
    log_info "Building frontend assets..."
    npm ci
    npm run build
    
    # Copy production environment file
    if [ -f ".env.production" ]; then
        cp .env.production .env
        log_success "Production environment file copied"
    else
        log_warning ".env.production not found, using .env.example"
        cp .env.example .env
    fi
    
    # Generate application key
    log_info "Generating application key..."
    php artisan key:generate --force
    
    # Cache Laravel configuration
    log_info "Caching Laravel configuration..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    # Create storage link
    log_info "Creating storage link..."
    php artisan storage:link
    
    log_success "Application preparation completed"
}

# Deploy to Laravel Cloud
deploy_to_cloud() {
    log_info "Deploying to Laravel Cloud..."
    
    # Check if deployment.yaml exists
    if [ ! -f ".cloud/deployment.yaml" ]; then
        log_error "deployment.yaml not found in .cloud directory"
        exit 1
    fi
    
    # Deploy the application
    if laravel-cloud deploy --force; then
        log_success "Deployment initiated successfully"
    else
        log_error "Deployment failed"
        exit 1
    fi
}

# Health check
health_check() {
    log_info "Performing health check..."
    
    # Get the application URL from Laravel Cloud
    APP_URL=$(laravel-cloud info | grep "URL" | awk '{print $2}')
    
    if [ -z "$APP_URL" ]; then
        log_warning "Could not retrieve application URL"
        return
    fi
    
    log_info "Checking application health at: $APP_URL"
    
    # Wait for the application to be ready
    for i in {1..30}; do
        if curl -f "$APP_URL/health" &> /dev/null; then
            log_success "Application is healthy and ready!"
            echo "Application URL: $APP_URL"
            break
        else
            log_info "Waiting for application to be ready... ($i/30)"
            sleep 10
        fi
        
        if [ $i -eq 30 ]; then
            log_warning "Health check failed after 30 attempts"
            log_info "Please check the application logs: laravel-cloud logs"
        fi
    done
}

# Main deployment process
main() {
    log_info "Starting Laravel Cloud deployment process..."
    
    # Check prerequisites
    check_laravel_cloud_cli
    check_auth
    
    # Prepare application
    prepare_app
    
    # Deploy
    deploy_to_cloud
    
    # Health check
    health_check
    
    log_success "Deployment process completed!"
    log_info "You can check your application status with: laravel-cloud info"
    log_info "View logs with: laravel-cloud logs"
}

# Handle script arguments
case "${1:-}" in
    "prepare")
        prepare_app
        ;;
    "deploy")
        deploy_to_cloud
        ;;
    "health")
        health_check
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [prepare|deploy|health|help]"
        echo ""
        echo "Commands:"
        echo "  prepare  - Prepare the application for deployment"
        echo "  deploy   - Deploy to Laravel Cloud"
        echo "  health   - Perform health check after deployment"
        echo "  help     - Show this help message"
        echo ""
        echo "If no command is provided, the full deployment process will run."
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown command: $1"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac
