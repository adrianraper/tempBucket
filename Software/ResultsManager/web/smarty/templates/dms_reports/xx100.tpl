{* Name: Early warning system *}
{* Description: Table summary of accounts, titles and usage *}
<html>
	<head>
		<title>DMS - Grid accounts report</title>
	</head>
	
	<body>
		<table width="900">
			<tr>
				<th width="300" align="left">Account</th>
				<th width="300" align="left">Title</th>
				<th width="200" align="left">Licence</th>
				<th width="50" align="left">Used</th>
				<th width="50" align="left">Expiry</th>
			</tr>
			{foreach from=$accounts item=account}
					<tr>
						<td>
						<a href='/area1/ResultsManager/Start.php?username={$account->adminUser->name}&password={$account->adminUser->password}' target='_blank'>{$account->name}</a>, prefix={$account->prefix}, root={$account->id}
						</td>
					</tr>
				{* And a detail for users *}
				{if $account->templateDetail=="1newAccount"}
					{include file='file:dms_reports/newAccount.tpl'}
				{elseif $account->templateDetail=="99standardAccount"}
					{include file='file:dms_reports/standardAccount.tpl'}
				{/if}
			{/foreach}
		</table>
	</body>
</html>