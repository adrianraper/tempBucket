{* Name: Expiry in 10 weeks *}
{* Description: Email 14. Expiry in 10 weeks. *}
{* Parameters: $account, $expiryDate, $template_dir *}

{assign var='dateDiff' value='+10weeks'}
{include file="file:includes/expiringTitles.tpl" assign=useWording}
{assign var='useWording' value=$useWording|strip:''}
{if $expiryDate == ''}
	{date_diff assign='expiryDate' date='' period=$dateDiff}
{/if}
{assign var="quotationFile" value="`$template_dir`quotations/`$account->prefix`_`$expiryDate`_quotation.pdf"}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Clarity English - Subscription reminder</title>
	<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
	<!-- <bcc>admin@clarityenglish.com</bcc> -->
		       <style>
    		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
			</style>
    {if ($quotationFile|file_exists)}
		<!-- <attachment>{$quotationFile}</attachment> -->
	{/if}
    
</head>
<body text="#000000" style="margin:0; padding:0;">
<div style="width:600px; margin:0 auto; padding:0;">
              <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Clarity English - Subscription reminder" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif;  line-height:18px; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Clarity English Subscription: {$account->name}</p>

		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">I'm dropping you a quick line because 
{if $useWording == 'all'}
	your Clarity English subscription is coming to an end. The subscription has
{elseif $useWording == 'one'}
	one program in your subscription is coming to an end. The program has
{elseif $useWording == 'couple'}
	two programs in your subscription are coming to an end. The programs have
{else}
	some programs in your subscription are coming to an end. The programs have
{/if}
		 approximately ten weeks to run, and will finish on {$expiryDate|date_format:"%B %e, %Y"}.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">
		I hope you, your colleagues and your learners have found your Clarity programs both useful and enjoyable &ndash; and I hope you are intending to renew. 
		If so, please send a quick email to <a href="mailto:sales@clarityenglish.com?Subject=Account%20renewal">sales@clarityenglish.com</a>, or to me, and we can set the renewal process in motion.
		{* If there is a security string, it means you can do a direct start to usage stats *}
		{if ($session)}
			If you would like to check your usage statistics, click <a href="http://www.ClarityEnglish.com/area1/ResultsManager/directUsageStats.php?session={$session}" target='_blank'>here</a></span>.
		{/if}
		</p>
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
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">As ever, if you have any queries about your subscription, please don't hesitate to get in touch.</p>
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
   Nicole
    </p>
	{include file='file:includes/SalesManager_Email_Signature.tpl'}
<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
	{include file='file:includes/Spacer_Before_Title_Details.tpl'}
	{include file='file:includes/Title_Details_Section.tpl' dateDiff=$dateDiff useWording=$useWording}
<!-- 
-- Email footer
-->
	{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>
</div>
</body>
</html>
