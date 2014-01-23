#!/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com

function dep_content {
	# Copies files from webpackage to appropriate locations
	# Assumes relative directory = deploy/
	cp webpackage/www/* /var/www/
	cp webpackage/cgi-bin/* /usr/lib/cgi-bin/
	chmod a+x /usr/lib/cgi-bin/*
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