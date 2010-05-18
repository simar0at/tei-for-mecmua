<xsl:stylesheet
  exclude-result-prefixes="xlink dbk rng tei teix xhtml a edate estr html pantor xd xs xsl"
  extension-element-prefixes="exsl estr edate" 
  version="2.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:teix="http://www.tei-c.org/ns/Examples"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:edate="http://exslt.org/dates-and-times"
  xmlns:estr="http://exslt.org/strings" xmlns:exsl="http://exslt.org/common"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:pantor="http://www.pantor.com/ns/local"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="TEIC">false</xsl:param>

<xsl:output method="xml" indent="yes"/>

<xsl:key name="SPEC" match="tei:schemaSpec|tei:specGrp" use="1"/>

<xsl:template match="*">
 <xsl:copy>
  <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
 </xsl:copy>
</xsl:template>

<xsl:template match="text()|@*|comment()|processing-instruction()">
  <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="tei:text">
 <tei:text>
  <tei:body>
    <xsl:apply-templates select="key('SPEC',1)"/>
    <xsl:if test="$TEIC='true'">
      <elementSpec ident="egXML" module="tagdocs" mode="change">
	<content>
	  <group xmlns="http://relaxng.org/ns/structure/1.0">
	    <zeroOrMore >
	      <choice>
		<text/>
		<xsl:copy-of
		    select="document('../Exemplars/exnames.xml')/rng:choice/rng:ref"/>
	      </choice>
	    </zeroOrMore>
	  </group>
	</content>
      </elementSpec>
    </xsl:if>
  </tei:body>
 </tei:text>
</xsl:template>

<xsl:template match="tei:schemaSpec/@ident">
  <xsl:attribute name="ident">
    <xsl:value-of select="."/>
    <xsl:text>-examples</xsl:text>
  </xsl:attribute>
</xsl:template>

<xsl:template match="tei:schemaSpec/@ns"/>

<xsl:template match="tei:schemaSpec">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:attribute name="ns">
      <xsl:text>http://www.tei-c.org/ns/Examples</xsl:text>
    </xsl:attribute>
  <xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>  </xsl:copy>
</xsl:template>
</xsl:stylesheet>


