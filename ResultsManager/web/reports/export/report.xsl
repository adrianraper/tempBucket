<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                			 extension-element-prefixes="php">
    <xsl:output method="text" />
	<xsl:template match="/">
		<!-- Header row -->
		<xsl:if test="report/row/@titleName"><xsl:value-of select="report/language//lit[@name='report_title']"/>,</xsl:if>
		<xsl:if test="report/row/@courseName"><xsl:value-of select="report/language//lit[@name='report_course']"/>,</xsl:if>
		<xsl:if test="report/row/@unitName"><xsl:value-of select="report/language//lit[@name='report_unit']"/>,</xsl:if>
		<xsl:if test="report/row/@exerciseName"><xsl:value-of select="report/language//lit[@name='report_exercise']"/>,</xsl:if>
		
		<xsl:if test="report/row/@groupName"><xsl:value-of select="report/language//lit[@name='report_group']"/>,</xsl:if>
		
		<xsl:if test="report/row/@userName"><xsl:value-of select="report/language//lit[@name='report_student']"/>,</xsl:if>
		<xsl:if test="report/row/@studentID"><xsl:value-of select="report/language//lit[@name='report_studentID']"/>,</xsl:if>
		
		<xsl:if test="report/row/@score"><xsl:value-of select="report/language//lit[@name='report_score']"/>,</xsl:if>
		<xsl:if test="report/row/@duration"><xsl:value-of select="report/language//lit[@name='report_duration_secs']"/>,</xsl:if>
		<xsl:if test="report/row/@start_date"><xsl:value-of select="report/language//lit[@name='report_startTime']"/>,</xsl:if>
		
		<xsl:if test="report/row/@average_score"><xsl:value-of select="report/language//lit[@name='report_averageScore']"/>,</xsl:if>
		<xsl:if test="report/row/@complete"><xsl:value-of select="report/language//lit[@name='report_complete']"/>,</xsl:if>
		<xsl:if test="report/row/@average_time"><xsl:value-of select="report/language//lit[@name='report_averageTime_secs']"/>,</xsl:if>
		<xsl:if test="report/row/@total_time"><xsl:value-of select="report/language//lit[@name='report_totalTime_secs']"/>,</xsl:if>
		<!-- Science Po -->
		<xsl:if test="report/row/@fullName">student Name,</xsl:if>
		<xsl:if test="report/row/@email">email,</xsl:if>
		<xsl:if test="report/row/@studentsYear">students year,</xsl:if>
		<xsl:if test="report/row/@correspondingFaculty">correspondingFaculty,</xsl:if>
		<!-- Science Po -->
		<xsl:text>
</xsl:text>

		<!-- Data rows -->
		<!-- v3.3 Need to enclose data in quote marks so that commas in the data don't trigger new columns -->
		<xsl:for-each select="report/row">
			<xsl:if test="@titleName">"<xsl:value-of select="@titleName"/>",</xsl:if>
			<xsl:if test="@courseName">"<xsl:value-of select="@courseName"/>",</xsl:if>
			<xsl:if test="@unitName">"<xsl:value-of select="@unitName"/>",</xsl:if>
			<xsl:if test="@exerciseName">"<xsl:value-of select="@exerciseName"/>",</xsl:if>
			
			<xsl:if test="@groupName">"<xsl:value-of select="@groupName"/>",</xsl:if>
			
			<xsl:if test="@userName">"<xsl:value-of select="@userName"/>",</xsl:if>
			<xsl:if test="@studentID">"<xsl:value-of select="@studentID"/>",</xsl:if>
			
			<xsl:if test="@score">"<xsl:value-of select="@score" />",</xsl:if>
			
			<xsl:if test="@duration">"<xsl:value-of select="@duration"/>",</xsl:if>
			<xsl:if test="@start_date">"<xsl:value-of select="@start_date"/>",</xsl:if>
			
			<xsl:if test="@average_score">"<xsl:value-of select="@average_score" />",</xsl:if>
			
			<xsl:if test="@complete">"<xsl:value-of select="@complete"/>",</xsl:if>
			<xsl:if test="@average_time">"<xsl:value-of select="@average_time"/>",</xsl:if>
			<xsl:if test="@total_time">"<xsl:value-of select="@total_time"/>",</xsl:if>
			
			<!-- Science Po -->
			<xsl:if test="@fullName">"<xsl:value-of select="@fullName"/>",</xsl:if>
			<xsl:if test="@email">"<xsl:value-of select="@email"/>",</xsl:if>
			<xsl:if test="@studentsYear">"<xsl:value-of select="@studentsYear"/>",</xsl:if>
			<xsl:if test="@correspondingFaculty">"<xsl:value-of select="@correspondingFaculty"/>",</xsl:if>
			<!-- Science Po -->
			<xsl:text>
</xsl:text>

		</xsl:for-each>
	</xsl:template>
</xsl:transform>