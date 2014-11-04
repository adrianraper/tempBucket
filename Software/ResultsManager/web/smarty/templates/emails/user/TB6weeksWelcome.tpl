{* Name: TB6weeks welcome *}
{* Description: Email sent to subscriber to TB6weeks *}
{* Parameters: $user, $ClarityLevel, $programLink, $dateDiff *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>TB6weeks - Your new subscription</title>
	<!-- <from>support@clarityenglish.com</from> -->
	<!-- <bcc>adrian@clarityenglish.com</bcc> -->
</head>
{* sadly this can't go in an include as var assignment is lost in the main *}
{* the unit names could go in an array, which would make later code less clumsy *}
{if $level == 'ELE'}
	{assign var='levelDescription' value='Elementary'}
	{assign var='unit1' value='Am, is, are (to be)'}
	{assign var='unit2' value='Simple present'}
	{assign var='unit3' value='Negatives (I don’t go)'}
	{assign var='unit4' value='Countable'}
	{assign var='unit5' value='I, my, me'}
	{assign var='unit6' value='Questions (does he?)'}
{/if}
{if $level == 'LI'}
	{assign var='levelDescription' value='Lower Intermediate'}
	{assign var='unit1' value='Simple present'}
	{assign var='unit2' value='Simple past'}
	{assign var='unit3' value='Present perfect'}
	{assign var='unit4' value='Comparisons'}
	{assign var='unit5' value='Present continuous'}
	{assign var='unit6' value='Prepositions'}
{/if}
{if $level == 'INT'}
	{assign var='levelDescription' value='Intermediate'}
	{assign var='unit1' value='The passive'}
	{assign var='unit2' value='"Will" and "going to"'}
	{assign var='unit3' value='Question tags'}
	{assign var='unit4' value='Equality'}
	{assign var='unit5' value='Relative clauses'}
	{assign var='unit6' value='Conditionals'}
{/if}
{if $level == 'UI'}
	{assign var='levelDescription' value='Upper Intermediate'}
	{assign var='unit1' value='Past continuous'}
	{assign var='unit2' value='Conditionals'}
	{assign var='unit3' value='Adjectives and adverbs'}
	{assign var='unit4' value='Present perfect'}
	{assign var='unit5' value='Modals verbs'}
	{assign var='unit6' value='The future'}
{/if}
{if $level == 'ADV'}
	{assign var='levelDescription' value='Advanced'}
	{assign var='unit1' value='Reported speech'}
	{assign var='unit2' value='Phrasal verbs'}
	{assign var='unit3' value='Nouns'}
	{assign var='unit4' value='Past perfect'}
	{assign var='unit5' value='The passive'}
	{assign var='unit6' value='Articles'}
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
<p>Week 1 (starts today) {$unit1}</p>
{math equation='x * y' x=1 y=$dateIntValue assign='weekMultiplier'}
{assign var='dateInterval' value="`$weekMultiplier` `$dateIntUnit`"}
<p>Week 2 (starts {$dateInterval|strtotime|date_format:'%Y-%m-%d'}) {$unit2}</p>
{math equation='x * y' x=2 y=$dateIntValue assign='weekMultiplier'}
{assign var='dateInterval' value="`$weekMultiplier` `$dateIntUnit`"}
<p>Week 3 (starts {$dateInterval|strtotime|date_format:'%Y-%m-%d'}) {$unit3}</p>
{math equation='x * y' x=3 y=$dateIntValue assign='weekMultiplier'}
{assign var='dateInterval' value="`$weekMultiplier` `$dateIntUnit`"}
<p>Week 4 (starts {$dateInterval|strtotime|date_format:'%Y-%m-%d'}) {$unit4}</p>
{math equation='x * y' x=4 y=$dateIntValue assign='weekMultiplier'}
{assign var='dateInterval' value="`$weekMultiplier` `$dateIntUnit`"}
<p>Week 5 (starts {$dateInterval|strtotime|date_format:'%Y-%m-%d'}) {$unit5}</p>
{math equation='x * y' x=5 y=$dateIntValue assign='weekMultiplier'}
{assign var='dateInterval' value="`$weekMultiplier` `$dateIntUnit`"}
<p>Week 6 (starts {$dateInterval|strtotime|date_format:'%Y-%m-%d'}) {$unit6}</p>

<a href="{$programLink}">Start Week 1 now</a>

<p>Or up your Tense Buster by logging in to Tense Buster through your library as <strong>{$user->email}</strong></p>
<p><strong>Password: </strong>{$user->password}</p>

<p>Or you can use the app - download from Apple AppStore or Google Play.</p>

<p>Enjoy your practice</p>
<p>Best Wishes</p>
<p>Clarity English</p>

<p>Want to change your level? <a href="/TB6weeks/changeLevel.html?email={$user->email}">Click here.</a></p>
<p><a href="/TB6weeks/unsubscribe.html?email={$user->email}</a>}">Unsubscribe.</a></p>

[footer: Clarity contact details]             
</body>
</html>
