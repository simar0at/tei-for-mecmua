<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
 xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
  exclude-result-prefixes="tei exsl" 
  version="1.0">
<xsl:key name="TAGMODS" match="Tag|AttClass" use="Tagset"/>
<xsl:key name="MODS" match="tei:module" use="@ident"/>
<xsl:output method="xml" indent="yes"/>
<xsl:param name="newlang">es</xsl:param>
<xsl:param name="ODDROOT">/TEI/P5/</xsl:param>
<xsl:param name="verbose">true</xsl:param>

<xsl:template match="tei:*|rng:*">
  <xsl:copy>
    <xsl:apply-templates select="@*|*|text()|comment()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*|comment()|text()">
  <xsl:copy/>
</xsl:template>

<xsl:template match="tei:elementSpec[@mode='change']">
  <xsl:copy>
    <xsl:apply-templates select="@*|*|text()|comment()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="tei:schema">
  <xsl:for-each select="tei:moduleRef">
    <xsl:variable name="test" select="@key"/>
    <xsl:if test="not(key('MODS',$test))">
      <xsl:choose>
	<xsl:when test="$test='tei'">
	  <module  xmlns="http://www.tei-c.org/ns/1.0" mode="change" ident="tei">
	    <xsl:call-template name="findTranslateNames">
	      <xsl:with-param name="modname">core</xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="findTranslateNames">
	      <xsl:with-param name="modname">header</xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="findTranslateNames">
	      <xsl:with-param name="modname">teikeywords</xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="findTranslateNames">
	      <xsl:with-param name="modname">teiclasses</xsl:with-param>
	    </xsl:call-template>
	  </module>
	</xsl:when>
	<xsl:when test="$test='general'">
	  <module  xmlns="http://www.tei-c.org/ns/1.0" mode="change" ident="general">
	    <xsl:call-template name="findTranslateNames">
	      <xsl:with-param name="modname">structure</xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="findTranslateNames">
	      <xsl:with-param name="modname">frontmatter</xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="findTranslateNames">
	      <xsl:with-param name="modname">backmatter</xsl:with-param>
	    </xsl:call-template>
	  </module>
	</xsl:when>
	<xsl:otherwise>
	  <module  xmlns="http://www.tei-c.org/ns/1.0" mode="change" ident="{$test}">
	  <xsl:call-template name="findTranslateNames">
	    <xsl:with-param name="modname">
	      <xsl:value-of select="$test"/>
	    </xsl:with-param>
	  </xsl:call-template>
	  </module>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:for-each>
  <xsl:copy>
    <xsl:apply-templates select="@*|*|text()|comment()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="tei:module[@mode='change']">
  <xsl:copy>
    <xsl:apply-templates select="@*|*|text()|comment()"/>
    <xsl:choose>
      <xsl:when test="@ident='tei'">
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">core</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">header</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">teikeywords</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">teiclasses</xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="@ident='general'">
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">structure</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">frontmatter</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">backmatter</xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">
	    <xsl:value-of select="@ident"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

<xsl:template name="findTranslateNames">
  <xsl:param name="modname"/>
  <xsl:variable name="HERE" select="."/>

  <xsl:message>Translations for <xsl:value-of select="$modname"/></xsl:message>

  <xsl:for-each
   select="document(concat($ODDROOT,'Tools/tags.xml'))/Table">
    <xsl:for-each select="key('TAGMODS',$modname)">
      <xsl:variable name="thisthing" select="ident"/>
      <xsl:variable name="ename">	
	<xsl:choose>
	  <xsl:when test="$HERE/tei:elementSpec[@ident=$thisthing]">
	    <xsl:if
	     test="$HERE/tei:elementSpec[@ident=$thisthing]/tei:attList">
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message>  translation for <xsl:value-of
	    select="$thisthing"/></xsl:message>
	    <xsl:for-each
	     select="document(concat($ODDROOT,'Tools/teinames.xml'))/i18n/element[@ident=$thisthing]">
	      <xsl:if test="@*[name(.)=$newlang]">
		<altIdent xmlns="http://www.tei-c.org/ns/1.0">
		  <xsl:value-of select="@*[name(.)=$newlang]"/>
		</altIdent>
	      </xsl:if>
	    </xsl:for-each>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="aname">
	<xsl:choose>
	  <xsl:when test="$HERE/tei:elementSpec[@ident=$thisthing]">
	    <xsl:if
	     test="$HERE/tei:elementSpec[@ident=$thisthing]/tei:attList">
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	<xsl:if test="Attributes">
	  <attList xmlns="http://www.tei-c.org/ns/1.0">
	    <xsl:for-each select="Attributes/Att">
	      <xsl:variable name="thisatt" select="@n"/>
	      <xsl:for-each
	       select="document(concat($ODDROOT,'Tools/teinames.xml'))/i18n/attribute[@ident=$thisatt]">
		<xsl:if test="@*[name(.)=$newlang]">

		  <xsl:message>     translate attribute <xsl:value-of
		  select="$thisatt"/> to  <xsl:value-of select="@*[name(.)=$newlang]"/></xsl:message>
		  <attDef ident="{$thisatt}" mode="change"
		    xmlns="http://www.tei-c.org/ns/1.0">
		    <altIdent xmlns="http://www.tei-c.org/ns/1.0">
		      <xsl:value-of select="@*[name(.)=$newlang]"/>
		    </altIdent>
		  </attDef>
		</xsl:if>
	      </xsl:for-each>
	    </xsl:for-each>
	  </attList>
	</xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:if test="string-length($aname)&gt;0 or
	      string-length($ename)&gt;0">
	<xsl:choose>
	  <xsl:when test="starts-with($thisthing,'tei.')">
	    <classSpec ident="{$thisthing}" mode="change" xmlns="http://www.tei-c.org/ns/1.0">
	      <xsl:copy-of select="$aname"/>
	    </classSpec>
	  </xsl:when>
	  <xsl:otherwise>
	    <elementSpec ident="{$thisthing}" mode="change" xmlns="http://www.tei-c.org/ns/1.0">
	      <xsl:copy-of select="$ename"/>
	      <xsl:copy-of select="$aname"/>
	    </elementSpec>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>


<xsl:template name="findAttributes">

</xsl:template>

</xsl:stylesheet>