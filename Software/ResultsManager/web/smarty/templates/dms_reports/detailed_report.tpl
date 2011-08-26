{* Name: Detailed_report *}
{* Description: List all details for an account *}
<html>
	<head>
		<title>DMS - Details accounts report</title>
	</head>
	
	<body>
		{foreach from=$accounts item=account}
			<h3>{$account->name}</h3>
			
			<h4>Details:</h4>
			<div style="margin-left:30px;">
			{$copy.idColumn}: {$account->id}<br/>
			{$copy.nameColumn}: {$account->name}<br/>
			{$copy.emailColumn}: {$account->email}<br/>
			{$copy.resellerCodeColumn}: {get_dictionary_label name=resellers data=$account->reseller dictionary_source=AccountOps}<br/>
			{$copy.accountStatusColumn}: {get_dictionary_label name=accountStatus data=$account->accountStatus dictionary_source=AccountOps}<br/>
			{$copy.approvalStatusColumn}: {get_dictionary_label name=approvalStatus data=$account->approvalStatus dictionary_source=AccountOps}<br/>
			{$copy.tacStatusColumn}: {get_dictionary_label name=termsConditions data=$account->tacStatus dictionary_source=AccountOps}<br/>
			Admin user id: {$account->adminUser->id}<br/>
			Admin username: {$account->adminUser->name}<br/>
			Admin password: {$account->adminUser->password}<br/>
			Reference: {$account->reference}<br/>
			Invoice #: {$account->invoiceNumber}<br/>
			Logo: {$account->logo}<br/>
			
			<h4>Titles:</h4>
			
			{foreach from=$account->titles item=title}
				<div style="margin-left:30px;">
					Title: {$title->caption}<br/>
					Expiry date: {format_ansi_date ansiDate=$title->expiryDate}<br/>
					Licence start date: {format_ansi_date ansiDate=$title->licenceStartDate}<br/>
					Max learners: {$title->maxStudents}<br/>
					Max teachers: {$title->maxTeachers}<br/>
					Max authors: {$title->maxAuthors}<br/>
					Max reporters: {$title->maxReporters}<br/>
					Licence type: {get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}<br/>
					Language code: {$title->languageCode}<br/>
					Start page: {$title->startPage}<br/>
					Licence file: {$title->licenceFile}<br/>
					Content location: {$title->contentLocation}<br/>
				</div>
				<hr/>
			{/foreach}
			
			</div>
		{/foreach}
	</body>
</html>