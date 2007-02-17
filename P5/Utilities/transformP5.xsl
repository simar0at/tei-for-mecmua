<xsl:stylesheet 
 xmlns:teix="http://www.tei-c.org/ns/Examples"
 xmlns:tei="http://www.tei-c.org/ns/1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:rng="http://relaxng.org/ns/structure/1.0"
 extension-element-prefixes="exsl"
 exclude-result-prefixes="exsl teix rng tei"
 xmlns:exsl="http://exslt.org/common"
 version="1.0">

<xsl:output 
   method="xml"
   indent="yes"
   cdata-section-elements="tei:eg teix:egXML"
   omit-xml-declaration="yes"/>


<xsl:param name="PREFIX" select="'newSource'"/>
<xsl:variable name="top" select="/"/>
<xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
<xsl:variable name="lc">abcdefghijklmnopqrstuvwxyz</xsl:variable>

<xsl:include href="transformbody.xsl"/>

<xsl:key name="IDS" match="tei:*" use="@xml:id"/>


<xsl:template match="/">
  <xsl:variable name="outName">
    <xsl:value-of select="$PREFIX"/>-driver.xml</xsl:variable>
    <xsl:message>write <xsl:value-of select="$outName"/></xsl:message>
 <exsl:document         
   method="xml"
   cdata-section-elements="tei:eg teix:egXML" 
   omit-doctype-declaration="yes"
   omit-xml-declaration="yes"
        href="{$outName}">
<xsl:text disable-output-escaping="yes">&lt;?xml version="1.0"?&gt;
&lt;!-- $Author$ $Date$ $Id$ --&gt;
&lt;!DOCTYPE TEI [
&lt;!NOTATION PNG SYSTEM ""&gt;
&lt;!NOTATION HTML SYSTEM ""&gt;
&lt;!ENTITY % ENTS SYSTEM "ents.dtd"&gt;
%ENTS;
</xsl:text>
<xsl:for-each
 select=".//tei:elementSpec|.//tei:macroSpec|.//tei:classSpec|.//tei:div[@type='div1' and @xml:id]">
  <xsl:sort select="tei:ident"/>
  <xsl:variable name="filename">
    <xsl:call-template name="Names"/>
  </xsl:variable>
  
    <xsl:text disable-output-escaping="yes">
&lt;!ENTITY </xsl:text>
    <xsl:value-of select="$filename"/>
    <xsl:text disable-output-escaping="yes"> SYSTEM "</xsl:text>
    <xsl:value-of select="$PREFIX"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$filename"/>
    <xsl:text>.xml"</xsl:text>
    <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
  </xsl:for-each>
<xsl:text disable-output-escaping="yes">
]>
</xsl:text>
  <xsl:apply-templates/> 
</exsl:document>

</xsl:template>


<xsl:template match="teix:*|tei:*|rng:*">
 <xsl:copy>
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates 
      select="teix:*|tei:*|rng:*|comment()|processing-instruction()|text()"/>
 </xsl:copy>
</xsl:template>

<xsl:template match="@*|processing-instruction()|text()">
  <xsl:copy/>
</xsl:template>

<xsl:template match="comment()">
  <xsl:copy/>
</xsl:template>

<xsl:template match="tei:div[@xml:id and @type='div1']">
    <xsl:variable name="ident">
      <xsl:call-template name="Names"/>
    </xsl:variable>
    <xsl:message>write <xsl:value-of select="$ident"/></xsl:message>
    <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
    <xsl:value-of select="$ident"/>
    <xsl:text disable-output-escaping="yes">;</xsl:text>
    <exsl:document         
     method="xml"
     cdata-section-elements="tei:eg teix:egXML" 
     omit-doctype-declaration="yes"
     omit-xml-declaration="yes" 
     href="{$PREFIX}/{$ident}.xml">
<xsl:comment>
Copyright TEI Consortium. 

Licensed under the GNU General Public License. 

See the file COPYING for details.

$Date$
$Author$

</xsl:comment>
      <xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:apply-templates select="rng:*|teix:*|tei:*|comment()|processing-instruction()|text()"/>
      </xsl:copy>
    </exsl:document>
</xsl:template>

<xsl:template match="tei:elementSpec|tei:classSpec|tei:macroSpec">
    <xsl:call-template name="redoDoc"/>
</xsl:template>

<xsl:template name="redoDoc">
    <xsl:variable name="ident">
      <xsl:value-of select="@ident"/>
    </xsl:variable>

    <xsl:message>write <xsl:value-of select="$ident"/> (<xsl:value-of select="@xml:id"/>) to <xsl:value-of select="$ident"/>.xml </xsl:message>
    <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
    <!--xsl:value-of select="tei:ident"/--><xsl:value-of select="$ident"/>
    <xsl:text disable-output-escaping="yes">;</xsl:text>
    <exsl:document         
     indent="yes"
     method="xml"
     cdata-section-elements="tei:eg teix:egXML" 
     omit-doctype-declaration="yes"
     omit-xml-declaration="yes"
        href="{$ident}.xml">
<xsl:comment>Copyright 2005 TEI Consortium. 

Licensed under the GNU General Public License. 

See the file COPYING for details.
</xsl:comment>
      <xsl:copy>
	<xsl:apply-templates select="rng:*|teix:*|tei:*|@*|comment()|processing-instruction()|text()"/>
      </xsl:copy>
    </exsl:document>
</xsl:template>

<xsl:template name="Names">
    <xsl:choose>
      <xsl:when test="@xml:id='AB'">
	<xsl:text>AB-About</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='AI'">
	<xsl:text>AI-AnalyticMechanisms</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='CC'">
	<xsl:text>CC-LanguageCorpora</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='CE'">
	<xsl:text>CE-CertaintyResponsibility</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='CF'">
	<xsl:text>CF-Conformance</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='CH'">
	<xsl:text>CH-LanguagesCharacterSets</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='CO'">
	<xsl:text>CO-CoreElements</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='DI'">
	<xsl:text>DI-PrintDictionaries</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='DR'">
	<xsl:text>DR-PerformanceTexts</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='DS'">
	<xsl:text>DS-DefaultTextStructure</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='DT'">
	<xsl:text>DT-ObtainingSchemas</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='FD'">
	<xsl:text>FD-FeatureSystemDeclaration</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='FS'">
	<xsl:text>FS-FeatureStructures</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='FT'">
	<xsl:text>FT-TablesFormulaeGraphics</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='GD'">
	<xsl:text>GD-GraphsNetworksTrees</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='HD'">
	<xsl:text>HD-Header</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='IN'">
	<xsl:text>IN-RulesForInterchange</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='MD'">
	<xsl:text>MD-ModifyingCustomizing</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='MS'">
	<xsl:text>MS-ManuscriptDescription</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='ND'">
	<xsl:text>ND-NamesDates</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='NH'">
	<xsl:text>NH-MultipleHierarchies</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='PH'">
	<xsl:text>PH-PrimarySources</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='REFCLA'">
	<xsl:text>Classes</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='REFENT'">
	<xsl:text>Macros</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='REFTAG'">
	<xsl:text>Elements</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='SA'">
	<xsl:text>SA-LinkingSegmentationAlignment</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='SG'">
	<xsl:text>SG-GentleIntroduction</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='SH'">
	<xsl:text>SH-OtherMetadataStandards</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='ST'">
	<xsl:text>ST-Infrastructure</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='TC'">
	<xsl:text>TC-CriticalApparatus</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='TD'">
	<xsl:text>TD-DocumentationElements</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='TE'">
	<xsl:text>TE-TerminologicalDatabases</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='TS'">
	<xsl:text>TS-TranscriptionsofSpeech</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='VE'">
	<xsl:text>VE-Verse</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:id='WD'">
	<xsl:text>WD-NonStandardCharacters</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@ident"/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
