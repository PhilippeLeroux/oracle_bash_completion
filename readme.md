### bash completion support for Oracle 12cR1 commands

Supported commands :

* srvctl \<command\> \<object\> option1, option2, ...
	* status : full support.
	* config : full support.
	* start : Must be tested on policy managed (-eval) & One Node (-node).
	* stop : Must be tested on policy managed (-eval).

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
	```
	./all_objects_for_cmd.sh > /tmp/file.sh
	```
	Use to generate functions _reply_with_object_list_cluster & _reply_with_object_list_standalone

* callback_func_for_command.sh (not tested, for future improvements)
	```
	./callback_func_for_command.sh config > /tmp/config.sh
	```
	Use to generate callback functions for command :
	* \_reply_for_cmd_[command]
	* \_next_reply_for_cmd_[command]
