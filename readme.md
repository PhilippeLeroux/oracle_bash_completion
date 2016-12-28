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
