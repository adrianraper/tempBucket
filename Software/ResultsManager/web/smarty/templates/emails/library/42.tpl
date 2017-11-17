{assign var='dateDiff' value='-14days'}
{include file="file:includes/expiringTitles.tpl" assign=useWording}
{assign var='useWording' value=$useWording|strip:''}
{if $expiryDate == ''}
	{date_diff assign='expiryDate' date='' period=$dateDiff}
{/if}
{assign var="quotationFile" value="`$template_dir`quotations/`$account->prefix`_`$expiryDate`_quotation.pdf"}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
{if $useWording == 'all'}
	<title>ClarityEnglish - Expired account</title>
{elseif $useWording == 'one'}
	<title>ClarityEnglish - One program in your account has expired</title>
{elseif $useWording == 'couple'}
	<title>ClarityEnglish - Two programs in your account have expired</title>
{else}
	<title>ClarityEnglish - Some programs in your account have expired</title>
{/if}
	<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
	<!-- <bcc>admin@clarityenglish.com</bcc> -->
    	       <style type="text/css">
    		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
			</style>
	{if ($quotationFile|file_exists)}
		<!-- <attachment>{$quotationFile}</attachment> -->
	{/if}
</head>
<body text="#000000" style="margin:0; padding:0;">
<div style="width:600px; margin:0 auto; padding:0;">
      <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="ClarityEnglish - expired account" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Librarian</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">ClarityEnglish Subscription: {$account->name}</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">This email is to remind you that 
{if $useWording == 'all'}
	your ClarityEnglish subscription 
{elseif $useWording == 'one'}
	one program in your ClarityEnglish subscription 
{elseif $useWording == 'couple'}
	two programs in your ClarityEnglish subscription 
{else}	
	some programs in your ClarityEnglish subscription 
{/if}
	ended two weeks ago. We haven't yet received a renewal note from you, so your learners no longer have access to the programs.</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">If you'd like to renew, just send us a quick email and we can have your subscription up and running within one working day. 
		
		{if ($session)}
			If you would like to check your usage statistics, click <a href="http://www.ClarityEnglish.com/area1/ResultsManager/directUsageStats.php?session={$session}" target='_blank'>here</a></span>.
		{/if}
	</p>
	

    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">If for any reason you have decided not to renew, I'd be really grateful if you could drop us a quick line saying why we haven't lived up to your expectations. This will help us to improve our products and service for you next time.</p>

<!--
-- If we have created a quote, then attach it - or link to it
-->
	{include file="file:includes/quotationDetails.tpl"}	
<!-- 
-- Resellers' contact details - if any
-->
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
<!-- 
-- Email signature 
-->
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">We look forward to hearing from you.</p>

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