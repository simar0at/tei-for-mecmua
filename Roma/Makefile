PREFIX=
LOCATION=/usr

FILES=ChangeLog \
	g \
	index.html \
	Makefile \
	notam \
	parser \
	progressbar \
	resource \
	roma \
	roma2.sh \
	roma.1 \
	roma.css \
	TEI-glow.png \
	roma.js \
	startroma.php \
	teilogo.jpg \
	VERSION 

.PHONY: release

default:
	@echo
	@echo TEI Roma
	@echo - install target puts files directly into ${PREFIX}${LOCATION}
	@echo - dist target  makes a release subdirectory of runtime files
	@echo There is no default action
	@echo

install: release-stamp
	mkdir -p ${PREFIX}${LOCATION}/share/tei-roma
	(cd release; tar cf - . ) | (cd ${PREFIX}${LOCATION}/share; tar xf - )
	mkdir -p ${PREFIX}${LOCATION}/bin
	sed "s/VVVERSION/`cat VERSION`/" roma2.sh > ${PREFIX}${LOCATION}/bin/roma
	sed "s/VVVERSION/`cat VERSION`/" roma2.sh > ${PREFIX}${LOCATION}/bin/roma2
	chmod 755 ${PREFIX}${LOCATION}/bin/roma ${PREFIX}${LOCATION}/bin/roma2
	mkdir -p $(PREFIX)/etc/tei-roma
	cp $(PREFIX)/${LOCATION}/share/tei-roma/roma/config-dist.php $(PREFIX)/etc/tei-roma/config.php
        perl -p -i -e 's+http://www.tei-c.org/release+/usr/share+' $(PREFIX)/etc/tei-roma/config.php
	(cd $(PREFIX)/${LOCATION}/share/tei-roma/roma; rm config.php; ln -s /etc/tei-roma/config.php config.php)


dist:  release-stamp
	(cd release; zip -r ../tei-roma-`cat ../VERSION`.zip tei-roma)

deb:	
	rm -f tei-roma*_*changes
	rm -f tei-roma*_*build
	rm -f tei-roma*_*deb
	(cd debian-tei-roma; debclean; debuild -i.svn -I.svn -uc -us)

release: clean release-stamp

release-stamp:
	rm -rf release/tei-roma
	mkdir -p release/tei-roma
	V=`cat VERSION` D=`head -1 ChangeLog | awk '{print $$1}'`;export D V; \
	echo version $$V of date $$D; \
	perl -p -i -e "s+.*define.*roma_date.*+define (\'roma_date\',\'$$D\');+" roma/config.php; \
	perl -p -i -e "s+.*define.*roma_version.*+define (\'roma_version\',\'$$V\');+" roma/config.php; \
	perl -p -i -e "s+.*define.*roma_date.*+define (\'roma_date\',\'$$D\');+" roma/config-dist.php; \
	perl -p -i -e "s+.*define.*roma_version.*+define (\'roma_version\',\'$$V\');+" roma/config-dist.php; \
	tar --exclude=.svn -c  -f - $(FILES) | (cd release/tei-roma; tar xf -); \
	perl -p -i -e "s/{roma_version}/$$V/;s/{roma_date}/$$D/" release/tei-roma/roma/templates/main.tem
	test -f /usr/share/xml/tei/odd/p5subset.xml && (cd roma; ../roma2.sh --nodtd --noxsd oddschema.odd .)
	touch release-stamp

clean:
	rm -rf release
	rm -f tei-roma-`cat VERSION`.zip
	rm -f release-stamp roma/oddschema.rnc
	rm -f tei-roma_*
	rm -rf debian-tei-roma/debian/tei-roma

log:
	(LastDate=`head -1 ChangeLog | awk '{print $$1}'`; \
	svn log -v -r 'HEAD:{'$$LastDate'}' | perl ../gnuify-changelog.pl | grep -v "^;" > newchanges)
	mv ChangeLog oldchanges
	cat newchanges oldchanges > ChangeLog
	rm newchanges oldchanges
