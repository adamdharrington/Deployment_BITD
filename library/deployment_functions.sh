#!/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com
function dep_speak {
	echo "---------- Deployment --"
}
function dep_content {
	# Copies files from webpackage to appropriate locations
	# Assumes relative directory = deploy/
	cp webpackage/www/* /var/www/
	cp webpackage/cgi-bin/* /usr/lib/cgi-bin/
	chmod 755 /usr/lib/cgi-bin/*
}

function dep_cron_add {
	# Copies cron scripts
	# Assumes relative directory = deploy/
	cp library/dep_monitor.sh /etc/cron.d/
	cp library/dep_error_mailer.pl /etc/cron.d/
	# Adds cronjob to root user
	CRONLINE='*/1 * * * * bash /etc/cron.d/dep_monitor.sh >> /tmp/logs/system.log'
	(sudo crontab -l; echo "$CRONLINE" ) | sudo crontab -
}
function dep_update {
	# apt-get update
	apt-get update -qq
}
function dep_check_pw {
	tables=`mysql -root -p"$1" -e"show databases;" | wc -l`
	if [[ $tables -eq 0 ]]; then
		echo "Incorrect Database password provided"
		dep_stop_services
		dep_reset_pw "$1"
	fi
}
function dep_reset_pw {
	echo "Attempting override"
	cat <<FINISH | sudo mysqld --skip-grant-tables &
update mysql.user set Password=PASSWORD('$1');
flush privileges;
exit;
FINISH
	sudo killall mysqld
}
function dep_stop_services {
	# Stop services
	service apache2 stop
	service mysql stop
}
function dep_clean {
	# Remove apache2 and mysql
	apt-get remove -qq apache2 mysql-server mysql-client
	apt-get purge -qq mysql-server
}
function dep_install_all {
	# Install dependencies
	apt-get install -qq git apache2 tidy perl

	# Install and set up MySql
	echo mysql-server mysql-server/root_password password "$1" | debconf-set-selections
	echo mysql-server mysql-server/root_password_again password "$1" | debconf-set-selections
	apt-get install -q -y -f mysql-server mysql-client
}
function dep_start_services {
	service mysql start
	service apache2 start
}
function dep_build_database {
	# Create a new database and table
	cat <<FINISH | mysql -uroot -p$DB_PASS
drop database if exists $DB_NAME;
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost IDENTIFIED BY '$DB_PASS';
use $DB_NAME;
drop table if exists custdetails;
create table if not exists custdetails (
name         VARCHAR(30)   NOT NULL DEFAULT '',
address      VARCHAR(30)   NOT NULL DEFAULT ''
);
insert into custdetails (name,address) values ('John Smith','Street Address'); select * from custdetails;
FINISH
}

