FROM composer:latest AS composer

FROM php:7.2-apache-stretch
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

ENV WORKDIR /app

WORKDIR ${WORKDIR}

#--------------------------------------------------------------------------------------------------
# Install base packages
#--------------------------------------------------------------------------------------------------

RUN apt-get update -y

# Requirement for Composer
RUN apt-get install -y zlibc git zip unzip zlib1g-dev libicu-dev g++ ssl-cert

#--------------------------------------------------------------------------------------------------
# Install PHP Modules
#--------------------------------------------------------------------------------------------------

# Install PHP Extension required for Symfony
RUN docker-php-ext-install intl pdo_mysql bcmath

# Install PHP GD
RUN apt-get install -y libgd-dev
RUN docker-php-ext-install gd

# Install PHP XDebug
RUN pecl install xdebug-2.7.2
RUN docker-php-ext-enable xdebug

# Install PHP Soap
RUN apt-get install -y libxml2-dev
RUN docker-php-ext-install soap

#--------------------------------------------------------------------------------------------------
# Setup Apache
#--------------------------------------------------------------------------------------------------

# Apache Modules
RUN a2enmod rewrite
RUN a2enmod deflate
RUN a2enmod headers
RUN a2enmod ssl

# Enable SSL sites
RUN a2ensite default-ssl

# Set Apache root directory
RUN echo "Set Apache root directory"
ENV APACHE_DOCUMENT_ROOT ${WORKDIR}/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

#--------------------------------------------------------------------------------------------------
# Setup PHP & modules
#--------------------------------------------------------------------------------------------------

COPY config/xdebug/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

#--------------------------------------------------------------------------------------------------
# Post setup
#--------------------------------------------------------------------------------------------------

# Clean out directory
RUN apt-get clean -y
