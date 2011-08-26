{* Name: Early warning system *}
{* Description: Table summary of accounts, titles and usage *}
<!DOCTYPE html>
<html>
<head>
<link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
<script src="/Software/ResultsManager/web/smarty/templates/css/jquery.tablesorter.js"></script>
<link href="/Software/ResultsManager/web/smarty/templates/css/themes/blue/style.css" rel="stylesheet" type="text/css" id="" media="print, projection, screen" />
<link href="/Software/ResultsManager/web/smarty/templates/css/EWS.css" rel="stylesheet" type="text/css"/>

<style>
{literal}
body {font-size: 11px;}
{/literal}
</style>

<script>
{* use jQuery accordion - note that you need to use smarty literals to stop smarty parsing the jQuery $ directive *}
{* One problem with accordion is that each segment is the same height, even if it only contains a few items. Tabs are much neater. *}
{literal}
	$(document).ready(function() {
		$("#myTable").tablesorter();
	});
{/literal}
</script>
</head>
<body>
		{* Build this data into a table that you can sort *}
		<table id="myTable" class="tablesorter">
		<thead>
			<tr>
				<th>Institution</th>
				<th>Prefix</th>
				<th>Root</th>
				<th>Expiry date</th>
			</tr>
		</thead>
		<tbody>
		{foreach from=$accounts item=account}
			{if $account->templateDetail=="99standardAccount"}
				{include file='file:dms_reports/standardAccount-101.tpl'}
			{/if}
		{/foreach}
		</tbody>
		</table>
</body>