#!/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com

function test_speak {
    echo "---------- Test --"
}

function test_integration {
	count=`grep -inr "replace_" webpackage/. | wc -l`
	if [[$count -gt 0]]; then
		echo "Integration failed"
		ERRORS=$((ERRORS+1))
		exit 1
	fi
}

