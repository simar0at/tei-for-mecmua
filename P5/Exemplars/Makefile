PREFIX=/usr
SAXON=java -Xmx752m -jar ../Utilities/lib/Saxon-HE-9.4.0.6.jar -ext:on
BIN=${PREFIX}/bin
ODDS= \
	tei_bare.dtd \
	tei_corpus.dtd \
	tei_drama.dtd \
	tei_minimal.dtd \
	tei_ms.dtd \
	tei_speech.dtd \
	tei_all.dtd 

MOREODDS=	isofs.rng \
	tei_svg.rng \
	tei_enrich.dtd \
	tei_xinclude.rng \
	tei_its.rng \
	tei_math.rng \
	tei_odds.rng

DOCONLYODDS=tei_lite_fr.doc.epub

XODDS = tei_allPlus.special	

DOCODDS=tei_tite.doc.pdf tei_lite.doc.pdf
LANGUAGE=en
P5=`(cd ..; pwd)`
DRIVER=guidelines-${LANGUAGE}.xml
XSL=/usr/share/xml/tei/stylesheet/
SOURCE=${P5}/p5subset.xml 
ANT=ANT_OPTS="-Xss2m -Xmx752m" ant -lib ../Utilities/lib/Saxon-HE-9.4.0.6.jar:/usr/share/java/jing.jar -Dtrang=/usr/share/trang/trang.jar  -Dprofile=tei -DdefaultSource=${SOURCE} -DXSL=${XSL} -Dbasedir=`pwd`

default: schemas

%.special: %.odd
	xmllint --xinclude $*.odd > $*.odd.xinclude
	$(ANT) -f ../Test/antruntest.xml -Doutputname=$* -Dtestfile2=$*.template -Dtestfile=$*.tei -DoddFile=$*.odd.xinclude validateodd compileodd rng validaterng validatesecondrng isoschematron validateschematron exampleschema  
	../run-onvdl $*.nvdl $*.odd.xinclude
	rm $*.odd.xinclude
	trang $*.rng $*.rnc

%.rng: %.odd 
	$(ANT) -f ../Test/antruntest.xml -Doutputname=$* -Dtestfile2=$*.template -Dtestfile=$*.tei -DoddFile=$*.odd validateodd compileodd dtd rng validaterng validatesecondrng isoschematron validateschematron exampleschema
	../run-onvdl $*.nvdl $*.odd
	trang  $*.rng $*.rnc

%.dtd: %.odd
	$(ANT) -f ../Test/antruntest.xml -Doutputname=$* -Dtestfile=$*.tei -DoddFile=$*.odd validateodd compileodd rng dtd exampleschema isoschematron validateschematron cleanup
	../run-onvdl $*.nvdl $*.odd
	trang   -o disable-abstract-elements $*.rng $*.xsd
	trang  $*.rng $*.rnc
	@echo Validate XSD using Jing ...
	perl -p -i -e 's+http://www.w3.org/2004/10/xml.xsd+xml.xsd+' $*.xsd
	-test -f teix.xsd && perl -p -i -e 's+<.*\"xml.xsd\".*++' teix.xsd
	-test -f spec.xsd && perl -p -i -e 's+<.*\"xml.xsd\".*++' spec.xsd
	-test -f teix.xsd && mv teix.xsd $*.teix.xsd
	-test -f $*.teix.xsd && perl -p -i -e "s/teix.xsd/$*.teix.xsd/" $*.xsd
	jing $*.xsd $*.tei
	@echo Validate using xmllint for DTD  
	xmllint --noout --dtdvalid $*.dtd $*.tei

%.doc.pdf: %.odd
	$(ANT) -f ../Test/antruntest.xml -Doutputname=$* -Dtestfile=$*.tei -DoddFile=$*.odd validateodd compileodd rng dtd docepub docpdf dochtml exampleschema 
	../run-onvdl $*.nvdl $*.odd
	trang  $*.rng $*.rnc
	trang   -o disable-abstract-elements $*.rng $*.xsd
	@echo Validate using xmllint for DTD  
	xmllint --noout --dtdvalid $*.dtd $*.tei
	-rm $*.doc.xml

%.doc.epub: %.odd
	$(ANT) -f ../Test/antruntest.xml -Doutputname=$* -Dlang=`echo $* | sed 's/.*_//'` -Dtestfile=$*.tei -DoddFile=$*.odd validateodd compileodd rng docepub docpdf dochtml exampleschema 
	../run-onvdl $*.nvdl $*.odd
	-rm $*.doc.xml
	-rm $*.rng

schemas: $(ODDS) $(MOREODDS) $(DOCODDS) $(XODDS) $(DOCONLYODDS)
	echo Done

dist: schemas
	rm -rf tei[0-9]*.xml ../release/tei-p5-exemplars
	rm -f *-examples*
	rm -f *compiled* *.doc.tex
	mkdir -p ../release/tei-p5-exemplars/share/xml/tei/custom/schema/relaxng
	mkdir -p ../release/tei-p5-exemplars/share/xml/tei/custom/schema/dtd
	mkdir -p ../release/tei-p5-exemplars/share/xml/tei/custom/schema/xsd
	mkdir -p ../release/tei-p5-exemplars/share/xml/tei/custom/templates
	mkdir -p ../release/tei-p5-exemplars/share/xml/tei/custom/odd
	mkdir -p ../release/tei-p5-exemplars/share/doc/tei-p5-exemplars/html
	mkdir -p ../release/tei-p5-exemplars/share/doc/tei-p5-exemplars/xml
	mkdir -p ../release/tei-p5-exemplars/share/doc/tei-p5-exemplars/pdf
	mkdir -p ../release/tei-p5-exemplars/share/doc/tei-p5-exemplars/epub
	for i in *.template; do $(SAXON) -it:main make_template.xsl file=`basename $$i .template`;done
	cp *.tei *.odd *.xsl ../release/tei-p5-exemplars/share/xml/tei/custom/odd
	cp *.xml  ../release/tei-p5-exemplars/share/xml/tei/custom/templates
	-rm -f../release/tei-p5-exemplars/share/xml/tei/custom/templates/*.doc.xml
	mv *.properties  ../release/tei-p5-exemplars/share/xml/tei/custom/templates
	mv *.xsd ../release/tei-p5-exemplars/share/xml/tei/custom/schema/xsd
	mv *.dtd ../release/tei-p5-exemplars/share/xml/tei/custom/schema/dtd
	mv isofs.rng tei*.rnc tei*.rng ../release/tei-p5-exemplars/share/xml/tei/custom/schema/relaxng
	cp mathml*rng relaxng.rng its.rng svg*rng *.mod ../release/tei-p5-exemplars/share/xml/tei/custom/schema/relaxng
	cp *png ../release/tei-p5-exemplars/share/doc/tei-p5-exemplars/html 
	mv *.doc.html ../release/tei-p5-exemplars/share/doc/tei-p5-exemplars/html 
	mv *.doc.pdf ../release/tei-p5-exemplars/share/doc/tei-p5-exemplars/pdf 
	mv *.doc.epub ../release/tei-p5-exemplars/share/doc/tei-p5-exemplars/epub
	cp ../catalog.p5.custom ../release/tei-p5-exemplars/share/xml/tei/custom/schema/catalog.xml

clean:
	rm -f *.xsd *.dtd *.doc.* *.rnc tei*.xsl tei*.rng *.compiled* *~ *.xi *.isosch *.epub *.pdf *.html *.nvdl *-examples*
	rm -f exnames.xml
	rm -f enrich.rng isofs.rng
	rm -f names.xml *properties
	rm -f [A-Z]*xml

