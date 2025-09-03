# Single-stage Laravel Docker image
FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    sqlite \
    sqlite-dev \
    libzip-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    nodejs \
    npm \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_sqlite \
        zip \
        mbstring \
        gd \
        fileinfo \
        opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-autoloader

# Copy package files and install Node.js dependencies
COPY package*.json ./
RUN npm install

# Copy application code
COPY . .

# Build frontend assets
RUN npm run build

# Install Composer autoloader
RUN composer dump-autoload --optimize --no-dev --classmap-authoritative

# Create necessary directories and set permissions
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    storage/app/public \
    bootstrap/cache \
    /var/log/supervisor \
    /var/run/supervisor \
    && chown -R www-data:www-data \
        storage \
        bootstrap/cache \
        public \
        database \
    && chmod -R 775 \
        storage \
        bootstrap/cache \
        database

# Copy configuration files
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/start.sh /start.sh

# Make start script executable
RUN chmod +x /start.sh

# Expose port
EXPOSE 80

# Start services
CMD ["/start.sh"]
