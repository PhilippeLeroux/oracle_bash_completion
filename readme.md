### bash completion support for Oracle 12cR1 commands

Supported commands :

* srvctl \<command\> \<object\> option1, option2, ...
	* status : full support.
	* config : support for standalone.
	* start database : must be tested on policy managed (-eval) & One Node (-node).
	* stop database : must be tested on policy managed (-eval).

* crsctl

	todo

### Installation
Copy files to `/etc/bash_completion.d/`
