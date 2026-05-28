FROM php:8.4-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libwebp-dev \
    tini \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions (including GD with full webp/jpeg format support)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install bcmath exif gd zip

# Pull latest Composer directly into our custom engine image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

EXPOSE 8000

ENTRYPOINT [ "tini", "--", "php" ]
CMD ["artisan", "serve", "--host=0.0.0.0", "--port=8000"]
