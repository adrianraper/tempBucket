<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:output method="xml" encoding="utf-8" doctype-system="about:legacy-compat" />
	
	<!-- By default, recursively copy all nodes unchanged -->
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="bento">
		<html>
			<xsl:apply-templates />
		</html>
	</xsl:template>
	
</xsl:stylesheet>