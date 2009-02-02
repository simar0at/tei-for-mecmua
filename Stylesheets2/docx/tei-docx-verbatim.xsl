<?xml version="1.0"?>
<xsl:stylesheet 
    version="2.0" 
    xmlns:sch="http://www.ascc.net/xml/schematron"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:atom="http://www.w3.org/2005/Atom"  
    xmlns:estr="http://exslt.org/strings"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:dbk="http://docbook.org/ns/docbook"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    exclude-result-prefixes="xlink xhtml dbk rng sch m tei teix atom w estr xd" >
    
    <xsl:import href="verbatim.xsl"/>
    
    <xd:doc type="stylesheet">
        <xd:short> TEI Utility stylesheet to create verbatim XML for the TEI to Word conversion </xd:short>
        <xd:detail> This library is free software; you can redistribute it and/or
            modify it under the terms of the GNU Lesser General Public License as
            published by the Free Software Foundation; either version 2.1 of the
            License, or (at your option) any later version. This library is
            distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
            without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
            PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
            details. You should have received a copy of the GNU Lesser General Public
            License along with this library; if not, write to the Free Software
            Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA </xd:detail>
        <xd:author>See AUTHORS</xd:author>
        <xd:cvsId>$Id$</xd:cvsId>
        <xd:copyright>2008, TEI Consortium</xd:copyright>
    </xd:doc>
    
    <!--
        <xsl:param name="startComment">&lt;span class="comment"&gt;</xsl:param>
    <xsl:param name="endComment">&lt;/span&gt;</xsl:param>
    <xsl:param name="startElement">&lt;span class="element"&gt;</xsl:param>
    <xsl:param name="endElement">&lt;/span&gt;</xsl:param>
    <xsl:param name="startElementName">&lt;span class="elementname"&gt;</xsl:param>
    <xsl:param name="endElementName">&lt;/span&gt;</xsl:param>
    <xsl:param name="startAttribute">&lt;span class="attribute"&gt;</xsl:param>
    <xsl:param name="endAttribute">&lt;/span&gt;</xsl:param>
    <xsl:param name="startAttributeValue">&lt;span class="attributevalue"&gt;</xsl:param>
    <xsl:param name="endAttributeValue">&lt;/span&gt;</xsl:param>
    <xsl:param name="startNamespace">&lt;span class="namespace"&gt;</xsl:param>
    <xsl:param name="endNamespace">&lt;/span&gt;</xsl:param>
    
    <xsl:param name="spaceCharacter">&#xA0;</xsl:param>
    <xsl:param name="showNamespaceDecls">true</xsl:param> -->
    
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
    
    <xsl:param name="spaceCharacter">&#xA0;</xsl:param>
    <xsl:param name="showNamespaceDecls">true</xsl:param>
    
    <xsl:template name="verbatim-lineBreak">
        <xsl:param name="id"/>
        <tei:lb/>
    </xsl:template>
    
    <xsl:template name="verbatim-createElement">
        <xsl:param name="name"/>
        <tei:hi rend="bold">
            <xsl:value-of select="$name"/>
        </tei:hi>
    </xsl:template>
    
    <xsl:template name="verbatim-createAttribute">
        <xsl:param name="name"/>
        <tei:hi rend="bold">
            <xsl:value-of select="$name"/>
        </tei:hi>
    </xsl:template>    
    
    
    
    <xsl:template name="create-egXML-section">
        <xsl:apply-templates mode="verbatim"/>
    </xsl:template>
    
</xsl:stylesheet>

