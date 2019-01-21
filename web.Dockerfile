# use debian latest
FROM debian:latest

#Set required env
ENV apache_default_site /etc/apache2/sites-available
ENV apache_default_dir /var/www/html
ENV apache_log_dir /var/log/apache2
ENV apache_cert_dir /etc/ssl/certs/custom
ENV COMPOSE_CONVERT_WINDOWS_PATHS 1

#Update container repository and install Apache2 and php7.0
RUN apt-get update && apt-get install -y locales apt-utils apache2 libapache2-mod-php7.0 libxrender1 libxext6 curl openssl mysql-client openssh-client redis-tools ca-certificates php7.0 php7.0-cli php7.0-common php7.0-fpm php7.0-mysql php7.0-curl php7.0-json php7.0-xml php7.0-gd php7.0-intl php7.0-imap php7.0-mcrypt php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-mbstring php7.0-gettext php7.0-pdo php7.0-pdo-mysql php7.0-zip php7.0-dom php7.0-soap php-pear php-imagick php-memcache php-memcached php-redis php-xdebug
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get autoclean && apt-get -y autoremove

#Enable necessary Mods
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod headers

#set locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

#Change php max_execution_time and set xdebug
RUN echo "max_execution_time=3600" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.remote_enable=on" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini

COPY ./apache_vhost/000-default.conf $apache_default_site

#Place certificate and key files
RUN mkdir -p "$apache_cert_dir"
COPY ./apache_cert/cert.key "$apache_cert_dir"
COPY ./apache_cert/cert.pem "$apache_cert_dir"

RUN chown -R www-data:www-data $apache_default_dir
#WORKDIR $apache_default_dir

VOLUME ["$apache_default_dir", "$apache_default_site", "$apache_log_dir"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80 443 9001
