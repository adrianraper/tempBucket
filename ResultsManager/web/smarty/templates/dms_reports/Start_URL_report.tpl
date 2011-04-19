{* Name: Start_URL_report *}
{* Description: List of the URLs to start each RM account *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - links to RM</title>
	</head>
	
	<body>
		<table width="100%">
			<tr>
				<th>Name</th>
				<th>Root</th>
				<th>Prefix</th>
				<th>URL</th>
				<th>RM expiry</th>
			</tr>
			{foreach from=$accounts item=account}
				<tr>
					<td>{$account->name}</td>
					<td>{$account->id}</td>
					<td>{$account->prefix}</td>
					<td><a href='/area1/ResultsManager/Start.php?username={$account->adminUser->name}&password={$account->adminUser->password}' target='_blank'>username={$account->adminUser->name}&password={$account->adminUser->password}</a><td>
					<td>
						{foreach from=$account->titles item=title}
							{if $title->productCode==2} 
								(expires {$title->expiryDate|truncate:10:""})
							{/if}
						{/foreach}
					</td>
				</tr>
			{/foreach}
		</table>
	</body>
</html>