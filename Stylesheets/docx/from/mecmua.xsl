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
            <xsl:when test="$style='annotation reference'"/> <!-- supress -->
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
    
    <xsl:variable name="nameStyle" as="xs:string">Name</xsl:variable>
    <xsl:variable name="placeStyle" as="xs:string">Orte</xsl:variable>
    <xsl:variable name="plantStyle" as="xs:string">Pflanzen</xsl:variable>
    <xsl:variable name="astronomyStyle" as="xs:string">Astronomie</xsl:variable>
    <xsl:variable name="comments" select="document(concat($wordDirectory,'/word/comments.xml'))"/>
    <xsl:variable name="nameRegExp" as="xs:string">aka:(.*)profession:(.*)died:(.*)reign:(.*)-(.*)remark:(.*)</xsl:variable>
    <xsl:variable name="placeRegExp">type:(.*)where today:(.*)today’s name:(.*)remark:(.*)</xsl:variable>
    <xsl:variable name="otherRegExp">Latin:(.*)English:(.*)</xsl:variable>
    
    <xsl:template name="generateAppInfo">
        <appInfo>
            <application ident="TEI_fromDOCX_for_Mecmua" version="2.15.0mecmua">
                <label>DOCX to TEI for mecmua</label>
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
        <tagsDecl>
            <namespace name="http://www.tei-c.org/ns/1.0">
                <xsl:if test="exists($names)">
                    <tagUsage gi="persName">
                        <listPerson>
                            <xsl:for-each select="$names">
                                <xsl:variable name="wordInText" select="./w:t" as="xs:string"/>
                                <xsl:variable name="thisId" select="for $aNode in subsequence(following-sibling::*, 1, 2) return $aNode[name($aNode) = 'w:commentRangeEnd']/@w:id"/>
                                <xsl:variable name="annotationText" select="if (exists($thisId)) then $comments/w:comments/w:comment[@w:id = $thisId] else ' '"/>
                                <xsl:element name="person">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="generate-id()"></xsl:value-of>
                                    </xsl:attribute>
                                    <xsl:analyze-string select="$annotationText"
                                        regex="{$nameRegExp}">
                                        <xsl:matching-substring>
                                            <persName xml:lang="ota-Latn-t">
                                                <xsl:value-of select="$wordInText"/>
                                                <addName xml:lang="ota-Latn-t">
                                                    <xsl:value-of select="normalize-space(regex-group(1))"/>
                                                </addName>
                                            </persName>
                                            <occupation>
                                                <xsl:value-of select="normalize-space(regex-group(2))"/>
                                            </occupation>
                                            <death>
                                                <xsl:value-of select="normalize-space(regex-group(3))"/>
                                            </death>
                                            <floruit from-custom="{normalize-space(regex-group(4))}" to-custom="{normalize-space(regex-group(5))}"/>
                                            <note>
                                                <xsl:value-of select="normalize-space(regex-group(6))"/>
                                            </note>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <persName>
                                                <xsl:value-of select="$wordInText"/>
                                            </persName>
                                            <note>This name is not annotated!</note>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>                               
                                </xsl:element>
                            </xsl:for-each>   
                        </listPerson>
                    </tagUsage>
                </xsl:if>
                <xsl:if test="exists($places)">
                    <tagUsage gi="placeName">
                        <listPlace>
                            <xsl:for-each select="$places">
                                <xsl:variable name="wordInText" select="./w:t" as="xs:string"/>
                                <xsl:variable name="thisId"
                                    select="for $aNode in subsequence(following-sibling::*, 1, 2) return $aNode[name($aNode) = 'w:commentRangeEnd']/@w:id"/>
                                <xsl:variable name="annotationText"
                                    select="if (exists($thisId)) then $comments/w:comments/w:comment[@w:id = $thisId] else ' '"/>
                                <xsl:element name="place">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:attribute>
                                    <xsl:analyze-string select="$annotationText"
                                        regex="{$placeRegExp}">
                                        <xsl:matching-substring>
                                            <xsl:attribute name="type">
                                                <xsl:value-of
                                                    select="normalize-space(regex-group(1))"/>
                                            </xsl:attribute>
                                            <placeName xml:lang="ota-Latn-t">
                                                <xsl:value-of select="$wordInText"/>
                                                <addName xml:lang="en-UK">
                                                    <xsl:value-of
                                                        select="normalize-space(regex-group(3))"/>
                                                </addName>
                                            </placeName>
                                            <location>
                                                <xsl:value-of
                                                    select="normalize-space(regex-group(2))"/>
                                            </location>
                                            <note>
                                                <xsl:value-of
                                                    select="normalize-space(regex-group(4))"/>
                                            </note>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <placeName>
                                                <xsl:value-of select="$wordInText"/>
                                            </placeName>
                                            <note> This name is not annotated!</note>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </xsl:element>
                            </xsl:for-each>
                        </listPlace>
                    </tagUsage>
                </xsl:if>
                <xsl:if test="exists($otherNames)">
                    <tagUsage gi="name">
                        <listNym>
                            <xsl:for-each select="$otherNames">
                                <xsl:variable name="wordInText" select="./w:t" as="xs:string"/>
                                <xsl:variable name="type" select="./w:rPr/w:rStyle/@w:val" as="xs:string"/>
                                <xsl:variable name="thisId"
                                    select="for $aNode in subsequence(following-sibling::*, 1, 2) return $aNode[name($aNode) = 'w:commentRangeEnd']/@w:id"/>
                                <xsl:variable name="annotationText"
                                    select="if (exists($thisId)) then $comments/w:comments/w:comment[@w:id = $thisId] else ' '"/>
                                <xsl:element name="nym">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:attribute>
                                    <xsl:analyze-string select="$annotationText"
                                        regex="{$otherRegExp}">
                                        <xsl:matching-substring>
                                            <xsl:attribute name="type">
                                                <xsl:value-of select="$type"/>
                                            </xsl:attribute>
                                            <form xml:lang="ota-Latn-t">
                                                <xsl:value-of select="$wordInText"/>
                                            </form>
                                            <form xml:lang="la">
                                                <xsl:value-of select="normalize-space(regex-group(1))"/>
                                            </form>
                                            <form xml:lang="en-UK">
                                                <xsl:value-of select="normalize-space(regex-group(2))"/>
                                            </form>                           
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:attribute name="type">
                                                <xsl:value-of select="$type"/>
                                            </xsl:attribute>
                                            <form xml:lang="ota-Latn-t">
                                                <xsl:value-of select="$wordInText"/>
                                            </form>
                                            <ab>
                                                <note> This name is not annotated! </note>
                                            </ab>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </xsl:element>
                            </xsl:for-each>                               
                        </listNym>
                    </tagUsage>
                </xsl:if>
            </namespace>
        </tagsDecl>
    </xsl:template>
    
    <xsl:template name="semanticStyle">
        <xsl:param name="style"/>
        <xsl:variable name="commentN" select="following-sibling::w:commentRangeEnd/@w:id" as="xs:string"/>
        <xsl:variable name="commentNText" select="$comments/w:comments/w:comment[@w:id=$commentN]" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$style=$nameStyle">
                <xsl:element name="persName">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style=$placeStyle">
                <xsl:element name="placeName">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='Pflanzen' or $style='Astronomie'">
                <xsl:element name="name">
                    <xsl:attribute name="ref">
                       <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>              
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when> 
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="w:commentReference"/> <!-- suppress -->
        
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

    <xsl:variable name="names" select="/w:document//w:r[w:rPr/w:rStyle/@w:val=$nameStyle]"/>
    <xsl:variable name="places" select="/w:document//w:r[w:rPr/w:rStyle/@w:val=$placeStyle]"/>
    <xsl:variable name="otherNames" select="/w:document//w:r[w:rPr/w:rStyle/@w:val=$plantStyle]|
        /w:document//w:r[w:rPr/w:rStyle/@w:val=$astronomyStyle]"/>
    
   
    <xsl:template name="getPubStatement">
        <p>Not to be published before the end of the project.</p>
    </xsl:template>
    
    <xsl:template name="getSourceDesc">
        <p>Converted from the Word source document</p>
    </xsl:template>
    
</xsl:stylesheet>