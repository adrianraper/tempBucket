{* Name: Early warning system *}
{* Description: layout of information for a new account *}
	{foreach name=titleForEach from=$account->titles item=title}
		<tr>
			<td >&nbsp;</td>
			<td >{$title->name}</td>
			{if $title->productCode==2}
				<td colspan="3">Learners={$account->userCounts[0]}, Teachers={$account->userCounts[1]}, Reporters={$account->userCounts[4]}</td>
			{else}
				<td >{$title->maxStudents}-{get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}</td>
				<td >{$title->licencesUsed}</td>
				<td >{$title->expiryDate|truncate:10:""}</td>
			{/if}
		</tr>
	{/foreach}
