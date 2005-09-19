ifeq ($(wildcard Makefile),)


Makefile: Makefile.PL MANIFEST
	perl Makefile.PL
	test -e Makefile
	make $(MAKECMDGOALS)

MANIFEST:
	cvsfiles -p | xargs lsfiles | sort > $@.new
	mv $@.new $@


else


include Makefile


endif
