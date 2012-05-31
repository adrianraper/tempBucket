<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
    <html>
    <body>
    <table>
<xsl:variable name="courseID">
	<xsl:value-of select="item/@id"/>
</xsl:variable>    
    <xsl:for-each select="item/item">
<xsl:variable name="unitID">
	<xsl:value-of select="@id"/>
</xsl:variable>    
<tr><td><xsl:value-of select="@caption" /> =<xsl:value-of select="@id"/></td><td>course=<xsl:copy-of select="$courseID" />&amp;startingPoint=unit:<xsl:value-of select="@id"/></td></tr>
<!--
   		<xsl:for-each select="item">
<tr><td><xsl:copy-of select="$courseID" /></td><td><xsl:value-of select="@unit"/></td><td><xsl:value-of select="@id"/></td></tr>
	    </xsl:for-each>
-->
    </xsl:for-each>
    </table>
    </body>
    </html>
</xsl:template>

</xsl:stylesheet>