{* Name: Early warning system *}
{* Description: layout of information for an account that is mixed or individual *}
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
<tr>
<td><a href='/area1/ResultsManager/Start.php?username={$account->adminUser->name}&password={$account->adminUser->password}' target='_blank'>{$account->name}</a></td>
<td>{$account->prefix}</td>
<td>{$account->id}</td>
<td>-</td>
<td>{$account->sessionCounts}</td>
<td>{$account->failedSessionCount}</td>
<td>{$account->expiryDate|truncate:10:""}</td>
</tr>