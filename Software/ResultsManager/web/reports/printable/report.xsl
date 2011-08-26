<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                			 extension-element-prefixes="php">
    
	<!-- Include various helper templates for use in generating reports - see functions.xsl for details -->
	<xsl:include href="../functions.xsl" />
	
	<xsl:template match="/">
		<html>
			<head>
				<title>Results Manager Generated Report</title>
				<link href="../../reports/printable/report.css" rel="stylesheet" type="text/css" />
				<script>
					function truncateText(text, maxLength) {
						maxLength = (maxLength == undefined) ? 250 : maxLength;
						// AR You need to encode this otherwise &quot; stops it appearing. Or do this bit in xsl
						if (text.length > maxLength) {
							// for the printing version just stick to ...
							document.write(text.substr(0, maxLength) + "...");
						} else {
							document.write(text);
						}
					}
				</script>
			</head>
			
			<body>
				<table width="100%">
				<tr valign="top" ><td class="nobord" width="70%">
				<!--
					This is where you format the header.
				-->					
					<table id="headerTable" width="80%">
					<tbody>
						<tr >
							<td class="headerTableLabels" width="100">
								<xsl:value-of select="report/@onReportLabel"/>:	
							</td>
							<td >
								<xsl:value-of select="substring(report/@onReport,1,250)"/>
							</td>
						</tr>
						<xsl:if test="report/@titles">
							<tr><td class="headerTableLabels" >
							<xsl:value-of select="report/language//lit[@name='report_titles']"/>:	
							</td>
							<td >
							<script>truncateText("<xsl:value-of select="report/@titles"/>");</script>
							</td></tr>
						</xsl:if>
						<xsl:if test="report/@courses">
							<tr><td class="headerTableLabels" >
							<xsl:value-of select="report/language//lit[@name='report_courses']"/>:	
							</td>
							<td >
							<script>truncateText("<xsl:value-of select="report/@courses"/>");</script>
							</td></tr>
						</xsl:if>
						<xsl:if test="report/@forReportDetail and report/@forReportDetail!=''">
							<tr><td class="headerTableLabels" >
							<xsl:value-of select="report/@forReportLabel"/>:	
							</td>
							<td >
							<script>truncateText("<xsl:value-of select="report/@forReportDetail"/>");</script>
							</td></tr>
						</xsl:if>
						<tr><td class="headerTableLabels" >
						<xsl:value-of select="report/language//lit[@name='report_attempts']"/>:	
						</td>
						<td >
						<xsl:value-of select="report/@attempts"/>
						</td></tr>
						<xsl:if test="report/@dateRange and report/@dateRange!=''">
							<tr><td class="headerTableLabels" >
							<xsl:value-of select="report/language//lit[@name='report_dateRange']"/>:	
							</td>
							<td >
							<xsl:value-of select="report/@dateRange"/>
							</td></tr>
						</xsl:if>
					</tbody>
					</table>
				</td>
				<td class="nobord" width="30%">
				<!--
					This is where you format the footer
				-->					
					<table id="headerTable" width="100%">
					<tbody>
					<tr ><td class="headerTableLabels" width="150">
					<xsl:value-of select="report/language//lit[@name='report_exercisesCompleted']"/>:	
					</td>
					<td >
					<xsl:call-template name="getSummaryExercisesCompleted" />
					</td></tr>
					<tr><td class="headerTableLabels" >
					<xsl:value-of select="report/language//lit[@name='report_averageScore']"/>:	
					</td>
					<td >
					<!-- I can't see how to do this neatly, maybe formatScore should be a PHP function like the time formatting one  -->
					<xsl:variable name="summaryAverageScore"><xsl:call-template name="getSummaryAverageScore" /></xsl:variable>
					<xsl:call-template name="formatScore"><xsl:with-param name="score" select="$summaryAverageScore" /></xsl:call-template>				
					</td></tr>
					<tr><td class="headerTableLabels" >
					<xsl:value-of select="report/language//lit[@name='report_averageDuration']"/>:	
					</td>
					<td >
					<xsl:call-template name="getSummaryAverageDuration" /><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text><xsl:value-of select="report/language//lit[@name='report_minutes']"/>
					</td></tr>
					<tr><td class="headerTableLabels" >
					<xsl:value-of select="report/language//lit[@name='report_totalTimeSpent']"/>:	
					</td>
					<td >
					<xsl:call-template name="getSummaryTotalTime" /><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text><xsl:value-of select="report/language//lit[@name='report_hours']"/>
					</td></tr>
					</tbody>
					</table>
					
				</td></tr>
				</table>
				
				<hr/>
				
				<xsl:call-template name="generateTable">
					<xsl:with-param name="tableId">reportTable</xsl:with-param>
				</xsl:call-template>
				
				<br/>
				
			</body>
		</html>
	</xsl:template>
</xsl:transform>