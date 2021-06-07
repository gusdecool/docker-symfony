FROM gusdecool/symfony:7.4

# Install PHP Xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

# Add apache SSL
RUN a2enmod ssl

# Setup SSL keys
COPY ./ssl-certificate /ssl-certificate
RUN sed -ri -e \
    's!SSLCertificateFile\s+/etc/ssl/certs/ssl-cert-snakeoil.pem!SSLCertificateFile /ssl-certificate/server.crt!g' \
    /etc/apache2/sites-available/default-ssl.conf

RUN sed -ri -e \
    's!SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key!SSLCertificateKeyFile /ssl-certificate/server.key!g' \
     /etc/apache2/sites-available/default-ssl.conf

RUN a2ensite default-ssl

# Setup xdebug
RUN sed -i \
    -e "s/\$/\nxdebug.mode=\"develop,debug\"/" \
    -e "s/\$/\nxdebug.start_with_request=\"trigger\"/" \
    -e "s/\$/\nxdebug.idekey=\"PHPSTORM\"/" \
    -e "s/\$/\nxdebug.client_host=host.docker.internal/" \
    /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get clean -y
