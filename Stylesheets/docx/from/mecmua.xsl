<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:prop="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:mec="http://mecmua.priv"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd tei prop w mec" version="2.0">
    <xsl:import href="docxtotei.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 30, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b>Omar Siam</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    
    <xsl:variable name="nameStyle" as="xs:string">Name</xsl:variable>
    <xsl:variable name="placeStyle" as="xs:string">Orte</xsl:variable>
    
    <xsl:variable name="plantStyle" as="xs:string">Pflanzen</xsl:variable>
    <xsl:variable name="auxSubstStyle" as="xs:string">Zusatzstoffe</xsl:variable>
    <xsl:variable name="astronomyStyle" as="xs:string">Astronomie</xsl:variable>
    <xsl:variable name="textGenreStyle" as="xs:string">Textgattungen</xsl:variable>
    <xsl:variable name="otherStyles" select="($plantStyle, $auxSubstStyle, $astronomyStyle, $textGenreStyle)"/>
    
    <xsl:variable name="nameRegExp" as="xs:string">aka:(.*)profession:(.*)died:(.*)reign:(.*)-?(.*)remark:(.*)</xsl:variable>
    <xsl:variable name="placeRegExp">type:(.*)where today:(.*)today’s name:(.*)remark:(.*)</xsl:variable>
    <xsl:variable name="otherRegExp">Latin:(.*)English:(.*)</xsl:variable>
    <xsl:variable name="otherRegExpAka">aka:(.*)(Latin:(.*)English:(.*))</xsl:variable>
    <xsl:variable name="remarkRegExp">(.*)remark:(.*)</xsl:variable>
    
    <!-- No break hyphens actually aren't characters but tags. Convert them to Unicode characters in pass0.
         Doing this in pass1 is to late for this stylesheet. -->
    <xsl:template match="w:noBreakHyphen" mode="pass0"><w:t>&#x2011;</w:t></xsl:template>

    <!-- Need to join all adjacent text runs with the same character style. -->
    <xsl:template match="w:p" mode="pass0">
        <w:p>
        <xsl:for-each-group select="*" group-adjacent="concat('x', ./w:rPr/w:rStyle/@w:val)">
            <xsl:choose>
                <xsl:when test="current-grouping-key() = 'x' or count(current-group() intersect //w:r) &lt; 2">
                    <xsl:for-each select="current-group()">
                        <xsl:copy>
                            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass0"/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="current-group() except (//w:r)">
                        <xsl:copy>
                            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass0"/>
                        </xsl:copy>
                    </xsl:for-each>
                    <w:r>
                        <xsl:apply-templates select="current-group()[1]/w:rPr" mode="pass0"/>
                        <xsl:apply-templates select="current-group()//w:t|current-group()//w:noBreakHyphen" mode="pass0"/>
                    </w:r>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
        </w:p>
    </xsl:template>
    
    <!-- Remove footnote/endnote references -->
    
    <xsl:template match="w:footnoteReference"/>
    <xsl:template match="w:endnoteReference"/>
    
    <!-- Acces to $pass0 is needed globally so duplicate this here. -->
    <xsl:variable name="pass0">
        <xsl:apply-templates select="/" mode="pass0"/>
    </xsl:variable>
    
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
            <xsl:when test="$style=($nameStyle, $placeStyle, $otherStyles)">
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
        <xsl:sequence select="$tagsDecl"/>
    </xsl:template>
    
    <!-- Text which has the special syles may occur in multiple adjacent w:r tags. This is hardly visible in word
    so try to join them here. --> 
    
    <xsl:variable name="comments">
        <xsl:apply-templates mode="pass0" select="document(concat($wordDirectory,'/word/comments.xml'))"/>
    </xsl:variable>
    
    <xsl:variable name="tagsDecl">
        <xsl:call-template name="_generateTagsDecl"/>
    </xsl:variable>
    
    <xsl:template name="_generateTagsDecl">
        <!-- context of caller (=$pass0) -->
        <xsl:variable name="names" select="$pass0//w:r[descendant::w:rStyle/@w:val=$nameStyle]"/>
        <xsl:variable name="places" select="$pass0//w:r[descendant::w:rStyle/@w:val=$placeStyle]"/>
        <xsl:variable name="otherNames"
            select="$pass0//w:r[descendant::w:rStyle/@w:val=$otherStyles]"/>
        <tagsDecl>
            <namespace name="http://www.tei-c.org/ns/1.0">
                <xsl:if test="exists($pass0//w:rStyle[@w:val=$placeStyle])">
                    <tagUsage gi="persName">
                        <listPerson>
                            <xsl:for-each select="$names">
                                <xsl:variable name="wordInText" select="string-join(./w:t, '')"
                                    as="xs:string"/>
                                <xsl:variable name="thisId"
                                    select="for $aNode in subsequence(./following-sibling::*, 1, 2) return $aNode[name($aNode) = 'w:commentRangeEnd']/@w:id"/>
                                <xsl:variable name="annotationText"
                                    select="if (exists($thisId)) then string-join($comments/w:comments/w:comment[@w:id = $thisId]//w:t, '') else ' '"/>
                                <xsl:variable name="type" select="./w:rPr/w:rStyle/@w:val"
                                    as="xs:string?"/>
                                <xsl:element name="person">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:attribute>
                                    <xsl:analyze-string select="$annotationText"
                                        regex="{$nameRegExp}">
                                        <xsl:matching-substring>
                                            <persName xml:lang="ota-Latn-t">
                                                <xsl:value-of select="$wordInText"/>
                                                <xsl:for-each select="tokenize(regex-group(1), ';')">
                                                <addName xml:lang="ota-Latn-t">                                                    
                                                  <xsl:value-of
                                                  select="normalize-space(.)"/>
                                                </addName>
                                                </xsl:for-each>
                                            </persName>
                                            <occupation>
                                                <xsl:value-of
                                                  select="normalize-space(regex-group(2))"/>
                                            </occupation>
                                            <death>
                                                <xsl:value-of
                                                  select="normalize-space(regex-group(3))"/>
                                            </death>
                                            <floruit>
                                                <xsl:if test="normalize-space(regex-group(4)) != ''">
                                                  <xsl:attribute name="from-custom"
                                                  select="normalize-space(regex-group(4))"/>
                                                </xsl:if>
                                                <xsl:if test="normalize-space(regex-group(5)) != ''">
                                                  <xsl:attribute name="to-custom"
                                                  select="normalize-space(regex-group(5))"/>
                                                </xsl:if>
                                            </floruit>
                                            <note>
                                                <xsl:value-of
                                                  select="normalize-space(regex-group(6))"/>
                                            </note>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <persName>
                                                <xsl:value-of select="$wordInText"/>
                                            </persName>
                                            <xsl:choose>
                                                <xsl:when test="$annotationText = ' '">
                                                  <note>This name is not annotated!</note>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <note>
                                                  <xsl:value-of select="$annotationText"/>
                                                  </note>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </xsl:element>
                            </xsl:for-each>
                        </listPerson>
                    </tagUsage>
                </xsl:if>
                <xsl:if test="exists($pass0//w:rStyle[@w:val=$placeStyle])">
                    <tagUsage gi="placeName">
                        <listPlace>
                            <xsl:for-each select="$places">
                                <xsl:variable name="wordInText" select="string-join(./w:t, '')"
                                    as="xs:string"/>
                                <xsl:variable name="thisId"
                                    select="for $aNode in subsequence(./following-sibling::*, 1, 2) return $aNode[name($aNode) = 'w:commentRangeEnd']/@w:id"/>
                                <xsl:variable name="annotationText"
                                    select="if (exists($thisId)) then string-join($comments/w:comments/w:comment[@w:id = $thisId]//w:t, '') else ' '"/>
                                <xsl:variable name="type" select="./w:rPr/w:rStyle/@w:val"
                                    as="xs:string?"/>
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
                                                <country>
                                                  <xsl:value-of
                                                  select="normalize-space(regex-group(2))"/>
                                                </country>
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
                <xsl:if test="exists($pass0//w:rStyle[@w:val=$otherStyles])">
                    <tagUsage gi="name">
                        <listNym>
                            <xsl:for-each select="$otherNames">
                                <xsl:variable name="wordInText" select="string-join(./w:t, '')"
                                    as="xs:string"/>
                                <xsl:variable name="thisId"
                                    select="for $aNode in subsequence(./following-sibling::*, 1, 2) return $aNode[name($aNode) = 'w:commentRangeEnd']/@w:id"/>
                                <xsl:variable name="annotationText"
                                    select="if (exists($thisId)) then string-join($comments/w:comments/w:comment[@w:id = $thisId]//w:t, '') else ' '"/>
                                <xsl:variable name="type" select="./w:rPr/w:rStyle/@w:val"
                                    as="xs:string?"/>
                                <xsl:element name="nym">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="type">
                                        <xsl:value-of select="$type"/>
                                    </xsl:attribute>
                                    <orth xml:lang="ota-Latn-t">
                                        <xsl:value-of select="$wordInText"/>
                                    </orth>
                                    <xsl:analyze-string select="$annotationText"
                                        regex="{$otherRegExpAka}">
                                        <xsl:matching-substring>
                                            <xsl:for-each select="tokenize(regex-group(1), ';')">
                                            <orth xml:lang="ota-Latn-t">
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </orth>
                                            </xsl:for-each>
                                            <xsl:sequence select="mec:otherInfo(regex-group(2))"/>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:sequence select="mec:otherInfo(.)"/>
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
    
    <xsl:function name="mec:otherInfo" as="node()+">
        <xsl:param name="commentString" as="xs:string"/>
        <xsl:analyze-string select="$commentString" regex="{$otherRegExp}">
                <xsl:matching-substring>
                    <sense xml:lang="la">
                        <xsl:value-of
                            select="normalize-space(regex-group(1))"/>
                    </sense>
                    <xsl:analyze-string select="regex-group(2)" regex="{$remarkRegExp}">
                    <xsl:matching-substring>
                    <sense xml:lang="en-UK">
                        <xsl:value-of
                            select="normalize-space(regex-group(1))"/>
                    </sense>
                    <ab>
                        <note>
                            <xsl:value-of
                                select="normalize-space(regex-group(2))"/>
                        </note>
                    </ab>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <sense xml:lang="en-UK">
                            <xsl:value-of
                                select="normalize-space(.)"/>
                        </sense>
                    </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:matching-substring>                                            
                <xsl:non-matching-substring>
                    <ab>
                        <note> This name is not annotated correctly!
                            <xsl:value-of select="normalize-space(.)"/>
                        </note>
                    </ab>
                </xsl:non-matching-substring>
            </xsl:analyze-string>            
        
    </xsl:function>
    
    <xsl:function name="mec:getRefIdPerson" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>
        <!-- idea search for best candidate not finished: replace 1 exists((tei:occupation, tei:death, tei:floruit)) -->
        <xsl:sequence select="$tagsDecl//tei:person[tei:persName/text()|tei:persName/tei:addName = $name][1]/@xml:id"/>
    </xsl:function>
    
    <xsl:function name="mec:getRefIdPlace" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>
        <!-- idea search for best candidate not finished: replace 1 with exists((tei:location)) -->
        <xsl:sequence select="$tagsDecl//tei:place[tei:placeName/text() = $name][1]/@xml:id"/>
    </xsl:function>
    
    <xsl:function name="mec:getRefIdOtherNames" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>
        <!-- idea search for best candidate not finished: replace 1 with exists((tei:sense[@xml:lang = 'la'], tei:sense[@xml:lang = 'en-UK'])) -->
        <xsl:sequence select="$tagsDecl//tei:nym[tei:orth[@xml:lang = 'ota-Latn-t']/text() = $name][1]/@xml:id"/>
    </xsl:function>
    
    <xsl:template name="semanticStyle">
        <xsl:param name="style"/>
        <xsl:variable name="name" select="string-join(w:t, '')"/>
        <xsl:variable name="commentN" select="following-sibling::w:commentRangeEnd/@w:id" as="xs:string"/>
        <xsl:variable name="commentNText" select="$comments/w:comments/w:comment[@w:id=$commentN]" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$style=$nameStyle">
                <xsl:element name="persName">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="mec:getRefIdPerson($name)"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style=$placeStyle">
                <xsl:element name="placeName">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="mec:getRefIdPlace($name)"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style=$otherStyles" >
                <xsl:element name="name">
                    <xsl:attribute name="ref">
                       <xsl:value-of select="mec:getRefIdOtherNames($name)"/>
                    </xsl:attribute>              
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when> 
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="w:commentReference"/> <!-- suppress -->
        
    <xsl:template name="semanticStyleInfoMissing">
        <xsl:param name="style"/>
        <xsl:variable name="name" select="string-join(w:t, '')"/>
        <xsl:choose>
            <xsl:when test="$style=$nameStyle">
                <xsl:choose>
                    <xsl:when test="exists(mec:getRefIdPerson($name))">
                        <xsl:call-template name="semanticStyle">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="persName">
                            <note>info missing</note>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$style=$placeStyle">
                <xsl:element name="placeName">
                    <note>info missing</note>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style=$otherStyles">
                <xsl:element name="name">
                    <xsl:choose>
                        <xsl:when test="$style=$placeStyle">
                            <xsl:attribute name="type">plant</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$style=$astronomyStyle">
                            <xsl:attribute name="type">astronomy</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$style=$auxSubstStyle">
                            <xsl:attribute name="type">aux_subst</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$style=$textGenreStyle">
                            <xsl:attribute name="type">text_genre</xsl:attribute>
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
   
    <xsl:template name="getPubStatement">
        <p>Not to be published before the end of the project.</p>
    </xsl:template>
    
    <xsl:template name="getSourceDesc">
        <p>Converted from the Word source document</p>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Retain all used person references</xd:desc>
    </xd:doc>
    <xsl:template match="tei:person[//tei:persName/@ref = @xml:id]" mode="pass2">
        <person>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass2"/>
        </person>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Zap unused person referneces</xd:desc>
    </xd:doc>
    <xsl:template match="tei:person" mode="pass2"/>
    
    <xd:doc>
        <xd:desc>Retain all used place references</xd:desc>
    </xd:doc>
    <xsl:template match="tei:place[//tei:placeName/@ref = @xml:id]" mode="pass2">
        <place>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass2"/>
        </place>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Zap unused place referneces</xd:desc>
    </xd:doc>
    <xsl:template match="tei:place" mode="pass2"/>
    
    <xd:doc>
        <xd:desc>Retain all used nym references</xd:desc>
    </xd:doc>
    <xsl:template match="tei:nym[//tei:name/@ref = @xml:id]" mode="pass2">
        <nym>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass2"/>
        </nym>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Zap unused nym referneces</xd:desc>
    </xd:doc>
    <xsl:template match="tei:nym" mode="pass2"/>
    
</xsl:stylesheet>