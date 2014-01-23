#!/usr/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com

# ====================================================================
#
#                                                Environment variables
#
# ====================================================================

echo running manage_deployment.sh
ROOT_PASS="$1"
DB_USER="$2"
DB_PASS="$3"
DB_NAME="dbtest"
DB_PORT="3306"
DB_HOST="localhost"
MS="smtp.o2.ie"
ADMIN_EMAIL="adamdharrington@gmail.com"

ERRORS=0

# ====================================================================
#
#                             Basic functions for managing environment
#
# ====================================================================
function check_root {
	if [ "$(id -u)" != "0" ]; then
		echo Sorry, you are not root.
		ERRORS=$((ERRORS+1))
		exit 1
	fi
}
function make_sandbox {
#---------- Build sandbox
	# sandbox will live in the /tmp directory
	cd /tmp
	# sandbox will live in the /tmp directory
	SANDBOX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)
	mkdir $SANDBOX
	cd /tmp/$SANDBOX
	echo Created sandbox directory: /tmp/$SANDBOX
}
function get_content {
	# ensure execution in sandbox diectory
	cd /tmp/$SANDBOX
	# clone from personal deployment repository on github
	git clone https://github.com/adamdharrington/Deployment_BITD.git
	# ensure files were downloaded
	if [[ `ls | grep Deployment_BITD | wc -l` -eq 1 ]]; then
		echo Downloaded deployment files from remote
	else
		echo Error downloading from remote. Exiting...
		ERRORS=$((ERRORS+1))
		exit 1
	fi
	# create directory structure
	mkdir build integrate test deploy build/library build/webpackage
	cp -R Deployment_BITD/library/* build/library/
	cp -R Deployment_BITD/webpackage/* build/webpackage/
	# Check copying was successful or exit
	if [[ `ls /tmp/$SANDBOX/build/webpackage | wc -l` -gt 0 &&
		  `ls /tmp/$SANDBOX/build/library | wc -l` -gt 0 ]]; then
		echo Files copied successfully
	else
		echo Error copying files. Exiting...
		ERRORS=$((ERRORS+1))
		exit 1
	fi
}

function pack_and_move {
	# Package all files in current directory into a different directory.
	# must be called with an argument build, integrate, test or deploy.
	tar -czf /tmp/$SANDBOX/"$1"/webpackage_pre_"$1".tgz *
	cd /tmp/$SANDBOX/"$1"
	if [[ `ls | wc -l` -gt 0 ]]; then
		echo Packed and moved successfully
	else 
		echo Error copying files in "$1". Exiting...
		ERRORS=$((ERRORS+1))
		exit 1
	fi
}
function unpack_webpackage {
	# unpack the archive
	# must be called with an argument build, integrate, test or deploy.
	tar -zxf webpackage_pre_"$1".tgz
	if [[ `ls webpackage | grep www | wc -l` -gt 0 ]]; then
		echo Unpacked webpackage_pre_"$1".tgz successfully
	else 
		echo Error unpacking webpackage_pre_"$1".tgz. Exiting...
		ERRORS=$((ERRORS+1))
		exit 1
	fi
}
function remove_sandbox {
	# remove sandbox
	rm -r /tmp/$SANDBOX
	if [[ `ls /tmp | grep "$SANDBOX" | wc -l` -eq 0 ]]; then
		echo sandbox removed
	else
		echo sandbox may still exist
	fi
}



# ====================================================================
#
#                                                        Execute Build
#
# ====================================================================

check_root
make_sandbox
get_content
cd /tmp/$SANDBOX/build
. /tmp/$SANDBOX/build/library/build_functions.sh
build_speak

# ====================================================================
#
#                                                    Execute integrate
#
# ====================================================================

pack_and_move "integrate"
unpack_webpackage "integrate"
. /tmp/$SANDBOX/integrate/library/integration_functions.sh
int_speak
int_configure username $DB_USER webpackage/cgi-bin/accept_form.pl
int_configure password $DB_PASS webpackage/cgi-bin/accept_form.pl
int_configure name $DB_NAME webpackage/cgi-bin/accept_form.pl
int_configure port $DB_PORT webpackage/cgi-bin/accept_form.pl
int_configure host $DB_HOST webpackage/cgi-bin/accept_form.pl

int_configure email $ADMIN_EMAIL library/dep_monitor.sh
int_configure smtp_ms $MS library/dep_monitor.sh

# ====================================================================
#
#                                                         Execute test
#
# ====================================================================

pack_and_move "test"
unpack_webpackage "test"
. /tmp/$SANDBOX/test/library/test_functions.sh
test_speak
test_integration

# ====================================================================
#
#                                                       Execute deploy
#
# ====================================================================

pack_and_move "deploy"
unpack_webpackage "deploy"
. /tmp/$SANDBOX/deploy/library/deployment_functions.sh
#bash library/dep_create_db.sh $DB_USER $DB_PASS $DB_NAME
dep_speak
dep_update
dep_check_pw $DB_NAME
dep_clean
dep_install_all $DB_PASS
dep_start_services
dep_build_database
dep_content
dep_cron_add 
bash library/dep_monitor.sh
# ====================================================================
#
#                                                          End Session
#
# ====================================================================
remove_sandbox
