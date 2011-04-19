{* Name: Early warning system *}
{* Description: layout of information for an account that has failed sessions *}
<div class='account'>
<div class='titleDetails'>
	<a href='/area1/ResultsManager/Start.php?username={$account->adminUser->name}&password={$account->adminUser->password}' target='_blank'>{$account->name}</a>, 
	prefix={$account->prefix}, root={$account->id}, failures={$account->failedSessionCount}
</div>
<div class='expiryDate'>
	{$account->expiryDate|truncate:10:""}
</div>
</div>