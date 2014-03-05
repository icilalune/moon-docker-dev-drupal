#!/bin/bash
if [ ! -f /mysql-root-pw.txt ]; then
	# Start mysql
	/usr/bin/mysqld_safe & 
	sleep 10s
	# Generate random passwords 
	DRUPAL_DB="drupal"
	MYSQL_PASSWORD=`pwgen -c -n -1 12`
	DRUPAL_PASSWORD=`pwgen -c -n -1 12`
	# This is so the passwords show up in logs. 
	echo mysql root password: $MYSQL_PASSWORD
	echo drupal password: $DRUPAL_PASSWORD
	echo $MYSQL_PASSWORD > /mysql-root-pw.txt
	echo $DRUPAL_PASSWORD > /drupal-db-pw.txt
	mysqladmin -u root password $MYSQL_PASSWORD 
	mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
	sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/default
	a2enmod rewrite vhost_alias
	killall mysqld
	sleep 10s
fi
mkdir $HOME
supervisord -n
