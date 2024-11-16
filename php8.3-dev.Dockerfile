# docker image prod designed for AWS AppRunner
# additonal contents
# - Xdebug

FROM gusdecool/symfony:php8.3 AS prod

RUN install-php-extensions xdebug
COPY docker-config/php-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
