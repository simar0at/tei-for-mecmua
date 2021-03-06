<?xml version="1.0" encoding="UTF-8"?>
<!--
#  The Contents of this file are made available subject to the terms of
# the GNU Lesser General Public License Version 2.1

# Sebastian Rahtz / University of Oxford
# copyright 2007

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
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:atom="http://www.w3.org/2005/Atom"  
    xmlns:estr="http://exslt.org/strings"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:dbk="http://docbook.org/ns/docbook"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:ooo="http://openoffice.org/2004/office"
    xmlns:oooc="http://openoffice.org/2004/calc"
    xmlns:ooow="http://openoffice.org/2004/writer"
    xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:teix="http://www.tei-c.org/ns/Examples"
    office:version="1.0"
    >

  <xsl:strip-space elements="teix:* rng:* xsl:* xhtml:* atom:* m:*"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:decimal-format name="staff" digit="D"/>
  <xsl:variable name="doc_type">TEI</xsl:variable>

  <xsl:param name="postQuote">’</xsl:param>
  <xsl:param name="preQuote">‘</xsl:param>

  <xsl:key name='IDS' match="tei:*[@xml:id]" use="@xml:id"/>

  <xsl:template match="/">
    <office:document>
      <office:meta>
	<meta:generator>Open Office TEI to OO XSLT</meta:generator>
	<dc:title>
	  <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
	</dc:title>
	<dc:description/>
	<dc:subject/>
	<meta:creation-date>
	  <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/tei:date"/>
	</meta:creation-date>
	<dc:date>
	  <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change/tei:date"/>
	</dc:date>
	<dc:language>
	  <xsl:value-of select="/tei:TEI/@xml:lang"/>
	</dc:language>
	<meta:editing-cycles>21</meta:editing-cycles>
	<meta:editing-duration>P1DT0H11M54S</meta:editing-duration>
	<meta:user-defined meta:name="Info 1"/>
	<meta:user-defined meta:name="Info 2"/>
	<meta:user-defined meta:name="Info 3"/>
	<meta:user-defined meta:name="Info 4"/>
	<meta:document-statistic meta:table-count="1" meta:image-count="0" meta:object-count="0" meta:page-count="1" meta:paragraph-count="42" meta:word-count="144" meta:character-count="820"/>
      </office:meta>
      <!--
	  <xsl:copy-of select="document('styles.xml')/office:document-styles"/>
      -->
      <office:body>
	<office:text>
	  <xsl:apply-templates select="(.//tei:TEI|tei:text|tei:div)[1]"/>
	</office:text>
      </office:body>
    </office:document>
  </xsl:template>

<!-- base structure -->
  <xsl:template match="tei:TEI">
    <xsl:apply-templates select="tei:text"/>
  </xsl:template>

  <xsl:template match="tei:body|tei:front|tei:back">
	<xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="tei:head">
    <xsl:choose>
      <xsl:when test="parent::tei:figure"/>
      <xsl:when test="parent::tei:list"/>
      <xsl:when test="parent::tei:div"/>
      <xsl:when test="parent::tei:div0"/>
      <xsl:when test="parent::tei:div1"/>
      <xsl:when test="parent::tei:div2"/>
      <xsl:when test="parent::tei:div3"/>
      <xsl:when test="parent::tei:div4"/>
      <xsl:when test="parent::tei:div5"/>
      <xsl:when test="parent::tei:table">
	<xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="parent::tei:appendix">
	    <text:p text:style-name="Appendix">
	      <xsl:apply-templates/>	   
	    </text:p>	
	  </xsl:when>
	  <xsl:when test="parent::tei:body">
	    <text:h text:outline-level="1">
	      <xsl:apply-templates/>
	    </text:h>
	  </xsl:when>
	  <xsl:otherwise>
	    <text:p>
	      <xsl:apply-templates/>	   
	    </text:p>
	  </xsl:otherwise>
	</xsl:choose>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template match="tei:div">
    <xsl:variable name="depth">
      <xsl:value-of select="count(ancestor::tei:div)"/>
    </xsl:variable>
    <text:h>
      <xsl:attribute name="text:level">
	<xsl:value-of select="$depth + 1"/>
      </xsl:attribute>
      <xsl:attribute name="text:style-name">
	<xsl:text>Heading </xsl:text><xsl:value-of select="$depth + 1"/>
      </xsl:attribute>
      <xsl:call-template name="test.id"/>
      <xsl:apply-templates select="tei:head" mode="show"/>
    </text:h>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:div0|tei:div1|tei:div2|tei:div3|tei:div4|tei:div5">
    <xsl:variable name="depth">
      <xsl:value-of select="substring-after(name(.),'div')"/>
    </xsl:variable>
    <text:h>
      <xsl:attribute name="text:level">
	<xsl:value-of select="$depth + 1"/>
      </xsl:attribute>
      <xsl:attribute name="text:style-name">
	<xsl:text>Heading </xsl:text><xsl:value-of select="$depth + 1"/>
      </xsl:attribute>
      <xsl:call-template name="test.id"/>
      <xsl:apply-templates select="tei:head" mode="show"/>
    </text:h>
    <xsl:apply-templates/>
  </xsl:template>



<!-- paragraphs -->
  <xsl:template match="tei:author">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:p">
    <text:p>
      <xsl:choose>
	<xsl:when test="ancestor::tei:note[@place='foot']">
	  <xsl:attribute name="text:style-name">
	    <xsl:text>Footnote</xsl:text>
	  </xsl:attribute>
	</xsl:when>
	<xsl:when test="ancestor::tei:row[@role='label']">
	  <xsl:attribute name="text:style-name">Table Heading</xsl:attribute>
	</xsl:when>
	<xsl:when test="ancestor::tei:row">
	  <xsl:attribute name="text:style-name">Table Contents</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="text:style-name">Text body</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="test.id"/>
      <xsl:apply-templates/>
    </text:p>
  </xsl:template>



<!-- figures -->
  <xsl:template match="tei:figure">
    <xsl:call-template name="startHook"/>
    <text:p text:style-name="Standard">
      <xsl:call-template name="test.id"/>
      <xsl:apply-templates select="tei:graphic"/>
    </text:p>
    <xsl:if test="tei:head">
      <text:p text:style-name="Caption">
	<text:span text:style-name="Figurenum">
	  <xsl:text>Figure </xsl:text>
	  <text:sequence 
	      text:ref-name="refFigure0" 
	      text:name="Figure"
	      text:formula="Figure+1"
	      style:num-format="1">
	  <xsl:number level="any"/>
	  <xsl:text>.</xsl:text>
	  </text:sequence>
	</text:span>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="tei:head" mode="show"/>
      </text:p>
    </xsl:if>
    <xsl:call-template name="endHook"/>

  </xsl:template>

  <xsl:template match="tei:graphic">
    <xsl:variable name="id">
      <xsl:choose>
	<xsl:when test="@xml:id">
	  <xsl:value-of select="@xml:id"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>Figure</xsl:text><xsl:number level="any"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <draw:frame draw:style-name="fr1" 
		draw:name="{$id}"
		draw:z-index="0">
      <xsl:attribute name="text:anchor-type">
	<xsl:choose>
	  <xsl:when test="parent::tei:figure">
	    <xsl:text>paragraph</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>as-char</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="svg:width">
	<xsl:choose>
	  <xsl:when test="@width">
	    <xsl:value-of select="@width"/>
	    <xsl:call-template name="checkunit">
	      <xsl:with-param name="dim" select="@width"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>4inch</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="svg:height">
	<xsl:choose>
	  <xsl:when test="@height">
	    <xsl:value-of select="@height"/>
	    <xsl:call-template name="checkunit">
	      <xsl:with-param name="dim" select="@height"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>4inch</xsl:text>
	    </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <draw:image
	  xlink:href="{@url}" 
	  xlink:type="simple" 
	  xlink:show="embed"
	  xlink:actuate="onLoad" 
	  draw:filter-name="&lt;All formats&gt;"/>
    </draw:frame>
    
  </xsl:template>


<!-- lists -->
  <xsl:template match="tei:list">
    <xsl:call-template name="startHook"/>
    <xsl:if test="tei:head">
      <text:p><xsl:apply-templates select="tei:head" mode="show"/></text:p>
    </xsl:if>
    <text:list text:style-name="L3">
      <xsl:apply-templates/>
    </text:list>
    <xsl:call-template name="endHook"/>
  </xsl:template>


  <xsl:template match="tei:list[@type='unordered']">
    <xsl:call-template name="startHook"/>
    <text:list text:style-name="L3">
      <xsl:apply-templates/>
    </text:list>
    <xsl:call-template name="endHook"/>
  </xsl:template>


  <xsl:template match="tei:list[@type='ordered']">
    <xsl:call-template name="startHook"/>
    <text:list text:style-name="L1">
      <xsl:apply-templates/>
    </text:list>
    <xsl:call-template name="endHook"/>
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']">
    <xsl:call-template name="startHook"/>
    <xsl:apply-templates/>
    <xsl:call-template name="endHook"/>
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']/tei:item">
    <text:p text:style-name="List Contents">
      <xsl:apply-templates/>
    </text:p>
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']/tei:label">
    <text:p text:style-name="List Heading">
      <xsl:apply-templates/>
    </text:p>
  </xsl:template>

  <xsl:template name="startHook">
    <xsl:choose>
      <xsl:when test="self::tei:list and parent::tei:item">
	<xsl:text disable-output-escaping="yes">&lt;/text:p&gt;</xsl:text>
	<xsl:text disable-output-escaping="yes">&lt;/text:list&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="parent::tei:p">
      <xsl:text disable-output-escaping="yes">&lt;/text:p&gt;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="endHook">
    <xsl:choose>
      <xsl:when test="self::tei:list and parent::tei:item">
	<xsl:text disable-output-escaping="yes">&lt;text:list
	</xsl:text>
	<xsl:choose>
	  <xsl:when test="parent::tei:list[@type='ordered']">
	  </xsl:when>
	</xsl:choose>
	<xsl:text>&gt;</xsl:text>
	<xsl:text disable-output-escaping="yes">&lt;text:p  text:style-name="List Contents&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="parent::tei:p">
      <xsl:text disable-output-escaping="yes">&lt;text:p&gt;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>



  <xsl:template match="tei:item/tei:p">
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="tei:item">
    <text:list-item>
      <xsl:choose>
	<xsl:when test="list">
	  <xsl:apply-templates/>
	</xsl:when>
	<xsl:otherwise>
	  <text:p>
	    <xsl:attribute name="text:style-name">
	      <xsl:choose>
		<xsl:when
		    test="parent::tei:list/@type='ordered'">P2</xsl:when>
		<xsl:otherwise>P1</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	    <xsl:apply-templates/>
	  </text:p>
	</xsl:otherwise>
      </xsl:choose>
    </text:list-item>
  </xsl:template>

<!-- inline stuff -->
  <xsl:template match="tei:emph">
    <text:span text:style-name="Emphasis">
      <xsl:apply-templates/>
    </text:span>
  </xsl:template>

  <xsl:template  match="tei:gi">
    <xsl:text>&lt;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:q">
    <text:span text:style-name="q">
      <xsl:text>&#x2018;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#x2019;</xsl:text>
    </text:span>
  </xsl:template>


  <xsl:template match="tei:note">
    <text:note text:note-class="footnote">
    <text:note-citation>
      <xsl:number level="any" count="tei:note[@place='foot']"/>
    </text:note-citation>
      <text:note-body>
	<text:p text:style-name="Footnote">
	  <xsl:apply-templates/>
	</text:p>
      </text:note-body>
    </text:note>  
  </xsl:template>

  <xsl:template match="tei:note[@place='end']">
    <text:note text:note-class="endnote">
    <text:note-citation>
      <xsl:number format="i" level="any" count="tei:note[@place='end']"/>
    </text:note-citation>
      <text:note-body>
	<text:p text:style-name="Endnote">
	  <xsl:apply-templates/>
	</text:p>
      </text:note-body>
    </text:note>
  </xsl:template>


  <xsl:template match="tei:ref">
    <text:a xlink:type="simple" xlink:href="{@target}">
      <xsl:apply-templates/>
    </text:a>
  </xsl:template>

  <xsl:template match="tei:ptr">
    <text:a xlink:type="simple" xlink:href="{@target}">
      <xsl:choose>
	<xsl:when test="starts-with(@target,'#')">
	  <xsl:for-each select="key('IDS',substring-after(@target,'#'))">
	    <xsl:apply-templates select="." mode="crossref"/>
	  </xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@target"/>
	</xsl:otherwise>
      </xsl:choose>
    </text:a>
  </xsl:template>

  <xsl:template match="tei:table|tei:figure|tei:item" mode="crossref">
    <xsl:number level="any"/>
  </xsl:template>

  <xsl:template match="tei:div" mode="crossref">
    <xsl:number format="1.1.1.1.1"
		level="multiple" 
		count="tei:div"/>
  </xsl:template>

  <xsl:template
      match="tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6" 
      mode="crossref">
    <xsl:number format="1.1.1.1.1"
        count="tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6"
        level="multiple"/>
  </xsl:template>

  <xsl:template name="test.id">
    <xsl:if test="@xml:id">
      <text:bookmark text:name="{@xml:id}"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="tei:hi">
    <text:span>
      <xsl:attribute name="text:style-name">
	<xsl:choose>
	  <xsl:when test="@rend='sup'">
	    <xsl:text>SuperScript</xsl:text>
	  </xsl:when>
	  <xsl:when test="@rend='sub'">
	    <xsl:text>SubScript</xsl:text>
	  </xsl:when>
	  <xsl:when test="@rend='bold'">
	    <xsl:text>Highlight</xsl:text>
	  </xsl:when>
	  <xsl:when test="@rend='it'">
	    <xsl:text>Emphasis</xsl:text>
	  </xsl:when>
	  <xsl:when test="@rend='i'">
	    <xsl:text>Emphasis</xsl:text>
	  </xsl:when>
	  <xsl:when test="@rend='ul'">
	    <xsl:text>Underline</xsl:text>
	  </xsl:when>
	  <xsl:when test="@rend='sc'">
	    <xsl:text>SmallCaps</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>Highlight</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </text:span>
  </xsl:template>

  <xsl:template match="tei:term">
    <text:span>
      <xsl:attribute name="text:style-name">
	<xsl:text>Emphasis</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </text:span>
  </xsl:template>

  <xsl:template match="tei:date">
    <text:span text:style-name="{name(.)}">
      <xsl:apply-templates/>
    </text:span>
  </xsl:template>


  <xsl:template match="tei:eg">
    <xsl:call-template name="startHook"/>
    <xsl:call-template name="Literal">
      <xsl:with-param name="Text">
	<xsl:value-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="endHook"/>
  </xsl:template>

  <xsl:template match="teix:egXML">
    <xsl:call-template name="startHook"/>
    <xsl:call-template name="Literal">
      <xsl:with-param name="Text">
	<xsl:apply-templates mode="verbatim"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="endHook"/>
  </xsl:template>

  <!-- safest to drop comments entirely, I think -->
  <xsl:template match="comment()"/>

  <xsl:template match="tei:head" mode="show">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:lb">
    <text:line-break/>
  </xsl:template>

  <xsl:template name="checkunit">
    <xsl:param name="dim"/>
    <xsl:if test="contains($dim,'in')">
      <xsl:text>ch</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- curiously, no apparent direct markup for a page break -->
  <xsl:template match="tei:pb">
    <text:p text:style-name="P3"/>
  </xsl:template>

  <xsl:template match="tei:bibl|tei:lg|tei:signed">
    <text:p text:style-name="{name(.)}">
      <xsl:apply-templates/>
    </text:p>
  </xsl:template>

  <xsl:template match="tei:l">
    <text:span text:style-name="l">
      <xsl:apply-templates/>
      <text:line-break/>
    </text:span>
  </xsl:template>

  <xsl:template name="Literal">
    <xsl:param name="Text"/>
    <xsl:choose>
      <xsl:when test="contains($Text,'&#10;')">
	<text:p text:style-name="Preformatted Text">
	  <xsl:value-of
	      select="translate(substring-before($Text,'&#10;'),' ','&#160;')"/>
	</text:p>
	<xsl:call-template name="Literal">
	  <xsl:with-param name="Text">
	    <xsl:value-of select="substring-after($Text,'&#10;')"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<text:p text:style-name="Preformatted Text">
	  <xsl:value-of select="translate($Text,' ','&#160;')"/>
	</text:p>
      </xsl:otherwise>
    </xsl:choose>
    <!-- text:s c="6" to ident 6 spaces -->
  </xsl:template>


  <xsl:template match="tei:sp">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:stage">
    <text:span text:style-name="Stage">
      <xsl:apply-templates/>
    </text:span>
  </xsl:template>

  <xsl:template match="tei:speaker">
      <text:p text:style-name="Speaker">
	<xsl:apply-templates/>
      </text:p>
  </xsl:template>

  <!-- tables-->

  <xsl:template match="tei:table">
    <xsl:call-template name="startHook"/>
    <xsl:variable name="tablenum">
      <xsl:choose>
	<xsl:when test="@xml:id"><xsl:value-of select="@xml:id"/></xsl:when>
	<xsl:otherwise>table<xsl:number level="any"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <table:table
	table:name="{$tablenum}"
	table:style-name="Table1">
      <table:table-column
	  table:style-name="Table1.col1">
	<xsl:attribute name="table:number-columns-repeated">
	  <xsl:value-of select="count(tei:row[1]/tei:cell)"/>
	</xsl:attribute>
      </table:table-column>
      <xsl:apply-templates/>
    </table:table>
    <xsl:if test="tei:head">
      <text:p text:style-name="Table">
	<xsl:apply-templates select="tei:head" mode="show"/>
      </text:p>
    </xsl:if>
    <xsl:call-template name="endHook"/>
  </xsl:template>


  <xsl:template match="tei:row[@role='label']">
    <table:table-header-rows>
      <table:table-row>
	<xsl:apply-templates/>
      </table:table-row>
    </table:table-header-rows>
  </xsl:template>


  <xsl:template match="tei:row">
    <table:table-row>
      <xsl:apply-templates/>
    </table:table-row>
  </xsl:template>


  <xsl:template match="tei:cell">
    <table:table-cell>
      <xsl:choose>
	<xsl:when test="parent::tei:row[@role='label']">
	  <xsl:attribute name="text:style-name">Table1.cellheading</xsl:attribute>
	</xsl:when>
	<xsl:when test="@role='label'">
	  <xsl:attribute name="text:style-name">Table1.cellheading</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="text:style-name">Table1.cellcontents</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
	<xsl:when test="not(child::tei:p)">
	  <text:p>
	    <xsl:choose>
	      <xsl:when test="parent::tei:row[@role='label']">
		<xsl:attribute name="text:style-name">Table Heading</xsl:attribute>
	      </xsl:when>
	      <xsl:when test="@role='label'">
		<xsl:attribute name="text:style-name">Table Heading</xsl:attribute>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:attribute name="text:style-name">Table Contents</xsl:attribute>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:apply-templates/>
	  </text:p>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </table:table-cell>
  </xsl:template>

<xsl:template match="code">
  <text:span text:style-name="User Entry">
    <xsl:apply-templates/>
  </text:span>
</xsl:template>




  <xsl:param name="startComment"></xsl:param>
  <xsl:param name="endComment"></xsl:param>
  <xsl:param name="startElement"></xsl:param>
  <xsl:param name="endElement"></xsl:param>
  <xsl:param name="startElementName"></xsl:param>
  <xsl:param name="endElementName"></xsl:param>
  <xsl:param name="startAttribute"></xsl:param>
  <xsl:param name="endAttribute"></xsl:param>
  <xsl:param name="startAttributeValue"></xsl:param>
  <xsl:param name="endAttributeValue"></xsl:param>
  <xsl:param name="startNamespace"></xsl:param>
  <xsl:param name="endNamespace"></xsl:param>

  <xsl:param name="spaceCharacter">&#160;</xsl:param>
  <xsl:param name="showNamespaceDecls">true</xsl:param>

  <xsl:param name="wrapLength">65</xsl:param>

  <xsl:param name="attsOnSameLine">3</xsl:param>
  <xsl:key name="Namespaces" match="*[ancestor::teix:egXML]" use="namespace-uri()"/>

  <xsl:key name="Namespaces" match="*[not(ancestor::*)]" use="namespace-uri()"/>


  <xsl:template name="newLine">&#10;</xsl:template>

  <xsl:template name="lineBreak">
    <xsl:param name="id"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="comment()" mode="verbatim">
    <xsl:choose>
      <xsl:when test="ancestor::Wrapper"/>
      <xsl:when test="ancestor::xhtml:Wrapper"/>
      <xsl:otherwise>
    <xsl:call-template name="lineBreak">
      <xsl:with-param name="id">21</xsl:with-param>
    </xsl:call-template>
    <xsl:value-of  disable-output-escaping="yes" select="$startComment"/>
    <xsl:text>&lt;!--</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>--&gt;</xsl:text>
    <xsl:value-of  disable-output-escaping="yes"
		   select="$endComment"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="verbatim">
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::node() or contains(.,'&#10;'))">
	<xsl:call-template name="Text">
	  <xsl:with-param name="words">
	    <xsl:value-of select="."/>
	  </xsl:with-param>
	</xsl:call-template>
<!--	
        <xsl:if test="substring(.,string-length(.))=' '">
	  <xsl:text> </xsl:text>
	</xsl:if>
-->
      </xsl:when>
      <xsl:when test="normalize-space(.)=''">
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:call-template name="lineBreak">
            <xsl:with-param name="id">7</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="makeIndent"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
<!--
	<xsl:if test="starts-with(.,' ')">
	  <xsl:text> </xsl:text>
	</xsl:if>
-->
        <xsl:call-template name="wraptext">
          <xsl:with-param name="count">0</xsl:with-param>
          <xsl:with-param name="indent">
            <xsl:for-each select="parent::*">
              <xsl:call-template name="makeIndent"/>
            </xsl:for-each>
          </xsl:with-param>
          <xsl:with-param name="text">
	    <xsl:choose>
	      <xsl:when test="starts-with(.,'&#10;') and not
			      (preceding-sibling::node())">
		<xsl:call-template name="Text">
		  <xsl:with-param name="words">
		    <xsl:value-of select="substring(.,2)"/>
		  </xsl:with-param>
		</xsl:call-template>
		
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="Text">
		  <xsl:with-param name="words">
		    <xsl:value-of select="."/>
		  </xsl:with-param>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
	<!--
	<xsl:if test="substring(.,string-length(.))=' '">
	  <xsl:text> </xsl:text>
	</xsl:if>
	-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="wraptext">
    <xsl:param name="indent"/>
    <xsl:param name="text"/>
    <xsl:param name="count">0</xsl:param>
    <xsl:choose>
      <xsl:when test="normalize-space($text)=''"/>
      <xsl:when test="contains($text,'&#10;')">
	<xsl:if test="$count &gt; 0">
	  <xsl:value-of select="$indent"/>
	  <xsl:text> </xsl:text>
	</xsl:if>
	<xsl:call-template name="Text">
	  <xsl:with-param name="words">
	    <xsl:value-of
		select="substring-before($text,'&#10;')"/>
	  </xsl:with-param>
	</xsl:call-template>
<!--	<xsl:if test="not(substring-after($text,'&#10;')='')">-->
	  <xsl:call-template name="lineBreak">
	    <xsl:with-param name="id">6</xsl:with-param>
	  </xsl:call-template>
	  <xsl:value-of select="$indent"/>
	  <xsl:call-template name="wraptext">
	    <xsl:with-param name="indent">
	      <xsl:value-of select="$indent"/>
	    </xsl:with-param>
	    <xsl:with-param name="text">
	      <xsl:value-of select="substring-after($text,'&#10;')"/>
	    </xsl:with-param>
	    <xsl:with-param name="count">
	      <xsl:value-of select="$count + 1"/>
	    </xsl:with-param>
	  </xsl:call-template>

      </xsl:when>
      <xsl:otherwise>
	<xsl:if test="$count &gt; 0 and parent::*">
	  <xsl:value-of select="$indent"/>
	  <xsl:text> </xsl:text>
	</xsl:if>
	<xsl:call-template name="Text">
	  <xsl:with-param name="words">
	    <xsl:value-of select="$text"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Text">
    <xsl:param name="words"/>
    <xsl:choose>
      <xsl:when test="contains($words,'&amp;')">
	<xsl:value-of
	    select="substring-before($words,'&amp;')"/>
	<xsl:text>&amp;amp;</xsl:text>
	<xsl:call-template name="Text">
	  <xsl:with-param name="words">
	    <xsl:value-of select="substring-after($words,'&amp;')"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$words"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="verbatim">
    <xsl:choose>
      <xsl:when test="parent::xhtml:Wrapper"/>
<!--      <xsl:when test="child::node()[last()]/self::text()[not(.='')] and child::node()[1]/self::text()[not(.='')]"/>-->
      <xsl:when test="not(parent::*)  or parent::teix:egXML">
	<xsl:choose>
	  <xsl:when test="preceding-sibling::node()[1][self::text()]
			  and following-sibling::node()[1][self::text()]"/>
	  <xsl:when test="preceding-sibling::*">
	    <xsl:call-template name="lineBreak">
	      <xsl:with-param name="id">-1</xsl:with-param>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="newLine"/>
        <!-- <xsl:call-template name="makeIndent"/>-->
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="not(preceding-sibling::node())">
	<xsl:call-template name="lineBreak">
          <xsl:with-param name="id">-2</xsl:with-param>
	</xsl:call-template>
        <xsl:call-template name="makeIndent"/>
      </xsl:when>
      <xsl:when test="preceding-sibling::node()[1]/self::*">
        <xsl:call-template name="lineBreak">
          <xsl:with-param name="id">1</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="makeIndent"/>
      </xsl:when>
      <xsl:when test="preceding-sibling::node()[1]/self::text()">
	</xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="lineBreak">
          <xsl:with-param name="id">9</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="makeIndent"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:value-of disable-output-escaping="yes" select="$startElement"/>
    <xsl:text>&lt;</xsl:text>
    <xsl:call-template name="makeElementName">
      <xsl:with-param name="start">true</xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates select="@*" mode="verbatim"/>
    <xsl:if test="$showNamespaceDecls='true' or parent::teix:egXML[@rend='full']">
      <xsl:choose>
      <xsl:when test="not(parent::*)">
	<xsl:apply-templates select="." mode="ns"/>
      </xsl:when>
      <xsl:when test="parent::teix:egXML and not(preceding-sibling::*)">
	<xsl:apply-templates select="." mode="ns"/>
      </xsl:when>
      </xsl:choose>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="child::node()">
        <xsl:text>&gt;</xsl:text>
        <xsl:value-of disable-output-escaping="yes" select="$endElement"/>
        <xsl:apply-templates mode="verbatim"/>
        <xsl:choose>
          <xsl:when test="child::node()[last()]/self::text() and child::node()[1]/self::text()"/>

	  <xsl:when test="not(parent::*)  or parent::teix:egXML">
            <xsl:call-template name="lineBreak">
              <xsl:with-param name="id">23</xsl:with-param>
            </xsl:call-template>
	  </xsl:when>
          <xsl:when test="child::node()[last()]/self::text()[normalize-space(.)='']">
            <xsl:call-template name="lineBreak">
              <xsl:with-param name="id">3</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="makeIndent"/>
          </xsl:when>
          <xsl:when test="child::node()[last()]/self::comment()">
            <xsl:call-template name="lineBreak">
              <xsl:with-param name="id">4</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="makeIndent"/>
          </xsl:when>
          <xsl:when test="child::node()[last()]/self::*">
            <xsl:call-template name="lineBreak">
              <xsl:with-param name="id">5</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="makeIndent"/>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of disable-output-escaping="yes" select="$startElement"/>
        <xsl:text>&lt;/</xsl:text>
	<xsl:call-template name="makeElementName">
	  <xsl:with-param name="start">false</xsl:with-param>
	</xsl:call-template>
        <xsl:text>&gt;</xsl:text>
        <xsl:value-of disable-output-escaping="yes" select="$endElement"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>/&gt;</xsl:text>
        <xsl:value-of disable-output-escaping="yes" select="$endElement"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="makeElementName">
    <xsl:param name="start"/>
    <xsl:choose>

      <xsl:when
	  test="namespace-uri()='http://docbook.org/ns/docbook'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>dbk:</xsl:text>
	<xsl:value-of disable-output-escaping="yes" select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://www.w3.org/2001/XMLSchema'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>xsd:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://www.ascc.net/xml/schematron'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>sch:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://www.w3.org/1998/Math/MathML'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>m:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://purl.oclc.org/dsdl/nvdl/ns/structure/1.0'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>nvdl:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://relaxng.org/ns/compatibility/annotations/1.0'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>a:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>
      <xsl:when
	  test="namespace-uri()='http://www.w3.org/1999/xhtml'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>xhtml:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://www.w3.org/1999/xlink'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>xlink:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://relaxng.org/ns/structure/1.0'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>rng:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://earth.google.com/kml/2.1'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>kml:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://www.w3.org/2005/11/its'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>its:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
      </xsl:when>

      <xsl:when test="namespace-uri()='http://www.w3.org/1999/XSL/Transform'">
        <xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
        <xsl:text>xsl:</xsl:text>
        <xsl:value-of select="local-name(.)"/>
        <xsl:value-of disable-output-escaping="yes" select="$endNamespace"/>
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://www.tei-c.org/ns/Examples'">
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://www.w3.org/2005/Atom'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>atom:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	    <xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
      </xsl:when>

      <xsl:when
	  test="namespace-uri()='http://purl.org/rss/1.0/modules/event/'">
	<xsl:value-of disable-output-escaping="yes" select="$startNamespace"/>
	<xsl:text>ev:</xsl:text>
	<xsl:value-of disable-output-escaping="yes"
		      select="$endNamespace"/>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	
      </xsl:when>

      <xsl:when test="not(namespace-uri()='')">
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
	<xsl:if test="$start='true'">
	  <xsl:text> xmlns="</xsl:text>
	  <xsl:value-of select="namespace-uri()"/>
	  <xsl:text>"</xsl:text>
	</xsl:if>
      </xsl:when>

      <xsl:otherwise>
	<xsl:value-of disable-output-escaping="yes" select="$startElementName"/>
	<xsl:value-of select="local-name(.)"/>
	<xsl:value-of disable-output-escaping="yes" select="$endElementName"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


    <xsl:template name="makeIndent">
      <xsl:variable name="depth"
		    select="count(ancestor::*[not(namespace-uri()='http://www.tei-c.org/ns/1.0')])"/>
      <xsl:call-template name="makeSpace">
	<xsl:with-param name="d">
	  <xsl:value-of select="$depth"/>
	</xsl:with-param>
      </xsl:call-template>
  </xsl:template>

  <xsl:template name="makeSpace">
    <xsl:param name="d"/>
    <xsl:if test="number($d)&gt;1">
      <xsl:value-of select="$spaceCharacter"/>
      <xsl:call-template name="makeSpace">
	<xsl:with-param name="d">
	  <xsl:value-of select="$d -1"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

<xsl:template match="@*" mode="verbatim">
  <xsl:variable name="L">
    <xsl:for-each select="../@*">
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:variable>
    <xsl:if test="count(../@*)&gt;$attsOnSameLine or string-length($L)&gt;40 or
		  namespace-uri()='http://www.w3.org/2005/11/its' or
		  string-length(.)+string-length(name(.)) &gt; 40">
    <xsl:call-template name="lineBreak">
      <xsl:with-param name="id">5</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="makeIndent"/>
  </xsl:if>
  <xsl:value-of select="$spaceCharacter"/>
  <xsl:value-of disable-output-escaping="yes" select="$startAttribute"/>
  <xsl:choose>
    <xsl:when test="namespace-uri()='http://www.w3.org/2005/11/its'">
      <xsl:text>its:</xsl:text>
    </xsl:when>
    <xsl:when
	test="namespace-uri()='http://www.w3.org/XML/1998/namespace'">
      <xsl:text>xml:</xsl:text>
    </xsl:when>
    <xsl:when test="namespace-uri()='http://www.w3.org/1999/xlink'">
      <xsl:text>xlink:</xsl:text>
    </xsl:when>
    <xsl:when
	test="namespace-uri()='http://www.example.org/ns/nonTEI'">
      <xsl:text>my:</xsl:text>
    </xsl:when>
    <xsl:when
	test="namespace-uri()='http://relaxng.org/ns/compatibility/annotations/1.0'">
      <xsl:text>a:</xsl:text>
    </xsl:when>
<!--    <xsl:otherwise>
    <xsl:for-each select="namespace::*">
      <xsl:if test="not(name(.)='')">
	  <xsl:value-of select="name(.)"/>
	  <xsl:text>:</xsl:text>
      </xsl:if>
    </xsl:for-each>
    </xsl:otherwise>
-->
  </xsl:choose>
  <xsl:value-of select="local-name(.)"/>
  <xsl:value-of disable-output-escaping="yes" select="$endAttribute"/>
  <xsl:text>="</xsl:text>
  <xsl:value-of disable-output-escaping="yes" select="$startAttributeValue"/>
  <xsl:apply-templates select="." mode="attributetext"/>
  <xsl:value-of disable-output-escaping="yes" select="$endAttributeValue"/>
  <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="@*" mode="attributetext">
  <xsl:choose>
    <xsl:when test="string-length(.)&gt;50">
      <xsl:choose>
	<xsl:when test="contains(.,'|')">
	  <xsl:call-template name="breakMe">
	    <xsl:with-param name="text">
	      <xsl:value-of select="."/>
	    </xsl:with-param>
	    <xsl:with-param name="sep">
	      <xsl:text>|</xsl:text>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="breakMe">
	    <xsl:with-param name="text">
	      <xsl:value-of select="."/>
	    </xsl:with-param>
	    <xsl:with-param name="sep">
	      <xsl:text> </xsl:text>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="breakMe">
  <xsl:param name="text"/>
  <xsl:param name="sep"/>
  <xsl:choose>
    <xsl:when test="string-length($text)&lt;50">
      <xsl:value-of select="$text"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="substring-before($text,$sep)"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:value-of select="$sep"/>
      <xsl:call-template name="breakMe">
	<xsl:with-param name="text">
	  <xsl:value-of select="substring-after($text,$sep)"/>
	</xsl:with-param>
	<xsl:with-param name="sep">
	  <xsl:value-of select="$sep"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="text()|comment()|processing-instruction()" mode="ns"/>

<xsl:template match="*" mode="ns">
  <xsl:param name="list"/>
  <xsl:variable name="used">
    <xsl:for-each select="namespace::*">
      <xsl:variable name="ns" select="."/>
      <xsl:choose>
	<xsl:when test="contains($list,$ns)"/>
	<xsl:when test=".='http://relaxng.org/ns/structure/1.0'"/>
	<xsl:when test=".='http://www.w3.org/2001/XInclude'"/>
	<xsl:when test=".='http://www.tei-c.org/ns/Examples'"/>
	<xsl:when test=".='http://relaxng.org/ns/compatibility/annotations/1.0'"/>
	<xsl:when test="name(.)=''"/>
	<xsl:when test=".='http://www.w3.org/XML/1998/namespace'"/>
	<xsl:otherwise>
	  <xsl:call-template name="lineBreak">
	    <xsl:with-param name="id">22</xsl:with-param>
	  </xsl:call-template>
	  <xsl:text>&#160;&#160;&#160;</xsl:text>
	  <xsl:text>xmlns:</xsl:text>
	  <xsl:value-of select="name(.)"/>
	  <xsl:text>="</xsl:text>
	  <xsl:value-of select="."/>
	  <xsl:text>"</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:variable>
  <xsl:copy-of select="$used"/>
  <xsl:apply-templates mode="ns">
    <xsl:with-param name="list">
      <xsl:value-of select="$list"/>
      <xsl:value-of select="$used"/>
    </xsl:with-param>
  </xsl:apply-templates>
</xsl:template>


  <xsl:template name="italicize"/>

  <xsl:template match="tei:soCalled">
    <xsl:value-of select="$preQuote"/>
    <xsl:apply-templates/>
    <xsl:value-of select="$postQuote"/>
  </xsl:template>
</xsl:stylesheet>