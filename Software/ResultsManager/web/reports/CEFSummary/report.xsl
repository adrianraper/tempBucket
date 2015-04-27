<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                			 extension-element-prefixes="php">
    
	<!-- Include various helper templates for use in generating reports - see functions.xsl for details -->
	<xsl:include href="../functions.xsl" />

	<xsl:template match="/">
		<html>
			<head>
				<title>LearnEnglish Level Test Summary Report</title>
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
						<td ><xsl:value-of select="count(report/row)"/></td>
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
							<th type="ro">Email</th>
							<th type="ro">Test taken</th>
							<th type="ro">Date</th>
							<th type="ro">Grammar</th>
							<th type="ro">Vocabulary</th>
							<th type="ro">Reading</th>
							<th type="ro">Overall</th>
							
						</tr>
						<xsl:for-each select="report/row">	
							<tr>
								<td><xsl:value-of select="@userName"/></td>
								<td><xsl:value-of select="@email"/></td>
								<td><xsl:value-of select="@unitName"/></td>
								<td><xsl:value-of select="@start_date"/></td>
								<xsl:choose>
									<xsl:when test="@unitName='LearnEnglish Level Test A'">
										<td>
											<xsl:choose>
												<xsl:when test="@grammarCorrect &lt; 5"> A0 </xsl:when>
												<xsl:when test="@grammarCorrect &gt;= 5 and @grammarCorrect &lt;= 11"> A1 </xsl:when>
												<xsl:otherwise> A2 </xsl:otherwise>
											</xsl:choose>
											(<xsl:value-of select="@grammarCorrect"/> correct)
										</td>
										<td>
											<xsl:choose>
												<xsl:when test="@vocabularyCorrect &lt; 11"> A0 </xsl:when>
												<xsl:when test="@vocabularyCorrect &gt;= 11 and @vocabularyCorrect &lt;= 20"> A1 </xsl:when>
												<xsl:otherwise> A2 </xsl:otherwise>
											</xsl:choose>
											(<xsl:value-of select="@vocabularyCorrect"/> correct)
										</td>
										<td>
											<xsl:choose>
												<xsl:when test="@readingCorrect &lt; 4"> A0 </xsl:when>
												<xsl:when test="@readingCorrect &gt;= 4 and @readingCorrect &lt;= 8"> A1 </xsl:when>
												<xsl:otherwise> A2 </xsl:otherwise>
											</xsl:choose>
											(<xsl:value-of select="@readingCorrect"/> correct)
										</td>
										<!-- Finally I need to know what level this all works out to -->
										<td>
											<xsl:choose>
												<xsl:when test="@grammarCorrect + @vocabularyCorrect + @readingCorrect &gt; 39">A2</xsl:when>
												<xsl:when test="@grammarCorrect + @vocabularyCorrect + @readingCorrect &gt; 19">A1</xsl:when>
												<xsl:otherwise>A0</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:when>
									<xsl:when test="@unitName='LearnEnglish Level Test B'">
										<td>
										<xsl:choose>
											<xsl:when test="@grammarCorrect &lt; 8"> A2 </xsl:when>
											<xsl:when test="@grammarCorrect &gt;= 8 and @grammarCorrect &lt;= 17"> B1 </xsl:when>
											<xsl:otherwise> B2 </xsl:otherwise>
										</xsl:choose>
										(<xsl:value-of select="@grammarCorrect"/> correct)</td>
										<td>
										<xsl:choose>
											<xsl:when test="@vocabularyCorrect &lt; 10"> A2 </xsl:when>
											<xsl:when test="@vocabularyCorrect &gt;= 10 and @vocabularyCorrect &lt;= 18"> B1 </xsl:when>
											<xsl:otherwise>	B2 </xsl:otherwise>
										</xsl:choose>
										(<xsl:value-of select="@vocabularyCorrect"/> correct)</td>
										<td>
										<xsl:choose>
											<xsl:when test="@readingCorrect &lt; 5"> A2 </xsl:when>
											<xsl:when test="@readingCorrect &gt;= 5 and @readingCorrect &lt;= 11"> B1 </xsl:when>
											<xsl:otherwise> B2 </xsl:otherwise>
										</xsl:choose>
										(<xsl:value-of select="@readingCorrect"/> correct)</td>
										<td>
											<xsl:choose>
												<xsl:when test="@grammarCorrect + @vocabularyCorrect + @readingCorrect &gt; 46">B2</xsl:when>
												<xsl:when test="@grammarCorrect + @vocabularyCorrect + @readingCorrect &gt; 22">B1</xsl:when>
												<xsl:otherwise>A2</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:when>
									<xsl:when test="@unitName='LearnEnglish Level Test C'">
									<!-- corrections from Alex Caughey, Tokyo, 1st Sept 2014 -->
										<td>
										<xsl:choose>
											<xsl:when test="@grammarCorrect &lt; 10"> B2 </xsl:when>
											<xsl:when test="@grammarCorrect &gt;= 10 and @grammarCorrect &lt;= 14"> C1 </xsl:when>
											<xsl:otherwise> C2 </xsl:otherwise>
										</xsl:choose>
										(<xsl:value-of select="@grammarCorrect"/> correct)</td>
										<td>
										<xsl:choose>
											<xsl:when test="@vocabularyCorrect &lt; 8"> B2 </xsl:when>
											<xsl:when test="@vocabularyCorrect &gt;= 8 and @vocabularyCorrect &lt;= 15"> C1 </xsl:when>
											<xsl:otherwise> C2 </xsl:otherwise>
										</xsl:choose>
										(<xsl:value-of select="@vocabularyCorrect"/> correct)</td>
										<td>
										<xsl:choose>
											<xsl:when test="@readingCorrect &lt; 7"> B2 </xsl:when>
											<xsl:when test="@readingCorrect &gt;= 7 and @readingCorrect &lt;= 13"> C1 </xsl:when>
											<xsl:otherwise> C2 </xsl:otherwise>
										</xsl:choose>
										(<xsl:value-of select="@readingCorrect"/> correct)</td>
										<td>
											<xsl:choose>
												<xsl:when test="@grammarCorrect + @vocabularyCorrect + @readingCorrect &gt; 42">C2</xsl:when>
												<xsl:when test="@grammarCorrect + @vocabularyCorrect + @readingCorrect &gt; 24">C1</xsl:when>
												<xsl:otherwise>B2</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:when>
									<xsl:otherwise>
										<td><xsl:value-of select="@grammarCorrect" /> correct</td>
										<td><xsl:value-of select="@vocabularyCorrect" /> correct</td>
										<td><xsl:value-of select="@readingCorrect" /> correct</td>
										<td>-</td>
									</xsl:otherwise>
								</xsl:choose>
							</tr>
						</xsl:for-each>
					</table>
					<hr />
			</body>
		</html>
	</xsl:template>
</xsl:transform>