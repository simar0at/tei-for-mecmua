#rend="none"/> Main makefile for TEI P5
# $Id$
ALLLANGUAGES=en
LANGUAGE=en
INPUTLANGUAGE=en
DOCUMENTATIONLANGUAGE=en
LATEX=pdflatex
XELATEX=xelatex 
VERBOSE=
PREFIX=/usr
SOURCETREE=Source
DRIVER=${SOURCETREE}/guidelines-${INPUTLANGUAGE}.xml
XSL=/usr/share/xml/tei/stylesheet
# If you have not installed the Debian packages, uncomment one
# of the next two lines:
#XSL=../Stylesheets/release/tei-xsl/p5
#XSL=http://www.tei-c.org/stylesheet/release/xml/tei
JING=jing
TRANG=trang
VERSION=`cat VERSION`
UPVERSION=`cat ../VERSION`
SAXONJAR=Saxon-HE-9.4.0.6.jar

.PHONY: convert schemas html-web validate valid test clean dist exemplars

default: validate exemplars test html-web

convert: schemas

check: check.stamp  p5.xml

check.stamp: 
	@echo Checking you have running XML tools and Perl before trying to run transform...
	@echo -n Ant: 
	@command -v  ant || exit 1
	@echo -n Perl: 
	@command -v  perl || exit 1
	@echo -n Java: 
	@command -v  java || exit 1
	@echo -n xmllint: 
	@command -v  xmllint || exit 1
	@echo -n trang: 
	@command -v  ${TRANG} || exit 1
	@echo -n jing: 
	@command -v  ${JING} || exit 1
	touch check.stamp

p5.xml: ${DRIVER} Source/Specs/*.xml Source/Guidelines/en/*.xml p5odds.odd check.stamp
	@echo BUILD: Generate modular DTDs, Schemas, Schematron and miscellaneous outputs
	ant -lib /usr/share/java/jing.jar:Utilities/lib/${SAXONJAR} -f antbuilder.xml -DXSL=${XSL} -DDRIVER=${DRIVER} base subset outputs
	@echo "BUILD: Generate modular RELAX NG (compact) schemas using trang"
	(cd Schema; for i in *rng; do ${TRANG} $$i `basename $$i .rng`.rnc;done)
	touch schemas.stamp

schemas: schemas.stamp
schemas.stamp: p5.xml

html-web: check.stamp p5.xml  html-web.stamp

html-web.stamp:  check.stamp p5.xml  Utilities/guidelines.xsl.model
	@echo BUILD: Making HTML Guidelines for language ${LANGUAGE}
	perl -p -e \
		"s+http://www.tei-c.org/release/xml/tei/stylesheet+${XSL}+; \
		 s+/usr/share/xml/tei/stylesheet+${XSL}+;" \
		Utilities/guidelines.xsl.model > Utilities/guidelines.xsl
	rm -rf Guidelines-web
	if [ -n ${GOOGLEANALYTICS} ] ; then curl -s http://www.tei-c.org/index.xml | sed 's/content="text\/html"/content="text\/html; charset=utf-8"/' | xmllint --html --noent --dropdtd --xmlout - > Utilities/teic-index.xml;fi
	echo '<project basedir="." default="html" name="buildweb"><import file="antbuildweb.xml"/><target name="html">' > buildweb.xml
	for i in $(ALLLANGUAGES) ;do \
		mkdir -p Guidelines-web/$$i/html; \
		cp odd.css guidelines.css guidelines-print.css Guidelines-web/$$i/html; \
		(cd Source/Guidelines/${INPUTLANGUAGE}; tar --exclude .svn -c -f - Images) | (cd Guidelines-web/$$i/html; tar xf - );\
		(cd webnav; tar --exclude .svn -c -f - .) | (cd Guidelines-web/$$i/html; tar xf - ); \
		echo "<buildweb lang=\"$$i\"/>" >> buildweb.xml; \
	done
	echo '</target></project>' >> buildweb.xml
	ant -lib /usr/share/java/jing.jar:Utilities/lib/${SAXONJAR} -f buildweb.xml -DgoogleAnalytics=${GOOGLEANALYTICS}
	rm -f buildweb.xml Utilities/teic-index.xml
	touch html-web.stamp

teiwebsiteguidelines:
	@echo BUILD: make HTML version of Guidelines just for TEI web site
	rm -rf teiwebsiteguidelines.zip 
	rm -f html-web.stamp
	make html-web ALLLANGUAGES="en es de ja ko fr it zh-TW" GOOGLEANALYTICS=UA-4372657-1
	(cd Guidelines-web; zip -r -q ../teiwebsiteguidelines.zip . ) 

pdf: Guidelines.pdf pdf-complete

epub: Guidelines.epub

Guidelines.epub: check.stamp p5.xml 
	@echo BUILD: Make epub version of Guidelines
	ant -q -f ${XSL}/epub3/build-to.xml -lib Utilities/lib/${SAXONJAR} -Dprofiledir=${XSL}/profiles -Dprofile=tei -DinputFile=`pwd`/p5.xml -DoutputFile=`pwd`/Guidelines.epub -Dcoverimage=`pwd`/Utilities/cover.jpg
	java -jar Utilities/epubcheck3.jar Guidelines.epub
	touch Guidelines.epub

epub3: check.stamp p5.xml 
	ant -q -f ${XSL}/epub3/build-to.xml -lib Utilities/lib/${SAXONJAR} -Dprofiledir=${XSL}/profiles -Dprofile=tei -DinputFile=`pwd`/p5.xml -DoutputFile=`pwd`/Guidelines.epub -Dcoverimage=`pwd`/Utilities/cover.jpg
	java -jar Utilities/epubcheck3.jar Guidelines.epub

mobi:  Guidelines.mobi

Guidelines.mobi: check.stamp p5.xml 
	ant -q -f ${XSL}/epub/build-to.xml -lib Utilities/lib/${SAXONJAR} -Dprofiledir=${XSL}/profiles -Dprofile=teikindle -DinputFile=`pwd`/p5.xml -DoutputFile=`pwd`/Guidelines-kindle.epub -Dcoverimage=`pwd`/Utilities/cover.jpg
	-command -v  kindlegen && kindlegen Guidelines-kindle.epub -o Guidelines.mobi
	rm Guidelines-kindle.epub

fonttest:
	-xelatex --interaction=batchmode Utilities/fonttest 
	if [ -f "missfont.log" ]  ; then  \
	  perl -p -i -e 's/(.*Minion)/%\1/;s/(.*Myriad)/%\1/' Utilities/guidelines.xsl ;\
	  echo "========================="; \
	  echo "Note: you do not have Minion or Myriad fonts installed, reverting to Computer Modern " ;\
	  echo "========================="; \
	fi
	rm -f fonttest.*

Guidelines.pdf: check.stamp p5.xml Utilities/guidelines-latex.xsl
	@echo check if XeLaTeX exist
	@command -v  xelatex || exit 1
	perl -p -e \
		"s+http://www.tei-c.org/release/xml/tei/stylesheet+${XSL}+; \
		 s+/usr/share/xml/tei/stylesheet+${XSL}+;" \
		Utilities/guidelines-latex.xsl > Utilities/guidelines.xsl
	@echo BUILD: build Lite version of Guidelines, then LaTeX version of Guidelines from Lite, then run to PDF using XeLaTeX
	@echo Make sure you have Junicode, Arphic and Mincho fonts installed 
	ant -lib Utilities/lib/${SAXONJAR} -f antbuilder.xml -DXSL=${XSL} -DXELATEX=${XELATEX} pdfonce

pdf-complete:
	ant -lib Utilities/lib/${SAXONJAR} -f antbuilder.xml -DXSL=${XSL} -DXELATEX=${XELATEX} pdfrest 2> pdfbuild.log 1> pdfbuild.log
	grep -v "Failed to convert input string to UTF16" pdfbuild.log
	for i in Guidelines*aux; do perl -p -i -e 's/.*zf@fam.*//' $$i; done

rewraprnc:
	for i in Guidelines-REF*tex; \
	  do \
	     perl Utilities/rewrapRNC-in-TeX.pl <$$i>$$i.new; \
		echo NOTE: diff $$i.new $$i; \
		diff $$i.new $$i; \
		mv $$i.new $$i; \
	done

chapterpdfs: check
	for i in `grep "\\include{" Guidelines.tex | sed 's/.*{\(.*\)}.*/\\1/'`; \
	do echo PDF for chapter $$i; \
	echo  $$i | ${XELATEX} Guidelines; \
	echo  $$i | ${XELATEX} Guidelines ; \
	mv Guidelines.pdf $$i.pdf; \
	perl -p -i -e 's/.*zf@fam.*//' $$i.aux; \
	done

validate: schemas.stamp valid 

valid: jing_version=$(wordlist 1,3,$(shell jing))
valid: check.stamp p5.xml 
	@echo BUILD: Check validity with rnv if we have it
	-command -v  rnv && rnv -v p5odds.rnc p5.xml
	ant -lib Utilities/lib/${SAXONJAR} -f antbuilder.xml -DXSL=${XSL} validators		
	cat ValidatorLog.xml
	(grep -q "<ERROR>" ValidatorLog.xml;if [ $$? -ne 1 ] ; then echo "Oh dear me. ERROR found";false; fi)
	diff ValidatorLog.xml expected-results/ValidatorLog.xml
	sh graphics.sh
	@echo BUILD: Check validity with nvdl, first examples with feasible validity, and then the valid ones
	./run-onvdl p5.nvdl p5.xml 
	./run-onvdl p5valid.nvdl v.xml

test: schemas.stamp
	@echo BUILD Run test cases for P5
	(cd Test; make XSL=${XSL})

exemplars:  schemas.stamp 
	@echo BUILD TEI Exemplars
	(cd Exemplars; make XSL=${XSL} PREFIX=${PREFIX})

dist-source.stamp: check.stamp p5.xml  schemas.stamp
	@echo BUILD: Make distribution directory for source
	rm -rf release/tei-p5-source*
	mkdir -p release/tei-p5-source/share/xml/tei/odd
	tar -c -f - --exclude "*~" --exclude .svn 	\
	p5subset.xml \
	p5subset.json \
	p5subset.js \
	stripspace.xsl.model \
	p5attlist.txt \
	Makefile \
	ReleaseNotes  \
	Source \
	Utilities   \
	VERSION  \
	Exemplars/Makefile  \
	Exemplars/mathml2-main.rng \
	Exemplars/mathml2-qname-1.mod \
	Exemplars/mathml2-qname-1.mod.rng \
	Exemplars/mathml2.rng \
	Exemplars/relaxng.rng \
	Exemplars/svg-main.rng \
	Exemplars/svg.rng \
	Exemplars/svg11.rng \
	p5.nvdl \
	p5valid.nvdl \
	p5odds.odd \
	p5odds.isosch \
	p5odds.rng \
	p5odds.rnc \
	p5odds-examples.odd \
	p5odds-examples.rng \
	p5odds-examples.rnc \
	relax.rng \
	schematron.rng \
	iso-schematron.rng \
	p5sch.xsl \
	schematron1-5.rnc \
	run-onvdl \
	*.css \
	webnav \
	xhtml.rnc \
	| (cd release/tei-p5-source/share/xml/tei/odd; tar xf - )
	touch dist-source.stamp
	rm p5subset.json p5subset.js p5attlist.txt stripspace.xsl.model

dist-schema.stamp:check.stamp p5.xml schemas.stamp 
	@echo BUILD: Make distribution directory for schema
	rm -rf release/tei-p5-schema*
	mkdir -p release/tei-p5-schema/share/xml/tei/schema/dtd
	mkdir -p release/tei-p5-schema/share/xml/tei/schema/relaxng
	(cd DTD; tar --exclude .svn -c -f - .) \
	| (cd release/tei-p5-schema/share/xml/tei/schema/dtd; tar xf - )
	cp catalog.p5 release/tei-p5-schema/share/xml/tei/schema/catalog.xml
	(cd Schema; tar --exclude .svn -c -f - .) \
	| (cd release/tei-p5-schema/share/xml/tei/schema/relaxng; tar xf - )
	touch dist-schema.stamp

dist-doc.stamp:  check.stamp p5.xml 
	@echo BUILD: Make distribution directory for doc
	rm -rf release/tei-p5-doc*
	mkdir -p release/tei-p5-doc/share/doc/tei-p5-doc/en
	cp VERSION release/tei-p5-doc/share/doc/tei-p5-doc
	@echo BUILD: Make web pages for release notes
	for i in ReleaseNotes/readme*xml; \
	do  teitohtml --css=en/html/guidelines.css --profile=readme $$i  \
		./release/tei-p5-doc/share/doc/tei-p5-doc/`basename $$i .xml`.html; \
	done
	@echo BUILD: Make web guidelines in all supported languages
	make html-web ALLLANGUAGES="en es de ja ko fr it zh-TW"
	(cd Guidelines-web; tar --exclude .svn -c -f - . ) | (cd release/tei-p5-doc/share/doc/tei-p5-doc; tar xf - )
	@echo BUILD: make PDF version of Guidelines
	make pdf
	@echo BUILD: make ePub and Kindle version of Guidelines
	make epub
	make mobi
	cp Guidelines.pdf Guidelines.epub release/tei-p5-doc/share/doc/tei-p5-doc/en
	-test -f Guidelines.mobi  && cp Guidelines.mobi release/tei-p5-doc/share/doc/tei-p5-doc/en
	touch dist-doc.stamp

dist-test.stamp: check.stamp p5.xml 
	@echo BUILD: Make distribution directory for test
	rm -rf release/tei-p5-test*
	mkdir -p release/tei-p5-test/share/xml/tei
	(cd Test; make clean)
	tar --exclude "*~" --exclude .svn -c -f - Test \
	| (cd release/tei-p5-test/share/xml/tei; tar xf - )
	touch dist-test.stamp

dist-exemplars.stamp: check.stamp p5.xml  schemas.stamp
	@echo BUILD: Make distribution directory for exemplars
	(cd Exemplars; make XSL=${XSL} dist)
	tar --exclude "*~" --exclude .svn -c -f - Exemplars \
	| (cd release/tei-p5-exemplars/share/xml/tei; tar xf - )
	touch dist-exemplars.stamp

dist-database.stamp: check.stamp p5.xml 
	@echo BUILD: Make distribution directory for database
	rm -rf release/tei-p5-database*
	mkdir -p release/tei-p5-database/share/xml/tei/xquery
	(cd Query; tar --exclude .svn --exclude "*~" -c -f - . ) \
	| (cd release/tei-p5-database/share/xml/tei/xquery; tar xf - )
	touch dist-database.stamp

dist-source: dist-source.stamp

dist-schema: dist-schema.stamp

dist-doc: dist-doc.stamp

dist-test: dist-test.stamp

dist-exemplars: dist-exemplars.stamp

dist-database: dist-database.stamp

dist: dist-source dist-schema dist-doc dist-test dist-exemplars dist-database
	@echo BUILD: Make overall zip archive
	rm -rf tei-*.zip release/xml release/doc
	(cd release/tei-p5-database/share; tar cf - . | (cd ../../; tar xf - ))
	(cd release/tei-p5-doc/share; tar cf - . | (cd ../../; tar xf - ))
	(cd release/tei-p5-exemplars/share; tar cf - . | (cd ../../; tar xf - ))
	(cd release/tei-p5-schema/share; tar cf - . | (cd ../../; tar xf - ))
	(cd release/tei-p5-source/share; tar cf - . | (cd ../../; tar xf - ))
	(cd release/tei-p5-test/share; tar cf - . | (cd ../../; tar xf - ))
	(cd release; zip -q -r ../tei-${UPVERSION}.zip xml doc)
	@echo BUILD: Make individual zip archives
	(cd release; rm -rf tei-p5-*-${UPVERSION}.zip)
	(cd release; zip -q -r tei-p5-database-${UPVERSION}.zip tei-p5-database )
	(cd release; zip -q -r tei-p5-doc-${UPVERSION}.zip tei-p5-doc )
	(cd release; zip -q -r tei-p5-exemplars-${UPVERSION}.zip tei-p5-exemplars )
	(cd release; zip -q -r tei-p5-source-${UPVERSION}.zip tei-p5-database )
	(cd release; zip -q -r tei-p5-schema-${UPVERSION}.zip tei-p5-schema )
	(cd release; zip -q -r tei-p5-test-${UPVERSION}.zip tei-p5-test )

debversion:
	sh ./mydch debian-tei-p5-database/debian/changelog
	sh ./mydch debian-tei-p5-doc/debian/changelog
	sh ./mydch debian-tei-p5-exemplars/debian/changelog
	sh ./mydch debian-tei-p5-schema/debian/changelog
	sh ./mydch debian-tei-p5-source/debian/changelog
	sh ./mydch debian-tei-p5-test/debian/changelog

deb: debversion
	rm -f tei-p5-*_*deb
	rm -f tei-p5-*_*changes
	rm -f tei-p5-*_*build
	@echo BUILD: make Debian tei-p5-database package
	(cd debian-tei-p5-database; debclean;debuild -eXSL=${XSL} --no-lintian  -nc  -b  -i.svn -I.svn -uc -us)
	@echo BUILD: make Debian tei-p5-doc package
	(cd debian-tei-p5-doc; debclean;debuild -eXSL=${XSL} --no-lintian  -nc  -b  -i.svn -I.svn -uc -us)
	@echo BUILD: make Debian tei-p5-exemplars package
	(cd debian-tei-p5-exemplars; debclean;debuild -eXSL=${XSL} --no-lintian  -nc  -b  -i.svn -I.svn -uc -us)
	@echo BUILD: make Debian tei-p5-schema package
	(cd debian-tei-p5-schema; debclean;debuild -eXSL=${XSL} --no-lintian  -nc  -b  -i.svn -I.svn -uc -us)
	@echo BUILD: make Debian tei-p5-source package
	(cd debian-tei-p5-source; debclean;debuild -eXSL=${XSL} --no-lintian  -nc  -b  -i.svn -I.svn -uc -us)
	@echo BUILD: make Debian tei-p5-test package
	(cd debian-tei-p5-test; debclean;debuild -eXSL=${XSL} --no-lintian  -nc  -b  -i.svn -I.svn -uc -us)

install-schema: dist-schema
	@echo Making schema release in ${PREFIX}
	(cd release/tei-p5-schema; tar cf - .) | (cd ${PREFIX}; tar xf - )

install-doc: dist-doc
	@echo BUILD: Make doc release in ${PREFIX}
	(cd release/tei-p5-doc; tar cf - .) | (cd ${PREFIX}; tar xf - )

install-source: dist-source
	@echo BUILD: Making source release in ${PREFIX}
	(cd release/tei-p5-source; tar cf - .) | (cd ${PREFIX}; tar xf - )

install-test: dist-test
	@echo BUILD: Making testfiles release in ${PREFIX}
	(cd release/tei-p5-test; tar cf - .) | (cd ${PREFIX}; tar xf - )

install-exemplars: dist-exemplars
	@echo BUILD: Making exemplars release in ${PREFIX}
	(cd release/tei-p5-exemplars; tar cf - share) | (cd ${PREFIX}; tar xf -)

install-database: dist-database
	@echo BUILD: Making database release in ${PREFIX}
	(cd release/tei-p5-database; tar cf - .) | (cd ${PREFIX}; tar xf - )

install: clean install-schema install-doc install-test install-exemplars install-source install-database


changelog:
	(LastDate=`head -1 ReleaseNotes/ChangeLog | awk '{print $$1}'`; \
	svn log -v -r 'HEAD:{'$$LastDate'}' | perl ../gnuify-changelog.pl | grep -v "^;" > newchanges)
	mv ReleaseNotes/ChangeLog oldchanges
	cat newchanges oldchanges > ReleaseNotes/ChangeLog
	rm newchanges oldchanges


dependencies:
	@echo to make this thing build under Ubuntu/Debian, here are all the packages you will need:
	@echo	jing
	@echo	msttcorefonts
	@echo	rnv
	@echo	saxon
	@echo	tei-oxygen
	@echo	tei-p5-source
	@echo	tei-p5-xsl
	@echo	tei-p5-xsl2
	@echo	tei-xsl-common
	@echo	trang-java
	@echo	ttf-arphic-ukai
	@echo	ttf-arphic-uming 
	@echo	ttf-baekmuk 
	@echo	ttf-junicode
	@echo	ttf-kochi-gothic
	@echo	ttf-kochi-mincho 
	@echo	zip 

clean:
	(cd Exemplars; make clean)
	(cd Test; make clean)
	rm -rf release Guidelines Guidelines-web Schema DTD dtd Split 
	rm -rf Guidelines.??? Guidelines-* 
	rm -f *.isosch.xsl 
	rm -f *.stamp
	rm -f *.xsd 
	rm -f Exemplars/stdout
	rm -f Test/*.isosch 
	rm -f Test/detest.dtd Test/detest.rnc Test/detest.rng Test/detest.xsl
	rm -f Test/stdout
	rm -f Utilities/guidelines.xsl
	rm -f anything buildweb.xml
	rm -f p5.sch p5.isosch p5.xml p5subset.xml p5subset.json p5subset.js
	rm -f p5attlist.txt
	rm -f p5odds-examples.rng p5odds-examples.rnc p5odds.rng p5odds.rnc p5odds.isosch
	rm -f pdfbuild.log
	rm -f stripspace.xsl.model
	rm -f tei-*.zip 
	rm -f tei-p5-*_*build
	rm -f tei-p5-*_*changes
	rm -f tei-p5-*_*deb
	rm -f teiwebsiteguidelines.zip
	rm -rf FASC-*
	rm -rf catalogue.* modList
	rm -rf valid v.xml ValidatorLog.xml Utilities/pointerattributes.xsl graphics.sh missfont.log v.body v.header Schematron1.xml Schematron2.xml
