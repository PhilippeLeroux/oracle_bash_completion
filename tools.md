
### Tools
Scripts to help me.

* all_objects_for_cmd.sh

	Use to generate functions `_build_object_list_cluster` & `_build_object_list_standalone`

	```
	./all_objects_for_cmd.sh > /tmp/file.sh
	```

* callback_func_for_command.sh

	Create callback function for a command : \_reply_for_cmd_[command]

	For command `config` : `./callback_func_for_command.sh config > /tmp/config.sh`

* copy_to : copy the scripts to my demo servers.

* callback_option_exists : test if a function for an option exist.

* stats : show stats.

--------------------------------------------------------------------------------

### Scripts srvctl.bash
#### Function `_srvctl` (main function)
* complete `srvctl` with command name
* complete `srvctl <command name>` with object name

For a command can be created 2 functions :
* `_reply_for_cmd_<command name>` : provide all options for the tuple [command,object]
* `_next_reply_for_cmd_<command name>` (optional)

If a function `_reply_for_cmd_<command name>` not exists there are no completion
for options.

* On the first option `_srvctl` call `_reply_for_cmd_<command name>`
* On the next options `_srvctl` call `_next_reply_for_cmd`

#### Function `_next_reply_for_cmd`
If a function named `_next_reply_for_cmd_<command name>` exists, it's called. This
function manage specifics case for a command.

Else if a function like `_reply_with_<option_name>_list` exists it's called else
`_reply_for_cmd_<command name>` it's called.

`_reply_with_<option_name>_list` provide a list of values for an options or nothing
if user must provide a value.

