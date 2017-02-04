### bash completion support for Oracle 12cR1 commands

* srvctl \<command\> \<object\> option1 option2 ...

	Completion work on all commands and on all objects for a command.

	Options supported for commands :
	* status : full completion.
	* config : full completion.
	* start : full completion.
	* stop : full completion.
	* enable : full completion.
	* disable : full completion.
	* getenv : full completion.
	* setenv : full completion.
	* unsetenv : full completion.
	* add : full completion.
	* remove : full completion.
	* relocate : full completion.
	* modify : RAC only.

	Options not supported for commands (todo) :
	* update
	* upgrade
	* downgrade

### Installation
Copy file `srvctl.bash` to `/etc/bash_completion.d`

GRID_HOME & ORACLE_HOME must be in PATH.

You can download file `srvctl.bash` with following command :
```
wget https://raw.githubusercontent.com/PhilippeLeroux/oracle_bash_completion/master/srvctl.bash
```

--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------

### LICENCE

Copyright © 2016,2017 Philippe Leroux

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
