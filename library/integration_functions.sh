#!/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com

function int_speak {
	echo "---------- integration --"
}

function int_configure {
	sed -i'' -e"s/replace_$1/$2/" "$3"
}
