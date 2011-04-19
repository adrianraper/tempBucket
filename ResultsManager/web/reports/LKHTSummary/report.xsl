<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                			 extension-element-prefixes="php">
    
	<!-- Include various helper templates for use in generating reports - see functions.xsl for details -->
	<xsl:include href="../functions.xsl" />

	<xsl:template name="testSectionScores">
		<xsl:param name="myName" />
		<xsl:param name="myID" />
		<xsl:param name="myTest" />
		<xsl:param name="myDate" />
		<!-- Note that we have to use a slash at the beginning otherwise our current node is assumed to be the base for the expression -->
		<xsl:if test="/report/row[@userName=$myName and @courseName=$myTest]" >
			<tr>
			<td><xsl:value-of select="$myName"/></td>
			<td><xsl:value-of select="$myID"/></td>
			<td><xsl:value-of select="$myTest"/></td>
			<td><xsl:value-of select="$myDate"/></td>
			<xsl:variable name="overallScore" select="sum(/report/row[@userName=$myName and @courseName=$myTest and @correct>0]/@correct)" />
			<xsl:variable name="grammarCorrect" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Grammar']/@correct)" />
			<xsl:variable name="vocabularyCorrect" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Vocabulary']/@correct)" />
			<xsl:variable name="readingCorrect" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Reading']/@correct)" />
			<xsl:variable name="listeningCorrect" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Listening']/@correct)" />
			<xsl:variable name="videoCorrect" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Video']/@correct)" />
			<xsl:variable name="grammarOf" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Grammar']/@numQuestions)" />
			<xsl:variable name="vocabularyOf" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Vocabulary']/@numQuestions)" />
			<xsl:variable name="readingOf" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Reading']/@numQuestions)" />
			<xsl:variable name="listeningOf" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Listening']/@numQuestions)" />
			<xsl:variable name="videoOf" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Video']/@numQuestions)" />
			<xsl:variable name="grammarMissed" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Grammar']/@missed)" />
			<xsl:variable name="vocabularyMissed" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Vocabulary']/@missed)" />
			<xsl:variable name="readingMissed" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Reading']/@missed)" />
			<xsl:variable name="listeningMissed" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Listening']/@missed)" />
			<xsl:variable name="videoMissed" select="sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Video']/@missed)" />
			<xsl:variable name="grammarDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Grammar']/@duration)))" />
			<xsl:variable name="vocabularyDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Vocabulary']/@duration)))" />
			<xsl:variable name="readingDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Reading']/@duration)))" />
			<xsl:variable name="listeningDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Listening']/@duration)))" />
			<xsl:variable name="videoDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @courseName=$myTest and substring-before(@exerciseName,' ')='Video']/@duration)))" />
			
			<td><xsl:value-of select="$overallScore"/>%</td>
			<td>
			<xsl:value-of select="$grammarCorrect"/> of <xsl:value-of select="$grammarOf"/>
			(in <xsl:value-of select="$grammarDuration"/> minutes, <xsl:value-of select="$grammarMissed"/> skipped)</td>
			<td>
			<xsl:value-of select="$vocabularyCorrect"/> of <xsl:value-of select="$vocabularyOf"/>
			(in <xsl:value-of select="$vocabularyDuration"/> minutes, <xsl:value-of select="$vocabularyMissed"/> skipped)</td>
			<td>
			<xsl:value-of select="$readingCorrect"/> of <xsl:value-of select="$readingOf"/>
			(in <xsl:value-of select="$readingDuration"/> minutes, <xsl:value-of select="$readingMissed"/> skipped)</td>
			<td>
			<xsl:value-of select="$listeningCorrect"/> of <xsl:value-of select="$listeningOf"/>
			(in <xsl:value-of select="$listeningDuration"/> minutes, <xsl:value-of select="$listeningMissed"/> skipped)</td>
			<td>
			<xsl:value-of select="$videoCorrect"/> of <xsl:value-of select="$videoOf"/>
			(in <xsl:value-of select="$videoDuration"/> minutes, <xsl:value-of select="$videoMissed"/> skipped)</td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>Language Key Hotel Test Summary Report</title>
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
					</tbody>
					</table>
					
				</td></tr>
				</table>
				
				<hr/>
				<!-- We don't want a standard table since we are going to merge rows. For now do it all here.
					We know that the rows are ordered by user name, lets hope that is unique, at least within this report. -->
					<table id="reportTable" style="width:100%" gridWidth="100%">
						<tr>
							<xsl:if test="report/row/@userName"><th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='report_name']"/></th></xsl:if>
							<xsl:if test="report/row/@studentID"><th type="ro">ID</th></xsl:if>
							<xsl:if test="report/row/@unitName"><th type="ro">Test taken</th></xsl:if>
							<xsl:if test="report/row/@unitName"><th type="ro">Date</th></xsl:if>
							<xsl:if test="report/row/@unitName"><th type="ro">Overall Score</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Grammar</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Vocabulary</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Reading</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Listening</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Video</th></xsl:if>
							
						</tr>
						<!-- I want to get the unique names from the rows in the XML. This code will ONLY work if rows are grouped by username. 
							But I also need to get each course that each user has done, so this doesn't work -->
						<!-- 
						<xsl:for-each select="report/row[not(@userName=preceding-sibling::row/@userName)]">	
							<xsl:call-template name="testSectionScores">
								<xsl:with-param name="myName" select="@userName"/>
								<xsl:with-param name="myID" select="@studentID"/>
								<xsl:with-param name="myTest" select="@courseName"/>
								<xsl:with-param name="myDate" select="@start_date"/>
							</xsl:call-template>
							<xsl:call-template name="getAllCourses">
								<xsl:with-param name="myName" select="@userName"/>
							</xsl:call-template>
						</xsl:for-each>
						-->
						<!-- go through each row and if it has a different user or course name to the one before, send the parameters to 
								the summarising function -->
						<xsl:for-each select="report/row">
							<xsl:if test="not(@userName=preceding-sibling::row/@userName) or not(@courseName=preceding-sibling::row/@courseName)">
								<xsl:call-template name="testSectionScores">
									<xsl:with-param name="myName" select="@userName"/>
									<xsl:with-param name="myID" select="@studentID"/>
									<xsl:with-param name="myTest" select="@courseName"/>
									<xsl:with-param name="myDate" select="@start_date"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:for-each>
					</table>
					<hr />
		<!-- Just for checking show the full table 
		
					<i>The following table is a full list of records to confirm the above summary</i>
					
					<table id="reportTable" style="width:100%" gridWidth="100%">
						<tr>
							<xsl:if test="report/row/@userName"><th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='report_student']"/></th></xsl:if>
							<xsl:if test="report/row/@studentID"><th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='studentID']"/></th></xsl:if>
							
							<xsl:if test="report/row/@courseName"><th type="ro">Test</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Section</th></xsl:if>
							<xsl:if test="report/row/@correct"><th type="ro">Score</th></xsl:if>
							
						</tr>
							
						<xsl:for-each select="report/row">
							<tr>
							<td><xsl:value-of select="@userName"/></td>
							<td><xsl:value-of select="@studentID"/></td>
							<td><xsl:value-of select="@courseName"/></td>
							<td><xsl:value-of select="@exerciseName"/></td>
								<xsl:if test="@correct"><td><xsl:value-of select="@correct"/> of 
															<xsl:value-of select="@numQuestions"/></td></xsl:if>
							</tr>
						</xsl:for-each>
					</table>
		
		 -->
			</body>
		</html>
	</xsl:template>
</xsl:transform>