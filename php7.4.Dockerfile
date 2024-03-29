# Build with:
# PHP v8.0.3
# Composer v1 as symfony-flex not yet support v2
# Apache
# Yarn
# Node v.15

FROM composer:2 AS composer

FROM php:7.4-apache
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /app

# OS Package install
RUN apt-get update -y
RUN apt-get install -y zlibc git zip unzip zlib1g-dev libicu-dev g++ libpng-dev libjpeg-dev libfreetype6-dev libzip-dev

# PHP extension
RUN docker-php-ext-configure gd \
    --with-jpeg \
    --with-freetype
RUN docker-php-ext-install ctype iconv pdo_mysql opcache gd bcmath zip

#----- Skip Host verification for git
ARG USER_HOME_DIR=/root
RUN mkdir ${USER_HOME_DIR}/.ssh/
RUN echo "StrictHostKeyChecking no " > ${USER_HOME_DIR}/.ssh/config

#----- Apache config
RUN a2enmod rewrite deflate headers
# setup web document root
ARG APACHE_DOCUMENT_ROOT=/app/public
RUN sed -ri -e 's!/var/www/html!/app/public!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www!/app/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
# enable sites
RUN a2ensite 000-default

# Setup OPCache
RUN sed -i \
    -e "s/\$/\nopcache.enable=1/" \
    -e "s/\$/\nopcache.enable_cli=1/" \
    -e "s/\$/\nopcache.memory_consumption=200/" \
    -e "s/\$/\nopcache.interned_strings_buffer=8/" \
    -e "s/\$/\nopcache.max_accelerated_files=10000/" \
    -e "s/\$/\nopcache.revalidate_freq=2/" \
    -e "s/\$/\nopcache.validate_timestamps=1/" \
    -e "s/\$/\nopcache.max_wasted_percentage=10/" \
    -e "s/\$/\nopcache.interned_strings_buffer=10/" \
    /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

#----- Cleaning
RUN apt-get clean -y

#----- Setup php.ini
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
