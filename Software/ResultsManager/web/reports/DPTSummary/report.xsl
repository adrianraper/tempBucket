<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                			 extension-element-prefixes="php">
    
	<!-- Include various helper templates for use in generating reports - see functions.xsl for details -->
	<xsl:include href="../functions.xsl" />
	
	<xsl:template match="/">
		<html>
			<head>
				<!-- You need this to avoid DOM warning: DOMElement::setAttribute() [domelement.setattribute]: string is not in UTF-8 -->
				<link rel="shortcut icon" href="/Software/RM.ico" type="image/x-icon" />
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<title>Results Manager Generated Report</title>
				
				<link rel="stylesheet" type="text/css" href="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/headerFooter.css" />
				<link rel="stylesheet" type="text/css" href="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/dhtmlxgrid.css" />
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/dhtmlxcommon.js"></script>
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/dhtmlxgrid.js"></script>
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/dhtmlxgridcell.js"></script> 
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_selection.js"></script> 
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_nxml.js"></script> 
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_filter.js"></script> 
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_group.js"></script>
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_start.js"></script>
				
				<script src="../../js/prototype-1.6.0.3.js"></script>
				
				<script>
					var grid;
					var groupIdxCounter = 0;
					
					function onLoaded() {
						
						<xsl:if test="count(report/row) = 0">return</xsl:if>

						grid = dhtmlXGridFromTable("reportTable");
						grid.setImagePath("../../reports/standard/dhtmlx/dhtmlxGrid/codebase/imgs/");
						grid.setSkin("light");
						grid.setInitWidths("*,*,*,*,*,*,*,*,*,*,*,*");
		
						/* Custom sorting function for durations */
						/* Cope with &lt;1 as a time spent 
							This is REALLY difficult as I can't even write the &lt; in a comment let alone match it!
							So use GenerateReport.php.secondsToMinutes to change it to 0.5
						*/
						duration_custom = function(a, b, order) {
							var a = new Number(a.split(":").join("."));
							var b = new Number(b.split(":").join("."));
							
							return (a > b ? 1 : -1) * (order == "asc" ? 1 : -1);
						}
						
						// We want one search box per text field
						var headerString = [];
						var sortTypes = [];
						
						<xsl:if test="report/row/@titleName">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_title']"/>");</xsl:if>
		  				<xsl:if test="report/row/@courseName">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_course']"/>");</xsl:if>
		  				<xsl:if test="report/row/@unitName">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_unit']"/>");</xsl:if>
		  				<xsl:if test="report/row/@exerciseName">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_exercise']"/>");</xsl:if>
						<xsl:if test="report/row/@groupName">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_group']"/>");</xsl:if>
						<xsl:if test="report/row/@userName">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_student']"/>");</xsl:if>
						<xsl:if test="report/row/@studentID">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_studentID']"/>");</xsl:if>
                        // gh#1505
                        <xsl:if test="report/row/@result">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_result']"/>");</xsl:if>

						<xsl:if test="report/row/@score">sortTypes.push("int");</xsl:if>
						<xsl:if test="report/row/@duration">sortTypes.push("duration_custom");</xsl:if>
						<xsl:if test="report/row/@start_date">sortTypes.push("date");</xsl:if>

						// Change average score to be a number not a string
						<xsl:if test="report/row/@average_score">sortTypes.push("int");</xsl:if>
						<xsl:if test="report/row/@complete">sortTypes.push("int");</xsl:if>
						
						//gh#23
						<xsl:if test="report/row/@exercise_percentage">sortTypes.push("int");</xsl:if>
						<xsl:if test="report/row/@exerciseUnit_percentage">sortTypes.push("int");</xsl:if>
						// What is this?
						<xsl:if test="report/row/@unit_percentage">sortTypes.push("duration_custom");</xsl:if>
						
						<xsl:if test="report/row/@average_time">sortTypes.push("duration_custom");</xsl:if>
						<xsl:if test="report/row/@total_time">sortTypes.push("duration_custom");</xsl:if>
						
						grid.attachHeader(headerString.join(","));
						grid.setColSorting(sortTypes.join(","));
						
						grid.enableBlockSelection();
						
						grid.enableCSVAutoID(true);
						grid.enableCSVHeader(true);
						
						//grid.enableAutoWidth(true);
						grid.enableAutoHeight(true);
						
						grid.setSizes();
					}
					
					function addGroupingOptions(text) {
						var elOptNew = document.createElement('option');
						elOptNew.text = text;
						elOptNew.value = groupIdxCounter;
						var elSel = $('groupingSelect');

						try {
							elSel.add(elOptNew, null); // standards compliant; doesn't work in IE
						} catch(ex) {
							elSel.add(elOptNew); // IE only
						}
						
						groupIdxCounter++;
					}
					
					function regroupGrid() {
						var groupBy = $('groupingSelect').value;
						
						if (groupBy != "") {
							grid.groupBy(groupBy);
						} else {
							grid.unGroup();
						}
						
						grid.setSizes();
					}
					
					function showGridView() {
						hideElement('exportDiv');
						showElement('tableDiv');
					}
					
					function showPrintableView() {
						//grid.printView();
						document.getElementById("printForm").submit();
					}
					
					function exportCSV() {
						//grid.setCSVDelimiter(",");
						//exportText();
						document.getElementById("exportForm").submit();
					}
					/*
					function exportTab() {
						grid.setCSVDelimiter("\t");
						// This will not work in Firefox. Can you test for IE?
						msg = "If you are running IE, all the data should now be on your clipboard. Go to Excel and paste into your spreadsheet. ";
						msg += "If you are running another browser, sorry, we are still working on it!"
						alert(msg);
						//if (ie) {
							grid.gridToClipboard();
							// Show a message saying that the clipboard now has all the data, paste it into Excel
						//} else {
						//	exportText();
							// Show a message telling you to select/copy all the text below and paste to Excel
						//}
					}
					
					function exportText() {
						var csvNew = grid.serializeToCSV();
						showElement('exportDiv');
						hideElement('tableDiv');
						$("csvTextInput").value = csvNew;
					}
					*/
					function hideElement(id) {
						// Hide an element with the given id
						$(id).hide();
					}

					function showElement(id) {
						// Show an element with a specified id
						$(id).show();
					}
					
					var moreIdx = 0;
					function truncateText(text, maxLength) {
						maxLength = (maxLength == undefined) ? 250 : maxLength;
						// AR You need to encode this otherwise &quot; stops it appearing. Or do this bit in xsl
						document.write(text.substr(0, maxLength));
						if (text.length > maxLength) {
							document.write("&lt;span id='moreLink_" + moreIdx + "'&gt;... &lt;a href='#' onclick=\"hideElement(\'moreLink_" + moreIdx + "\');showElement(\'moreText_" + moreIdx + "\');\"&gt;more&lt;/a&gt; &lt;/span&gt;");
							document.write("&lt;span id='moreText_" + moreIdx + "'&gt;" + text.substring(maxLength) + "&lt;/span&gt;");
							hideElement("moreText_" + moreIdx);
						}
						
						moreIdx++;
					}
					
	  					/* font: bold 84% 'trebuchet ms', helvetica, sans-serif; */
				</script>
				<style>
					input.btn {
						color: #055A78; 
						font-family: Tahoma, Sans-Serif;
						font-size: 11px;
						font-weight: bold;
	  					background-color: #C9DBDF;
	 					border: 1px solid; 
	 					border-color: #8D8D8D #8D8D8D #8D8D8D #8D8D8D;
						padding-left: 8px;
						padding-top: 4px;
						padding-right: 8px;
						padding-bottom: 4px;
					}
					input.btn:hover {
						border-left: 1px white solid; 
						border-top: 1px white solid; 
						border-right: 1px #055A78 solid; 
						border-bottom: 1px #055A78 solid; 
					}

				</style>
			</head>
			
			<body onLoad="onLoaded();">
				<table width="80%">
				<xsl:if test="count(report/row)>500">
					<tr><td>Warning - this is a big report. If it doesn't display properly, switch to the plain or print view which is much faster.</td></tr>
				</xsl:if>
				<tr valign="top" ><td align="left" width="70%">
				<!-- AR does the truncation cause problem with &quot;? Yes. Applies to @titles and @content too.
				<xsl:value-of select="report/language//lit[@name='report_report']"/>: <script>truncateText("<xsl:value-of select="report/@report"/>");</script><br/> 
				//AR I have changed the names of attributes within opts.headers
				// headers.report has become .onReport
				// headers.content has become .forReportDetail
				// added headers.forReportLabel
				// added headers.titles, headers.courses if needed.
				//
				// removed from below: 
				// <xsl:value-of select="report/language//lit[@name='report_report']"/>
				// <xsl:value-of select="report/language//lit[@name='report_content']"/>
				-->
				<!--
					This is where you format the header. Please make it nice!
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
						<!-- AR this test doesn't work, and it seems to slow things down.
						<xsl:if test="string-length(report/@dateRange) &gt; 0"><xsl:value-of select="report/language//lit[@name='report_dateRange']"/>: <xsl:value-of select="report/@dateRange"/><br/></xsl:if>
						-->
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
				<!-- This is where we could put the summary -->
				<td align="left" valign="top" width="30%">
				<!--
					This is where you format the footer
				-->					
					<table id="headerTable" width="100%">
					<tbody>
					<tr ><td class="headerTableLabels" width="150">
					<xsl:value-of select="report/language//lit[@name='report_testsCompleted']"/>:
					</td>
					<td >
					<xsl:call-template name="getSummaryExercisesCompleted" />
					</td></tr>
					</tbody>
					</table>
					
				</td>
				<td valign="top" align="right">
				</td></tr>
				</table>
				<hr/>
				<!--
					This is where you format the function buttons
				-->					
				<xsl:if test="count(report/row) > 0">
				<!-- drop some buttons
					<input type="button" class="btn" id="showGridViewButton" onClick="showGridView();" /><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
					<input type="button" class="btn" id="showTabViewButton" onClick="exportTab();" /><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
				-->					
					<input type="button" class="btn" id="showCSVViewButton" onClick="exportCSV();" /><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
					<input type="button" class="btn" id="showPrintableViewButton" onClick="showPrintableView();" /><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>										
					<input type="button" class="btn" id="regroupByButton" onClick="regroupGrid();" /><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
					<select id="groupingSelect" style="width:130px;">
						<option value="" />
					</select><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
					<script>
				<!-- drop csv button
						//$("showGridViewButton").value = "<xsl:value-of select="report/language//lit[@name='report_showGridView']"/>";
						//$("showTabViewButton").value = "<xsl:value-of select="report/language//lit[@name='report_showTabView']"/>";
				-->					
						$("showCSVViewButton").value = "<xsl:value-of select="report/language//lit[@name='report_showCSVView']"/>";
						$("showPrintableViewButton").value = "<xsl:value-of select="report/language//lit[@name='report_showPrintableView']"/>";
						$("regroupByButton").value = "<xsl:value-of select="report/language//lit[@name='report_regroupBy']"/>";
					</script>
					
					<hr/>
				</xsl:if>
				
				<xsl:if test="count(report/row) = 0">
					<b><xsl:value-of select="report/language//lit[@name='report_noResults']"/></b>
				</xsl:if>
				
				<div id="exportDiv" style="display:none;">
					<textarea style="width:100%;height:60%;" id="csvTextInput" wrap="off" />
				</div>
				
				<div id="tableDiv">
					<xsl:call-template name="generateTable">
						<xsl:with-param name="tableId">reportTable</xsl:with-param>
					</xsl:call-template>
				</div>
				<!--
				<xsl:for-each select="report/row">
					<xsl:if test="@result">
						<xsl:if test="php:function('dptResultFormatter', string(@result), 'CEF') = '****'">
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
				-->
                <xsl:if test="report/row/@result = '****'">
				    <p>Results marked **** are saved but not enough tests have been purchased to see them.<br/>Use the Test Admin tool to buy some more and these results will be shown.</p>
                </xsl:if>
				<br/>
							
				<xsl:call-template name="generateSubmitableForm">
					<xsl:with-param name="formId">printForm</xsl:with-param>
					<xsl:with-param name="reportTemplate">printable</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="generateSubmitableForm">
					<xsl:with-param name="formId">exportForm</xsl:with-param>
					<xsl:with-param name="reportTemplate">export</xsl:with-param>
				</xsl:call-template>
			</body>
		</html>
	</xsl:template>
</xsl:transform>