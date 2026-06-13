#!/bin/sh
set -e

# Ensure required dirs exist (volume mount may wipe them)
mkdir -p storage/framework/cache/data \
         storage/framework/sessions \
         storage/framework/views \
         storage/logs \
         bootstrap/cache

# Fix permissions
chown www-data:www-data /var/www/html/.env
chown -R www-data:www-data storage bootstrap/cache content
chmod -R 775 storage bootstrap/cache content

# Generate APP_KEY if missing
if ! grep -q '^APP_KEY=.\+' /var/www/html/.env; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Seed content from image if volume is empty (first deploy)
if [ -z "$(ls -A content 2>/dev/null)" ]; then
    echo "Seeding initial content..."
    cp -r /var/www/html/content.seed/. /var/www/html/content/
fi

php artisan vendor:publish --tag=statamic-cp --force

exec tini -- php artisan serve --host=0.0.0.0 --port=8000
