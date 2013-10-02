{if $dateDiff == ''}
	{assign var='dateDiff' value='-1month'}
{/if}
{date_diff assign='expiringDate' date='' period=$dateDiff}
{date_diff assign='oneMonthAgo' date='' period='-1month'}
{* two loops, first for expiring titles, then for the rest *}
{foreach name=orderDetails from=$account->titles item=title}
	{* Just totally skip IYJ Practice Centre and titles older than one month (unlikely to be any) *}
	{* Ignore Road to IELTS v1 *}
	{if $title->expiryDate|truncate:10:"" >= $oneMonthAgo && !$title->name|stristr:"Practice Centre" && $title->productCode!=12 && $title->productCode!=13}
		{if $expiringDate == $title->expiryDate|truncate:10:""}
			<div style="background:url(http://www.clarityenglish.com/images/email/dot_line.jpg) no-repeat bottom left; padding:5 0 10px 0; margin:0 0 10px 0">
		   	{include file='file:includes/titleTemplateDetails.tpl' method='image' enabled='on'}
			{assign var='enabledColor' value='#000000'}
			{assign var='highlightColor' value='#FFFF00'}
	        <p style="font-family: 'Oxygen', Arial, sans-serif; font-weight:400; font-size: 13px; margin:5px 0 0 0; padding:0; color:{$enabledColor}; line-height:18px;">{$title->name}</p>
			<p style="font-family: 'Oxygen', Arial, sans-serif; font-weight:400; font-size: 13px; margin:0; padding:0; color:{$enabledColor};">
			Licence type: {get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}<br/>
			{if in_array($title->productCode, array(3,9,10,33,38,45,46,49))}
				{if $title->languageCode=='EN'} 
					{assign var='languageName' value='International English'}
				{elseif $title->languageCode=='NAMEN'} 
					{assign var='languageName' value='North American English'}
				{elseif $title->languageCode=='BREN'} 
					{assign var='languageName' value='British English'}
				{elseif $title->languageCode=='INDEN'} 
					{assign var='languageName' value='Indian English'}
				{elseif $title->languageCode=='AUSEN'} 
					{assign var='languageName' value='Australian English'}
				{elseif $title->languageCode=='ZHO'} 
					{assign var='languageName' value='with Chinese instruction'}
				{else} 
					{assign var='languageName' value=$title->languageCode}
				{/if}
				Version: {$languageName}<br/>
			{/if}
			{* If it is an AA RM, don't say anything here *}
			{if $title->name == "Results Manager"} 
				{if $title->licenceType == 1}
					Number of teachers: {$title->maxTeachers}<br/>
					Number of reporters: {$title->maxReporters}<br/>
				{/if}
			{else}
				Number of students: {$title->maxStudents}<br/>
			{/if}
			Hosted by: Clarity<br/>
			Start date: {format_ansi_date ansiDate=$title->licenceStartDate}<br/>
			<a style="background-color:{$highlightColor}">Expiry date: {format_ansi_date ansiDate=$title->expiryDate}</a><br/>
			</div>
		{/if}
	{/if}
{/foreach}
{foreach name=orderDetails from=$account->titles item=title}
	{if $title->expiryDate|truncate:10:"" >= $oneMonthAgo && !$title->name|stristr:"Practice Centre" && $title->productCode!=12 && $title->productCode!=13}
		{if $expiringDate != $title->expiryDate|truncate:10:""}
			<div style="background:url(http://www.clarityenglish.com/images/email/dot_line.jpg) no-repeat bottom left; padding:5 0 10px 0; margin:0 0 10px 0">
		 	{include file='file:includes/titleTemplateDetails.tpl' method='image' enabled='on'}
			{assign var='enabledColor' value='#000000'}
			{assign var='highlightColor' value='#FFFFFF'}
	        <p style="font-family: 'Oxygen', Arial, sans-serif; font-weight:400; font-size: 13px; margin:5px 0 0 0; padding:0; color:{$enabledColor}; line-height:18px;">{$title->name}</p>
			<p style="font-family: 'Oxygen', Arial, sans-serif; font-weight:400; font-size: 13px; margin:0; padding:0; color:{$enabledColor};">
			Licence type: {get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}<br/>
			{if in_array($title->productCode, array(3,9,10,33,38,45,46,49))}
				{if $title->languageCode=='EN'} 
					{assign var='languageName' value='International English'}
				{elseif $title->languageCode=='NAMEN'} 
					{assign var='languageName' value='North American English'}
				{elseif $title->languageCode=='BREN'} 
					{assign var='languageName' value='British English'}
				{elseif $title->languageCode=='INDEN'} 
					{assign var='languageName' value='Indian English'}
				{elseif $title->languageCode=='AUSEN'} 
					{assign var='languageName' value='Australian English'}
				{elseif $title->languageCode=='ZHO'} 
					{assign var='languageName' value='with Chinese instruction'}
				{else} 
					{assign var='languageName' value=$title->languageCode}
				{/if}
				Version: {$languageName}<br/>
			{/if}
			{* If it is an AA RM, don't say anything here *}
			{if $title->name == "Results Manager"} 
				{if $title->licenceType == 1}
					Number of teachers: {$title->maxTeachers}<br/>
					Number of reporters: {$title->maxReporters}<br/>
				{/if}
			{else}
				Number of students: {$title->maxStudents}<br/>
			{/if}
			Hosted by: Clarity<br/>
			Start date: {format_ansi_date ansiDate=$title->licenceStartDate}<br/>
			<a style="background-color:{$highlightColor}">Expiry date: {format_ansi_date ansiDate=$title->expiryDate}</a><br/>
			</div>
		{/if}
	{/if}
{/foreach}