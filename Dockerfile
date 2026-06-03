FROM php:5.6.40-fpm

# Debian Stretch (EOL): официальные зеркала отдают 404, используем archive.debian.org
RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
        -e 's/security.debian.org/archive.debian.org/g' \
        /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list \
    && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y --allow-unauthenticated --no-install-recommends \
    nginx \
    gettext-base \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libxml2-dev \
    libxslt1-dev \
    libc-client-dev \
    libkrb5-dev \
    libzip-dev \
    libreadline-dev \
    libedit-dev \
    mysql-client \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-imap-ssl --with-imap --with-kerberos \
    && docker-php-ext-install -j"$(nproc)" \
        gd \
        mysqli \
        pdo_mysql \
        mysql \
        mbstring \
        mcrypt \
        xml \
        xsl \
        exif \
        zip \
        imap \
        gettext \
        opcache \
        pcntl \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        wddx \
        readline

COPY docker/php.ini /usr/local/etc/php/conf.d/mediawiki.ini
COPY docker/nginx-mediawiki.conf /etc/nginx/conf.d/mediawiki.conf
RUN rm -f /etc/nginx/sites-enabled/default

COPY docker/ /docker/
COPY php-modules.txt /php-modules.txt

RUN chmod +x /docker/docker-entrypoint.sh /docker/wait-for-db.sh /docker/verify-php-modules.sh

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/docker/docker-entrypoint.sh"]
