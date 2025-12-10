# docker/Dockerfile.php

# STAGE 1: FASE DE CONSTRUCCIÓN (BUILDER)
FROM php:8.3-fpm-alpine AS builder 
# Instalar dependencias de construcción si son necesarias
RUN apk update && apk add --no-cache composer

WORKDIR /app
COPY src/app*/composer.json /app/
RUN composer install --no-dev --prefer-dist --optimize-autoloader

# STAGE 2: FASE FINAL DE EJECUCIÓN (RUNTIME)
FROM php:8.3-fpm-alpine AS final

# Configurar PHP-FPM para escuchar en todas las interfaces (necesario para Docker networking)
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/www.conf

# Principio de Mínimo Privilegio: El usuario por defecto de PHP-FPM es www-data (UID > 0)
RUN chown -R www-data:www-data /var/www/html

# Copiar solo los artefactos necesarios (código NO se copia aquí, se monta como RO en compose)
COPY --from=builder /app/vendor /var/www/html/vendor

USER www-data
CMD ["php-fpm"]
