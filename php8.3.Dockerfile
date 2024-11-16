# docker image prod designed for AWS AppRunner
# contents
# PHP 8.3
# WebServer nginx
FROM composer:2 AS composer

FROM php:8.3-fpm-alpine
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
WORKDIR /app

# add install-php-extensions to optimize the PHP size
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# install php extensions
RUN install-php-extensions mysqli pdo_mysql intl

# setup PHP .ini
COPY php-config/error_reporting.ini /usr/local/etc/php/conf.d/error_reporting.ini

# configure PHP-FPM to forward error logs to Docker
RUN echo "catch_workers_output = yes" >> /usr/local/etc/php-fpm.d/www.conf

# setup nginx
RUN apk add nginx
COPY nginx-config/site.conf /etc/nginx/http.d/*.conf

# to allow composer to run executable file
ENV COMPOSER_ALLOW_SUPERUSER=1

# open port 80
EXPOSE 80

# fix warning JSONArgsRecommended: JSON arguments recommended for CMD to prevent unintended behavior related to OS signals (line 38)
CMD ["sh", "-c", "nginx -g 'daemon off;' & php-fpm"]
