<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
 xmlns:rng="http://relaxng.org/ns/structure/1.0"
 xmlns:tei="http://www.tei-c.org/ns/1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:exsl="http://exslt.org/common"
 extension-element-prefixes="exsl"
 exclude-result-prefixes="tei exsl" 
 version="1.0">
<xsl:output method="xml" indent="yes" encoding="utf-8"/>
<xsl:param name="lang">es</xsl:param>
<xsl:param name="verbose"></xsl:param>
<xsl:key name="ELEMENTS" match="element" use="@ident"/>
<xsl:key name="ATTRIBUTES" match="attribute" use="@ident"/>
<xsl:param name="TEISERVER">http://tei.oucs.ox.ac.uk/Query/i18n.xq</xsl:param>

<xsl:template match="comment()|text()|processing-instruction()">
  <xsl:copy/>
</xsl:template>

<xsl:template match="/">
  <xsl:if test="$verbose='true'">
    <xsl:message>Translating to language [<xsl:value-of select="$lang"/>]</xsl:message>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:*">
<xsl:variable name="oldname" select="local-name(.)"/>
<xsl:variable name="newname">
  <xsl:for-each select="document($TEISERVER)">
    <xsl:choose>
      <xsl:when test="key('ELEMENTS',$oldname)">
	<xsl:for-each select="key('ELEMENTS',$oldname)">
	  <xsl:choose>
	    <xsl:when test="equiv[@xml:lang=$lang][not(@value='')]">
	      <xsl:value-of select="equiv[@xml:lang=$lang]/@value"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$oldname"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$oldname"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:variable>

<!--
  <xsl:if test="$verbose='true'">
    <xsl:message> :<xsl:value-of select="$oldname"/> to <xsl:value-of select="$newname"/></xsl:message>
  </xsl:if>
-->
<xsl:element name="{$newname}" xmlns="http://www.tei-c.org/ns/1.0">
  <xsl:apply-templates select="@*|*|text()|comment()"/>
</xsl:element>
</xsl:template>

<xsl:template match="@xml:lang">
  <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="@xml:id">
  <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="@*">
<xsl:variable name="oldname" select="local-name(.)"/>
<xsl:variable name="newname">
  <xsl:for-each select="document($TEISERVER)">
    <xsl:choose>
      <xsl:when test="key('ATTRIBUTES',$oldname)">
	<xsl:for-each select="key('ATTRIBUTES',$oldname)">
	  <xsl:choose>
	    <xsl:when test="equiv[@xml:lang=$lang][not(@value='')]">
	      <xsl:value-of select="equiv[@xml:lang=$lang]/@value"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$oldname"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$oldname"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:variable>
<xsl:attribute name="{$newname}">
  <xsl:value-of select="."/>
</xsl:attribute>
</xsl:template>

</xsl:stylesheet>
