FROM composer:2 AS composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --optimize-autoloader --no-dev --no-scripts

FROM node:20-alpine AS node
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM php:8.4-cli-alpine

RUN apk add --no-cache \
    tini zip unzip \
    libpng libjpeg-turbo freetype libwebp libzip \
    libpng-dev libjpeg-turbo-dev freetype-dev libwebp-dev libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install bcmath exif gd zip opcache \
    && apk del libpng-dev libjpeg-turbo-dev freetype-dev libwebp-dev libzip-dev \
    && rm -rf /var/cache/apk/*

WORKDIR /var/www/html

COPY . .
COPY --from=composer /app/vendor ./vendor
COPY --from=node /app/public/build ./public/build

# Keep a seed copy separate from the volume mount path
RUN cp -r content content.seed \
    && rm -f bootstrap/cache/*.php \
    && mkdir -p bootstrap/cache storage/framework/cache/data \
                storage/framework/sessions storage/framework/views \
                storage/logs

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# run as root so entrypoint can fix permissions, then drops to www-data via gosu
ENTRYPOINT ["/entrypoint.sh"]
