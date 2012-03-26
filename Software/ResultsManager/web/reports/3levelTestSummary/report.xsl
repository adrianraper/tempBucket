<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                			 extension-element-prefixes="php">
    
	<!-- Include various helper templates for use in generating reports - see functions.xsl for details -->
	<xsl:include href="../functions.xsl" />

	<xsl:template name="loopSessions">
		<xsl:param name="myName" />
		<xsl:for-each select="/report/row[@userName=$myName and not(@sessionID=preceding-sibling::row/@sessionID)]">
			<xsl:call-template name="testSectionScores">
				<xsl:with-param name="myName" select="$myName"/>
				<xsl:with-param name="mySessionID" select="@sessionID"/>
				<xsl:with-param name="myStartDate" select="@start_date"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="testSectionScores">
		<xsl:param name="myName" />
		<xsl:param name="mySessionID" />
		<xsl:param name="myStartDate" />
		<!-- Note that we have to use a slash at the beginning otherwise our current node is assumed to be the base for the expression -->
		<!-- What is the point of this if? 
			 The point is that otherwise you will see this for each test, even if you didn't do that test!
			 But that only applies to tests with multiple sections, which we are not. -->
		<!-- <xsl:if test="/report/row[@userName=$myName and @sessionID=$mySessionID]" > -->
			<tr>

				<!-- It is wrong to sum these. We should only really be reporting on the first or last attempt. 
					If I take out sum(), it will give me the first. This seems fine. Not really, what happens when someone takes the test a few times? 
					I think we need to group by sessionID (which is not set for rows yet, just for details. Done. So sum() now good for adding many grammar exercises together -->
				<xsl:variable name="grammarCorrect" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,7)='Grammar']/@correct)" />
				<xsl:variable name="vocabularyCorrect" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,10)='Vocabulary']/@correct)" />
				<xsl:variable name="listeningCorrect" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,9)='Listening']/@correct)" />
				<xsl:variable name="grammarMissed" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,7)='Grammar']/@missed)" />
				<xsl:variable name="vocabularyMissed" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,10)='Vocabulary']/@missed)" />
				<xsl:variable name="listeningMissed" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,9)='Listening']/@missed)" />
				<xsl:variable name="grammarWrong" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,7)='Grammar']/@wrong)" />
				<xsl:variable name="vocabularyWrong" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,10)='Vocabulary']/@wrong)" />
				<xsl:variable name="listeningWrong" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,9)='Listening']/@wrong)" />
				<!-- 
				<xsl:variable name="grammarTotal" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,7)='Grammar']/@missed|@correct|@wrong)" />
				<xsl:variable name="vocabularyTotal" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,10)='Vocabulary']/@missed|@correct|@wrong)" />
				<xsl:variable name="listeningTotal" select="sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,11)='Listening 1']/@missed|@wrong|@correct)" />
				-->
				<xsl:variable name="grammarDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,7)='Grammar']/@duration)))" />
				<xsl:variable name="vocabularyDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,10)='Vocabulary']/@duration)))" />
				<xsl:variable name="listeningDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,9)='Listening']/@duration)))" />
				<!-- For the details I DO need to sum them and multiply itemID by score, and list them out -->
				<xsl:variable name="selfAssessment" select="sum(/report/detail[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,5)='What ' and @score=1]/@itemID)" />
				<!-- Print it all out -->
				<td>
					<xsl:value-of select="$myName"/>
				</td>
				<td>
					<xsl:value-of select="$vocabularyCorrect" /> of <xsl:value-of select="$vocabularyCorrect + $vocabularyWrong + $vocabularyMissed"/>
				</td>
				<td>
					<xsl:value-of select="$listeningCorrect" /> of <xsl:value-of select="$listeningCorrect + $listeningWrong + $listeningMissed"/>
					<!--(in <xsl:value-of select="$listeningDuration"/> minutes, <xsl:value-of select="$listeningMissed"/> were skipped) -->
				</td>
				<td>
					<xsl:value-of select="$grammarCorrect" /> of <xsl:value-of select="$grammarCorrect + $grammarWrong + $grammarMissed"/>
				</td>
				<td>
					<!--
					<xsl:value-of select="$selfAssessment" /> ( 
					This is not enough, you need to know which questions they agreed with and weight the results
					<xsl:for-each select="/report/detail[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,17)='What do you think' and @score=1]/@itemID">
						<xsl:value-of select="." />,
					</xsl:for-each>
					)
					 -->
					Yes: 
					<xsl:for-each select="/report/detail[@userName=$myName and @sessionID=$mySessionID and substring(@exerciseName,1,5)='What ' and @score=1]/@itemID">
						<!-- Sort the items by order (numeric), not sure why they are out of order anyway -->
						<xsl:sort select="." data-type="number" />
						<xsl:value-of select="." />,
					</xsl:for-each>
				</td>
				<!-- Finally I need to know what level this all works out to -->
				<!-- But some tests have a different system. 
					Either I need to pick up something from T_LicenceAttributes; tricky as RM doesn't read it at present 
					Or I can just base it on prefix (which I will do, but is not a long-term idea)
					Or I need a copy of the whole test as Mexico Test etc.-->
				<td>
					<xsl:choose>
						<xsl:when test="$grammarCorrect + $vocabularyCorrect + $listeningCorrect + $selfAssessment &gt; 90"> Advanced </xsl:when>
						<xsl:when test="$grammarCorrect + $vocabularyCorrect + $listeningCorrect + $selfAssessment &gt; 46"> Intermediate </xsl:when>
						<xsl:otherwise> Elementary </xsl:otherwise>
					</xsl:choose>
				</td>
				<td><xsl:value-of select="$myStartDate" /></td>
			</tr>
		<!-- </xsl:if> -->
	</xsl:template>

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
						<xsl:for-each select="report/row[not(@userName=preceding-sibling::row/@userName)]">	
							<!-- How do I then do a loop for each sessionID within the one name? -->
							<!-- <xsl:call-template name="testSectionScores"> -->
							<xsl:call-template name="loopSessions">
								<xsl:with-param name="myName" select="@userName"/>
							</xsl:call-template>
						</xsl:for-each>
					</table>
					<hr />
		<!-- Just for checking show the full table 
					<i>The following table is a full list of records to confirm the above summary</i>
					
					<table id="reportTable" style="width:100%" gridWidth="100%">
						<tr>
							<xsl:if test="report/row/@groupName"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_group']"/></th></xsl:if>
							<xsl:if test="report/row/@userName"><th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='report_student']"/></th></xsl:if>
							
							<xsl:if test="report/row/@exerciseName"><th type="ro">Section</th></xsl:if>
							
							<xsl:if test="report/row/@start_date"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_startTime']"/></th></xsl:if>
							<xsl:if test="report/row/@duration"><th type="ro">Minutes</th></xsl:if>
							<xsl:if test="report/row/@correct"><th type="ro">Correct - Wrong - Skipped</th></xsl:if>
							<th type="ro">Total</th>
							
						</tr>
						<xsl:for-each select="report/row">
							<tr>
							<td><xsl:value-of select="@groupName"/></td>
							<td><xsl:value-of select="@userName"/></td>
							<td><xsl:value-of select="@exerciseName"/></td>
							<td><xsl:value-of select="@start_date"/></td>
							<td><xsl:value-of select="php:function('XSLTFunctions::secondsToMinutes', string(@duration))"/></td>
								<xsl:if test="@correct"><td><xsl:call-template name="formatCorrect"><xsl:with-param name="correct" select="@correct"/>
																									<xsl:with-param name="wrong" select="@wrong" />
																									<xsl:with-param name="missed" select="@missed"/></xsl:call-template></td></xsl:if>
							<td><xsl:value-of select="sum(@missed|@wrong|@correct)" /></td>
							</tr>
						</xsl:for-each>
					</table>
		 -->
			</body>
		</html>
	</xsl:template>
</xsl:transform>