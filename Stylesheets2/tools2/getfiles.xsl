<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
      exclude-result-prefixes="n tei xs"
      xmlns:n="www.example.com"
      xmlns:tei="http://www.tei-c.org/ns/1.0"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="corpus"/>
  <xsl:param name="corpusList"/>
  <xsl:param name="processP4">false</xsl:param>
  <xsl:param name="verbose">false</xsl:param>
  <xsl:key name="All" match="*" use="1"/>
  <xsl:key name="E" match="*" use="local-name()"/>

  <xsl:template match="/">
    <xsl:variable name="pathlist">
      <xsl:choose>
	<xsl:when test="corpusList=''">
	  <xsl:value-of 
	      select="concat($corpus,
		      '?select=*.xml;recurse=yes;on-error=warning')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$corpusList"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="docs" select="collection($pathlist)"/> 
    <xsl:variable name="all">
      <n:ROOT>
	<xsl:choose>
	<xsl:when test="$processP4='true'">
	  <xsl:for-each select="$docs/TEI.2">
	    <xsl:if test="$verbose='true'">
	      <xsl:message>processing <xsl:value-of select="base-uri(.)"/></xsl:message>
	    </xsl:if>
	    <TEI.2 xn="{base-uri(.)}">
	      <xsl:apply-templates select="*|@*" mode="copy"/>
	    </TEI.2>
	  </xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:for-each select="$docs/tei:TEI">
	    <xsl:if test="$verbose='true'">
	      <xsl:message>processing <xsl:value-of select="base-uri(.)"/></xsl:message>
	    </xsl:if>
	    <tei:TEI xn="{base-uri(.)}">
	      <xsl:apply-templates select="*|@*" mode="copy"/>
	    </tei:TEI>
	  </xsl:for-each>
	  <xsl:for-each select="$docs/tei:teiCorpus">
	    <xsl:if test="$verbose='true'">
	      <xsl:message>processing <xsl:value-of select="base-uri(.)"/></xsl:message>
	    </xsl:if>
	    <tei:teiCorpus xn="{base-uri(.)}">
	      <xsl:copy-of select="@*|*"/>
	    </tei:teiCorpus>
	  </xsl:for-each>
	</xsl:otherwise>
	</xsl:choose>
      </n:ROOT>
    </xsl:variable>
    <xsl:for-each select="$all">
      <xsl:call-template name="processAll"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="processAll">
    <html>
      <body>
	<table border="1">
	  <xsl:for-each-group select="key('All',1)" group-by="local-name()">
	    <xsl:sort select="current-grouping-key()"/>
	    <tr valign="top">
	      <td> 
		<xsl:value-of select="current-grouping-key()"/>
	      </td> 
	      <td> 
		<xsl:value-of select="count(current-group())"/>
	      </td> 
	    </tr>
	  </xsl:for-each-group>
	</table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="@*" mode="copy">
    <xsl:copy-of select="."/>
  </xsl:template>


  <xsl:template match="*" mode="copy">
    <xsl:copy>
      <xsl:apply-templates 
	  select="*|@*" mode="copy"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>


