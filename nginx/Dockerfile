FROM openresty/openresty:alpine

# Install openssl for certificate generation
RUN apk add --no-cache openssl

# Create directories for SSL certificates and logs
RUN mkdir -p /etc/nginx/ssl /var/log/nginx

# Copy nginx configuration
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
EXPOSE 80 443 22

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
