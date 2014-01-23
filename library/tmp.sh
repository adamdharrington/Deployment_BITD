#!/bin/bash

ADMIN_EMAIL="ah"

. integration_functions.sh


int_configure email $ADMIN_EMAIL dep_monitor.sh
