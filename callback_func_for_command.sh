#!/bin/bash
# vim: ts=4:sw=4

typeset -r command="$1"
if [ x"$command" == x ]
then
	echo "Usage ${0##*/} command"
	exit 1
fi

echo "function _reply_for_cmd_$command"
echo "{"
echo "	case "\"\$object_name\"" in"
while read object_name
do
	echo "		$object_name)"
	echo "			_reply_with_options \"\""
	echo "			;;"
	echo ""
done<<<"$(srvctl $command -h | grep "^Usage:" | awk '{ print $4 }')"
echo "		*)"
echo "			_log \"_reply_for_cmd_$command \$object_name : todo\""
echo "			COMPREPLY=()"
echo "			;;"
echo "	esac"
echo "}"
echo ""
