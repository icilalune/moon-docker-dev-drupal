# Dev Drupal
#
# VERSION       1

# use the ubuntu base image provided by dotCloud
FROM ubuntu:trusty

MAINTAINER Simon Morvan simon@icilalune.com

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install  python-setuptools vim-tiny python-pip
RUN easy_install supervisor

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install bzip2 curl git mysql-client apache2 libapache2-mod-php5 pwgen php5-mysql php-apc php5-gd php5-curl php5-dev php5-memcache php5-xdebug php-pear autoconf libmagickwand-dev pngnq pngcrush pngquant libmagickwand-dev wget unzip

RUN a2enmod rewrite

RUN cd /usr/local ; curl -sS https://getcomposer.org/installer | php
RUN chmod +x /usr/local/composer.phar ; ln -s /usr/local/composer.phar /usr/local/bin/composer

RUN cd /usr/local ; git clone http://github.com/drush-ops/drush.git --branch master
RUN cd /usr/local/drush ; composer install
RUN ln -s /usr/local/drush/drush /usr/bin/drush


RUN pear install PHP_CodeSniffer
RUN pear channel-discover pear.phpmd.org
RUN pear channel-discover pear.pdepend.org
RUN pear install --alldeps phpmd/PHP_PMD
RUN cd /usr/local && wget https://phar.phpunit.de/phpcpd.phar && chmod +x phpcpd.phar && ln -s /usr/local/phpcpd.phar /usr/local/bin/phpcpd

RUN pecl install uploadprogress
RUN echo "extension=uploadprogress.so" > /etc/php5/mods-available/uploadprogress.conf
RUN ln -s /etc/php5/mods-available/uploadprogress.conf /etc/php5/apache2/conf.d/30-uploadprogress.ini

RUN drush dl coder --destination=/usr/local
RUN ln -s /usr/local/coder/coder_sniffer/Drupal /usr/share/php/PHP/CodeSniffer/Standards/

RUN apt-get clean

ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./xdebug.ini /etc/php5/mods-available/xdebug.ini
ADD ./vhost.conf /etc/apache2/sites-available/000-default.conf


RUN chmod 755 /start.sh /etc/apache2/foreground.sh

EXPOSE 80
VOLUME /project
RUN rm -rf /var/www ; ln -s /project/www /var/www
CMD ["/bin/bash", "/start.sh"]
