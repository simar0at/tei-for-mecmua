<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:tbx="http://www.lisa.org/TBX-Specification.33.0.html" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="ve o r m v wp w10 w wne mml
					 tei tbx">

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
        <xd:desc>
            <xd:p> TEI Utility stylesheet for making Word docx files from TEI XML (see
                tei-docx.xsl)</xd:p>
            <xd:p>pass0: a normalization process for styles. Can also detect illegal styles.</xd:p>
            <xd:p>Included into (that is: is part of) docxtotei.xsl. Adds parameters $word-directory and $debug (only used for this part of the stylescheet)</xd:p>
            <xd:p>Needs variable $styledoc which is the node tree of a styles.xml document to check styles against</xd:p>
            <xd:p>This software is dual-licensed: 1. Distributed under a Creative Commons
                Attribution-ShareAlike 3.0 Unported License
                http://creativecommons.org/licenses/by-sa/3.0/ 2.
                http://www.opensource.org/licenses/BSD-2-Clause All rights reserved. Redistribution
                and use in source and binary forms, with or without modification, are permitted
                provided that the following conditions are met: * Redistributions of source code
                must retain the above copyright notice, this list of conditions and the following
                disclaimer. * Redistributions in binary form must reproduce the above copyright
                notice, this list of conditions and the following disclaimer in the documentation
                and/or other materials provided with the distribution. This software is provided by
                the copyright holders and contributors "as is" and any express or implied
                warranties, including, but not limited to, the implied warranties of merchantability
                and fitness for a particular purpose are disclaimed. In no event shall the copyright
                holder or contributors be liable for any direct, indirect, incidental, special,
                exemplary, or consequential damages (including, but not limited to, procurement of
                substitute goods or services; loss of use, data, or profits; or business
                interruption) however caused and on any theory of liability, whether in contract,
                strict liability, or tort (including negligence or otherwise) arising in any way out
                of the use of this software, even if advised of the possibility of such damage. </xd:p>
            <xd:p>Author: See AUTHORS</xd:p>
            <xd:p>Id: $Id$</xd:p>
            <xd:p>Copyright: 2008, TEI Consortium</xd:p>
        </xd:desc>
        <xd:param name="word-directory">
            Where to find the root of the standardized docx directory structure. (a little bit naive)
        </xd:param>
        <xd:param name="debug">If $debug ist true checks that every style mentioned in document.xml is in
            style.xml (if you don't set variable $styledoc to a styles.xml you keep seperate this
            wont do anything useful)</xd:param>
    </xd:doc>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Where to find the root of the standardized docx directory structure. (a little bit naive)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="word-directory">..</xsl:param>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Enables some verbose messages for finding styles we dont understand.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="debug">false</xsl:param>
    
    <xd:desc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:p>Key => value pair of all the styles in document.xml by w:styleId</xd:p>
    </xd:desc>
    <xsl:key name="STYLES" match="w:style" use="@w:styleId"/>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Copy every attribute, text, comment or processing instruction from the source document.xml</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@*|text()|comment()|processing-instruction()" mode="pass0">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>If there is no first level heading in text make one up.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:body" mode="pass0">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="w:p[tei:is-firstlevel-heading(.)]"/>
                <xsl:otherwise>
                    <w:p>
                        <w:pPr>
                            <w:pStyle w:val="Heading 1"/>
                        </w:pPr>
                        <w:r>
                            <w:rPr>
                                <w:sz w:val="36"/>
                            </w:rPr>
                            <w:t/>
                        </w:r>
                    </w:p>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass0"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>In general just copy everything.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*" mode="pass0">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass0"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>If $debug ist true checks that every style mentioned in document.xml is in
                style.xml. Gives warning messages if anything changed. (if you don't set variable $styledoc to a styles.xml you keep seperate this
                wont do anything useful)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:pStyle/@w:val|w:rStyle/@w:val" mode="pass0">
        <xsl:variable name="old" select="."/>
        <xsl:variable name="new">
            <xsl:for-each select="$styledoc">
                <xsl:value-of select="key('STYLES',$old)/w:name/@w:val"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:attribute name="w:val">
            <xsl:choose>
                <xsl:when test="$new=''">
                    <xsl:value-of select="$old"/>
                    <xsl:if test="$debug='true'">
                        <xsl:message>! style <xsl:value-of select="$old"/> ... NOT FOUND
                        </xsl:message>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="not($new=$old)">
                    <xsl:if test="$debug='true'">
                        <xsl:message>! style <xsl:value-of select="$old"/> ... CHANGED ...
                                <xsl:value-of select="$new"/>
                        </xsl:message>
                    </xsl:if>
                    <xsl:value-of select="$new"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$old"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>


    <xsl:template match="w:r[w:instrText][normalize-space(w:instrText)='']" mode="pass0"/>

</xsl:stylesheet>
