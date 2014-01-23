#!/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com

function test_speak {
    echo "---------- Test --"
}

function test_integration {
	REPLACES=$(grep -inr "replace_" webpackage/. | wc -l)
	if [ $REPLACES -gt 0 ]; then
		echo "Integration failed"
		exit 1
	fi
}

