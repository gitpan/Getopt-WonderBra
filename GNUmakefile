all::

Makefile: Makefile.PL MANIFEST lib/Getopt/WonderBra.pm
	perl Makefile.PL
	test -e Makefile
	touch XXX
	make $(MAKECMDGOALS)

MANIFEST:
	cvsfiles -p | xargs lsfiles | sort > $@.new
	mv $@.new $@

$(shell touch XXX)
include Makefile
