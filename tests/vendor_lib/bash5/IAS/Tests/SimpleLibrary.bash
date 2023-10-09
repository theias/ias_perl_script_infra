#!/bin/bash

function debug_this_test
{
	local msg="$*"

	if [[ -z "$msg" ]]
	then
		if [[ "$DEBUG_THIS_TEST" == "1" ]]
		then
			cat
		else
			cat > /dev/null
		fi
	else
		if [[ "$DEBUG_THIS_TEST" == "1" ]]
		then
			first="$1"; shift

			printf "$first" "$@"
		fi
	fi
}
