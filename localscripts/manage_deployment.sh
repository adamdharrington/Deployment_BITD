#!/usr/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com
echo running manage_deployment.sh
ROOT_PASS="$1"
DB_USER="$2"
DB_PASS="$3"
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
#---------- remove sandbox
	rm -r /tmp/$SANDBOX
	if [[ `ls /tmp | grep "$SANDBOX" | wc -l` -eq 0 ]]; then
		echo sandbox removed
	else
		echo sandbox may still exist
	fi
}


# ====================================================================
#
#                                                   Set up environment
#
# ====================================================================

# =================  initialize
check_root
make_sandbox
get_content

# ====================================================================
#
#                                                        Execute Build
#
# ====================================================================

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

# ====================================================================
#
#                                                         Execute test
#
# ====================================================================

pack_and_move "test"
unpack_webpackage "test"
. /tmp/$SANDBOX/test/library/test_functions.sh
test_speak

# ====================================================================
#
#                                                       Execute deploy
#
# ====================================================================

pack_and_move "deploy"
unpack_webpackage "deploy"
. /tmp/$SANDBOX/deploy/library/deployment_functions.sh
dep_speak

# ====================================================================
#
#                                                          End Session
#
# ====================================================================
remove_sandbox