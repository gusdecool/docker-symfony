FROM composer:latest AS composer

FROM php:7.4-apache
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

ARG WORKDIR=/app
WORKDIR ${WORKDIR}

#--------------------------------------------------------------------------------------------------
# Install base packages
#--------------------------------------------------------------------------------------------------

RUN apt-get update -y
RUN apt-get install -y zlibc git zip unzip zlib1g-dev libicu-dev g++ ssl-cert vim

#--------------------------------------------------------------------------------------------------
# Setup Apache
#--------------------------------------------------------------------------------------------------

# Apache Modules
RUN a2enmod rewrite
RUN a2enmod deflate
RUN a2enmod headers
RUN a2enmod ssl

# Set Apache root directory
RUN echo "Set Apache root directory"
ENV APACHE_DOCUMENT_ROOT ${WORKDIR}/public

RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf
RUN sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Setup SSL the SSL
COPY ./ssl-certificate /ssl-certificate
RUN sed -ri -e \
    's!SSLCertificateFile\s+/etc/ssl/certs/ssl-cert-snakeoil.pem!SSLCertificateFile /ssl-certificate/server.crt!g' \
    /etc/apache2/sites-available/default-ssl.conf

RUN sed -ri -e \
    's!SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key!SSLCertificateKeyFile /ssl-certificate/server.key!g' \
     /etc/apache2/sites-available/default-ssl.conf

# Enable the sites
RUN a2ensite 000-default
RUN a2ensite default-ssl

#--------------------------------------------------------------------------------------------------
# Setup PHP
#--------------------------------------------------------------------------------------------------

# Setup INI
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -i "s|error_reporting\s=\sE_ALL|error_reporting= E_ALL \| E_STRICT|g" /usr/local/etc/php/php.ini
RUN sed -i "s|memory_limit = 1024M|memory_limit = 2024M|g" /usr/local/etc/php/php.ini

# Install PHP Extension required for Symfony
RUN apt-get install -y libgd-dev libxml2-dev
RUN docker-php-ext-install intl
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install gd
RUN docker-php-ext-install soap

# Install OPCache
RUN docker-php-ext-install opcache
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

# Install XDEBUG
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

RUN sed -i \
    -e "s/\$/\nxdebug.mode=\"develop,debug\"/" \
    -e "s/\$/\nxdebug.start_with_request=\"trigger\"/" \
    -e "s/\$/\nxdebug.idekey=\"PHPSTORM\"/" \
    -e "s/\$/\nxdebug.client_host=host.docker.internal/" \
    /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

#--------------------------------------------------------------------------------------------------
# Install Yarn
#--------------------------------------------------------------------------------------------------

RUN apt-get install -y gnupg
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update
RUN apt install -y yarn

#--------------------------------------------------------------------------------------------------
# Post setup
#--------------------------------------------------------------------------------------------------

# Install PHP MongoDB
RUN apt-get install -y libcurl4-openssl-dev pkg-config libssl-dev
RUN pecl install mongodb
RUN docker-php-ext-enable mongodb

# strangely required by Symfony
RUN apt-get install -y python2

# install postgress
RUN apt-get install -y libpq-dev
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pgsql pdo_pgsql

# Clean out directory
RUN apt-get clean -y
