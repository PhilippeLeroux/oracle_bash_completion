### bash completion support for Oracle 12cR1 commands

* srvctl \<command\> \<object\> option1, option2, ...

	Completion work on all commands and on all objects for a command.

	Options supported for commands :
	* status : full support.
	* config : full support.
	* start : must be tested on policy managed (-eval) & One Node (-node).
	* stop : must be tested on policy managed (-eval).
	* enable : tested on RAC only.
	* disable : tested on RAC only.
	* getenv : tested on RAC only.
	* setenv : tested on RAC only.
	* unsetenv : tested on RAC only.

	Options not supported for commands (todo) :
	* add
	* remove
	* modify
	* update
	* upgrade
	* downgrade

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

* copy_to

	Copy the scripts to my demo servers.

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
