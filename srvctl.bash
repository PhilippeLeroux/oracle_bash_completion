# bash completion support for srvctl 12cR1
# vim: ts=4:sw=4:filetype=sh:cc=81

# Copyright (C) 2016 Philippe Leroux <philippe.lrx@gmail.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

#	============================================================================
#	Pour mémo :
#		COMP_WORDS	is an array of words in the current command line.
#		COMP_CWORD	is the index of the current word in the command line.
#		COMPREPLY	is a list of replies.
#	============================================================================

#	srvctl <command> <object> [<options>]
#	COMP_WORD[0] == srvctl
#	COMP_WORD[1] == command
#	COMP_WORD[2] == object
#	COMP_WORD[0] == first option
typeset	-ri	icommand=1
typeset	-ri	iobject=2
typeset	-ri	ifirstoption=3

typeset -r	command_list="enable disable start stop status add remove modify
						update getenv setenv unsetenv config upgrade downgrade"

# Global variables built dynamically
#	object_list : contain all objects.
#	count_nodes : number of nodes.

#	Work only with : export SRVCTL_LOG=yes
function _log
{
	[ "$SRVCTL_LOG" == yes ] && echo "$@" >> /tmp/srvctl_completion.log || true
}

#	return 0 if cluster, 1 if standalone server
function _is_cluster
{
	[ ! -v count_nodes ] && typeset	-rgi count_nodes=$(wc -l<<<"$(olsnodes)") || true
	[ $count_nodes -gt 1 ] && return 0 || return 1
}

#	build the reply : COMP_REPLY is set.
function _reply
{
	COMPREPLY=( $( compgen -W "$@" -- ${COMP_WORDS[COMP_CWORD]} ) )
}

#	init global variable object_list with all objects for the courent command.
#	reply with object_list
function _reply_with_object_list
{
	if _is_cluster
	then
		typeset -g	object_list="database instance service nodeapps vip
								listener asm scan scan_listener srvpool
								server oc4j rhpserver rhpclient home
								filesystem volume diskgroup cvu gns mgmtdb
								mgmtlsnr exportfs havip mountfs"
	else
		typeset	-g	object_list="database service asm diskgroup listener
								home ons"
	fi

	case ${COMP_WORDS[icommand]} in
		config) # TODO : for RAC
			object_list=${object_list/diskgroup/}
			object_list=${object_list/home/}
			;;

		getenv) # TODO : for RAC
			object_list="database asm listener"
			;;
	esac

	_reply "$object_list"
}

function _reply_with_database_list
{
	_reply "$(crsctl stat res	|\
					grep "\.db$" | sed "s/NAME=ora\.\(.*\).db/\1/g" | xargs)"
}

function _reply_with_diskgroup_list
{
	_reply	"$(crsctl stat res		|\
					grep -E "ora.*.dg$"	|\
					sed "s/NAME=ora.\(.*\).dg/\1/g" | xargs)"
}

function _reply_with_listener_list
{
	#	For RAC database we must exclude listener for scan vips.
	_reply	"$(crsctl stat res				|\
					grep -E "NAME=ora.*.lsnr$"	|\
					grep -v "SCAN"				|\
					sed "s/NAME=ora.\(.*\).lsnr/\1/g" | xargs)"
}

function _reply_with_oracle_home_list
{
	_reply	"$(cat /etc/oratab			|\
					grep -E "^(\+|[A-Z])"	|\
					sed "s/.*:\(.*\):[Y|N].*/\1/g" | xargs)"
}

function _reply_with_vip_list
{
	_reply	"$(crsctl stat res				|\
					grep -E "NAME=ora.*.vip$"	|\
					grep -v "scan"				|\
					sed "s/NAME=ora.\(.*\).vip/\1/g" | xargs)"
}

function _reply_with_network_list
{
	typeset -i count_net=$(crsctl stat res|grep -E "\.network$"|wc -l)
	typeset list
	for i in $( seq $count_net )
	do
		list="$list $i"
	done
	_reply "$list"
}

function _reply_with_node_number_list
{
	[ ! -v count_nodes ] && _is_cluster || true

	typeset list
	for i in $( seq $count_nodes )
	do
		list="$list $i"
	done
	_reply "$list"
}

function _reply_with_node_list
{
	_reply "$(olsnodes | xargs)"
}

#	return dbname index in COMP_WORDS, -1 if not found.
function _get_dbname_index
{
	for i in $( seq $ifirstoption ${#COMP_WORDS[@]} )
	do
		if [[ ${COMP_WORDS[i]} == "-db" || ${COMP_WORDS[i]} == "-database" ]]
		then
			[ x"${COMP_WORDS[i+1]}" == x ] && echo -1 || echo $(( i + 1 ))
			return 0
		fi
	done

	echo -1
}

function _reply_with_service_list
{
	typeset	-ri idbname=$(_get_dbname_index)
	if [ $idbname -eq -1 ]
	then # return all services
		_reply "$(crsctl stat res			|\
						grep -E "ora.*.svc$"	|\
						sed "s/NAME=ora\.\(.*\)\.svc/\1/g" | xargs)"
	else # return services for specified database.
		typeset -r dbname=$(tr [:upper:] [:lower:]<<<"${COMP_WORDS[idbname]}")
		_reply "$(crsctl stat res						|\
						grep -Ei "ora.$dbname.*.svc$"		|\
						sed "s/NAME=ora\.${dbname}\.\(.*\)\.svc/\1/g" | xargs)"
	fi
}

function _reply_with_instance_list
{
	typeset	-ri idbname=$(_get_dbname_index)
	if [ $idbname -eq -1 ]
	then
		COMPREPLY=()
		return 0
	fi

	if [ -v instance_list ]
	then
		if [ $(( SECONDS - tt_instance_list )) -lt 60 ]
		then
			_reply "$instance_list"
			return 0
		fi
		# cache to old.
	fi

	typeset	cmd="srvctl status database -db ${COMP_WORDS[idbname]}"
	cmd="$cmd | sed 's/Instance \(.*\) is running.*/\1/g' | xargs"
	_log "cmd='$cmd'"

	typeset -g	instance_list="$(eval $cmd)"
	typeset	-gi	tt_instance_list=$SECONDS

	_reply "$instance_list"
}

#	$@	option_list
#	return option_list without options already in used.
function _remove_used_options
{
	typeset	option_list="$@"

	for i in $( seq $ifirstoption ${#COMP_WORDS[@]} )
	do
		if [[ $i -ne $COMP_CWORD && "$option_list" == *"${COMP_WORDS[i]}"* ]]
		then
			option_list=${option_list/${COMP_WORDS[i]}/}
		fi
	done

	echo $option_list
}

#	$1 option_list
#	do reply without options already in used.
function _reply_for_options
{
	typeset	option_list="$@"

	if [ $COMP_CWORD == $ifirstoption ]
	then
		_reply "$option_list"
	else
		_reply "$(_remove_used_options $option_list)"
	fi
}

#	reply for command status on object $1
function _status_reply_on_object
{
	typeset	-r object_name="$1"

	case "$object_name" in
		database)
			if _is_cluster
			then
				_reply_for_options "-db -serverpool -thisversion -thishome
										-force -verbose"
			else
				_reply_for_options "-db -thisversion -thishome
										-force -verbose"
			fi
			;;

		instance)
			_reply_for_options "-db -node -instance -force -verbose"
			;;

		service)
			_reply_for_options "-db -service -force -verbose"
			;;

		nodeapps)
			_reply "-node"
			;;

		vip)
			_reply_for_options "-node -vip -verbose"
			;;

		listener)
			_reply_for_options "-listener -verbose"
			;;

		asm)
			_reply_for_options "-detail -verbose"
			;;

		scan|scan_listener)
			_reply_for_options "-netnum -scannumber -all -verbose"
			;;

		srvpool)
			_log "todo _status_reply_on_object $@"
			;;

		server)
			_reply_for_options "-servers -detail"
			;;

		oc4j)
			_reply_for_options "-node -verbose"
			;;

		rhpserver)
			COMPREPLY=()
			;;

		rhpclient)
			COMPREPLY=()
			;;

		home)
			if _is_cluster
			then
				_reply_for_options "-node -oraclehome -statefile"
			else
				_reply_for_options "-oraclehome -statefile"
			fi
			;;

		filesystem)
			_reply_for_options "-device -verbose"
			;;

		volume)
			_reply_for_options "-volume -diskgroup -device -node -all"
			;;

		diskgroup)
			if _is_cluster
			then
				_reply_for_options "-diskgroup -node -detail -verbose"
			else
				_reply_for_options "-diskgroup -detail -verbose"
			fi
			;;

		cvu)
			_reply_for_options "-node"
			;;

		gns)
			_reply_for_options "-node -verbose"
			;;

		mgmtdb)
			_reply_for_options "-verbose"
			;;

		mgmtlsnr)
			_reply_for_options "-verbose"
			;;

		exportfs)
			_reply_for_options "-name -id"
			;;

		havip)
			_reply_for_options "-id"
			;;

		mountfs)
			_reply_for_options "-name"
			;;

		ons)
			_reply_for_options "-verbose"
			;;

		*)
			_log "error object '$object_name' unknow."
			COMPREPLY=()
			;;
	esac
}

#	next reply for command status on object $1 (after the first option)
function _status_next_reply_on_object
{
	typeset	-r object_name="$1"

	case "$prev_word" in
		-diskgroup)
			_reply_with_diskgroup_list
			;;

		-db|-database)
			_reply_with_database_list
			;;

		-service|-s)
			_reply_with_service_list
			;;

		-listener)
			_reply_with_listener_list
			;;

		-oraclehome)
			_reply_with_oracle_home_list
			;;

		-node|-servers)
			_reply_with_node_list
			;;

		-instance)
			_reply_with_instance_list
			;;

		-vip)
			_reply_with_vip_list
			;;

		-scannumber)
			_reply_with_reply "1 2 3"
			;;

		-netnum)
			_reply_with_network_list
			;;

		*)
			_status_reply_on_object $object_name
			;;
	esac
}

#	reply for command start on object $1
function _start_reply_on_object
{
	typeset	-r	object_name="$1"

	case "$object_name" in
		database)
			if _is_cluster
			then
				# -node only for RAC On Node
				# -eval for policy managed
				_reply_for_options "-db -startoption -startconcurrency
										-eval -verbose"
			else
				_reply_for_options "-db -startoption -verbose"
			fi
			;;

		*)
			_log "_start_reply_on_object $object_name : todo"
			COMPREPLY=()
			;;
	esac
}

#	next reply for command start on object $1 (after the first option)
function _start_next_reply_on_object
{
	typeset	-r object_name="$1"

	case "$prev_word" in
		-db|-database)
			_reply_with_database_list
			;;

		-startconcurrency)
			_reply_with_node_number_list
			;;

		read)
			COMPREPLY=( only )
			;;

		-startoption)
			_reply "open mount read"
			;;

		*)
			_start_reply_on_object $object_name
			;;
	esac
}

#	reply for command stop on object $1
function _stop_reply_on_object
{
	typeset	-r	object_name="$1"

	case "$object_name" in
		database)
			if _is_cluster
			then
				# -node only for RAC On Node
				# -eval for policy managed
				_reply_for_options "-db -stopoption -stopconcurrency
										-force -eval -verbose"
			else
				_reply_for_options "-db -stopoption -force -verbose"
			fi
			;;

		*)
			_log "_start_reply_on_object $object_name : todo"
			COMPREPLY=()
			;;
	esac
}

#	next reply for command stop on object $1 (after the first option)
function _stop_next_reply_on_object
{
	typeset	-r object_name="$1"

	case "$prev_word" in
		-db|-database)
			_reply_with_database_list
			;;

		-stopconcurrency)
			_reply_with_node_number_list
			;;

		-stopoption)
			_reply "normal transactional immediate abort"
			;;

		*)
			_stop_reply_on_object $object_name
			;;
	esac
}

#	reply for command config on object $1
function _config_reply_on_object
{
	typeset	-r	object_name="$1"

	case "$object_name" in
		database)
			if _is_cluster
			then
				# TODO : to complete.
				_reply_for_options "-db -all -verbose"
			else
				_reply_for_options "-db -all -verbose"
			fi
			;;

		service)
			if _is_cluster
			then
				# TODO : to complete.
				_reply_for_options "-db -service -verbose"
			else
				_reply_for_options "-db -service -verbose"
			fi
			;;

		asm)
			if _is_cluster
			then
				# TODO : to complete.
				_reply_for_options "-all"
			else
				_reply_for_options "-all"
			fi
			;;

		listener)
			if _is_cluster
			then
				# TODO : to complete.
				_reply_for_options "-listener"
			else
				_reply_for_options "-listener"
			fi
			;;

		ons)
			COMP_REPLY=()
			;;

		*)
			_log "_start_reply_on_object $object_name : todo"
			COMPREPLY=()
			;;
	esac
}

#	next reply for command config on object $1 (after the first option)
function _config_next_reply_on_object
{
	typeset	-r object_name="$1"

	case "$prev_word" in
		-db|-database)
			_reply_with_database_list
			;;

		-s|-service)
			_reply_with_service_list
			;;

		-listener)
			_reply_with_listener_list
			;;

		*)
			_config_reply_on_object $object_name
			;;
	esac
}

function _srvctl_complete
{
	typeset prev_word="${COMP_WORDS[COMP_CWORD-1]}"

	#	srvctl <command> <object> firstoption ...
	_log
	_log "${COMP_WORDS[*]}"
	_log "command       : ${COMP_WORDS[icommand]}"
	_log "object        : ${COMP_WORDS[iobject]}"
	_log "first option  : ${COMP_WORDS[ifirstoption]}"
	_log "cur_word      : ${COMP_WORDS[COMP_CWORD]}"
	_log "prev_word     : $prev_word"
	_log "COMP_CWORD    : $COMP_CWORD"

	if [[ "$prev_word" == "srvctl" ]]
	then # srvctl TAB
		_reply "${command_list}"
	elif [[ "$command_list" == *"$prev_word"* ]]
	then # srvctl <command> TAB
		_reply_with_object_list
	elif [[ "$object_list" == *"$prev_word"* ]]
	then # srvctl <command> <object> TAB
		case ${COMP_WORDS[icommand]} in
			status)
				_status_reply_on_object ${COMP_WORDS[iobject]}
				;;

			start)
				_start_reply_on_object ${COMP_WORDS[iobject]}
				;;

			stop)
				_stop_reply_on_object ${COMP_WORDS[iobject]}
				;;

			config)
				_config_reply_on_object ${COMP_WORDS[iobject]}
				;;

			*)
				_log "todo option for '${COMP_WORDS[icommand]}'"
				COMPREPLY=()
				;;
		esac
	else
		case ${COMP_WORDS[icommand]} in
			status)
				_status_next_reply_on_object ${COMP_WORDS[iobject]}
				;;

			start)
				_start_next_reply_on_object ${COMP_WORDS[iobject]}
				;;

			stop)
				_stop_next_reply_on_object ${COMP_WORDS[iobject]}
				;;

			config)
				_config_next_reply_on_object ${COMP_WORDS[iobject]}
				;;

			*)
				_log "todo complete option for '${COMP_WORDS[icommand]}'"
				COMPREPLY=()
				;;
		esac
	fi

	_log "return : '${COMPREPLY[*]}'"
}

complete -F _srvctl_complete srvctl
