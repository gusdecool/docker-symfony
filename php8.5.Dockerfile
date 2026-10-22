# docker image prod designed for AWS AppRunner
# contents
# - PHP 8.5
# - WebServer nginx
FROM composer:2 AS composer

FROM php:8.5-fpm-bookworm
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
WORKDIR /app

# add install-php-extensions to optimize the PHP size
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# install php extensions
RUN install-php-extensions mysqli pdo_mysql intl bcmath

# setup PHP .ini
COPY docker-config/php-error_reporting.ini /usr/local/etc/php/conf.d/error_reporting.ini

# configure PHP-FPM to forward error logs to Docker
RUN echo "catch_workers_output = yes" >> /usr/local/etc/php-fpm.d/www.conf

# setup nginx (drop Debian's default site so it doesn't conflict with ours on port 80)
RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/* /etc/nginx/sites-enabled/default
COPY docker-config/nginx-site.conf /etc/nginx/conf.d/default.conf

# to allow composer to run executable file
ENV COMPOSER_ALLOW_SUPERUSER=1

# open port 80
EXPOSE 80

# fix warning JSONArgsRecommended: JSON arguments recommended for CMD to prevent unintended behavior related to OS signals (line 38)
CMD ["sh", "-c", "nginx -g 'daemon off;' & php-fpm"]

# install nodejs and npm (NodeSource repo, since Debian's own nodejs/npm
# packages pull in a large tree of repackaged node-* library dependencies).
# npm is upgraded because the copy bundled with nodejs ships vulnerable dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/*
