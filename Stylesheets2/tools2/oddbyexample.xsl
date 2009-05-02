<xsl:stylesheet 
    exclude-result-prefixes="rng tei n"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:n="www.example.com"
    xmlns:rng="http://relaxng.org/ns/structure/1.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
>
<!-- This library is free software; you can redistribute it and/or
      modify it under the terms of the GNU Lesser General Public License as
      published by the Free Software Foundation; either version 2.1 of the
      License, or (at your option) any later version. This library is
      distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
      without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
      PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
      details. You should have received a copy of the GNU Lesser General Public
      License along with this library; if not, write to the Free Software
      Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
      02111-1307 USA 

$Id: iden.xsl 4549 2008-04-23 16:40:01Z rahtz $

2008, TEI Consortium
-->

<xsl:import href="getfiles.xsl"/>
<!-- 
read a corpus of TEI P5 documents and construct
an ODD customization file which expresses the subset
of the TEI you need to validate that corpus
-->
<xsl:output indent="yes"/>
<!-- name of odd -->
<xsl:param name="schema">oddbyexample</xsl:param>
<!-- the document corpus -->
<xsl:param name="corpus">./</xsl:param>
<!-- the source of the TEI (just needs *Spec)-->
<xsl:param name="tei">/usr/share/xml/tei/odd/p5subset.xml</xsl:param>

<xsl:key name="Atts" match="@*" use="local-name(parent::*)"/>  
<xsl:key name="attVals" match="@*" use="concat(local-name(parent::*),local-name())"/>
<xsl:key name="ELEMENTS" use="1" match="elementSpec"/>
<xsl:key name="CLASSES" use="1" match="classSpec[@type='atts']"/>
<xsl:key name="IDENTS" use="@ident" match="*[@ident]"/>
<xsl:key name="MEMBERS" use="@key" match="elementSpec/classes/memberOf"/>
<xsl:key name="CLASSMEMBERS" use="@key" match="classSpec/classes/memberOf"/>
<xsl:key name="Used" use="@ident" match="docs/element"/>
<xsl:key name="UsedAtt" use="concat(../@ident,@ident)" match="docs/element/attribute"/>
<!--
1) start a variable and copy in all of the TEI 
2) read the corpus and get a list of all the elements and their
attributes that it uses
3) process the variable and read the TEI section. if an element or
 attribute is not present in the corpus section, put out a delete
 customization
-->

<xsl:template name="processAll">
<xsl:variable name="count">
  <xsl:value-of select="count(/n:ROOT/*)"/>
</xsl:variable>
<!-- assemble together all the TEI elements and attributes, 
     followed by all the
     elements and attributes used in the corpus -->
 <xsl:variable name="stage1">
   <stage1>
     <tei>
       <xsl:for-each select="document($tei)">
	 <xsl:for-each select="key('CLASSES',1)">
	   <class>
	     <xsl:copy-of select="@ident"/>
	     <xsl:copy-of select="@module"/>
	     <xsl:for-each select=".//attDef">
	       <attribute>
		 <xsl:copy-of select="@ident"/>
		 <xsl:call-template name="checktype"/>
	       </attribute>
	     </xsl:for-each>
	     <xsl:call-template name="classmembers"/>
	   </class>
	 </xsl:for-each>
	 <xsl:for-each select="key('ELEMENTS',1)">
	   <element>
	     <xsl:copy-of select="@ident"/>
	     <xsl:copy-of select="@module"/>
	     <xsl:for-each select=".//tei:attDef">
	       <attribute>
		 <xsl:copy-of select="@ident"/>
		 <xsl:call-template name="checktype"/>
	       </attribute>
	     </xsl:for-each>
	     <xsl:for-each select="key('IDENTS','att.global')">
	       <xsl:for-each select=".//tei:attDef">
		 <attribute class="att.global">
		   <xsl:copy-of select="@ident"/>
		   <xsl:call-template name="checktype"/>
		 </attribute>
	       </xsl:for-each>
	     </xsl:for-each>
	     <xsl:call-template name="classatts"/>
	   </element>
	 </xsl:for-each>
       </xsl:for-each>
     </tei>
     <docs>
       <xsl:for-each-group select="key('All',1)" group-by="local-name()">
	 <xsl:sort select="current-grouping-key()"/>
	 <xsl:variable name="ident" select="current-grouping-key()"/>
	 <element>
	   <xsl:attribute name="ident">
	     <xsl:copy-of select="current-grouping-key()"/>
	   </xsl:attribute>
	   <xsl:for-each-group
	       select="key('Atts',$ident)"
	       group-by="local-name()">
	     <attribute ident="{name()}">
	       <valList type="closed">
		 <xsl:for-each-group
		     select="key('attVals',concat($ident,local-name()))"
		     group-by=".">
		   <xsl:sort select="."/>
		   <xsl:choose>
		     <xsl:when test="contains(current-grouping-key(),' ')">
		       <xsl:for-each
			   select="tokenize(current-grouping-key(),' ')">
			 <valItem ident="{.}"/>
		       </xsl:for-each>
		     </xsl:when>
		     <xsl:otherwise>
		       <valItem ident="{current-grouping-key()}"/>
		     </xsl:otherwise>
		   </xsl:choose>
		 </xsl:for-each-group>
	       </valList>
	     </attribute>
	   </xsl:for-each-group>
	 </element>
       </xsl:for-each-group>
     </docs>
   </stage1>
 </xsl:variable>

 <xsl:variable name="stage2">
   <stage2>
     <!-- for every attribute class, see if its members should be
     deleted, by seeing if they are used anywhere-->
     <xsl:for-each select="$stage1/stage1/tei/class">
       <classSpec ident="{@ident}" module="{@module}" type="atts" mode="change">
	 <attList>
	   <xsl:for-each select="attribute">
	     <xsl:variable name="this" select="@ident"/>
	     <xsl:variable name="used">
	       <xsl:for-each select="../member">
<!--		 <xsl:message>check for <xsl:value-of select="concat(@ident,$this)"/></xsl:message>-->
		 <xsl:if test="key('UsedAtt',concat(@ident,$this))">true</xsl:if>
	       </xsl:for-each>
	     </xsl:variable>
	     <xsl:if test="$used=''">
	       <attDef ident="{@ident}" mode="delete"/>
	     </xsl:if>
	   </xsl:for-each>
	 </attList>
       </classSpec>
     </xsl:for-each>
     <!-- for every TEI element, say if it is actually used or is to be deleted -->
     <xsl:for-each select="$stage1/stage1/tei/element">
       <xsl:choose>
	 <xsl:when test="key('Used',@ident)">
	   <elementSpec ident="{@ident}" module="{@module}"
			mode="keep">
	     <xsl:copy-of select="attribute"/>
	   </elementSpec>
	 </xsl:when>
	 <xsl:otherwise>
	   <elementSpec ident="{@ident}" module="{@module}" mode="delete"/>
	 </xsl:otherwise>
       </xsl:choose>
     </xsl:for-each>
   </stage2>
 </xsl:variable>

<!-- start writing the final ODD document -->
 <TEI xml:lang="en">
   <teiHeader>
      <fileDesc>
         <titleStmt>
            <title>TEI customization based on analyzing 
	    <xsl:value-of select="$count"/> files from
	    <xsl:value-of select="$corpus"/></title>
         </titleStmt>
         <publicationStmt>
	   <p> </p>
	 </publicationStmt>
         <sourceDesc>
            <p>generated by oddbyexample.xsl</p>
         </sourceDesc>
      </fileDesc>
   </teiHeader>
   <text>
     <body>
       <!--<xsl:copy-of select="$stage1"/>-->
       <schemaSpec ident="{$schema}">
	 <moduleRef key="tei"/>
	 <xsl:apply-templates select="$stage2/stage2/classSpec[@module='tei']"/>
	 <moduleRef key="core"/>
	 <!-- we need to list only modules from which elements have been used -->
	 <xsl:for-each-group select="$stage2/stage2/elementSpec[@mode='keep']" group-by="@module">
	   <xsl:sort select="current-grouping-key()"/>
	   <xsl:choose>
	     <xsl:when test="@module='core'"/>
	     <xsl:otherwise>
	       <moduleRef key="{@module}"/>
	     </xsl:otherwise>
	   </xsl:choose>
	   <xsl:for-each select="current-group()">
	     <xsl:variable name="e" select="@ident"/>
	       <!-- for every attribute, if its a class attribute, see if
	       its already deleted. if its a local attribute, see if its used. -->
	     <xsl:variable name="a">
	       <attList>
		 <xsl:for-each select="attribute">
		   <xsl:variable name="class" select="@class"/>
		   <xsl:variable name="ident" select="@ident"/>
		   <xsl:variable name="enumerated" select="@enumerated"/>
		   <xsl:for-each select="$stage1">
		     <xsl:choose>
		       <xsl:when test="not($class='') and $stage2/stage2/classSpec[@ident=$class]/attList/attDef[@ident=$ident]">
		       </xsl:when>
		       <xsl:when
			   test="not(key('UsedAtt',concat($e,$ident)))">
			 <attDef ident="{$ident}" mode="delete"/>
		       </xsl:when>
		       <xsl:when test="$enumerated='true'">
			 <attDef ident="{$ident}" mode="change">
			   <xsl:apply-templates select="key('UsedAtt',concat($e,$ident))/valList"/>
			 </attDef>
		       </xsl:when>
		     </xsl:choose>
		   </xsl:for-each>
		 </xsl:for-each>
	       </attList>
	     </xsl:variable>
	     <xsl:for-each select="$a">
	       <xsl:if test="attList/attDef">
		 <elementSpec ident="{$e}" mode="change">
		   <xsl:copy-of select="attList"/>
		 </elementSpec>
	       </xsl:if>
	     </xsl:for-each>
	   </xsl:for-each>
	   <xsl:copy-of
	       select="$stage2/stage2/elementSpec[@mode='delete'
		       and @module=current-grouping-key()]"/>
	   <xsl:apply-templates select="$stage2/stage2/classSpec[@module=current-grouping-key()]"/>
	 </xsl:for-each-group>
       </schemaSpec>
     </body>
   </text>
 </TEI>
</xsl:template>

<xsl:template name="classmembers">
  <xsl:choose>
    <xsl:when test="@ident='att.global'">
      <xsl:for-each select="key('ELEMENTS',1)">
	<xsl:sort select="@ident"/>
	<member ident="{@ident}"/>
      </xsl:for-each>    
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="key('MEMBERS',@ident)">
	<member ident="{ancestor::elementSpec/@ident}"/>
      </xsl:for-each>
      <xsl:for-each select="key('CLASSMEMBERS',@ident)/ancestor::classSpec">
	  <xsl:call-template name="classmembers"/>
	</xsl:for-each>
      </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="classatts">
  <xsl:for-each select="classes/memberOf">
    <xsl:for-each select="key('IDENTS',@key)">
      <xsl:for-each select=".//tei:attDef">
	<attribute class="{ancestor::classSpec/@ident}">
	  <xsl:copy-of select="@ident"/>
	</attribute>
      </xsl:for-each>
      <xsl:call-template name="classatts"/>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template name="checktype">
  <xsl:attribute name="enumerated">
    <xsl:choose>
      <xsl:when
	  test="@ident='n'">false</xsl:when>
      <xsl:when
	  test="@ident='rend'">true</xsl:when>
      <xsl:when
	  test="valList[@type='closed']">true</xsl:when>
      <xsl:when
	  test="datatype/rng:ref[@name='data.enumerated']">true</xsl:when>
      <!--
      <xsl:when
	  test="datatype/rng:ref[@name='data.word']">true</xsl:when>
      -->
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:template>

<xsl:template match="valList">
  <valList mode="add" type="closed">
    <xsl:for-each-group select="valItem" group-by="@ident">
      <xsl:sort select="@ident"/>
      <valItem ident="{current-grouping-key()}"/>
    </xsl:for-each-group>
  </valList>
</xsl:template>

<xsl:template match="classSpec">
  <xsl:if test="attList/attDef">
    <xsl:copy-of select="."/>
  </xsl:if>
</xsl:template>
</xsl:stylesheet>
