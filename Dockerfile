# Dev Drupal
#
# VERSION       1

# use the ubuntu base image provided by dotCloud
FROM ubuntu:precise

MAINTAINER Simon Morvan simon@icilalune.com

# make sure the package repository is up to date
RUN echo "deb http://mir1.ovh.net/ubuntu precise  main restricted universe multiverse" > /etc/apt/sources.list
RUN echo "deb http://ftp.free.fr/mirrors/ftp.ubuntu.com/ubuntu precise  main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update
#RUN apt-get -y upgrade

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN rm /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install  python-setuptools vim-tiny python-pip
RUN easy_install supervisor

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install bzip2 git mysql-client mysql-server apache2 libapache2-mod-php5 pwgen php5-mysql php-apc php5-gd php5-curl php5-memcache php5-xdebug php-pear memcached mc autoconf libmagickwand-dev pngnq pngcrush pngquant libmagickwand-dev 
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

RUN drush dl coder --destination=/usr/local
RUN ln -s /usr/local/coder/coder_sniffer/Drupal /usr/share/php/PHP/CodeSniffer/Standards/

RUN apt-get clean
# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./xdebug.ini /etc/php5/conf.d/xdebug.ini


RUN chmod 755 /start.sh /etc/apache2/foreground.sh

EXPOSE 80
VOLUME /project
RUN rm -rf /var/www ; ln -s /project/www /var/www
CMD ["/bin/bash", "/start.sh"]
