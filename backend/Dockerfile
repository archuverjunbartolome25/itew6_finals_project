# Use the official PHP image
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    supervisor \
    cron \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath zip

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Clear package cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Create system user to run Composer and Artisan Commands
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/html

# Change current user to www
USER www

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Install Node.js and NPM
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install NPM dependencies and build assets
RUN npm install && npm run build

# Set up Laravel environment
RUN cp .env.production .env

# Generate Laravel application key
RUN php artisan key:generate

# Create storage link
RUN php artisan storage:link

# Cache Laravel configuration
RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

# Expose port 9000 and start php-fpm server
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
