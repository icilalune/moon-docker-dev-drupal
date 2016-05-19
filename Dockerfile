FROM moonscale/runner-drupal:latest

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

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Moon" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && echo "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707" > $PHP_INI_DIR/conf.d/blackfire.ini
