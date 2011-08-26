{* Name: Grid_title_report *}
{* Description: Table summary of accounts and their titles *}
<html>
	<head>
		<title>DMS - Grid accounts report</title>
	</head>
	
	<body>
		<table width="800">
			<tr>
				<th width="400">Account and reseller</th>
				<th width="250">Title</th>
				<th width="50">Licence</th>
				<th width="100">Expiry Date</th>
			</tr>
			{foreach from=$accounts item=account}
					<tr>
						<td width="200">{$account->name} 
						{if $account->resellerCode>0}
							- {get_dictionary_label name=resellers data=$account->resellerCode dictionary_source=AccountOps}
						{/if}
						</td>
					</tr>
				{foreach name=titleForEach from=$account->titles item=title}
					<tr>
						<td width="200">&nbsp;</td>
						<td width="150">{$title->name}</td>
						<td width="50">{$title->maxStudents}</td>
						<td width="100">{format_ansi_date ansiDate=$title->expiryDate}</td>
					</tr>
				{/foreach}
			{/foreach}
		</table>
	</body>
</html>