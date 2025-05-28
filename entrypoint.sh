#!/bin/bash

# Wait for database to be ready
while ! mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" --silent; do
    echo "Waiting for database..."
    sleep 1
done

# Run migrations
php artisan migrate --force
php artisan db:seed --force
# Start Apache
exec apache2-foreground