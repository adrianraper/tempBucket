  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td height="10">
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
    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
      <tr>
        <td width="40%" background="http://www.claritylifeskills.com/email/{$thisImage}"><img src="http://www.claritylifeskills.com/email/{$thisImage}" width="221" height="30" alt="{$thisName} package" style="color:#EA8A12; font-weight:bold; font-size:12px;"/></td>
        <td width="60%"><strong>Subscription period: </strong><br/>{$thisTitleStartDate|date_format:"%B %e, %Y"} - {$thisTitleExpiryDate|date_format:"%B %e, %Y"}</td>
      </tr>
      <tr>
        <td height="10" colspan="2"></td>
      </tr>
  
      <tr>
        <td colspan="2">
{* Start table for graphic header *}
        <table width="100%" height="60" border="0" cellpadding="0" cellspacing="0" bgcolor="#EBEBEB" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" >
  <tr>
    <td colspan="2" height="15"></td>
    </tr>
{foreach name=orderDetails from=$account->titles item=title}
	{* is this title in this package? *}
	{if in_array($title->productCode, explode(",", $thisPackageList))}
	  <tr>
		<td width="15"></td>
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
		<td width="305" height="15">{$title->name} {$languageName}</td>
	  </tr>
	{/if}
{/foreach}
 <tr>
    <td colspan="2" height="15"></td>
  </tr>
</table>
{* End table for graphic header *}
	</td>
    </tr>
    </table>
{* End table for package *}
    <!--End of each package-->    
</td>
</tr>
