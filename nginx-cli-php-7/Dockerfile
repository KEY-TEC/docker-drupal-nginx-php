FROM ubuntu:15.10

MAINTAINER Christian Wiedemann <christian.wiedemann@key-tec.de>
MAINTAINER Daniel Redwig <daniel.redwig@key-tec.de>

# Set timezone and locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TERM xterm

# Prevent services autoload (http://jpetazzo.github.io/2013/10/06/policy-rc-d-do-not-start-services-automatically/)
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install software-properties-common
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:ondrej/php && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    php7.0-common \
    php7.0-cli \
    php7.0-mysql \
    php7.0-mcrypt \
    php7.0-curl \
    php7.0-mbstring \
    php7.0-gd \
    php7.0-sqlite \
    php7.0-json \
    php7.0-intl \
    php7.0-bcmath \
    php7.0-xml \
    php7.0-soap \
    php7.0-fpm

# Basic packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes --no-install-recommends install \
    zip unzip \
    git \
    vim \
    nano \
    curl \
    git \
    mysql-client \
    pv \
    openssh-client \
    rsync \
    apt-transport-https \
    sudo \
    locales \
    supervisor \
    procps \
    nginx \
    sendmail \
    mc \
    # Cleanup
    && DEBIAN_FRONTEND=noninteractive apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN php7enmod mcrypt

# Configuration
ADD ./config/nginx.conf /etc/nginx/nginx.conf
ADD ./config/includes/drupal.conf /etc/nginx/conf.d/includes/drupal.conf
ADD ./config/default /etc/nginx/sites-available/default
ADD ./config/realip.conf /etc/nginx/conf.d/realip.conf
ADD ./config/supervisor.conf /etc/supervisor/conf.d/supervisord-nginx.conf

# Generate SSL certificate and key
RUN openssl req -batch -nodes -newkey rsa:2048 -keyout /etc/ssl/private/server.key -out /tmp/server.csr && \
    openssl x509 -req -days 365 -in /tmp/server.csr -signkey /etc/ssl/private/server.key -out /etc/ssl/certs/server.crt;rm /tmp/server.csr

RUN \
    # PHP settings changes
    sed -i 's/memory_limit = .*/memory_limit = 196M/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/memory_limit = .*/memory_limit = 196M/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/cgi.fix_pathinfo = .*/cgi.fix_pathinfo = 0/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 500M/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/;sendmail_path =/sendmail_path = \/usr\/sbin\/sendmail -t -i/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 500M/' /etc/php/7.0/fpm/php.ini && \
    # PHP FPM config changes
    sed -i 's/listen = .*/listen = \/var\/run\/php7.0-fpm\.sock/' /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "/;listen.owner = www-data/c\listen.owner = www-data" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "/;listen.group = www-data/c\listen.group = www-data" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "/;listen.mode = 0666/c\listen.mode = 0666" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "/;daemonize = yes/c\daemonize = no" /etc/php/7.0/fpm/php-fpm.conf

ENV DRUSH_VERSION 8.0.1
# Composer
RUN curl -sSL https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

    # Drush 8 (default)
RUN curl -sSL https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar -o /root/drush.phar
RUN mv /root/drush.phar /usr/local/bin/drush && \
    chmod +x /usr/local/bin/drush

ENV PATH /root/.composer/vendor/bin:$PATH

# Set TERM so text editors/etc. can be used
ENV TERM xterm

ADD ./config/.ssh /root/.ssh
ADD ./config/.drush /root/.drush
ADD ./config/supervisor.conf /etc/supervisor/conf.d/supervisord.conf
# Startup script
# This startup script wll configure nginx
ADD ./startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

RUN mkdir /run/php

ADD ./config/index.php /var/www/drupal/index.php

RUN usermod -u 1000 www-data && \
    chown -R www-data:www-data /var/www

EXPOSE 80 443

WORKDIR /var/www

ENV SSH_KEY_NAME id_rsa

CMD /opt/startup.sh; /usr/bin/supervisord -n
