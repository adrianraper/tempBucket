
{assign var='dateDiff' value='+14days'}
{include file="file:includes/expiringTitles.tpl" assign=useWording}
{assign var='useWording' value=$useWording|strip:''}
{if $expiryDate == ''}
	{date_diff assign='expiryDate' date='' period=$dateDiff}
{/if}
{assign var="quotationFile" value="`$template_dir`quotations/`$account->prefix`_`$expiryDate`_quotation.pdf"}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>ClarityEnglish - Subscription reminder, 14 days left</title>
	<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
	<!-- <bcc>admin@clarityenglish.com</bcc> -->
	{if ($quotationFile|file_exists)}
		<!-- <attachment>{$quotationFile}</attachment> -->
	{/if}
    	<style type="text/css">
  	    	@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
		</style>
</head>
<body text="#000000" style="margin:0; padding:0;">
<div style="width:600px; margin:0 auto; padding:0;">
      <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="ClarityEnglish - subscription reminder, 14 days left" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Librarian</p>
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745; font-weight:700;">ClarityEnglish Subscription: {$account->name}</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">This is a quick reminder that your subscription 
{if $useWording == 'all'}
	for the programs below 
{elseif $useWording == 'one'}
	for one of the programs below 
{elseif $useWording == 'couple'}
	for two of the programs below 
{else}
	for some of the programs below 
{/if}
	will end in just 14 days. I hope that you have found these Clarity resources useful and enjoyable over the last year, and that you will renew your subscription. If you would like to do this, please send a quick email to your Account Manager and we'll arrange for your account to be updated.
		
		{if ($session)}
			If you would like to check your usage statistics, click <a href="http://www.ClarityEnglish.com/area1/ResultsManager/directUsageStats.php?session={$session}" target='_blank'>here</a></span>.
		{/if}
	</p>
<!-- 
-- Resellers' contact details - if any
-->
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
<!--
-- If we have created a quote, then attach it - or link to it
-->
	{include file="file:includes/quotationDetails.tpl"}

<!-- 
-- Email signature 
-->
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">We're looking forward to hearing from you.</p>

<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
	{include file='file:includes/Spacer_Before_Title_Details.tpl'}
	{include file='file:includes/Title_Details_Section_Library.tpl' dateDiff=$dateDiff useWording=$useWording}

     <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
   
    </p>
	{include file='file:includes/SalesManager_Email_Signature.tpl'}	
<!-- 
-- Email footer
-->
	{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>
</div>
</body>
</html>
