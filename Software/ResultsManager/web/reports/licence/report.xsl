<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                			 extension-element-prefixes="php">
    
    <xsl:output method="html"/>
    
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
						<xsl:if test="report/row/@userName">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_student']"/>");</xsl:if>
                        <xsl:if test="report/row/@licences">headerString.push("#text_filter");sortTypes.push("str");addGroupingOptions("<xsl:value-of select="report/language//lit[@name='report_licences']"/>");</xsl:if>
						
						<xsl:if test="report/row/@score">sortTypes.push("int");</xsl:if>
						<xsl:if test="report/row/@duration">sortTypes.push("duration_custom");</xsl:if>
						<xsl:if test="report/row/@start_date">sortTypes.push("date");</xsl:if>
						
						// Change average score to be a number not a string
						<xsl:if test="report/row/@average_score">sortTypes.push("int");</xsl:if>
						<xsl:if test="report/row/@licences">sortTypes.push("int");</xsl:if>
						
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
				<tr valign="top" ><td align="left" width="70%">
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
						<tr><td class="headerTableLabels" >
						<xsl:value-of select="report/language//lit[@name='report_attempts']"/>:	
						</td>
						<td >
						<xsl:value-of select="report/@attempts"/>
						</td></tr>
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

				</td>
				<td valign="top" align="right">
				</td></tr>
				</table>
				<hr/>
				<!--
					This is where you format the funtion buttons
				-->					
				<xsl:if test="count(report/row) = 0">
					<b><xsl:value-of select="report/language//lit[@name='report_noResults']"/></b>
				</xsl:if>
				
				<div id="tableDiv">
					<xsl:call-template name="generateTable">
						<xsl:with-param name="tableId">reportTable</xsl:with-param>
					</xsl:call-template>
				</div>
				
				<br/>
							
			</body>
		</html>
	</xsl:template>
</xsl:transform>