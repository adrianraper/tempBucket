{* Name: Early warning system *}
{* Description: layout of information for a standard AA account *}
{*
<div class='account'>
<div class='titleDetails'>
	<a href='/area1/ResultsManager/Start.php?username={$account->adminUser->name}&password={$account->adminUser->password}' target='_blank'>{$account->name}</a>, prefix={$account->prefix}, root={$account->id}
</div>
<div class='expiryDate'>
	{$account->expiryDate|truncate:10:""}
</div>
</div>
*}
{* Version for use with tables *}
{* I want to get an average of the licences used across all the titles *}
{foreach name=titleForEach from=$account->titles item=title}
	{if $title->productCode!=2}
		{assign var='countLicences' value=$countLicences+$title->maxStudents}
	{/if}
{/foreach}
<tr>
<td><a href='/area1/ResultsManager/Start.php?username={$account->adminUser->name}&password={$account->adminUser->password}' target='_blank'>{$account->name}</a></td>
<td>{$account->prefix}</td>
<td>{$account->id}</td>
<td>{$countLicences}</td>
{* 
	Explanation: 100% usage is each licence being used 10 times a day, 7 days a week
	So this is 300 times a month (assume that these stats were done for the last 30 days).
	Can't use brackets in the expression so 100/20 = 5
	How many days between start and expiry?	$account->daysUsed
*}
{if $countLicences>0}
	{assign var='denominator' value=$countLicences*10*$account->daysUsed}
	{assign var='satisfaction' value=$account->sessionCounts*100/$denominator}
	{if $satisfaction>100} {assign var='satisfaction' value=100} {/if}
	<td>{$satisfaction|number_format:0}%</td>

	<td>{$account->sessionCounts}</td>
{else}
	<td>-</td>
	<td>0</td>
{/if}
<td>{$account->failedSessionCount}</td>
<td>{$account->startDate|truncate:10:""}</td>
<td>{$account->expiryDate|truncate:10:""}</td>
</tr>