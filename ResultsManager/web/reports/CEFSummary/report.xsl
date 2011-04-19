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
				<xsl:with-param name="myName" select="@userName"/>
				<xsl:with-param name="myTest">ILA Level Check A3</xsl:with-param>
				<xsl:with-param name="mySessionID" select="@sessionID"/>
				<xsl:with-param name="myStartDate" select="@start_date"/>
			</xsl:call-template>
			<xsl:call-template name="testSectionScores">
				<xsl:with-param name="myName" select="@userName"/>
				<xsl:with-param name="myTest">ILA Level Check B3</xsl:with-param>
				<xsl:with-param name="mySessionID" select="@sessionID"/>
				<xsl:with-param name="myStartDate" select="@start_date"/>
			</xsl:call-template>
			<xsl:call-template name="testSectionScores">
				<xsl:with-param name="myName" select="@userName"/>
				<xsl:with-param name="myTest">ILA Level Check C3</xsl:with-param>
				<xsl:with-param name="mySessionID" select="@sessionID"/>
				<xsl:with-param name="myStartDate" select="@start_date"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="testSectionScores">
		<xsl:param name="myName" />
		<xsl:param name="myTest" />
		<xsl:param name="mySessionID" />
		<xsl:param name="myStartDate" />
		<!-- Note that we have to use a slash at the beginning otherwise our current node is assumed to be the base for the expression -->
		<!-- What is the point of this if? 
			 The point is that otherwise you will see this for each test, even if you didn't do that test! -->
		<xsl:if test="/report/row[@userName=$myName and @unitName=$myTest]" >
			<tr>
				<td><xsl:value-of select="$myName"/></td>
				<td><xsl:value-of select="$myTest"/></td>
				<td><xsl:value-of select="$myStartDate"/></td>
				<xsl:variable name="grammarCorrect" select="sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and @exerciseName='Grammar']/@correct)" />
				<xsl:variable name="vocabularyCorrect" select="sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and substring-before(@exerciseName,' ')='Vocabulary']/@correct)" />
				<xsl:variable name="readingCorrect" select="sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and substring-before(@exerciseName,' ')='Reading']/@correct)" />
				<!-- 
				<xsl:variable name="grammarMissed" select="sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and @exerciseName='Grammar']/@missed)" />
				<xsl:variable name="vocabularyMissed" select="sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and substring-before(@exerciseName,' ')='Vocabulary']/@missed)" />
				<xsl:variable name="readingMissed" select="sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and substring-before(@exerciseName,' ')='Reading']/@missed)" />
				<xsl:variable name="grammarDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and @exerciseName='Grammar']/@duration)))" />
				<xsl:variable name="vocabularyDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and substring-before(@exerciseName,' ')='Vocabulary']/@duration)))" />
				<xsl:variable name="readingDuration" select="php:function('XSLTFunctions::secondsToMinutes', string(sum(/report/row[@userName=$myName and @unitName=$myTest and @sessionID=$mySessionID and substring-before(@exerciseName,' ')='Reading']/@duration)))" />
				 -->
				<xsl:choose>
					<xsl:when test="$myTest='ILA Level Check A3'">
						<td>
							<xsl:choose>
								<xsl:when test="$grammarCorrect &lt; 5"> A0 </xsl:when>
								<xsl:when test="$grammarCorrect &gt;= 5 and $grammarCorrect &lt;= 11"> A1 </xsl:when>
								<xsl:otherwise> A2 </xsl:otherwise>
							</xsl:choose>
							(<xsl:value-of select="$grammarCorrect"/> correct)
						</td>
						<td>
							<xsl:choose>
								<xsl:when test="$vocabularyCorrect &lt; 11"> A0 </xsl:when>
								<xsl:when test="$vocabularyCorrect &gt;= 11 and $vocabularyCorrect &lt;= 20"> A1 </xsl:when>
								<xsl:otherwise> A2 </xsl:otherwise>
							</xsl:choose>
							(<xsl:value-of select="$vocabularyCorrect"/> correct)
						</td>
						<td>
							<xsl:choose>
								<xsl:when test="$readingCorrect &lt; 4"> A0 </xsl:when>
								<xsl:when test="$readingCorrect &gt;= 4 and $readingCorrect &lt;= 8"> A1 </xsl:when>
								<xsl:otherwise> A2 </xsl:otherwise>
							</xsl:choose>
							(<xsl:value-of select="$readingCorrect"/> correct)
						</td>
						<!-- Finally I need to know what level this all works out to -->
						<td>
							<xsl:choose>
								<xsl:when test="$grammarCorrect + $vocabularyCorrect + $readingCorrect &gt; 39">A2</xsl:when>
								<xsl:when test="$grammarCorrect + $vocabularyCorrect + $readingCorrect &gt; 19">A1</xsl:when>
								<xsl:otherwise>A0</xsl:otherwise>
							</xsl:choose>
						</td>
					</xsl:when>
					<xsl:when test="$myTest='ILA Level Check B3'">
						<td>
						<xsl:choose>
							<xsl:when test="$grammarCorrect &lt; 8"> A2 </xsl:when>
							<xsl:when test="$grammarCorrect &gt;= 8 and $grammarCorrect &lt;= 17"> B1 </xsl:when>
							<xsl:otherwise> B2 </xsl:otherwise>
						</xsl:choose>
						(<xsl:value-of select="$grammarCorrect"/> correct)</td>
						<td>
						<xsl:choose>
							<xsl:when test="$vocabularyCorrect &lt; 10"> A2 </xsl:when>
							<xsl:when test="$vocabularyCorrect &gt;= 10 and $vocabularyCorrect &lt;= 18"> B1 </xsl:when>
							<xsl:otherwise>	B2 </xsl:otherwise>
						</xsl:choose>
						(<xsl:value-of select="$vocabularyCorrect"/> correct)</td>
						<td>
						<xsl:choose>
							<xsl:when test="$readingCorrect &lt; 5"> A2 </xsl:when>
							<xsl:when test="$readingCorrect &gt;= 5 and $readingCorrect &lt;= 11"> B1 </xsl:when>
							<xsl:otherwise> B2 </xsl:otherwise>
						</xsl:choose>
						(<xsl:value-of select="$readingCorrect"/> correct)</td>
						<td>
							<xsl:choose>
								<xsl:when test="$grammarCorrect + $vocabularyCorrect + $readingCorrect &gt; 46">B2</xsl:when>
								<xsl:when test="$grammarCorrect + $vocabularyCorrect + $readingCorrect &gt; 22">B1</xsl:when>
								<xsl:otherwise>A2</xsl:otherwise>
							</xsl:choose>
						</td>
					</xsl:when>
					<xsl:when test="$myTest='ILA Level Check C3'">
						<td>
						<xsl:choose>
							<xsl:when test="$grammarCorrect &lt; 8"> B2 </xsl:when>
							<xsl:when test="$grammarCorrect &gt;= 8 and $grammarCorrect &lt;= 14"> C1 </xsl:when>
							<xsl:otherwise> C2 </xsl:otherwise>
						</xsl:choose>
						(<xsl:value-of select="$grammarCorrect"/> correct)</td>
						<td>
						<xsl:choose>
							<xsl:when test="$vocabularyCorrect &lt; 8"> B2 </xsl:when>
							<xsl:when test="$vocabularyCorrect &gt;= 8 and $vocabularyCorrect &lt;= 15"> C1 </xsl:when>
							<xsl:otherwise> C2 </xsl:otherwise>
						</xsl:choose>
						(<xsl:value-of select="$vocabularyCorrect"/> correct)</td>
						<td>
						<xsl:choose>
							<xsl:when test="$readingCorrect &lt; 5"> B2 </xsl:when>
							<xsl:when test="$readingCorrect &gt;= 5 and $readingCorrect &lt;= 11"> C1 </xsl:when>
							<xsl:otherwise> C2 </xsl:otherwise>
						</xsl:choose>
						(<xsl:value-of select="$readingCorrect"/> correct)</td>
						<td>
							<xsl:choose>
								<xsl:when test="$grammarCorrect + $vocabularyCorrect + $readingCorrect &gt; 40">C2</xsl:when>
								<xsl:when test="$grammarCorrect + $vocabularyCorrect + $readingCorrect &gt; 20">C1</xsl:when>
								<xsl:otherwise>B2</xsl:otherwise>
							</xsl:choose>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td><xsl:value-of select="$grammarCorrect" /> correct</td>
						<td><xsl:value-of select="$vocabularyCorrect" /> correct</td>
						<td><xsl:value-of select="$readingCorrect" />correct</td>					
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<html>
			<head>
				<title>BC ILA Level Check CEF Summary Report</title>
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
							<th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='report_student']"/></th>
							<th type="ro">Test taken</th>
							<th type="ro">Date</th>
							<th type="ro">Grammar</th>
							<th type="ro">Vocabulary</th>
							<th type="ro">Reading</th>
							<th type="ro">Overall</th>
							
						</tr>
						<!-- I want to get the unique names from the rows in the XML. This code will ONLY work if rows are grouped by username. -->
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
							
							<xsl:if test="report/row/@unitName"><th type="ro">Test</th></xsl:if>
							<xsl:if test="report/row/@exerciseName"><th type="ro">Section</th></xsl:if>
							
							<xsl:if test="report/row/@start_date"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_startTime']"/></th></xsl:if>
							<xsl:if test="report/row/@duration"><th type="ro">Minutes</th></xsl:if>
							<xsl:if test="report/row/@correct"><th type="ro">Correct - Wrong - Skipped</th></xsl:if>
							
						</tr>
							
						<xsl:for-each select="report/row">
							<tr>
							<td><xsl:value-of select="@groupName"/></td>
							<td><xsl:value-of select="@userName"/></td>
							<td><xsl:value-of select="@unitName"/></td>
							<td><xsl:value-of select="@exerciseName"/></td>
							<td><xsl:value-of select="@start_date"/></td>
							<td><xsl:value-of select="php:function('XSLTFunctions::secondsToMinutes', string(@duration))"/></td>
								<xsl:if test="@correct"><td><xsl:call-template name="formatCorrect"><xsl:with-param name="correct" select="@correct"/>
																									<xsl:with-param name="wrong" select="@wrong" />
																									<xsl:with-param name="missed" select="@missed"/></xsl:call-template></td></xsl:if>
							</tr>
						</xsl:for-each>
					</table>
		-->
			</body>
		</html>
	</xsl:template>
</xsl:transform>