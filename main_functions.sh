#!/bin/bash
# Adam Harrington x13113305

# =================== Import functions =================

# load functions script
. main_script

# =================== Initial config ===================

# ---------- Root?
check_root 
# ---------- Build sandbox
make_sandbox 
# ---------- Monitor
new_monitor
# ---------- Make directories
make_directories
# ---------- Download from git
get_from_git "https://github.com/adamdharrington/Deployment_BITD.git"
# ---------- Package dummy files as webpackage_pre_build.tgz
pack_and_move "build" "Deployment_BITD"
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