#!/bin/bash
# vim: ts=4:sw=4

typeset	-A commands

function objects_for
{
	typeset	-r cmd=$1

	commands[$cmd]=$(srvctl $cmd -h | grep "^Usage:" | awk '{ print $4 }' | xargs)
}

while read command
do
	objects_for $command
done<<<"$(srvctl -h | grep "^Usage:" | grep -v "\-V" | awk '{ print $3 }' | sort | uniq)"

echo "# Generated by script : ${0##*/}"
echo "# Built object_list for current command"
echo "# $(srvctl -V)"
echo "function _reply_with_object_list"
echo "{"
echo "	case \"\$command\" in"
for i in "${!commands[@]}"
do
	echo "		$i)"
	echo "			typeset -g object_list=\"${commands[$i]}\""
	echo "			;;"
done
echo "		*)"
echo "			_log \"\$command not supported.\""
echo "			typeset -g object_list=\"\""
echo "	esac"
echo "}"
