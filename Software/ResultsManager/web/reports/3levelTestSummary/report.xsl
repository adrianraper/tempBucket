<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                			 extension-element-prefixes="php">
    
	<!-- Include various helper templates for use in generating reports - see functions.xsl for details -->
	<xsl:include href="../functions.xsl" />

	<xsl:template match="/">
		<html>
			<head>
				<title>Practical Placement Test Summary Report</title>
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
					This is where you format the other part of the header
				-->					
					<table id="headerTable" width="100%">
					<tbody>
					<tr >
						<td class="headerTableLabels" width="150">Number of test takers:</td>
						<td ><xsl:value-of select="count(report/row[not(@userName=preceding-sibling::row/@userName)])"/></td>
					</tr>
					<tr>
						<td class="headerTableLabels" ><xsl:value-of select="report/language//lit[@name='report_totalTimeSpent']"/>:</td>
						<td ><xsl:call-template name="getSummaryTotalTime" /><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text><xsl:value-of select="report/language//lit[@name='report_hours']"/></td>
					</tr>
					<tr>
						<td class="headerTableLabels" >CEF Equivalance link</td>
						<td ><a href="/support/user/pdf/ppt/CEF_Chart_PPT.pdf" target="_blank">PDF reference</a></td>
					</tr>
					</tbody>
					</table>
					
				</td></tr>
				</table>
				
				<hr/>
				<!-- We don't want a standard table since we are going to merge rows. For now do it all here.
					We know that the rows are ordered by user name, lets hope that is unique, at least within this report. 
					We are also now going to order by sessionID so that we can report multiple attempts -->
					<table id="reportTable" style="width:100%" gridWidth="100%">
						<tr>
							<xsl:if test="report/row/@userName"><th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='report_student']"/></th></xsl:if>
							
							<xsl:if test="report/row/@exerciseName"><th type="ro">Vocabulary</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Listening</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Grammar</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Self-assessment</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Recommended level</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Date</th></xsl:if>
							
						</tr>
						<xsl:for-each select="report/row">	
							<tr>
								<td>
									<xsl:value-of select="@userName"/>
								</td>
								<td>
									<xsl:value-of select="@vocabularyCorrect" /> of <xsl:value-of select="@vocabularyCorrect + @vocabularyWrong + @vocabularyMissed"/>
								</td>
								<td>
									<xsl:value-of select="@listeningCorrect" /> of <xsl:value-of select="@listeningCorrect + @listeningWrong + @listeningMissed"/>
								</td>
								<td>
									<xsl:value-of select="@grammarCorrect" /> of <xsl:value-of select="@grammarCorrect + @grammarWrong + @grammarMissed"/>
								</td>
								<td>
									Yes: <xsl:value-of select="@selfAssessmentList" />
								</td>
								<td>
									<xsl:choose>
										<xsl:when test="$grammarCorrect + $vocabularyCorrect + $listeningCorrect + $selfAssessment &gt; 90"> Advanced </xsl:when>
										<xsl:when test="$grammarCorrect + $vocabularyCorrect + $listeningCorrect + $selfAssessment &gt; 46"> Intermediate </xsl:when>
										<xsl:otherwise> Elementary </xsl:otherwise>
									</xsl:choose>
								</td>
								<td><xsl:value-of select="@myStartDate" /></td>
							</tr>
						</xsl:for-each>
					</table>
					<hr />
			</body>
		</html>
	</xsl:template>
</xsl:transform>