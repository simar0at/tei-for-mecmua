<?xml version="1.0" encoding="UTF-8"?>
<!--
 #  The Contents of this file are made available subject to the terms of
 # the GNU Lesser General Public License Version 2.1

 # Sebastian Rahtz / University of Oxford
 # copyright 2005

 # This stylesheet is derived from the OpenOffice to Docbook conversion
 #  Sun Microsystems Inc., October, 2000

 #  GNU Lesser General Public License Version 2.1
 #  =============================================
 #  Copyright 2000 by Sun Microsystems, Inc.
 #  901 San Antonio Road, Palo Alto, CA 94303, USA
 #
 #  This library is free software; you can redistribute it and/or
 #  modify it under the terms of the GNU Lesser General Public
 #  License version 2.1, as published by the Free Software Foundation.
 #
 #  This library is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 #  Lesser General Public License for more details.
 #
 #  You should have received a copy of the GNU Lesser General Public
 #  License along with this library; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 #  MA  02111-1307  USA
 #
 #
-->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dom="http://www.w3.org/2001/xml-events"
    xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
    xmlns:math="http://www.w3.org/1998/Math/MathML"
    xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
    xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:ooo="http://openoffice.org/2004/office"
    xmlns:oooc="http://openoffice.org/2004/calc"
    xmlns:ooow="http://openoffice.org/2004/writer"
    xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    office:version="1.0"
    exclude-result-prefixes="office style text table draw fo xlink dc meta
			 number svg chart dr3d math form script ooo ooow oooc dom xforms xsd xsi"
>

  <xsl:key name="headchildren" match="text:p | text:alphabetical-index
| table:table | text:span | office:annotation |
text:list | text:footnote | text:a | text:list-item |
draw:plugin | draw:text-box | text:footnote-body | text:section"
use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5'])[last()])"/>

  <xsl:key name="children" match="text:h[@text:outline-level='2']"
use="generate-id(preceding-sibling::text:h[@text:outline-level='1'][1])"/>

  <xsl:key name="children" match="text:h[@text:outline-level='3']"
use="generate-id(preceding-sibling::text:h[@text:outline-level='2' or
@text:outline-level='1'][1])"/>

  <xsl:key name="children" match="text:h[@text:outline-level='4']"
use="generate-id(preceding-sibling::text:h[@text:outline-level='3' or
@text:outline-level='2' or @text:outline-level='1'][1])"/>

  <xsl:key name="children" match="text:h[@text:outline-level='5']"
use="generate-id(preceding-sibling::text:h[@text:outline-level='4' or
@text:outline-level='3' or @text:outline-level='2' or @text:outline-level='1'][1])"/>

  <xsl:key name="secondary_children" match="text:p[@text:style-name =
'Index 2']"
use="generate-id(preceding-sibling::text:p[@text:style-name = 'Index
1'][1])"/>

  <xsl:key name="STYLES" match="style:style" use="@style:name"/>

  <xsl:key name="Headings" match="text:h" use="text:outline-level"/>

  <xsl:param name="META" select="/"/>

  <xsl:output encoding="utf-8" indent="yes"/>

  <xsl:strip-space elements="text:span"/>

  <xsl:variable name="document-title">
    <xsl:choose>
      <xsl:when test="/office:document-content/office:body/office:text/text:p[@text:style-name='Title']">
        <xsl:value-of select="/office:document-content/office:body/office:text/text:p[@text:style-name='Title'][1]"/>
      </xsl:when>
      <xsl:when test="/office:document/office:meta/dc:title">
        <xsl:value-of select="/office:document/office:meta/dc:title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Untitled Document</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


<xsl:template match="/office:document">
    <xsl:for-each select="descendant::text:variable-decl">
      <xsl:variable name="name">
        <xsl:value-of select="@text:name"/>
      </xsl:variable>
      <xsl:if test="contains(@text:name,'entitydecl')">
	<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE TEI.2 [
	</xsl:text>
	<xsl:text disable-output-escaping="yes">&lt;!ENTITY </xsl:text>
	<xsl:value-of select="substring-after(@text:name,'entitydecl_')"/>
	<xsl:text> &quot;</xsl:text>
	<xsl:value-of select="/descendant::text:variable-set[@text:name= $name][1]"/>
	<xsl:text disable-output-escaping="yes">&quot;&gt;</xsl:text>
	<xsl:text disable-output-escaping="yes">]&gt;</xsl:text>
      </xsl:if>
    </xsl:for-each>

    <TEI.2 lang="{normalize-space(/office:document/office:meta/dc:language)}">
      <xsl:call-template name="teiHeader"/>
      <xsl:apply-templates/>
    </TEI.2>
  </xsl:template>


<xsl:template match="text:variable-set|text:variable-get">
    <xsl:choose>
      <xsl:when test="contains(@text:style-name,'entitydecl')">
        <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
        <xsl:value-of select="substring-after(@text:style-name,'entitydecl_')"/>
        <xsl:text disable-output-escaping="yes">;</xsl:text>
      </xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template name="teiHeader">
  <teiHeader >
    <fileDesc>
      <titleStmt>
	<title>
	  <xsl:value-of select="$document-title"/>
	</title>
	<author>
	  <xsl:value-of select="/office:document/office:meta/meta:initial-creator"/>
	</author>
      </titleStmt>
      <editionStmt>
	<edition>
	  <date>
	    <xsl:value-of select="/office:document/office:meta/meta:creation-date"/>
	  </date>
	</edition>
      </editionStmt>
      <publicationStmt>
	<authority></authority>
      </publicationStmt>
      <sourceDesc>
	<p><xsl:apply-templates select="/office:document/office:meta/meta:generator"/>Written by OpenOffice</p>
      </sourceDesc>
    </fileDesc>
    <profileDesc>
      <langUsage>
	<language>
	  <xsl:attribute name="id">
	    <xsl:value-of
		select="/office:document/office:meta/dc:language"/>
	  </xsl:attribute>
	  <xsl:value-of select="/office:document/office:meta/dc:language"/>
	</language>
      </langUsage>
      <xsl:if test="/office:document/office:meta/meta:keyword">
	<textClass>
	  <keywords>
	    <list>
	      <xsl:for-each select="/office:document/office:meta/meta:keyword">
		<item>
		  <xsl:value-of select="."/>
		</item>
	      </xsl:for-each>
	    </list>
	  </keywords>
	</textClass>
      </xsl:if>
    </profileDesc>
    <revisionDesc>
      <change>
	<date> <xsl:apply-templates select="/office:document/office:meta/dc:date"/></date>
	<respStmt>
	  <name> <xsl:apply-templates select="/office:document/office:meta/dc:creator"/></name>
	</respStmt>
	<item>revision</item>
        </change>
    </revisionDesc>
    </teiHeader>
</xsl:template>



<xsl:template match="/office:document/office:body">
  <text>
    <xsl:apply-templates/>
  </text>
</xsl:template>

<xsl:template match="office:text">
  <body>
    <xsl:apply-templates select="key('headchildren', generate-id())"/>
    <xsl:choose>
      <xsl:when test="text:h[@text:outline-level='1']">
	<xsl:apply-templates
	    select="text:h[@text:outline-level='1']"/>
      </xsl:when>
      <xsl:when test="text:h[@text:outline-level='2']">
	<xsl:apply-templates
	    select="text:h[@text:outline-level='2']"/>
      </xsl:when>
      <xsl:when test="text:h[@text:outline-level='3']">
	<xsl:apply-templates
	    select="text:h[@text:outline-level='3']"/>
      </xsl:when>
    </xsl:choose>
  </body>
</xsl:template>

<!-- sections -->
<xsl:template match="text:h">
    <xsl:choose>
      <xsl:when test="@text:style-name='ArticleInfo'">
      </xsl:when>
      <xsl:when test="@text:style-name='Abstract'">
        <div type="abstract" >
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:when test="@text:style-name='Appendix'">
        <div>
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="sectvar">
          <xsl:text>div</xsl:text>
  <!--          <xsl:value-of select="count(ancestor::text:section)+1"/>-->
        </xsl:variable>
        <xsl:variable name="idvar">
          <xsl:text> id=&quot;</xsl:text>
          <xsl:value-of select="@text:style-name"/>
          <xsl:text>&quot;</xsl:text>
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
        <xsl:value-of select="$sectvar"/>
        <xsl:value-of select="$idvar"/>
        <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text disable-output-escaping="yes">&lt;/</xsl:text>
        <xsl:value-of select="$sectvar"/>
        <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


<xsl:template match="text:h[@text:outline-level='1']">
    <xsl:choose>
      <xsl:when test=".='Abstract'">
        <div  type="abstract">
          <xsl:apply-templates select="key('headchildren', generate-id())"/>
          <xsl:apply-templates select="key('children', generate-id())"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-section">
          <xsl:with-param name="current" select="@text:outline-level"/>
          <xsl:with-param name="prev" select="1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


<xsl:template match="text:h[@text:outline-level='2'] | text:h[@text:outline-level='3']| text:h[@text:outline-level='4'] | text:h[@text:outline-level='5']">
    <xsl:variable name="level">
      <xsl:value-of select="@text:outline-level"/>
    </xsl:variable>
    <xsl:if test="not(normalize-space(.)='')">
    <xsl:call-template name="make-section">
      <xsl:with-param name="current" select="$level"/>
      <xsl:with-param name="prev" select="preceding-sibling::text:h[@text:outline-level &lt; $level][1]/@text:outline-level "/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="make-section">
    <xsl:param name="current"/>
    <xsl:param name="prev"/>
    <div >
      <!--
<xsl:value-of select="@text:outline-level"/>, <xsl:value-of select="normalize-space(.)"/>:
        <xsl:for-each select="key('children',generate-id())">
<xsl:text>  </xsl:text><xsl:value-of select="@text:outline-level"/>, <xsl:value-of select="normalize-space(.)"/>;
        </xsl:for-each>
-->
    <xsl:call-template name="id.attribute"/>
    <xsl:choose>
      <xsl:when test="$current &gt; $prev+1">
          <head/>
          <xsl:call-template name="make-section">
            <xsl:with-param name="current" select="$current"/>
            <xsl:with-param name="prev" select="$prev +1"/>
          </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<head><xsl:apply-templates/></head>
	<xsl:variable name="this">
	  <xsl:value-of select="generate-id()"/>
	</xsl:variable>
	<xsl:for-each select="key('headchildren', $this)">
	  <xsl:if test="not(parent::text:h)">
	    <xsl:apply-templates select="."/>
	  </xsl:if>
	</xsl:for-each>
	<xsl:apply-templates select="key('children', generate-id())"/>
      </xsl:otherwise>
    </xsl:choose>
    </div>
</xsl:template>


<!-- special case paragraphs -->
<xsl:template match="text:p[@text:style-name='XMLComment']">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>


<xsl:template match="text:section[@text:style-name = 'ArticleInfo']/text:p[not(@text:style-name='XMLComment')]">
    <xsl:apply-templates/>
  </xsl:template>


<xsl:template match="text:p[@text:style-name='Document Title']">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>

<xsl:template match="text:p[@text:style-name='Author']">
  <author><xsl:apply-templates/></author>
</xsl:template>

<xsl:template match="text:p[@text:style-name='lg']">
  <lg><xsl:apply-templates/></lg>
</xsl:template>

<xsl:template match="text:p[@text:style-name='Title']">
  <title>
    <xsl:apply-templates/>
  </title>
</xsl:template>

<xsl:template match="text:p[@text:style-name='Date']">
  <date>
      <xsl:apply-templates/>
  </date>
</xsl:template>

<xsl:template match="text:p[@text:style-name='signed']">
  <signed>
    <xsl:apply-templates/>
  </signed>
</xsl:template>

<xsl:template match="text:p[@text:style-name='Section Title']">
  <head>
    <xsl:apply-templates/>
  </head>
</xsl:template>

<xsl:template match="text:p[@text:style-name='Appendix Title']">
  <head>
    <xsl:apply-templates/>
  </head>
</xsl:template>

<xsl:template match="text:p[@text:style-name='Screen']">
    <Screen>
      <xsl:apply-templates/>
    </Screen>
  </xsl:template>


<xsl:template match="text:p[@text:style-name='Output']">
    <Output>
      <xsl:apply-templates/>
    </Output>
  </xsl:template>


<xsl:template match="office:annotation/text:p">
    <note>
      <remark>
        <xsl:apply-templates/>
      </remark>
    </note>
  </xsl:template>


<!-- normal paragraphs -->
<xsl:template match="text:p">
    <xsl:choose>
      <xsl:when test="parent::text:list-item">
	<xsl:call-template name="applyStyle"/>
      </xsl:when>
      <xsl:when test="@text:style-name='Table'"/>
      <xsl:when test="normalize-space(.)=''"/>
      <xsl:when test="text:span[@text:style-name = 'XrefLabel']"/>
      <xsl:when test="@text:style-name='Speech'">
          <sp>
	    <speaker></speaker>
	    <p>
	      <xsl:call-template name="id.attribute"/>
	      <xsl:call-template name="applyStyle"/>
	    </p>
          </sp>
      </xsl:when>
      <xsl:otherwise>
          <p>
            <xsl:call-template name="id.attribute"/>
            <xsl:call-template name="applyStyle"/>
          </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- lists -->
<xsl:template match="text:list">
    <xsl:choose>
      <xsl:when test="@text:style-name='Var List'">
        <list>
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:when test="starts-with(@text:style-name,'P')">
        <list type="ordered" >
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:otherwise>
        <list type="unordered" >
          <xsl:apply-templates/>
        </list>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template match="text:list-header">
  <head>
    <xsl:apply-templates/>
  </head>
</xsl:template>

<xsl:template match="text:list-item">
  <xsl:choose>
    <xsl:when test="parent::text:list/@text:style-name='Var List'">
      <item>
        <xsl:for-each select="text:p[@text:style-name='VarList Term']">
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </item>
    </xsl:when>
    <xsl:otherwise>
      <item >
        <xsl:apply-templates/>
      </item>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="text:p[@text:style-name='VarList Item' or @text:style-name='List Contents']">
    <xsl:if test="not(preceding-sibling::text:p[@text:style-name='VarList Item'])">
      <xsl:text disable-output-escaping="yes">&lt;item&gt;</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="not(following-sibling::text:p[@text:style-name='VarList Item'])">
      <xsl:text disable-output-escaping="yes">&lt;/item&gt;</xsl:text>
    </xsl:if>
  <xsl:variable name="next">
    <xsl:for-each select="following-sibling::text:p[1]">
        <xsl:value-of select="@text:style-name"/>
    </xsl:for-each>
  </xsl:variable>
<xsl:choose>
    <xsl:when test="$next='VarList Term'"/>
    <xsl:when test="$next='List Heading'"/>
    <xsl:when test="$next='VarList Item'"/>
    <xsl:when test="$next='List Contents'"/>
    <xsl:otherwise>
      <xsl:text disable-output-escaping="yes">&lt;/list&gt;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template match="text:p[@text:style-name='VarList Term' or @text:style-name='List Heading']">
  <xsl:variable name="prev">
    <xsl:for-each select="preceding-sibling::text:p[1]">
        <xsl:value-of select="@text:style-name"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$prev='VarList Term'"/>
    <xsl:when test="$prev='List Heading'"/>
    <xsl:when test="$prev='VarList Item'"/>
    <xsl:when test="$prev='List Contents'"/>
    <xsl:otherwise>
          <xsl:text disable-output-escaping="yes">&lt;list type="gloss"&gt;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
    <label>
      <xsl:apply-templates/>
    </label>
  </xsl:template>

<!-- inline -->

<xsl:template match="text:span">
  <xsl:variable name="Style">
    <xsl:value-of select="@text:style-name"/>
  </xsl:variable>
    <xsl:choose>
      <xsl:when test="$Style='Emphasis'">
        <emph >
          <xsl:apply-templates/>
        </emph>
      </xsl:when>
      <xsl:when test="$Style='Underline'">
        <hi rend="ul" >
          <xsl:apply-templates/>
        </hi>
      </xsl:when>
      <xsl:when test="$Style='SmallCaps'">
        <hi rend="sc" >
          <xsl:apply-templates/>
        </hi>
      </xsl:when>
      <xsl:when test="$Style='Emphasis Bold'">
        <hi >
          <xsl:apply-templates/>
        </hi>
      </xsl:when>
      <xsl:when test="$Style='Highlight'">
        <hi >
          <xsl:apply-templates/>
        </hi>
      </xsl:when>
      <xsl:when test="$Style='q'">
        <q>
          <xsl:choose>
            <xsl:when test="starts-with(.,'&#x2018;')">
               <xsl:value-of
select="substring-before(substring-after(.,'&#x2018;'),'&#x2019;')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </q>
      </xsl:when>
      <xsl:when test="$Style='date'">
        <date>
          <xsl:apply-templates/>
        </date>
      </xsl:when>
      <xsl:when test="$Style='l'">
        <l>
          <xsl:apply-templates/>
        </l>
      </xsl:when>
      <xsl:when test="$Style='Filespec'">
        <Filespec>
          <xsl:apply-templates/>
        </Filespec>
      </xsl:when>
      <xsl:when test="$Style='gi'">
        <gi>
          <xsl:apply-templates/>
        </gi>
      </xsl:when>
      <xsl:when test="$Style='Code'">
        <Code>
          <xsl:apply-templates/>
        </Code>
      </xsl:when>
      <xsl:when test="$Style='Input'">
        <Input>
          <xsl:apply-templates/>
        </Input>
      </xsl:when>
      <xsl:when test="$Style='Internet Link'">
          <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$Style='SubScript'">
        <hi rend="sub" >
          <xsl:apply-templates/>
        </hi>
      </xsl:when>
      <xsl:when test="$Style='SuperScript'">
        <hi rend="sup" >
          <xsl:apply-templates/>
        </hi>
      </xsl:when>
      <xsl:when test="../text:h">
         <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="normalize-space(.)=''"/>
      <xsl:otherwise>
        <xsl:call-template name="applyStyle"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template name="applyStyle">
  <xsl:variable name="name">
    <xsl:value-of select="@text:style-name"/>
  </xsl:variable>
 <xsl:choose>
   <xsl:when test="key('STYLES',$name)">
     <xsl:variable name="contents">
       <xsl:apply-templates/>
     </xsl:variable>
     <xsl:for-each select="key('STYLES',$name)">
<!--
    <xsl:message>! <xsl:for-each select="style:text-properties/@*">
    <xsl:value-of select="name(.)"/>:        <xsl:value-of select="."/>&#10;
    </xsl:for-each>
    </xsl:message>
-->
       <xsl:choose>
	 <xsl:when
	     test="style:text-properties[starts-with(@style:text-position,'super')]">
	   <hi rend="sup">
	     <xsl:copy-of select="$contents"/>
	   </hi>
	 </xsl:when>
	 <xsl:when
	     test="style:text-properties[starts-with(@style:text-position,'sub')]">
	   <hi rend="sub">
	     <xsl:copy-of select="$contents"/>
	   </hi>
	 </xsl:when>
	 <xsl:when test="style:text-properties[@fo:font-weight='bold']">
	   <hi>
	     <xsl:copy-of select="$contents"/>
	   </hi>
	 </xsl:when>
	 <xsl:when
	     test="style:text-properties[style:text-underline-style='solid']">
	   <hi rend="underline">
	     <xsl:copy-of select="$contents"/>
	   </hi>
	 </xsl:when>
	 <xsl:when test="style:text-properties[@fo:font-style='italic']">
	   <emph>
	     <xsl:copy-of select="$contents"/>
	   </emph>
	 </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="$contents"/>
      </xsl:otherwise>
       </xsl:choose>
     </xsl:for-each>
   </xsl:when>
   <xsl:otherwise>
     <xsl:apply-templates/>
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- tables -->
<xsl:template match="table:table">
 <table rend="frame">
   <xsl:if test="@table:name">
     <xsl:attribute name="id">
       <xsl:value-of select="@table:name"/>
     </xsl:attribute>
   </xsl:if>
   <xsl:if test="following-sibling::text:p[@text:style-name='Table']">
   <head>
   <xsl:value-of select="following-sibling::text:p[@text:style-name='Table']"/>
   </head>
  </xsl:if>
  <xsl:call-template name="generictable"/>
 </table>

</xsl:template>


<xsl:template name="generictable">
    <xsl:variable name="cells" select="count(descendant::table:table-cell)"/>
    <xsl:variable name="rows">
      <xsl:value-of select="count(descendant::table:table-row) "/>
    </xsl:variable>
    <xsl:variable name="cols">
      <xsl:value-of select="$cells div $rows"/>
    </xsl:variable>
    <xsl:variable name="numcols">
      <xsl:choose>
        <xsl:when test="child::table:table-column/@table:number-columns-repeated">
          <xsl:value-of select="number(table:table-column/@table:number-columns-repeated+1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$cols"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:apply-templates/>
  </xsl:template>

<xsl:template name="colspec">
    <xsl:param name="left"/>
    <xsl:if test="number($left &lt; ( table:table-column/@table:number-columns-repeated +2)  )">
      <xsl:element name="colspec">
        <xsl:attribute name="colnum">
          <xsl:value-of select="$left"/>
        </xsl:attribute>
        <xsl:attribute name="colname">c
                    <xsl:value-of select="$left"/>
                </xsl:attribute>
      </xsl:element>
      <xsl:call-template name="colspec">
        <xsl:with-param name="left" select="$left+1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

<xsl:template match="table:table-column">
    <xsl:apply-templates/>
  </xsl:template>

<xsl:template match="table:table-header-rows">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="table:table-header-rows/table:table-row">
    <row role="label">
      <xsl:apply-templates/>
    </row>
  </xsl:template>

<xsl:template match="table:table/table:table-row">
    <row>
      <xsl:apply-templates/>
    </row>
</xsl:template>

<xsl:template match="table:table-cell/text:h">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="table:table-cell/text:p">
  <xsl:call-template name="applyStyle"/>
</xsl:template>

<xsl:template match="table:table-cell">
  <cell>
      <xsl:if test="@table:number-columns-spanned &gt;'1'">
        <xsl:attribute name="cols">
          <xsl:value-of select="@table:number-columns-spanned"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="text:h">
	<xsl:attribute name="role">label</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
  </cell>
</xsl:template>


<!-- notes -->
<xsl:template match="text:note-citation"/>

<xsl:template match="text:note-body">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="text:note-body/text:p">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="text:note">
  <note >
    <xsl:choose>
      <xsl:when test="@text:note-class='endnote'">
	<xsl:attribute name="place">end</xsl:attribute>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates/>
  </note>
</xsl:template>

<!-- drawing -->
<xsl:template match="draw:plugin">
  <ptr target="{@xlink:href}" />
</xsl:template>

<xsl:template match="draw:text-box"/>

<xsl:template match="draw:image">
    <xsl:choose>
      <xsl:when test="parent::text:p[@text:style-name='Mediaobject']">
        <figure>
	  <xsl:call-template name="findGraphic"/>
          <head>
            <xsl:value-of select="."/>
          </head>
        </figure>
      </xsl:when>
      <xsl:otherwise>
	<figure>
	  <xsl:call-template name="findGraphic"/>
	</figure>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template name="findGraphic">
  <xsl:choose>
    <xsl:when test="office:binary-data">
      <binaryObject mimeType="image/jpg">
	<xsl:value-of select="."/>
      </binaryObject>
    </xsl:when>
    <xsl:when test="@xlink:href">
      <xsl:attribute name="url">
	<xsl:value-of select="@xlink:href" />
      </xsl:attribute>
    </xsl:when>
  </xsl:choose>
</xsl:template>
<!-- linking -->
<xsl:template match="text:a">
  <xsl:choose>
    <xsl:when test="starts-with(@xlink:href,'mailto:')">
      <xsl:choose>
	<xsl:when test=".=@xlink:href">
	  <xptr url="{substring-after(@xlink:href,'mailto:')}"/>
	</xsl:when>
	<xsl:otherwise>
	  <xref url="{@xlink:href}">
	    <xsl:apply-templates/>
	  </xref>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="contains(@xlink:href,'://')">
      <xsl:choose>
	<xsl:when test=".=@xlink:href">
	  <xptr url="{@xlink:href}"/>
	</xsl:when>
	<xsl:otherwise>
	  <xref url="{@xlink:href}">
	    <xsl:apply-templates/>
	  </xref>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="not(contains(@xlink:href,'#'))">
      <ref target="{@xlink:href}">
	<xsl:apply-templates/>
        </ref>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="linkvar"
          select="substring-after(@xlink:href,'#')"/>
        <xsl:choose>
          <xsl:when test=".=$linkvar">
            <ptr target="{$linkvar}" />
          </xsl:when>
          <xsl:otherwise>
            <ref target="{$linkvar}" >
              <xsl:apply-templates/>
            </ref>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template match="text:line-break">
  <xsl:if test="not(parent::text:span[@text:style-name='l'])">
    <lb/>
  </xsl:if>
</xsl:template>

<xsl:template match="text:tab">
  <xsl:text>	</xsl:text>
</xsl:template>

<xsl:template match="text:reference-ref">
    <ptr target="{@text:ref-name}"/>
  </xsl:template>

<xsl:template name="id.attribute">
    <xsl:if test="child::text:reference-mark-start">
      <xsl:attribute name="id">
        <xsl:value-of select="child::text:reference-mark-start/@text:style-name"/>
      </xsl:attribute>
    </xsl:if>
<!-- Constraints imposed by OOo method of displaying
reference-ref text means that xreflabel and endterm are lost -->
  </xsl:template>

<xsl:template match="text:reference-mark-start"/>

<xsl:template match="text:reference-mark-end"/>

<xsl:template match="comment">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>

<xsl:template match="text:alphabetical-index-mark-start">
    <xsl:element name="indexterm">
      <xsl:attribute name="class">
        <xsl:text disable-output-escaping="yes">startofrange</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="id">
        <xsl:value-of select="@text:id"/>
      </xsl:attribute>
<!--<xsl:if test="@text:key1">-->
      <xsl:element name="primary">
        <xsl:value-of select="@text:key1"/>
      </xsl:element>
<!--</xsl:if>-->
      <xsl:if test="@text:key2">
        <xsl:element name="secondary">
          <xsl:value-of select="@text:key2"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

<xsl:template match="text:alphabetical-index-mark-end">
    <xsl:element name="indexterm">
      <xsl:attribute name="startref">
        <xsl:value-of select="@text:id"/>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text disable-output-escaping="yes">endofrange</xsl:text>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

<xsl:template match="text:alphabetical-index">
    <xsl:element name="index">
      <xsl:element name="title">
        <xsl:value-of select="text:index-body/text:index-title/text:p"/>
      </xsl:element>
      <xsl:apply-templates select="text:index-body"/>
    </xsl:element>
  </xsl:template>

<xsl:template match="text:index-body">
    <xsl:for-each select="text:p[@text:style-name = 'Index 1']">
      <xsl:element name="indexentry">
        <xsl:element name="primaryie">
          <xsl:value-of select="."/>
        </xsl:element>
        <xsl:if test="key('secondary_children', generate-id())">
          <xsl:element name="secondaryie">
            <xsl:value-of select="key('secondary_children', generate-id())"/>
          </xsl:element>
        </xsl:if>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
<!--
These seem to have no obvious translation
-->

<xsl:template match="text:bookmark-start"/>

<xsl:template match="text:bookmark-end"/>

<xsl:template match="text:bookmark"/>

<xsl:template match="text:endnotes-configuration"/>

<xsl:template match="text:file-name"/>

<xsl:template match="text:footnotes-configuration"/>

<xsl:template match="text:linenumbering-configuration"/>

<xsl:template match="text:list-level-style-bullet"/>

<xsl:template match="text:list-level-style-number"/>

<xsl:template match="text:list-style"/>

<xsl:template match="text:outline-level-style"/>

<xsl:template match="text:outline-style"/>

<xsl:template match="text:s"/>


<xsl:template match="text:*">
      [[[UNTRANSLATED <xsl:value-of select="name(.)"/>
    <xsl:apply-templates/>]]]
</xsl:template>


  <!-- sections of the OO format we don't need at present -->

<xsl:template match="office:automatic-styles"/>

<xsl:template match="office:font-decls"/>

<xsl:template match="office:meta"/>

<xsl:template match="office:script"/>

<xsl:template match="office:settings"/>

<xsl:template match="office:styles"/>

<xsl:template match="style:*"/>


<xsl:template match="dc:*">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="meta:creation-date">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="meta:editing-cycles"/>

<xsl:template match="meta:editing-duration"/>

<xsl:template match="meta:generator"/>

<xsl:template match="meta:user-defined"/>

<!--
<xsl:template match="text()">
  <xsl:apply-templates select="normalize-space(.)"/>
</xsl:template>
-->
</xsl:stylesheet>
