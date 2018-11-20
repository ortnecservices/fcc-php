FROM php:5.5.38-apache

RUN a2enmod rewrite

RUN docker-php-ext-install opcache

RUN apt-get update \
    && apt-get install -y git zlibc zlib1g zlib1g-dev libicu52 libicu-dev \
       libmcrypt-dev ssh --no-install-recommends \
       libmemcached-dev \
       mysql-client \
       less \
    && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install intl pdo_mysql mysql pcntl bcmath

RUN git clone --branch=phalcon-v2.0.13 --depth=1 https://github.com/phalcon/cphalcon.git
RUN cd cphalcon/build && ./install
RUN echo 'extension=phalcon.so' > /usr/local/etc/php/conf.d/phalcon.ini

RUN apt-get install -y libmcrypt-dev && docker-php-ext-install mcrypt

RUN apt-get update && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng12-dev \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install -j$(nproc) gd

RUN pecl install memcached-2.2.0 memcache-2.2.6 && docker-php-ext-enable memcached memcache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN pear install Mail Mail_Mime

#RUN apt-get install -y libmagickwand-dev libmagickcore-dev

RUN apt-get install -y wget

RUN wget https://www.imagemagick.org/download/ImageMagick-6.9.10-14.tar.gz
RUN tar xzvf ImageMagick-6.9.10-14.tar.gz
RUN cd ImageMagick-6.9.10-14/ \
    && ./configure \
    && make \
    && make install

RUN pecl install imagick && docker-php-ext-enable imagick

RUN pecl install apcu-4.0.11 && docker-php-ext-enable apcu

RUN pear install MDB2 MDB2_Driver_mysql MDB2_Driver_mysqli

RUN cd /tmp && wget http://sphinxsearch.com/files/sphinx-2.1.9-release.tar.gz \
    && tar -zxf sphinx-2.1.9-release.tar.gz && cd sphinx-2.1.9-release \
    && cd api/libsphinxclient \
    && ./configure && make && make install

RUN pecl install sphinx && docker-php-ext-enable sphinx

RUN docker-php-ext-install mysqli

RUN docker-php-ext-install calendar

RUN apt-get install -y nodejs
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN apt-get install -y npm
RUN npm install -g grunt-cli

RUN mkdir /localhost \
    && ln -s /var/www/fcc_main /localhost/fantasti.cc \
    && ln -s /var/www/fcc_admin /localhost/admin

RUN apt-get install -y zip

RUN apt-get install -y cron
RUN apt-get install -y vim

CMD ["apache2-foreground"]