FROM php:5.6-apache
MAINTAINER Synctree App Force <appforce+docker@synctree.com>

ENV MEDIAWIKI_VERSION 1.23
ENV MEDIAWIKI_FULL_VERSION 1.23.7

RUN apt-get update && \
    apt-get install -y g++ libicu52 libicu-dev && \
    pecl install intl && \
    echo extension=intl.so >> /usr/local/etc/php/conf.d/ext-intl.ini && \
    apt-get remove -y g++ libicu-dev && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install mysqli opcache

RUN apt-get update && \
    apt-get install -y imagemagick && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

RUN mkdir -p /usr/src/mediawiki && \
    curl -sSL https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz | \
    tar --strip-components=1 -xzC /usr/src/mediawiki

COPY apache/mediawiki.conf /etc/apache2/
RUN echo Include /etc/apache2/mediawiki.conf >> /etc/apache2/apache2.conf

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
