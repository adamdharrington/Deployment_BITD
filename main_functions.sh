#!/bin/bash
# Adam Harrington x13113305

# =================== Initial config ===================

# ---------- Root?
function check_root {
# check root
if [ "$(id -u)" != "0" ]; then
    echo Sorry, you are not root.
    exit 1
fi
}
# ---------- Build sandbox
function make_sandbox {
cd ~/tmp
FOLDER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
mkdir $FOLDER
cd $FOLDER
}
# ---------- Monitor scripts
function new_monitor {
ERRORCOUNT=0
}
function add_error {
# Call with string, add to report
# Create error-report.txt if not exist
let "ERRORCOUNT += 1" 
echo "Error number $ERRORCOUNT     $1"  >> ~/tmp/$FOLDER/error-report.txt
}
# ---------- Download from git
function get_from_git {
# call with a git address
git clone $1
}
# ---------- Package dummy files as webpackage_pre_build.tgz
function pack_and_move {
tar czvf $2/webpackage_pre_$2.tgz $1
}
# ---------- Make directories
function make_directories {
mkdir webpackage build intergrate test deploy
}
# ---------- Move to Build directory

# ================== Build =============================

# ---------- Unzip webpackage_pre_build.tgz

# ---------- Manipulate (add text "built"?)

# ---------- Make new package webpackage_pre_integrate.tgz

# ---------- Move package to integrate directory

# ================== Integrate =========================

# ---------- Unzip webpackage_pre_integrate.tgz

# ---------- Manipulate (add text "Integrated"?)

# ---------- Make new package webpackage_pre_test.tgz

# ---------- Move package to test directory

# ================== Test ==============================

# ---------- Unzip webpackage_pre_test.tgz

# ---------- Manipulate (add text "tested"?)

# ---------- Make new package webpackage_pre_deploy.tgz

# ---------- Move package to deploy directory

# ================== Deploy ============================

# ---------- Unzip webpackage_pre_deploy.tgz

# ---------- Manipulate (add text "deployed"?)

# ---------- Email report

# ---------- Cleanup
function remove_sandbox {
rm -r $FOLDER
}
