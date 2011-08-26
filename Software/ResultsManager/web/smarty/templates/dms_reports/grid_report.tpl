{* Name: Grid_report *}
{* Description: Table summary of accounts *}
<html>
	<head>
		<title>DMS - Grid accounts report</title>
	</head>
	
	<body>
		<table width="100%">
			<tr>
				<th>{$copy.nameColumn}</th>
				<th>{$copy.idColumn}</th>
				<th>{$copy.emailColumn}</th>
				<th>{$copy.resellerCodeColumn}</th>
				<th>{$copy.accountStatusColumn}</th>
				<th>{$copy.approvalStatusColumn}</th>
				<th>{$copy.tacStatusColumn}</th>
			</tr>
			{foreach from=$accounts item=account}
				<tr>
					<td>{$account->name}</td>
					<td>{$account->id}</td>
					<td>{$account->email}</td>
					<td>{get_dictionary_label name=resellers data=$account->reseller dictionary_source=AccountOps}</td>
					<td>{get_dictionary_label name=accountStatus data=$account->accountStatus dictionary_source=AccountOps}</td>
					<td>{get_dictionary_label name=approvalStatus data=$account->approvalStatus dictionary_source=AccountOps}</td>
					<td>{get_dictionary_label name=termsConditions data=$account->tacStatus dictionary_source=AccountOps}</td>
				</tr>
			{/foreach}
		</table>
	</body>
</html>