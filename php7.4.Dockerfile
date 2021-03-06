# Build with:
# PHP v7.4
# Composer v2
# Apache

FROM composer:2 AS composer

FROM php:7.4-apache
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /app
RUN apt-get update -y

#----- Install packages
# requirement for composer
RUN apt-get install -y zlibc git zip unzip zlib1g-dev libicu-dev g++

# Symfony v5 minimum package requirements
RUN docker-php-ext-install ctype iconv

# Install MySQL TODO add as argument?
RUN docker-php-ext-install pdo_mysql

# Install PHP Xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

# Install OPCache
RUN docker-php-ext-install opcache

#----- Skip Host verification for git
ARG USER_HOME_DIR=/root
RUN mkdir ${USER_HOME_DIR}/.ssh/
RUN echo "StrictHostKeyChecking no " > ${USER_HOME_DIR}/.ssh/config

#----- Apache config
RUN a2enmod rewrite
RUN a2enmod deflate
RUN a2enmod headers
RUN a2enmod ssl

ARG APACHE_DOCUMENT_ROOT=/app/public
RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf
RUN sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Setup SSL keys
COPY ./ssl-certificate /ssl-certificate
RUN sed -ri -e \
    's!SSLCertificateFile\s+/etc/ssl/certs/ssl-cert-snakeoil.pem!SSLCertificateFile /ssl-certificate/server.crt!g' \
    /etc/apache2/sites-available/default-ssl.conf

RUN sed -ri -e \
    's!SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key!SSLCertificateKeyFile /ssl-certificate/server.key!g' \
     /etc/apache2/sites-available/default-ssl.conf

# Enable sites
RUN a2ensite 000-default
RUN a2ensite default-ssl

#----- PHP config
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -i "s|error_reporting\s=\sE_ALL|error_reporting= E_ALL \| E_STRICT|g" /usr/local/etc/php/php.ini
RUN sed -i "s|memory_limit = 1024M|memory_limit = 2024M|g" /usr/local/etc/php/php.ini

# Debug
RUN sed -i \
    -e "s/\$/\nxdebug.mode=\"develop,debug\"/" \
    -e "s/\$/\nxdebug.start_with_request=\"trigger\"/" \
    -e "s/\$/\nxdebug.idekey=\"PHPSTORM\"/" \
    -e "s/\$/\nxdebug.client_host=host.docker.internal/" \
    /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install OPCache
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
