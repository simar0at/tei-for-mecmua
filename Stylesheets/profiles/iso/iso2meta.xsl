<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:iso="http://www.iso.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="tei iso"
                version="2.0">

  <xsl:import href="isoutils.xsl"/>
  <xsl:output method="xhtml" encoding="utf-8"/>

  <xsl:key name="DIV" match="tei:div" use="@type"/>

  <xsl:template match="tei:TEI">
      <html>
         <head>
            <title>Report on ISO document</title>
            <link href="iso.css" rel="stylesheet" type="text/css"/>

         </head>
         <body>
            <h1 class="maintitle">Report on metadata</h1>
            <table>
               <tr>
                  <td>Today's date</td>
                  <td>
                     <xsl:call-template name="whatsTheDate"/>
                  </td>
               </tr>
	              <xsl:for-each select="key('ALLMETA',1)">
	                 <xsl:sort select="@iso:meta"/>
	                 <tr>
	                    <td>
                        <xsl:value-of select="@iso:meta"/>
                     </td>
	                    <td>
                        <xsl:value-of select="key('ISOMETA',@iso:meta)"/>
                     </td>
	                 </tr>
	              </xsl:for-each>
            </table>

         </body>
      </html>
  </xsl:template>

 <xsl:template name="block-element">
     <xsl:param name="select"/>
     <xsl:param name="style"/>
     <xsl:param name="pPr"/>
     <xsl:param name="nop"/>
     <xsl:param name="bookmark-name"/>
     <xsl:param name="bookmark-id"/>
   </xsl:template>

   <xsl:template name="termNum"/>

</xsl:stylesheet>