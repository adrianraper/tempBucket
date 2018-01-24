{if $dateDiff == ''}
	{assign var='dateDiff' value='-1month'}
{/if}
{date_diff assign='expiringDate' date='' period=$dateDiff}
{date_diff assign='oneMonthAgo' date='' period='-1month'}

{assign var='hasR2I' value='false'}
{assign var='hasTBv10' value='false'}
{assign var='hasARv10' value='false'}
{assign var='hasCP1v10' value='false'}
{assign var='hasSSSv11' value='false'}
{foreach name=orderDetails from=$account->titles item=title}
	{if $title->productCode=='52' || $title->productCode=='53'}
		{assign var='hasR2I' value='true'}
	{/if}  
	{if $title->productCode=='55'}
		{assign var='hasTBv10' value='true'}
	{/if}
    {if $title->productCode=='56'}
		{assign var='hasARv10' value='true'}
	{/if} 
    {if $title->productCode=='57'}
		{assign var='hasCP1v10' value='true'}
	{/if}
    {if $title->productCode=='66'}
		{assign var='hasSSSv11' value='true'}
	{/if}
{/foreach}
{foreach name=orderDetails from=$account->titles item=title}

	{if ($title->productCode=='9' && $hasTBv10 == 'true') || ($title->productCode=='33' && $hasARv10 == 'true') || ($title->productCode=='39' && $hasCP1v10 == 'true') || ($title->productCode=='59') ||($title->productCode=='63') || ($title->productCode=='65') || ($title->productCode=='49' && $hasSSSv11 == 'true')}
	{else}
	{if $title->expiryDate|truncate:10:"" >= $oneMonthAgo && !$title->name|stristr:"Practice Centre" && $title->productCode!=12 && $title->productCode!=13}
		{if $expiringDate == $title->expiryDate|truncate:10:""}
			<div style="background:url(http://www.clarityenglish.com/images/email/dot_line.jpg) no-repeat bottom left; padding:5 0 10px 0; margin:0 0 10px 0">
		   	{include file='file:includes/titleTemplateDetails.tpl' method='image' enabled='on'}
			{assign var='enabledColor' value='#000000'}
			{assign var='highlightColor' value='#FFFF00'}
	        <p style="font-family: 'Oxygen', Arial, sans-serif; font-weight:400; font-size: 13px; margin:5px 0 0 0; padding:0; color:{$enabledColor}; line-height:18px;">{$title->name}</p>
			<p style="font-family: 'Oxygen', Arial, sans-serif; font-weight:400; font-size: 13px; margin:0; padding:0; color:{$enabledColor};">
			
			{if $title->licenceType  =='2'}						
				Licence type: Library<br/>	
			{elseif $title->licenceType  =='7'}
				Licence type: Premium<br/>
			{else}
				Licence type: {get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}<br/>
			{/if}
 
			{if in_array($title->productCode, array(3,9,10,33,38,45,46,49,55,56,61,66))}
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
			
			{if $title->name == "Results Manager"} 

			{else}
			
				{if $title->maxStudents >999}	
				Number of concurrent users: unlimited <br/>				
				{else} 
				Number of concurrent users: {$title->maxStudents}<br/>
				{/if}
				
			{/if}
			Hosted by: Clarity<br/>
			Start date: {format_ansi_date ansiDate=$title->licenceStartDate}<br/>
			<a style="background-color:{$highlightColor}">Expiry date: {format_ansi_date ansiDate=$title->expiryDate}</a><br/>
			</div>
		{/if}
	{/if}
	{/if}
{/foreach}
{foreach name=orderDetails from=$account->titles item=title}
	{if ($title->productCode=='9' && $hasTBv10 == 'true') || ($title->productCode=='33' && $hasARv10 == 'true') || ($title->productCode=='39' && $hasCP1v10 == 'true') || ($title->productCode=='59') ||($title->productCode=='63') || ($title->productCode=='65') || ($title->productCode=='49' && $hasSSSv11 == 'true')}
	{else}
	{if $title->expiryDate|truncate:10:"" >= $oneMonthAgo && !$title->name|stristr:"Practice Centre" && $title->productCode!=12 && $title->productCode!=13}
		{if $expiringDate != $title->expiryDate|truncate:10:""}
			<div style="background:url(http://www.clarityenglish.com/images/email/dot_line.jpg) no-repeat bottom left; padding:5 0 10px 0; margin:0 0 10px 0">
		 	{include file='file:includes/titleTemplateDetails.tpl' method='image' enabled='on'}
			{assign var='enabledColor' value='#000000'}
			{assign var='highlightColor' value='#FFFFFF'}
	        <p style="font-family: 'Oxygen', Arial, sans-serif; font-weight:400; font-size: 13px; margin:5px 0 0 0; padding:0; color:{$enabledColor}; line-height:18px;">{$title->name}</p>
			<p style="font-family: 'Oxygen', Arial, sans-serif; font-weight:400; font-size: 13px; margin:0; padding:0; color:{$enabledColor};">
		{if $title->licenceType  =='2'}						
			Licence type: Library   <br/>	
		{elseif $title->licenceType  =='7'}
			Licence type: Premium<br/>
		{else}
			Licence type: {get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}<br/>
		{/if}
 
			{if in_array($title->productCode, array(3,9,10,33,38,45,46,49,55,56,61,66))}
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
			
			{if $title->name == "Results Manager"} 
			{else}
				{if $title->maxStudents >=999}	
				Number of concurrent users: unlimited <br/>				
				{else} 
				Number of concurrent users: {$title->maxStudents}<br/>
				{/if}
			{/if}
			Hosted by: Clarity<br/>
			Start date: {format_ansi_date ansiDate=$title->licenceStartDate}<br/>
			<a style="background-color:{$highlightColor}">Expiry date: {format_ansi_date ansiDate=$title->expiryDate}</a><br/>
			</div>
		{/if}
	{/if}
	{/if}
{/foreach}