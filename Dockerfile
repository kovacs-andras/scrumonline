# build scrumonline
FROM php:7.4.33-cli-alpine@sha256:1e1b3bb4ee1bcb039f559adb9a3fae391c87205ba239b619cdc239b78b7f2557 as builder
ARG COMPOSER_ALLOW_SUPERUSER=1
COPY scrumonline /scrumonline
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer -O - -q | php --
RUN php composer.phar update -n -d /scrumonline
RUN php composer.phar install -n -d /scrumonline
RUN touch /scrumonline/src/sponsors.php
RUN mv /scrumonline/src/sample-config.php /scrumonline/src/config.php
COPY config.php /tmp
RUN cat /tmp/config.php >> /scrumonline/src/config.php
COPY mysql_init.sh /scrumonline/

# build the web frontend
FROM php:7.4.33-apache@sha256:18b3497ee7f2099a90b66c23a0bc3d5261b12bab367263e1b40e9b004c39e882
ENV DB_NAME=scrum_online
ENV DB_USER=root
ENV DB_PASS=passwd
ENV DB_HOST=127.0.0.1
ENV HOST="http://localhost:80"

RUN a2enmod rewrite

RUN docker-php-ext-install pdo_mysql

WORKDIR /scrumonline

COPY --from=builder /scrumonline /scrumonline 

RUN rm -r /var/www/html && \
  ln -s /scrumonline/src/ /var/www/html
