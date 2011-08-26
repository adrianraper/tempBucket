{* Name: Early warning system *}
{* Description: layout of information for a new account *}
<div class='account'>
	<div class='institution'>
		<a href='/area1/ResultsManager/Start.php?username={$account->adminUser->name}&password={$account->adminUser->password}' target='_blank'>{$account->name}</a>, prefix={$account->prefix}, root={$account->id},
		started on {$account->startDate|truncate:10:""}, Learners={$account->userCounts[0]}, Teachers={$account->userCounts[1]}, Reporters={$account->userCounts[4]}
	</div>
	<table class="tablesorter">
	<thead>
		<tr>
			<th>Title</th>
			<th>Licence</th>
			<th>Licences used</th>
			<th>Sessions</th>
			<th>Expiry date</th>
		</tr>
	</thead>
	<tbody>
	{foreach name=titleForEach from=$account->titles item=title}
	<div class='title'>
		{if $title->productCode!=2}
			<tr>
			<td>{$title->name}</td>
			<td>{$title->maxStudents}-{get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}</td>
			<td>{$title->licencesUsed*100/$title->maxStudents|number_format:0}% ({$title->licencesUsed})</td>
			<td>{$title->sessionCounts}</td>
			<td>{$title->expiryDate|truncate:10:""}</td>
			</tr>
		{/if}
	</div>
	{/foreach}
	</tbody>
	</table>
</div>