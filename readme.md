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
	* convert
	* export
	* import
	* predict
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
