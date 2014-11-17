{* Name: TB6weeks welcome *}
{* Description: Email sent to subscriber to TB6weeks *}
{* Parameters: $user, $ClarityLevel, $programLink, $dateDiff, $server *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>TB6weeks - Your new subscription</title>
	<!-- <from>support@clarityenglish.com</from> -->
	<!-- <bcc>adrian@clarityenglish.com</bcc> -->
</head>
{if $server == ''}{assign var='server' value='dock.projectbench'}{/if}

{* sadly this can't go in an include as var assignment is lost in the main EVEN if you do scope=parent*}
{if $level == 'ELE'}
	{assign var='levelDescription' value='Elementary'}
	{assign var='unitNames' value=';'|explode:"Am, is, are (to be);Simple present;Negatives (I don't go);Countable;I, my, me;Questions (does he?)"}
{/if}
{if $level == 'LI'}
	{assign var='levelDescription' value='Lower Intermediate'}
	{assign var='unitNames' value=';'|explode:"Simple present;Simple past;Present perfect;Comparisons;Present continuous;Prepositions"}
{/if}
{if $level == 'INT'}
	{assign var='levelDescription' value='Intermediate'}
	{assign var='unitNames' value=';'|explode:'The passive;"Will" and "going to";Question tags;Equality;Relative clauses;Conditionals'}
{/if}
{if $level == 'UI'}
	{assign var='levelDescription' value='Upper Intermediate'}
	{assign var='unitNames' value=';'|explode:'Past continuous;Conditionals;Adjectives and adverbs;Present perfect;Modals verbs;The future'}
{/if}
{if $level == 'ADV'}
	{assign var='levelDescription' value='Advanced'}
	{assign var='unitNames' value=';'|explode:'Reported speech;Phrasal verbs;Nouns;Past perfect;The passive;Articles'}
{/if}

{* expect date diff to be like '7 days' *}
{if $dateDiff == ''}
	{assign var='dateDiff' value='7 days'}
{/if}
{* split the date interval into value and unit *}
{assign var='dateIntValue' value=$dateDiff|string_format:"%d"}
{assign var='dateIntTemp' value=" "|explode:$dateDiff}
{assign var='dateIntUnit' value=$dateIntTemp[1]}

<body style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; background-color:#E5E5E5;">
<p>Welcome to TB6weeks</p>
<p>Dear {$user->name}</p>
<p>Your English level is {$levelDescription}</p>

<p>Here are your 6 grammar units</p>
{foreach from=$unitNames name=unit item=unitName}
{math equation='x * y' x=$smarty.foreach.unit.iteration-1 y=$dateIntValue assign='weekMultiplier'}
{assign var='dateInterval' value="`$weekMultiplier` `$dateIntUnit`"}
<p>Week {$smarty.foreach.unit.iteration} (starts {if $smarty.foreach.unit.iteration==1}today{else}{$dateInterval|strtotime|date_format:'%Y-%m-%d'}{/if}) {$unitName}</p>
{/foreach}
<a href="{$programLink}">Start Week 1 now</a>

<p>Or up your Tense Buster by logging in to Tense Buster through your library as <strong>{$user->email}</strong></p>
<p>Password: <strong>{$user->password}</strong></p>

<p>Or you can use the app - download from Apple AppStore or Google Play.</p>

<p>Enjoy your practice</p>
<p>Best Wishes</p>
<p>Clarity English</p>

<p>Want to change your level? <a href="http://{$server}/TB6weeks/changeLevel.html?email={$user->email}">Click here.</a></p>
<p><a href="http://{$server}/TB6weeks/unsubscribe.html?email={$user->email}</a>">Unsubscribe.</a></p>

[footer: Clarity contact details]             
</body>
</html>
