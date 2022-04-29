qjar
====

query record-jar files using awk with named field variables

Quick-Start
-----------

`example.txt` contains a stuff list:

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

Download the source tarball of the latest release and:

	make test
	sudo make install

Documentation
-------------

The man page *qjar(1)* is shipped with the installation.
Typing `man qjar` to read.
