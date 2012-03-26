{* Start and end dates are title based, not account based. But assume that for a new subscription they are all the same. 
	But you might have two packages with different expiry dates, so need to get dates from the first title in the package list. *}
{foreach name=orderDetails from=$account->titles item=title}
	{* is this title in this package? *}
	{if in_array($title->productCode, explode(",", $thisPackageList))}
		{assign var='thisTitleStartDate' value=$title->licenceStartDate}
		{assign var='thisTitleExpiryDate' value=$title->expiryDate}
	{/if}
{/foreach}
{* Start table for package *}



<div style="width:490px; padding:0; margin:0 0 5px 0;">
        <div style="width:221px; float:left;"><img src="http://www.claritylifeskills.com/email/{$thisImage}" width="221" height="30" alt="{$thisName} package" style="color:#EA8A12; font-weight:bold; font-size:12px;"/></div>
		<div style="width:269px; float:left;">
        	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;"><strong>Subscription period: </strong><br/>{$thisTitleStartDate|date_format:"%B %e, %Y"} - {$thisTitleExpiryDate|date_format:"%B %e, %Y"}</p>
        </div>
        <div style="clear:both"></div>



	</div>


        
{* Start table for graphic header *}

<div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; color:#000000;">
	{foreach name=orderDetails from=$account->titles item=title}
	{* is this title in this package? *}
	{if in_array($title->productCode, explode(",", $thisPackageList))}
        
        {* The language code should be decoded from the table *}
		{* I have no idea how to get the program description from the name *}
		{* And we would ideally only list the language if there is more than one they could have chosen *}
		{if in_array($title->productCode, array(3,9,10,33,38,45,46,48,49,1001))}
			{if $title->languageCode=='EN'} 
				{assign var='languageName' value='(International English)'}
			{elseif $title->languageCode=='NAMEN'} 
				{assign var='languageName' value='(North American English)'}
			{elseif $title->languageCode=='BREN'} 
				{assign var='languageName' value='(British English)'}
			{elseif $title->languageCode=='INDEN'} 
				{assign var='languageName' value='(Indian English)'}
			{elseif $title->languageCode=='ZHO'} 
				{assign var='languageName' value='(with Chinese instruction)'}
			{else} 
				{assign var='languageName' value=''}
			{/if}
		{else} 
			{assign var='languageName' value=''}
		{/if}
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">{$title->name} {$languageName}</p>
	{/if}
{/foreach}
	</div>
{* End table for graphic header *}
{* End table for package *}
    <!--End of each package-->    
