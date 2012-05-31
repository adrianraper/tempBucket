<?xml version="1.0" encoding="utf-8"?><!-- DWXMLSource="ConnectedSpeech-NAmerican/Courses/1267078592421/menu.xml" -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
<html>
<head>
</head>
<body>
<xsl:for-each select="item/item">
case '<xsl:value-of select="substring(@picture,1,4)"/>':<br/>
<xsl:for-each select="item">
'<xsl:value-of select="substring-before(@fileName,'.xml')"/>'=>'<xsl:value-of select="@id"/>',<br/>
</xsl:for-each>
</xsl:for-each>
</body>
</html>

</xsl:template>
</xsl:stylesheet>