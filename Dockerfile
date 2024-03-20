# Use the official PHP image as the base image
FROM php:8.1
# Install required system packages and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install zip gd \
    && docker-php-ext-install zip \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set the working directory
WORKDIR /var/www/html

# Copy Laravel application files
COPY . .
# Install PHP dependencies
RUN composer update
RUN composer dump-autoload
# Set permissions for Laravel
RUN mkdir -p /var/www/html/storage/framework/views
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
# Expose the PHP port
EXPOSE 8000
# Start Laravel development server
CMD php artisan migrate
CMD php artisan cache:clear
CMD php artisan serve --host=0.0.0.0 --port=8000
