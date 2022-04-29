.PHONY: test install clean

prefix = /usr/local
bindir = $(prefix)/bin
datarootdir = $(prefix)/share
mandir = $(datarootdir)/man

all: qjar qjar.1

qjar: qjar.sh version
	sed "s/__version__/`cat version`/g" qjar.sh >qjar
	chmod +x qjar

qjar.1: qjar.man1 version LICENSE
	cp qjar.man1 qjar.1
	>>qjar.1 echo .SH VERSION
	>>qjar.1 echo
	>>qjar.1 echo "qjar `cat version`"
	>>qjar.1 echo
	>>qjar.1 cat LICENSE

install: all
	install -d $(bindir)/ $(mandir)/man1/
	install qjar $(bindir)/
	install -m644 qjar.1 $(mandir)/man1/

test:
	rm -rf tenv tinst
	make install prefix=tinst
	cp -R test tenv
	@set -e; \
	for i in tenv/*; do \
		( \
			PATH="`pwd`/tinst/bin:$$PATH"; \
			echo run test "$$i"...; \
			cd "$$i"; \
			chmod +x run; \
			./run; \
		); \
	done

clean:
	rm -rf tinst tenv qjar qjar.1
