{* DMS log report *}
<html>
	<head>
		<title>DMS - Log report</title>
		
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
		
		{literal}
		<script>
			var grid;
			
			function onLoaded() {
				grid = dhtmlXGridFromTable("logTable");
				grid.setImagePath("../../reports/standard/dhtmlx/dhtmlxGrid/codebase/imgs/");
				grid.setSkin("light");
				//grid.setInitWidths("*,*,*,*");
				
				grid.attachHeader("#text_filter,#text_filter,#text_filter");
				grid.setColSorting("str,str,str,date");
				
				grid.enableBlockSelection();
				
				grid.enableCSVAutoID(true);
				grid.enableCSVHeader(true);
				
				//grid.enableAutoWidth(true);
				grid.enableAutoHeight(true);
						
				grid.setSizes();
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
		{/literal}
	</head>
	
	<body onLoad="onLoaded()">
		<input type="button" class="btn" id="regroupByButton" onClick="regroupGrid();" value="{$copy.report_regroupBy}"/>&nbsp;
		<select id="groupingSelect" style="width:130px;">
			<option value=""></option>
			<option value="0">{$copy.logUsername}</option>
			<option value="1">{$copy.logProduct}</option>
			<option value="3">{$copy.logDate}</option>
		</select>
		
		<div id="fromDate"></div>
		<div id="toDate"></div>
		
		<table id="logTable" width="100%">
		<tbody>
			<tr valign="top">
				<th>{$copy.logUsername}</th>
				<th>{$copy.logProduct}</th>
				<th>{$copy.logMessage}</th>
				<th>{$copy.logDate}</th>
			</tr>
			{foreach from=$logs item=log}
				<tr>
					<td>{$log.F_UserName}</td>
					<td>{$log.F_ProductName}</td>
					<td>{$log.F_Message}</td>
					<td>{format_ansi_date ansiDate=$log.F_Date format='%Y-%m-%d %H:%M'}</td>
				</tr>
			{/foreach}
		</tbody>
		</table>
		
	</body>
</html>