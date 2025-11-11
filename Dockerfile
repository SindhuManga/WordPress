# ✅ Base image: Official WordPress with Apache
FROM wordpress:6.4-apache

# ✅ Switch to root to install dependencies
USER root

# ✅ Install additional utilities commonly needed in builds
RUN apt-get update && apt-get install -y \
    less \
    wget \
    unzip \
    vim \
    curl \
    jq \
    git \
    && rm -rf /var/lib/apt/lists/*

# ✅ Set working directory to WordPress root
WORKDIR /var/www/html

# ✅ Optional: copy your themes or plugins if available
# COPY plugins/ wp-content/plugins/
# COPY themes/ wp-content/themes/

# ✅ Fix permissions (important for uploads & plugin installs)
RUN chown -R www-data:www-data /var/www/html/wp-content

# ✅ Expose port 80 for HTTP traffic
EXPOSE 80

# ✅ Health check (optional but recommended for container orchestration)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost/wp-login.php || exit 1

# ✅ Switch back to non-root for better security
USER www-data
