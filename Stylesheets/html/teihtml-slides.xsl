<!-- 
TEI XSLT stylesheet family
$Date$, $Revision$, $Author$

XSL stylesheet to format TEI XML documents to HTML or XSL FO

Copyright 1999-2003 Sebastian Rahtz / Text Encoding Initiative Consortium
                                              
    This is an XSLT stylesheet for transforming TEI (version P5) XML documents

    Version 3.2. Date Fri Jul 30 12:15:01 BST 2004
                                  
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
                                                                                
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
                                                                                
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
                                                                                
    The author may be contacted via the e-mail address

    sebastian.rahtz-services.oxford.ac.uk--> 

<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  version="1.0"  >

<xsl:import href="teihtml.xsl"/>

<xsl:output encoding="iso-8859-1" 
	    method="html" 
	    doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>
<xsl:param
name="cssFile">http://www.tei-c.org/Stylesheets/teislides.css</xsl:param>
<xsl:param name="logoFile">logo.png</xsl:param>
<xsl:param name="logoWidth">60</xsl:param>
<xsl:param name="logoHeight">60</xsl:param>

<xsl:param name="numberHeadings"></xsl:param>
<xsl:param name="splitLevel">0</xsl:param>
<xsl:param name="subTocDepth">-1</xsl:param>
<xsl:param name="topNavigationPanel"></xsl:param>
<xsl:param name="bottomNavigationPanel">true</xsl:param>
<xsl:param name="linkPanel"></xsl:param>
<xsl:template name="copyrightStatement"/>
<xsl:param name="makingSlides">true</xsl:param>
 <xsl:param name="inputFileName">
  <xsl:choose>
 <xsl:when test="not($inputName ='')"><xsl:value-of select="$inputName"/></xsl:when>
 <xsl:when test="contains($processor,'SAXON')">
   <xsl:call-template name="get-basename">
     <xsl:with-param name="file">
    <xsl:value-of 
       xmlns:saxon="http://icl.com/saxon"  select="substring-after(saxon:system-id(),'file:')"/>
  </xsl:with-param>
</xsl:call-template>
 </xsl:when>
   <xsl:otherwise><xsl:value-of select="$inputName"/></xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="masterFile">
  <xsl:choose>
   <xsl:when test="$inputFileName =''">index-slides</xsl:when>
   <xsl:when test="contains($inputFileName,'.xml')"><xsl:value-of select="substring-before($inputFileName,'.xml')"/>-slides</xsl:when>
   <xsl:otherwise><xsl:value-of select="$inputFileName"/>-slides</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:template match="tei:div" mode="genid">
  <xsl:value-of select="$masterFile"/><xsl:number/>
</xsl:template>

<xsl:template match="tei:docAuthor">
       <div class="docAuthor"><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="tei:docDate">
       <div class="docDate"><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="/tei:TEI">
<xsl:param name="slidenum">
  <xsl:value-of select="$masterFile"/>0</xsl:param>
  <xsl:call-template name="outputChunk">
   <xsl:with-param name="ident">
    <xsl:value-of select="$slidenum"/>
   </xsl:with-param>
   <xsl:with-param name="content">
    <xsl:call-template name="mainslide"/>
   </xsl:with-param>
  </xsl:call-template>
  <xsl:apply-templates select="tei:text/tei:body/tei:div"/>
</xsl:template>

<xsl:template name="xrefpanel">
  <b><xsl:number/></b><xsl:text> </xsl:text>
  <xsl:variable name="first"><xsl:value-of select="$masterFile"/>0</xsl:variable>
  <xsl:if test="preceding-sibling::tei:div">
    <xsl:variable name="prev">
      <xsl:apply-templates select="preceding-sibling::tei:div[1]" mode="genid"/>
    </xsl:variable>
    <a class="xreflink" accesskey="p" href="{concat($prev,'.html')}"> 
    <span class="button">&#171;</span>
    </a>
  </xsl:if>

  <xsl:text>  </xsl:text>
  <a class="xreflink"  accesskey="f"
     href="{concat($first,'.html')}"> 
    <span class="button">^</span>
  </a>
  
  <xsl:if test="following-sibling::tei:div">
    <xsl:variable name="next">
      <xsl:apply-templates select="following-sibling::tei:div[1]" mode="genid"/>
    </xsl:variable>
    <xsl:text>  </xsl:text>
    <a class="xreflink" accesskey="n"
       href="{concat($next,'.html')}">
      <span class="button">&#187;</span> 
    </a>
  </xsl:if>
</xsl:template>

<xsl:template name="mainslide">
  <html><xsl:call-template name="addLangAtt"/> 
  <head>
    <title> 
      <xsl:call-template name="generateTitle"/>
    </title>
    <xsl:call-template name="includeCSS"/>
  </head>
  <body>
    <div class="slidetitle" style="font-size: 36pt;">
      <xsl:call-template name="generateTitle"/>
    </div>
    <div class="slidemain">
      <xsl:apply-templates select="tei:text/tei:front//tei:docAuthor"/>
      <xsl:apply-templates select="tei:text/tei:front//tei:docDate"/>
      <ul class="slidetoc">
	<xsl:for-each select="tei:text/tei:body/tei:div">
	  <xsl:variable name="n"><xsl:value-of select="$masterFile"/><xsl:number/></xsl:variable>
	  <li class="slidetoc"> <a href="{$n}.html"><xsl:value-of select="tei:head"/></a></li>
	</xsl:for-each>
      </ul>
    </div>
    <div class="slidebottom">
      <img src="{$logoFile}" width="{$logoWidth}" height="${logoHeight}" alt="logo"/>
      <xsl:text> </xsl:text>
      <xsl:variable name="next"><xsl:value-of select="$masterFile"/>1</xsl:variable>
      <a accesskey="n" href="{concat($next,'.html')}">Start</a>
    </div>
  </body>
  </html>
</xsl:template>

<xsl:template match="tei:body/tei:div">
  <xsl:choose>
    <xsl:when test="$splitLevel&gt;-1">
      <xsl:variable name="slidenum"><xsl:value-of select="$masterFile"/>
      <xsl:number/></xsl:variable>
      <xsl:call-template name="outputChunk">
	<xsl:with-param name="ident">
	  <xsl:value-of select="$slidenum"/>
	</xsl:with-param>
	<xsl:with-param name="content">
	  <xsl:call-template name="slideout"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="slidebody"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="slideout">
	 <html><xsl:call-template name="addLangAtt"/> 
	 <head>
         <title><xsl:value-of select="tei:head"/></title>
         <xsl:call-template name="includeCSS"/>
	 </head>
	 <body>
	   <xsl:call-template name="slidebody"/>
	</body>
	</html>
</xsl:template>


<xsl:template name="slidebody">
  <div  class="slidetop">
    <div class="slidetitle"><xsl:call-template name="header"/></div>
    <xsl:if test="$splitLevel &gt;-1">
      <div class="xref"><xsl:call-template name="xrefpanel"/>
      </div>
    </xsl:if>
  </div>
  <div class="slidemain">
    <xsl:apply-templates/>
  </div>
  <div class="slidebottom">
    <xsl:call-template name="slideBottom"/>
  </div>
</xsl:template>

<xsl:template name="slideBottom">
  <img src="{$logoFile}" width="{$logoWidth}" height="{$logoHeight}" alt="logo"/>
  <xsl:text> </xsl:text>
  <xsl:call-template name="generateTitle"/>
</xsl:template>

</xsl:stylesheet>
