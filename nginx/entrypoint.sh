#!/bin/sh
set -e

echo "Starting Nginx reverse proxy..."

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f /etc/nginx/ssl/cert.pem ]; then
    echo "Generating self-signed SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out /etc/nginx/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    echo "SSL certificate generated"
else
    echo "SSL certificate already exists"
fi

echo "Starting OpenResty..."
exec /usr/local/openresty/bin/openresty -g "daemon off;"
