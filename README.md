qjar
====

query record-jar files using awk with named field variables

Quick-Start
-----------

`example.txt` contains a staff list:

	name	Alice Smith
	mail	alice@example.com
	pos	programmer

	name	Bob Goodman
	mail	bob@example.com
	pos	HR
	phone	123-457890

The following command prints every programmer's name and mail.

	qjar 'pos == "programmer" { print name":", mail }' example.txt

Outputs:

	Alice Smith: alice@example.com

Installation
------------

Download the source of
[the latest release](https://github.com/dongyx/qjar/releases)
and:

	make test
	sudo make install

By default, `qjar` and supporting files are installed to `/usr/local`.

Documentation
-------------

The man page *qjar(1)* is shipped with the installation.
Typing `man qjar` to read.

Uninstallation
--------------

For default installation:

	sudo rm /usr/local/bin/qjar
	sudo rm /usr/local/share/man/man1/qjar.1
