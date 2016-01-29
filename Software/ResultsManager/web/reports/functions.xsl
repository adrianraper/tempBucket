<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:xdt="http://www.w3.org/2005/04/xpath-datatype"
							 xmlns:date="http://exslt.org/dates-and-times"
							 xmlns:php="http://php.net/xsl"
							 xmlns:exslt="http://exslt.org/common"
							 extension-element-prefixes="php date xdt xs">
    
	<!-- Define global variables for use in the XSL -->
	<xsl:variable name="scriptName"><xsl:value-of select="report/@scriptName" /></xsl:variable>							 
	<xsl:variable name="onReportablesIDObjects"><xsl:value-of select="report/@onReportablesIDObjects" /></xsl:variable>							 
	<xsl:variable name="onClass"><xsl:value-of select="report/@onClass" /></xsl:variable>							 
	<xsl:variable name="forReportablesIDObjects"><xsl:value-of select="report/@forReportablesIDObjects" /></xsl:variable>							 
	<xsl:variable name="forClass"><xsl:value-of select="report/@forClass" /></xsl:variable>		
	<xsl:variable name="opts"><xsl:value-of select="report/@opts" /></xsl:variable>		
	
	<!-- formatScore takes a percentage score and formats it for display -->
	<xsl:template name="formatScore">
		<xsl:param name="score" />
		<xsl:choose>
			<xsl:when test="$score != ''"><xsl:value-of select='format-number($score, "0")'/>%</xsl:when>
			<xsl:otherwise>---</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- formatCorrect takes the correct, wrong and missed values and formats them for display -->
	<xsl:template name="formatCorrect">
		<xsl:param name="correct" />
		<xsl:param name="wrong" />
		<xsl:param name="missed" />
		<xsl:choose>
			<xsl:when test="$correct != ''"><xsl:value-of select="$correct"/>-<xsl:value-of select="$wrong"/>-<xsl:value-of select="$missed"/></xsl:when>
			<xsl:otherwise>---</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- getSummaryExercisesCompleted calculates the total exercises completed in this report -->
	<xsl:template name="getSummaryExercisesCompleted">
		<xsl:choose>
			<xsl:when test="report/row/@complete">
				<xsl:value-of select="sum(report/row/@complete)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="count(report/row)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- getSummaryAverageScore calculates the average score for this report -->
	<!-- This is not the right way to calculate averages, you have to look at each row to get average*complete -->
	<!-- <xsl:value-of select="round(sum(report/row[@average_score >= 0]/@average_score) div count(report/row[@average_score >= 0]))"/> -->
	<!-- 	<xsl:value-of select="round(sum($myTotal/weightedAverage/item) div sum(report/row/@complete))" />  -->
	<!-- This looks to see if the report has an average score column or a score column. 
		If it is an average score, then we get a recordset for everything that has an average>0 and build a new average * complete.
		We then use this new recordset to do the final average. -->
	<xsl:template name="getSummaryAverageScore">
		<xsl:choose>
			<xsl:when test="report/row/@score">
				<xsl:value-of select="round(sum(report/row[@score != '']/@score) div count(report/row[@score != '']))"/>
			</xsl:when>
			<xsl:when test="report/row/@average_score">
			    <xsl:variable name="wA">
					<weightedAverage>
						<xsl:for-each select="report/row[@average_score >= 0]">
							<item1>
								<xsl:value-of select="@average_score * @complete"/>
							</item1>
							<item2>
								<xsl:value-of select="@complete"/>
							</item2>
						</xsl:for-each>
						<!-- gh#905 Stop division by zero -->
                        <xsl:for-each select="report/row[@average_score = '']">
                            <item1>
                                <xsl:value-of select="0"/>
                            </item1>
                            <item2>
                                <xsl:value-of select="1"/>
                            </item2>
                        </xsl:for-each>
					</weightedAverage>
				</xsl:variable>
				<xsl:variable name="myTotal" select="exslt:node-set($wA)"/>
			    <xsl:value-of select="round(sum($myTotal/weightedAverage/item1) div sum($myTotal/weightedAverage/item2))" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- getSummaryAverageDuration calculates the average duration for this report -->
	<xsl:template name="getSummaryAverageDuration">
		<xsl:choose>
			<xsl:when test="report/row/@duration">
				<xsl:value-of select="php:function('XSLTFunctions::secondsToMinutes', string(sum(report/row/@duration) div count(report/row)))"/>
			</xsl:when>
			<xsl:when test="report/row/@average_time">
			    <xsl:variable name="wA">
					<weightedAverage>
						<xsl:for-each select="report/row">
							<item>
								<xsl:value-of select="@average_time * @complete"/>
							</item>
						</xsl:for-each>
					</weightedAverage>
				</xsl:variable>
				<xsl:variable name="myTotal" select="exslt:node-set($wA)"/>
				<xsl:variable name="myTotalTime" select="round(sum($myTotal/weightedAverage/item) div sum(report/row/@complete))" />
				<xsl:value-of select="php:function('XSLTFunctions::secondsToMinutes', string($myTotalTime))"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- getSummaryTotalTime calculates the average duration for this report -->
	<xsl:template name="getSummaryTotalTime">
		<xsl:choose>
			<xsl:when test="report/row/@duration">
				<xsl:value-of select="php:function('XSLTFunctions::secondsToHours', string(sum(report/row/@duration)))"/>
			</xsl:when>
			<xsl:when test="report/row/@average_time">
				<xsl:value-of select="php:function('XSLTFunctions::secondsToHours', string(sum(report/row/@total_time)))"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- gh#1450
    <xsl:template name="generateCourseNameSelector">
        <xsl:param name="component" />
        <select id="{$component}">
        <xsl:for-each select="bento/head/script/menu/course">
            <option value='<xsl:value-of select="@id"/>'><xsl:value-of select="@caption"/></option>
        </xsl:for-each>
        </select>
    </xsl:template>
    -->

	<!-- generateTable generates an HTML table containing all the results in the XML document -->
	<xsl:template name="generateTable">
		<xsl:param name="tableId" />
		
		<!-- <table id="{$tableId}" style="width:100%;height:100%;" gridWidth="100%"> This badly impacts simple printable tables-->
		<table id="{$tableId}" style="width:100%" gridWidth="100%">
			<tr>
				<xsl:if test="report/row/@titleName"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_title']"/></th></xsl:if>
				<xsl:if test="report/row/@courseName"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_course']"/></th></xsl:if>
				<xsl:if test="report/row/@unitName"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_unit']"/></th></xsl:if>
				<xsl:if test="report/row/@exerciseName"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_exercise']"/></th></xsl:if>
				
				<xsl:if test="report/row/@groupName"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_group']"/></th></xsl:if>
				
				<xsl:if test="report/row/@userName"><th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='report_student']"/></th></xsl:if>
				<xsl:if test="report/row/@studentID"><th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='report_studentID']"/></th></xsl:if>
				<!-- for Science Po -->
				<xsl:if test="report/row/@email"><th type="ro" min-width="200px"><xsl:value-of select="report/language//lit[@name='report_email']"/></th></xsl:if>
				<xsl:if test="report/row/@studentsYear"><th type="ro" min-width="200px">Student's year</th></xsl:if>
				<xsl:if test="report/row/@correspondingFaculty"><th type="ro" min-width="200px">Faculty</th></xsl:if>
				<!-- for Science Po -->
				
				<xsl:if test="report/row/@score"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_score']"/></th></xsl:if>
				<xsl:if test="report/row/@correct"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_score_correct']"/></th></xsl:if>
				<xsl:if test="report/row/@duration"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_duration']"/></th></xsl:if>
				<xsl:if test="report/row/@start_date"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_startTime']"/></th></xsl:if>
				
				<xsl:if test="report/row/@average_score"><th type="ro"><xsl:value-of select="report/language//lit[@name='report_averageScore']"/></th></xsl:if>
				<xsl:if test="report/row/@complete"><th type="ro" width="100px"><xsl:value-of select="report/language//lit[@name='report_complete']"/></th></xsl:if>
				<!--gh#23-->
				<xsl:if test="report/row/@exercise_percentage"><th type="ro" width="100px"><xsl:value-of select="report/language//lit[@name='report_completePercentage']"/></th></xsl:if>
				<xsl:if test="report/row/@exerciseUnit_percentage"><th type="ro" width="100px"><xsl:value-of select="report/language//lit[@name='report_completePercentage']"/></th></xsl:if>
				<xsl:if test="report/row/@unit_percentage"><th type="ro" width="100px"><xsl:value-of select="report/language//lit[@name='report_unitPercentage']"/></th></xsl:if>
				
				<xsl:if test="report/row/@average_time"><th type="ro" width="100px"><xsl:value-of select="report/language//lit[@name='report_averageTime']"/></th></xsl:if>
				<xsl:if test="report/row/@total_time"><th type="ro" width="100px"><xsl:value-of select="report/language//lit[@name='report_totalTime']"/></th></xsl:if>
			</tr>
			<xsl:for-each select="report/row">
				<tr>
					<xsl:if test="@titleName"><td><xsl:value-of select="@titleName"/></td></xsl:if>
					<xsl:if test="@courseName"><td><xsl:value-of select="@courseName"/></td></xsl:if>
					<xsl:if test="@unitName"><td><xsl:value-of select="@unitName"/></td></xsl:if>
					<xsl:if test="@exerciseName"><td><xsl:value-of select="@exerciseName"/></td></xsl:if>
					
					<xsl:if test="@groupName"><td><xsl:value-of select="@groupName"/></td></xsl:if>
					
					<!-- If the full name exists, use that instead of username. But only if you wanted name in the first place. -->
					<xsl:if test="@userName">
						<xsl:choose>
							<xsl:when test="string-length(@fullName)&gt;0" >
								<td><xsl:value-of select="@fullName"/></td>
							</xsl:when>
							<xsl:otherwise>
								<td><xsl:value-of select="@userName"/></td>
							</xsl:otherwise>
						</xsl:choose> 
					</xsl:if>
					
					<xsl:if test="@studentID"><td><xsl:value-of select="@studentID"/></td></xsl:if>
					<!-- for Science Po -->
					<xsl:if test="@email"><td><xsl:value-of select="@email"/></td></xsl:if>
					<xsl:if test="@studentsYear"><td><xsl:value-of select="@studentsYear"/></td></xsl:if>
					<xsl:if test="@correspondingFaculty"><td><xsl:value-of select="@correspondingFaculty"/></td></xsl:if>
					<!-- for Science Po -->
					
					<xsl:if test="@score"><td><xsl:call-template name="formatScore"><xsl:with-param name="score" select="@score" /></xsl:call-template></td></xsl:if>
					<xsl:if test="@correct"><td><xsl:call-template name="formatCorrect"><xsl:with-param name="correct" select="@correct"/>
																						<xsl:with-param name="wrong" select="@wrong" />
																						<xsl:with-param name="missed" select="@missed"/></xsl:call-template></td></xsl:if>
					
					<xsl:if test="@duration"><td><xsl:value-of select="php:function('XSLTFunctions::secondsToMinutes', string(@duration))"/></td></xsl:if>
					<xsl:if test="@start_date"><td><xsl:value-of select="@start_date"/></td></xsl:if>
					
					<xsl:if test="@average_score"><td><xsl:call-template name="formatScore"><xsl:with-param name="score" select="@average_score" /></xsl:call-template></td></xsl:if>
					
					<xsl:if test="@complete"><td><xsl:value-of select="@complete"/></td></xsl:if>
					
					<!--gh#23-->
					<xsl:if test="@exercise_percentage"><td><xsl:call-template name="formatScore"><xsl:with-param name="score" select="@exercise_percentage" /></xsl:call-template></td></xsl:if>
					<xsl:if test="@exerciseUnit_percentage"><td><xsl:call-template name="formatScore"><xsl:with-param name="score" select="@exerciseUnit_percentage"  /></xsl:call-template></td></xsl:if>
					<xsl:if test="@unit_percentage"><td><xsl:call-template name="formatScore"><xsl:with-param name="score" select="@unit_percentage" /></xsl:call-template></td></xsl:if>
					
					<xsl:if test="@average_time"><td><xsl:value-of select="php:function('XSLTFunctions::secondsToMinutes', string(@average_time))"/></td></xsl:if>
					<xsl:if test="@total_time"><td><xsl:value-of select="php:function('XSLTFunctions::secondsToHours', string(@total_time))"/></td></xsl:if>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	
	<!-- Generate a form that, when submitted, recreates the current report but allows a reportTemplate to be specified.  Useful for adding
	     links to the same report but run through a different xsl file (e.g. 'printable' view) -->
	<xsl:template name="generateSubmitableForm">
		<xsl:param name="formId" />
		<xsl:param name="reportTemplate" />
		
		<form id="{$formId}" action="{$scriptName}" method="post" target="_blank">
			<input type="hidden" name="onReportablesIDObjects" value='{$onReportablesIDObjects}' />
			<input type="hidden" name="onClass" value='{$onClass}' />
			<input type="hidden" name="forReportablesIDObjects" value='{$forReportablesIDObjects}' />
			<input type="hidden" name="forClass" value='{$forClass}' />
			<input type="hidden" name="opts" value='{$opts}' />
			<input type="hidden" name="template" value='{$reportTemplate}' />
		</form>
	</xsl:template>
	
</xsl:transform>