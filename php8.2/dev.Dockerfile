FROM gusdecool/symfony:php8.2-dev

#----- Install packages
RUN apt-get update -y \
    # install xdebug
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

#----- Setup php.ini
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && sed -i "s|error_reporting\s=\sE_ALL|error_reporting= E_ALL \| E_STRICT|g" /usr/local/etc/php/php.ini \
    && sed -i "s|memory_limit = 1024M|memory_limit = 2024M|g" /usr/local/etc/php/php.ini \
    && sed -i "s|max_execution_time = 30|max_execution_time = 300|g" /usr/local/etc/php/php.ini \
    && sed -i "s|upload_max_filesize = 2M|upload_max_filesize = 10M|g" /usr/local/etc/php/php.ini \
    && sed -i "s|post_max_size = 8M|upload_max_filesize = 10M|g" /usr/local/etc/php/php.ini

#----- Setup xdebug.ini
RUN sed -i \
    -e "s/\$/\nxdebug.mode=\"develop,debug\"/" \
    -e "s/\$/\nxdebug.start_with_request=\"trigger\"/" \
    -e "s/\$/\nxdebug.idekey=\"PHPSTORM\"/" \
    -e "s/\$/\nxdebug.client_host=host.docker.internal/" \
    /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
