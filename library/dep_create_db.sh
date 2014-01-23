#!/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com

DB_username="$1"
DB_password="$2"
DB_name="$3"

# apt-get update
apt-get update -qq

# Stop services
service apache2 stop
service mysql stop

# Remove apache2 and mysql
apt-get remove apache2 mysql-server mysql-client -qq

# Install dependencies
apt-get install git apache2 tidy perl -qq

# Install and set up MySql
echo mysql-server mysql-server/root_password password $DB_password | debconf-set-selections
echo mysql-server mysql-server/root_password_again password $DB_password | debconf-set-selections
apt-get -q -y install mysql-server mysql-client

# Start services
service apache2 start
service mysql start

# Create a new database
cat <<FINISH | mysql -uroot -p$DB_password
drop database if exists $DB_name;
CREATE DATABASE $DB_name;
GRANT ALL PRIVILEGES ON $DB_name.* TO $DB_username@localhost IDENTIFIED BY '$DB_password';
use $DB_name;
drop table if exists custdetails;
create table if not exists custdetails (
name         VARCHAR(30)   NOT NULL DEFAULT '',
address      VARCHAR(30)   NOT NULL DEFAULT ''
);
insert into custdetails (name,address) values ('John Smith','Street Address'); select * from custdetails;
FINISH
