{* Name: Early warning system *}
{* Description: layout of information for a standard account *}
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
		{assign var='countLicencesUsed' value=$countLicencesUsed+$title->licencesUsed}
		{assign var='countLicences' value=$countLicences+$title->maxStudents}
	{/if}
{/foreach}
<tr>
<td><a href='/area1/ResultsManager/Start.php?username={$account->adminUser->name}&password={$account->adminUser->password}' target='_blank'>{$account->name}</a></td>
<td>{$account->prefix}</td>
<td>{$account->id}</td>
{if $countLicences>0}
	<td>{$countLicencesUsed*100/$countLicences|number_format:0}% ({$countLicencesUsed} of {$countLicences})</td>
{else}
	<td>-</td>
{/if}
{if $countLicencesUsed>0}
	{assign var='satisfaction' value=$account->sessionCounts*5/$countLicencesUsed}
	{if $satisfaction>100} {assign var='satisfaction' value=100} {/if}
	<td>{$satisfaction|number_format:0}% ({$account->sessionCounts})</td>
{else}
	<td>-</td>
{/if}
{* 
	Explanation: 100% usage would be each student who has used up a licence using the program 5 days out of 7
	So this is 20 days in a month (assume that these stats were done for the last 30 days).
	Can't use brackets in the expression so 100/20 = 5
*}
<td>{$account->failedSessionCount}</td>
<td>{$account->expiryDate|truncate:10:""}</td>
</tr>