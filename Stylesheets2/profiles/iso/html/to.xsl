<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:iso="http://www.iso.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:s="http://www.ascc.net/xml/schematron" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:estr="http://exslt.org/strings"
    xmlns:t="http://www.thaiopensource.com/ns/annotations"
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
    xmlns:edate="http://exslt.org/dates-and-times"
    xmlns:exsl="http://exslt.org/common"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    extension-element-prefixes="exsl estr edate"
    exclude-result-prefixes="exsl edate estr tei html t a rng s iso teix" 
    version="1.0">
  
<xsl:import href="/usr/share/xml/tei/stylesheet/xhtml/tei.xsl"/>
<xsl:import href="../isoutils.xsl"/>
<xsl:param name="numberFormat">uk</xsl:param>
<xsl:output encoding="utf-8" 
 omit-xml-declaration="yes" 
 method="xml" 
 doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
 indent="yes"/>

<xsl:param name="STDOUT">true</xsl:param>
<xsl:param name="xhtml">true</xsl:param>
<xsl:param name="splitLevel">-1</xsl:param>
<xsl:param name="autoToc">true</xsl:param>
<xsl:param name="institution">ITSIG</xsl:param>
<xsl:param name="department">XML Project</xsl:param>
<xsl:param name="cssFile">iso.css</xsl:param>
<xsl:param name="cssSecondaryFile">odd.css</xsl:param>
<xsl:param name="TEIC">false</xsl:param>
<xsl:param name="wrapLength">65</xsl:param>
<xsl:param name="attLength">60</xsl:param>
<xsl:param name="forceWrap">true</xsl:param>
<xsl:template name="myi18n">
  <xsl:param name="word"/>
  <xsl:choose>
    <xsl:when test="$word='appendixWords'">
      <xsl:text>Annex</xsl:text><!-- was Annex -->
    </xsl:when>
  </xsl:choose>
</xsl:template>

  <xsl:template name="divClassAttribute">
    <xsl:param name="depth"/>
    <xsl:choose>
      <xsl:when test="@type">
        <xsl:attribute name="class">
          <xsl:value-of select="@type"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="class">
          <xsl:text>teidiv</xsl:text>
          <xsl:value-of select="$depth"/>
	  <xsl:text> from-</xsl:text>
	  <xsl:value-of select="local-name(ancestor::tei:body|ancestor::tei:front|ancestor::tei:back)"/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="ident">
      <xsl:apply-templates mode="ident" select="."/>
    </xsl:variable>
    <xsl:attribute name="id">
      <xsl:value-of select="$ident"/>
    </xsl:attribute>
  </xsl:template>


<xsl:template match="tei:note[@rend='example']">
  <p>EXAMPLE <xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="tei:list[@type='termlist']/tei:item">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:list[@type='termlist']/tei:item/tei:term">
  <dt>
    (<xsl:value-of select="parent::tei:item/@n"/>)
    <xsl:apply-templates/>
  </dt>
</xsl:template>

<xsl:template match="tei:list[@type='termlist']">
<dl>
  <xsl:apply-templates/>
</dl>
</xsl:template>


<xsl:template match="tei:list[@type='termlist']/tei:item/tei:gloss">
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<xsl:template match="tei:p[count(*)=1 and tei:term]">
  <p style="font-weight: bold">
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template match="tei:p[count(*)=1 and tei:gloss]">
  <p style="margin-left: 1em">
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template match="tei:num">
  <span class="isonum">
    <xsl:choose>
      <xsl:when test="$numberFormat='fr'">
	<xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="translate(.,',&#160;','.,')"/>
      </xsl:otherwise>
    </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="tei:c[@rend='tab']">
  <xsl:text>	</xsl:text>
</xsl:template>

<xsl:template match="tei:c[@iso:font]">
  <xsl:value-of select="@n"/>
</xsl:template>

<xsl:template match="tei:seg[@iso:provision]">
  <span class="provision_{@iso:provision}">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template name="makeHTMLHeading">
  <xsl:param name="text"/>
  <xsl:param name="class">title</xsl:param>
  <xsl:param name="level">1</xsl:param>
  <xsl:choose>
    <xsl:when
	test="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type)]">
    <xsl:element name="h{$level}">
      <xsl:attribute name="class">
	<xsl:value-of select="$class"/>
      </xsl:attribute>
      <xsl:value-of select="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type)][1]"/>
    </xsl:element>
    </xsl:when>

    <xsl:when test="not($text='')">
    <xsl:element name="h{$level}">
      <xsl:attribute name="class">
	<xsl:value-of select="$class"/>
      </xsl:attribute>
      <xsl:value-of select="$text"/>
    </xsl:element>
    </xsl:when>
  </xsl:choose>
</xsl:template>
 

</xsl:stylesheet>
