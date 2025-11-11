# Base image: official WordPress with Apache
FROM wordpress:6.4-apache

# Install any extra utilities you might want
RUN apt-get update && apt-get install -y less wget unzip \
    && rm -rf /var/lib/apt/lists/*

# (Optional) — copy plugins or themes if you have them
# COPY plugins /usr/src/wordpress/wp-content/plugins/
# COPY themes /usr/src/wordpress/wp-content/themes/

# Fix permissions (important for uploads)
RUN chown -R www-data:www-data /var/www/html/wp-content

# Expose port 80 for HTTP traffic
EXPOSE 80

# Default WordPress entrypoint
CMD ["apache2-foreground"]
