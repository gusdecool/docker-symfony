FROM composer:2 AS composer

FROM php:8.1-fpm-alpine
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /app

# update package list
RUN apk update && apk upgrade
