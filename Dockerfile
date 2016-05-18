FROM moonscale/runner-drupal:php7

RUN docker-php-pecl-install \
        xdebug

RUN pear install PHP_CodeSniffer

# Install phpcpd
RUN pear channel-discover pear.phpmd.org
RUN pear channel-discover pear.pdepend.org
RUN pear install --alldeps phpmd/PHP_PMD
RUN cd /usr/local && wget https://phar.phpunit.de/phpcpd.phar && chmod +x phpcpd.phar && ln -s /usr/local/phpcpd.phar /usr/local/bin/phpcpd

# Install coder
RUN drush dl coder --destination=/usr/local \
        && ln -s /usr/local/coder/coder_sniffer/Drupal /usr/local/lib/php/PHP/CodeSniffer/Standards/

RUN rm -rf /var/www/html && ln -s /project/www /var/www/html

COPY xdebug.ini /usr/local/etc/php/conf.d/conf-xdebug.ini
