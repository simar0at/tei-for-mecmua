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
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="folioDescStyle">folio</xsl:variable>
    
    <xsl:variable name="nameStyle" as="xs:string">Name</xsl:variable>
    <xsl:variable name="placeStyle" as="xs:string">Orte</xsl:variable>
    
    <xsl:variable name="plantStyle" as="xs:string">Pflanzen</xsl:variable>
    <xsl:variable name="auxSubstStyle" as="xs:string">Zusatzstoffe</xsl:variable>
    <xsl:variable name="astronomyStyle" as="xs:string">Astronomie</xsl:variable>
    <xsl:variable name="textGenreStyle" as="xs:string">Textgattungen</xsl:variable>
    <xsl:variable name="illnessesStyle" as="xs:string">Krankheiten</xsl:variable>
    
    <xsl:variable name="otherStyles" select="($plantStyle, $auxSubstStyle, $astronomyStyle, $textGenreStyle, $illnessesStyle)"/>
    
    <xsl:variable name="nameRegExp" as="xs:string">aka:(.*)profession:(.*)died:(.*)reign:(.*)-?(.*)remark:(.*)</xsl:variable>
    <xsl:variable name="placeRegExp">type:(.*)where today:(.*)today’s name:(.*)remark:(.*)</xsl:variable>
    <xsl:variable name="otherRegExp">Latin:(.*)English:(.*)</xsl:variable>
    <xsl:variable name="otherRegExpAka">aka:(.*)(Latin:(.*)English:(.*))</xsl:variable>
    <xsl:variable name="remarkRegExp">(.*)remark:(.*)</xsl:variable>
    
    <xd:doc>
        <xd:desc>No break hyphens actually aren't characters but tags. Convert them to Unicode characters in pass0.
         Doing this in pass1 is to late for this stylesheet.
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:noBreakHyphen" mode="pass0"><w:t>&#x2011;</w:t></xsl:template>

    <xd:doc>
        <xd:desc>Need to join all adjacent text runs with the same character style.
        <xd:p>Note: this is designed so it eats up emtpty text runs including such containing only xreference markers and page breaks.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p" mode="pass0">
        <w:p>
        <xsl:for-each-group select="*" group-adjacent="concat('x', ./w:rPr/w:rStyle/@w:val)">
            <xsl:choose>
                <xsl:when test="current-grouping-key() = 'x' or count(current-group() intersect //w:r) &lt; 2">
                    <xsl:for-each select="current-group()">
                        <xsl:if test="empty(current-group() intersect //w:r) or not(empty(current-group()//w:t)) or (string-join(current-group()//w:t, '') ne '')">                            
                        <xsl:copy>
                            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass0"/>
                        </xsl:copy>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="current-group() except (//w:r)">
                        <xsl:copy>
                            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass0"/>
                        </xsl:copy>
                    </xsl:for-each>
                    <xsl:if test="empty(current-group() intersect //w:r) or not(empty(current-group()//w:t)) or (string-join(current-group()//w:t, '') ne '')">                            
                         <w:r>
                            <xsl:apply-templates select="current-group()[1]/w:rPr" mode="pass0"/>
                            <xsl:apply-templates select="current-group()//w:t|current-group()//w:noBreakHyphen" mode="pass0"/>
                        </w:r>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
        </w:p>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Remove footnote references</xd:desc>
    </xd:doc>
    <xsl:template match="w:footnoteReference"/>
    <xd:doc>
        <xd:desc>Remove endnote references</xd:desc>
    </xd:doc>
    <xsl:template match="w:endnoteReference"/>
    
    <xd:doc>
        <xd:desc>Access to $pass0 is needed globally so duplicate this here.</xd:desc>
    </xd:doc>
<!--    <xsl:variable name="pass0">
        <xsl:apply-templates select="/" mode="pass0"/>
    </xsl:variable>-->
    <xsl:variable name="pass0">
        <xsl:copy-of select="/"/>
    </xsl:variable>

    <xd:doc>
        <xd:desc>Handle character styles that have a special meaning in the mecmua project and ignore some styles that we defined to be suppressed.
            <xd:p>Note: uses a cusotmization in textruns.xsl.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="namedCharacterStyle">
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="$style='Kommentarzeichen'"/> <!-- supress -->
            <xsl:when test="$style='annotation reference'"/> <!-- supress -->
            <xsl:when test="$style='footnote reference'"/><!-- suppress -->
            <xsl:when test="$style='Funotenzeichen'"/><!-- suppress -->
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
    
    <xd:doc>
        <xd:desc>The template generateAppInfo is customized but also adds the whole section describing the named entities taged in the body.</xd:desc>
    </xd:doc>
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
    
    <xd:doc>
        <xd:desc>This uses a customization in functions.xsl to mark the sections in mecmua documents that is the folios.</xd:desc>
    </xd:doc>
    <xsl:function name="tei:custom-is-firstlevel-heading" as="xs:boolean">
        <xsl:param name="p" as="node()"/>
        <xsl:param name="s" as="xs:string*"/>    
        <xsl:choose>
            <xsl:when test="($s eq $folioDescStyle) and
                matches(string-join($p//w:t, ''), '\d+[vr]:')">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Within the folios there are subsections that describe parts of the text that were added on top of the original writing.</xd:desc>
    </xd:doc>
    <xsl:function name="tei:custom-is-heading" as="xs:boolean">
        <xsl:param name="p" as="node()"/>
        <xsl:param name="s" as="xs:string*"/>
        <xsl:value-of select="($s ne '') and ($s eq $folioDescStyle)"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>For the mecmua project the next level headers are in most cases descriptions of other writings around or on top of the original text.</xd:desc>
    </xd:doc>
    <xsl:function name="tei:get-nextlevel-header" as="xs:string">
        <xsl:param name="current-header"/>
        <xsl:choose>
            <xsl:when test="$current-header eq $folioDescStyle">
                <xsl:value-of select="$folioDescStyle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate($current-header,'12345678','23456789')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Superseeds the default as page breaks of the described documents are not identical to the docx page breaks but denoted by the
        folio descriptions.</xd:desc>
    </xd:doc>
    <xsl:template name="generate-section-heading">
        <xsl:param name="Style"/>
        <xsl:variable name="heading" select="string-join(.//w:t/text(), '')"/>
        <xsl:choose>
            <xsl:when test="matches($heading, '\d+[vr]:')">
                <pb n="{substring-before($heading, ':')}"/>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Customized group by section as we don't need more sepcific div elements.
        </xd:desc>
    </xd:doc>
    <xsl:template name="group-by-section">
        <xsl:variable name="Style" select="w:pPr/w:pStyle/@w:val"/>
        <xsl:variable name="NextHeader" select="tei:get-nextlevel-header($Style)"/>
        <xsl:variable name="heading" select="string-join(.//w:t/text(), '')"/>
        <div>
            <xsl:if test="matches($heading, '\d+[vr]:')">
                <xsl:attribute name="xml:id" select="generate-id(.)"/>
                <xsl:attribute name="type">page</xsl:attribute>
            </xsl:if>
            <!-- generate the head -->
            <xsl:call-template name="generate-section-heading">
                <xsl:with-param name="Style" select="$Style"/>
            </xsl:call-template>
            
            <!-- Process sub-sections -->
            <xsl:for-each-group select="current-group() except ."
                group-starting-with="w:p[w:pPr/w:pStyle/@w:val=$NextHeader]">
                <xsl:choose>
                    <xsl:when test="tei:is-heading(.)">
                        <xsl:call-template name="group-by-section"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="inSectionGroup"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Comments have to be preprocessed the same way the main document is preprocessd. E. g. to join text runs that Word generated
        for some reason.</xd:desc>
    </xd:doc>
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
                                <xsl:variable name="generated-id" select="generate-id()"/>
                                    <xsl:analyze-string select="$annotationText"
                                        regex="{$placeRegExp}">
                                        <xsl:matching-substring>
                                            <xsl:element name="place">
                                            <xsl:attribute name="xml:id">
                                                 <xsl:value-of select="$generated-id"/>
                                            </xsl:attribute>
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
                                            </xsl:element>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                        <place>
                                            <xsl:attribute name="xml:id">
                                                <xsl:value-of select="$generated-id"/>
                                            </xsl:attribute>
                                            <placeName>
                                                <xsl:value-of select="$wordInText"/>
                                            </placeName>
                                            <note> This name is not annotated!</note>
                                        </place>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
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
        <xsl:param name="commentN" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$commentN eq ''">
                <xsl:sequence select="($tagsDecl//tei:person[(tei:persName/text()[1]|tei:persName/tei:addName) = $name])[1]/@xml:id"/>                
            </xsl:when>
            <xsl:otherwise>
                <!-- idea search for best candidate not finished: replace 1 exists((tei:occupation, tei:death, tei:floruit)) -->
                <xsl:sequence select="($tagsDecl//tei:person[(tei:persName/text()[1]|tei:persName/tei:addName) = $name])[1]/@xml:id"/>                
            </xsl:otherwise>
        </xsl:choose>       
    </xsl:function>
    
    <xsl:function name="mec:getRefIdPlace" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="commentN" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$commentN eq ''">
                <xsl:sequence select="($tagsDecl//tei:place[tei:placeName/text() = $name])[1]/@xml:id"/>                
            </xsl:when>
            <xsl:otherwise>
                <!-- idea search for best candidate not finished: replace 1 with exists((tei:location)) -->
                <xsl:sequence select="($tagsDecl//tei:place[tei:placeName/text() = $name])[1]/@xml:id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="mec:getRefIdOtherNames" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="commentN" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$commentN eq ''">
                <xsl:sequence select="($tagsDecl//tei:nym[tei:orth[@xml:lang = 'ota-Latn-t']/text() = $name])[1]/@xml:id"/>                
            </xsl:when>
            <xsl:otherwise>
                <!-- idea search for best candidate not finished: replace 1 with exists((tei:sense[@xml:lang = 'la'], tei:sense[@xml:lang = 'en-UK'])) -->
                <xsl:sequence select="($tagsDecl//tei:nym[tei:orth[@xml:lang = 'ota-Latn-t']/text() = $name])[1]/@xml:id"/>               
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="semanticStyle">
        <xsl:param name="style"/>
        <xsl:variable name="name" select="string-join(w:t, '')"/>
        <xsl:variable name="commentN" select="(following-sibling::w:commentRangeEnd)[1]/@w:id" as="xs:string?"/>
        <xsl:variable name="commentNText" select="if (commentN ne '') then $comments/w:comments/w:comment[@w:id=$commentN] else ''" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$style=$nameStyle">
                <xsl:element name="persName">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="mec:getRefIdPerson($name, $commentN)"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style=$placeStyle">
                <xsl:element name="placeName">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="mec:getRefIdPlace($name, $commentN)"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style=$otherStyles" >
                <xsl:element name="name">
                    <xsl:attribute name="ref">
                       <xsl:value-of select="mec:getRefIdOtherNames($name, $commentN)"/>
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
        <xsl:variable name="commentN" select="(following-sibling::w:commentRangeEnd)[1]/@w:id" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$style=$nameStyle">
                <xsl:choose>
                    <xsl:when test="exists(mec:getRefIdPerson($name, $commentN))">
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
                <xsl:choose>
                    <xsl:when test="exists(mec:getRefIdPlace($name, $commentN))">
                        <xsl:call-template name="semanticStyle">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="placeName">
                            <note>info missing</note>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$style=$otherStyles">
                <xsl:choose>
                    <xsl:when test="exists(mec:getRefIdOtherNames($name, $commentN))">
                        <xsl:call-template name="semanticStyle">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="name">
                            <xsl:choose>
                                <xsl:when test="$style=$plantStyle">
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
                                <xsl:when test="$style=$illnessesStyle">
                                    <xsl:attribute name="type">illness</xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <note>info missing</note>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when> 
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Uses a customization in paragraphs.xsl to tap into the docx paragraph processing and simplify the meaning of some styles.</xd:desc>
    </xd:doc>
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
    
    <xd:doc>
        <xd:desc>Zap page breaks not marked with a reference to a particular folio</xd:desc>
    </xd:doc>
    <xsl:template match="tei:pb[not(@n)]" mode="pass2"/>
    
</xsl:stylesheet>