<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:prop="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd tei prop w" version="2.0">
    <xsl:import href="docxtotei.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 30, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b>Omar Siam</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:template name="namedCharacterStyle">
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="$style='Kommentarzeichen'"/> <!-- supress -->
            <xsl:when test="$style='annotate reference'"/> <!-- supress -->
            <xsl:when test="$style='footnote reference'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$style='Funotenzeichen'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$style='Name' or $style='Orte' or $style='Pflanzen' or $style='Astronomie'">
                <xsl:choose>
                    <xsl:when test="following-sibling::w:commentRangeEnd/@w:id">
                        <xsl:call-template name="semanticStyle">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="semanticStyleInfoMissing">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="namedCharacterStyle-base">
                    <xsl:with-param name="style" select="$style"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="semanticStyle">
        <xsl:param name="style"/>
        <xsl:variable name="commentN" select="following-sibling::w:commentRangeEnd/@w:id" as="xs:string"/>
        <xsl:variable name="commentNText" select="document(concat($wordDirectory,'/word/comments.xml'))/w:comments/w:comment[@w:id=$commentN]" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$style='Name'">
                <xsl:element name="persName">
                    <xsl:analyze-string select="$commentNText"
                        regex="aka:(.*)profession:(.*)died:(.*)reign:(.*)-(.*)remark:(.*)">
                        <xsl:matching-substring>
                            <xsl:attribute name="to-custom">
                                <xsl:value-of select="normalize-space(regex-group(3))"/>
                            </xsl:attribute>
                            <addName xml:lang="ota-Latn-t">
                                <xsl:value-of select="normalize-space(regex-group(1))"/>
                            </addName>
                            <roleName>
                                <xsl:value-of select="normalize-space(regex-group(2))"/>
                                <affiliation from-custom="{normalize-space(regex-group(4))}" to-custom="{normalize-space(regex-group(5))}"/>
                            </roleName>
                            <note>
                                <xsl:value-of select="normalize-space(regex-group(6))"/>
                            </note>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <note>
                                <xsl:value-of select="."/>
                            </note>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='Orte'">
                <xsl:element name="placeName">
                    <xsl:analyze-string select="$commentNText" regex="type:(.*)where today:(.*)today’s name:(.*)remark:(.*)">
                        <xsl:matching-substring>
                            <xsl:attribute name="type">
                                <xsl:value-of select="normalize-space(regex-group(1))"/>
                            </xsl:attribute>
                            <location>
                                <xsl:value-of select="normalize-space(regex-group(2))"/>
                            </location>
                            <addName xml:lang="en-UK">
                                <xsl:value-of select="normalize-space(regex-group(3))"/>
                            </addName>
                            <note>
                                <xsl:value-of select="normalize-space(regex-group(4))"/>
                            </note>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <note>
                                <xsl:value-of select="."/>
                            </note>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='Pflanzen' or $style='Astronomie'">
                <xsl:element name="name">
                    <xsl:choose>
                        <xsl:when test="$style='Pflanzen'">
                            <xsl:attribute name="type">plant</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$style='Astronomie'">
                            <xsl:attribute name="type">astronomy</xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:analyze-string select="$commentNText" regex="Latin:(.*)English:(.*)">
                        <xsl:matching-substring>
                            <addName xml:lang="la">
                                <xsl:value-of select="normalize-space(regex-group(1))"/>
                            </addName>
                            <addName xml:lang="en-UK">
                                <xsl:value-of select="normalize-space(regex-group(2))"/>
                            </addName>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <note>
                                <xsl:value-of select="."/>
                            </note>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when> 
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="semanticStyleInfoMissing">
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="$style='Name'">
                <xsl:element name="persName">
                    <note>info missing</note>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='Orte'">
                <xsl:element name="placeName">
                    <note>info missing</note>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='Pflanzen' or $style='Astronomie'">
                <xsl:element name="name">
                    <xsl:choose>
                        <xsl:when test="$style='Pflanzen'">
                            <xsl:attribute name="type">plant</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$style='Astronomie'">
                            <xsl:attribute name="type">astronomy</xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <note>info missing</note>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when> 
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="paragraph-wp">
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="$style='StandardWeb' or $style='Funotentext'">
                <p>
                        <xsl:call-template name="process-checking-for-crossrefs"/>
                </p>
            </xsl:when>
            <xsl:when test="$style='mecmuastandardfett'">
                <p>
                    <hi rend="bold">
                        <xsl:call-template name="process-checking-for-crossrefs"/>
                    </hi>
                </p>
            </xsl:when>
            <xsl:when test="$style='mecmuastandardkursiv'">
                <p>
                    <hi rend="italic">
                        <xsl:call-template name="process-checking-for-crossrefs"/>
                    </hi>
                </p>
            </xsl:when>
            <xsl:when test="$style='mecmuaARAB'">
                <p>
                    <hi rend="color(FF0000)">
                        <xsl:call-template name="process-checking-for-crossrefs"/>
                    </hi>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="paragraph-wp-base">
                    <xsl:with-param name="style" select="$style"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="generateAppInfo">
        <appInfo>
            <application ident="TEI_fromDOCX_for_Mecmua" version="2.15.0mecmua">
                <label>DOCX to TEI</label>
            </application>
            <xsl:if test="doc-available(concat($wordDirectory,'/docProps/custom.xml'))">
                <xsl:for-each select="document(concat($wordDirectory,'/docProps/custom.xml'))/prop:Properties">
                    <xsl:for-each select="prop:property">
                        <xsl:choose>
                            <xsl:when test="@name='TEI_fromDOCX'"/>
                            <xsl:when test="contains(@name,'TEI')">
                                <application ident="{@name}" version="{.}">
                                    <label>
                                        <xsl:value-of select="@name"/>
                                    </label>
                                </application>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:if test="prop:property[@name='WordTemplateURI']">
                        <application ident="WordTemplate" version="{prop:property[@name='WordTemplate']}">
                            <label>Word template file</label>
                            <ptr target="{prop:property[@name='WordTemplateURI']}"/>
                        </application>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </appInfo>
    </xsl:template>
    
    <xsl:template name="getPubStatement">
        <p>Not to be published before the end of the project.</p>
    </xsl:template>
    
    <xsl:template name="getSourceDesc">
        <p>Converted from the Word source document</p>
    </xsl:template>
    
</xsl:stylesheet>