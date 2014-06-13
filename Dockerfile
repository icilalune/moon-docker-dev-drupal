# Dev Drupal
#
# VERSION       1

# use the ubuntu base image provided by dotCloud
FROM ubuntu:trusty

MAINTAINER Simon Morvan simon@icilalune.com

# make sure the package repository is up to date
RUN echo "deb http://mir1.ovh.net/ubuntu trusty  main restricted universe multiverse" > /etc/apt/sources.list
RUN echo "deb http://ftp.free.fr/mirrors/ftp.ubuntu.com/ubuntu trusty  main restricted universe multiverse" >> /etc/apt/sources.list
RUN apt-get update
#RUN apt-get -y upgrade

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install  python-setuptools vim-tiny python-pip
RUN easy_install supervisor

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install bzip2 curl git mysql-client mysql-server apache2 libapache2-mod-php5 pwgen php5-mysql php-apc php5-gd php5-curl php5-dev php5-memcache php5-xdebug php-pear memcached mc autoconf libmagickwand-dev pngnq pngcrush pngquant libmagickwand-dev wget
RUN pip install git-review

RUN cd /usr/local ; git clone http://github.com/drush-ops/drush.git --branch 6.x
RUN ln -s /usr/local/drush/drush /usr/bin/drush


RUN pear install PHP_CodeSniffer
RUN pear channel-discover pear.phpmd.org
RUN pear channel-discover pear.pdepend.org
RUN pear install --alldeps phpmd/PHP_PMD
RUN pear channel-discover pear.phpunit.de
RUN pear channel-discover pear.symfony.com
RUN pear channel-discover pear.netpirates.net
RUN pear install --alldeps pear.phpunit.de/phpcpd

RUN pecl install uploadprogress
RUN echo "extension=uploadprogress.so" >> /etc/php5/mods-available/uploadprogress.conf
RUN ln -s /etc/php5/mods-available/uploadprogress.conf /etc/php5/apache2/conf.d/30-uploadprogress.ini

RUN drush dl coder --destination=/usr/local
RUN ln -s /usr/local/coder/coder_sniffer/Drupal /usr/share/php/PHP/CodeSniffer/Standards/

RUN apt-get clean
# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./xdebug.ini /etc/apache2/conf.d/20-xdebug.ini
ADD ./vhost.conf /etc/apache2/sites-available/000-default.conf


RUN chmod 755 /start.sh /etc/apache2/foreground.sh

EXPOSE 80
VOLUME /project
RUN rm -rf /var/www ; ln -s /project/www /var/www
CMD ["/bin/bash", "/start.sh"]
