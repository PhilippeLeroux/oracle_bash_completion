### bash completion support for Oracle 12cR1 commands

* srvctl \<command\> \<object\> option1, option2, ...

	Completion work for all commands and all objects for a command.

	Options supported for commands :
	* status : full support.
	* config : full support.
	* start : must be tested on policy managed (-eval) & One Node (-node).
	* stop : must be tested on policy managed (-eval).
	* enable : tested on RAC only.

### Installation
Copy file `srvctl.bash` to `/etc/bash_completion.d`

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
