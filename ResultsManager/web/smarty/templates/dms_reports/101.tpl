{* Name: Early warning system *}
{* Description: Table summary of accounts, titles and usage *}
<!DOCTYPE html>
<html>
<head>
<link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
<script src="/Software/ResultsManager/web/smarty/templates/css/jquery.tablesorter.min.js"></script>
<link href="/Software/ResultsManager/web/smarty/templates/css/themes/blue/style.css" rel="stylesheet" type="text/css" id="" media="print, projection, screen" />
<link href="/Software/ResultsManager/web/smarty/templates/css/EWS.css" rel="stylesheet" type="text/css"/>

<style>
{literal}
h3 {font-size: large; color: blue;} /* must be overridden by accordion */
div.account {padding: 10px; border:1px solid gray; 
			}
div.institution {margin: 0 0 10px; font-weight: bold; font-size:12px;}
div.title {margin:0 20px 0 20px; border-bottom:1px solid purple; clear: both;}
div.expiryDate {font-style: italic; text-align: right; }
div.titleDetails {float: left;}
{/literal}
</style>

<script>
{* use jQuery accordion - note that you need to use smarty literals to stop smarty parsing the jQuery $ directive *}
{* One problem with accordion is that each segment is the same height, even if it only contains a few items. Tabs are much neater. *}
{literal}
	$(document).ready(function() {
		$("#tabs").tabs({selected:0});
		$("#fragment-3-table").tablesorter({sortList: [[3,0]]});
		$("#fragment-4-table").tablesorter({sortList: [[3,0]]});
		$("#fragment-5-table").tablesorter({sortList: [[3,0]]});
		$("#fragment-6-table").tablesorter({sortList: [[3,0]]});
	});
{/literal}
</script>
</head>
<body>
<div id="tabs">
<ul>
	<li><a href="#fragment-1"><span>New accounts</span></a></li>
	<li><a href="#fragment-2"><span>Licence too full</span></a></li>
	<li><a href="#fragment-3"><span>Learner Tracking</span></a></li>
	<li><a href="#fragment-4"><span>Anonymous Access</span></a></li>
	<li><a href="#fragment-5"><span>Concurrent Tracking</span></a></li>
	<li><a href="#fragment-6"><span>Other</span></a></li>
</ul>
    <div id="fragment-1">
		{foreach from=$accounts item=account}
			{*if $account->templateDetail=="99standardAccount" -- use this line for debugging to get more info on each account to check summaries *}
			{if $account->templateDetail=="1newAccount"}
				{include file='file:ews_reports/newAccount-101.tpl'}
			{/if}
		{/foreach}
		</tbody>
	</div>
    <div id="fragment-2">
		{* seems better listed in standard reports *}
		{* 
			{foreach from=$accounts item=account}
			{if $account->templateDetail=="50failedSessionsAccount"}
				{include file='file:ews_reports/failedSessionsAccount-101.tpl'}
			{/if}
		{/foreach}
		*}
		Not currently active
	</div>
    <div id="fragment-3">
		{* Build this data into a table that you can sort *}
		<table id="fragment-3-table" class="tablesorter">
		<thead>
			<tr>
				<th>Institution</th>
				<th>Prefix</th>
				<th>Root</th>
				<th>Licences used</th>
				<th>Satisfaction*</th>
				<th>Licence full</th>
				<th>Expiry date</th>
			</tr>
		</thead>
		<tbody>
		{foreach from=$accounts item=account}
			{if $account->templateDetail=="90standardLTAccount"}
				{include file='file:ews_reports/standardLTAccount-101.tpl'}
			{/if}
		{/foreach}
		</tbody>
		</table>
		<div class="satisfaction-explanation">
			* Satisfaction:<br/>
			100% satisfaction would be every student who has used a licence, continuing to use that at least once a day (5 days out of 7)
		</div>
	</div>
    <div id="fragment-4">
		<table id="fragment-4-table" class="tablesorter">
		<thead>
			<tr>
				<th>Institution</th>
				<th>Prefix</th>
				<th>Root</th>
				<th>Licences</th>
				<th>Satisfaction*</th>
				<th>Licence full</th>
				<th>Expiry date</th>
			</tr>
		</thead>
		<tbody>
		{foreach from=$accounts item=account}
			{if $account->templateDetail=="91standardAAAccount"}
				{include file='file:ews_reports/standardAAAccount-101.tpl'}
			{/if}
		{/foreach}
		</tbody>
		</table>
		<div class="satisfaction-explanation">
			* Satisfaction:<br/>
			100% usage is each licence being used 10 times a day, 7 days a week
		</div>
	</div>
    <div id="fragment-5">
		{* Build this data into a table that you can sort *}
		<table id="fragment-5-table" class="tablesorter">
		<thead>
			<tr>
				<th>Institution</th>
				<th>Prefix</th>
				<th>Root</th>
				<th>Licences used</th>
				<th>Satisfaction*</th>
				<th>Licence full</th>
				<th>Expiry date</th>
			</tr>
		</thead>
		<tbody>
		{foreach from=$accounts item=account}
			{if $account->templateDetail=="92standardCTAccount"}
				{include file='file:ews_reports/standardCTAccount-101.tpl'}
			{/if}
		{/foreach}
		</tbody>
		</table>
		<div class="satisfaction-explanation">
			* Satisfaction:<br/>
			100% satisfaction would be every student who has used a licence, continuing to use that at least once a day (5 days out of 7)
		</div>
	</div>
    <div id="fragment-6">
		{* Build this data into a table that you can sort *}
		<table id="fragment-6-table" class="tablesorter">
		<thead>
			<tr>
				<th>Institution</th>
				<th>Prefix</th>
				<th>Root</th>
				<th>Licences used*</th>
				<th>Sessions</th>
				<th>Licence full</th>
				<th>Expiry date</th>
			</tr>
		</thead>
		<tbody>
		{foreach from=$accounts item=account}
			{if $account->templateDetail=="99standardAccount"}
				{include file='file:ews_reports/standardAccount-101.tpl'}
			{/if}
		{/foreach}
		</tbody>
		</table>
		<div class="satisfaction-explanation">
			* Licences used:<br/>
			There is no measure of licences used for these accounts as they mix AA and LT licences (or have other licences that don't fit in the report).
		</div>
	</div>
</div>
