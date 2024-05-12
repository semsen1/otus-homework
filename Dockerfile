FROM php:8.2-fpm
ARG WORKDIR=/var/www/html
ENV DOCUMENT_ROOT=${WORKDIR}
ENV LARAVEL_PROCS_NUMBER=1
ENV NODE_MAJOR=20
ARG HOST_UID=1000
ENV USER=www-data
# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmemcached-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    librdkafka-dev \
    libpq-dev \
    openssh-server \
    zip \
    unzip \
    supervisor \
    sqlite3  \
    nano \
    cron
#RUN apt-get install build-essential
# Install Nodejs
RUN apt-get update && apt-get install -y ca-certificates curl gnupg
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update &&  apt-get install nodejs -y

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
# Install Kafka
RUN git clone https://github.com/arnaud-lb/php-rdkafka.git\
    && cd php-rdkafka \
    && phpize \
    && ./configure \
    && make all -j 5 \
    && make install

# Install Rdkafka and enable it
RUN docker-php-ext-enable rdkafka \
     && cd .. \
    && rm -rf /php-rdkafka

# Install PHP extensions zip, mbstring, exif, bcmath, intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install  zip mbstring exif pcntl bcmath -j$(nproc) gd intl

# Install Redis and enable it
RUN pecl install redis  && docker-php-ext-enable redis

# Install imagic
RUN apt-get update -y
RUN apt-get autoremove -y
RUN apt-get install libmagickwand-dev -y
RUN apt-get install imagemagick -y
RUN pecl install imagick

#install oci
RUN apt-get install wget
#RUN export PHP_DTRACE=yes
#RUN pecl install oci8

# Install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql

# Install PHP Opcache extention
RUN docker-php-ext-install opcache


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR $WORKDIR

RUN rm -Rf /var/www/* && \
mkdir -p /var/www/html

RUN usermod -u ${HOST_UID} www-data
RUN groupmod -g ${HOST_UID} www-data

RUN chmod -R 755 $WORKDIR
RUN chown -R www-data:www-data $WORKDIR

EXPOSE 9000

RUN docker-php-ext-install zip

#oracle
RUN apt-get install libaio1 libaio-dev
RUN mkdir /opt/oracle
# Install Oracle Instantclient

RUN wget https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-basic-linux.x64-21.6.0.0.0dbru.zip \
&& wget https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-sdk-linux.x64-21.6.0.0.0dbru.zip \
&& wget https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-sqlplus-linux.x64-21.6.0.0.0dbru.zip \
&& unzip instantclient-basic-linux.x64-21.6.0.0.0dbru.zip -d /opt/oracle \
&& unzip instantclient-sdk-linux.x64-21.6.0.0.0dbru.zip -d /opt/oracle \
&& unzip instantclient-sqlplus-linux.x64-21.6.0.0.0dbru.zip -d /opt/oracle \
&& rm -rf *.zip \
&& mv /opt/oracle/instantclient_21_6 /opt/oracle/instantclient
#add oracle instantclient path to environment
ENV LD_LIBRARY_PATH /opt/oracle/instantclient/
RUN echo /opt/oracle/instantclient_21_6/ > /etc/ld.so.conf.d/oic.conf && \
        ldconfig
# Install Oracle extensions
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient,21.1 \
&& echo 'instantclient,/opt/oracle/instantclient/' | pecl install oci8 \
&& docker-php-ext-install \
        pdo_oci \
&& docker-php-ext-enable \
        oci8
