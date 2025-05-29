#!/bin/bash

# Wait for database to be ready
while ! mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" --silent; do
    echo "Waiting for database..."
    sleep 1
done

# Replace placeholders in .env.template and save as .env
envsubst < /var/www/html/.env.template > /var/www/html/.env
# Generate Laravel APP_KEY if not already set
if grep -q "APP_KEY=" /var/www/html/.env && ! grep -q "APP_KEY=base64" /var/www/html/.env; then
  php artisan key:generate
fi

# Run migrations
php artisan migrate --force
php artisan db:seed --force
# Start Apache
exec apache2-foreground