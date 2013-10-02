{* Name:  Expires today *}
{* Description: Email 20. Expires today. *}
{* Parameters: $account, $expiryDate, $template_dir *}

{assign var='dateDiff' value='+0day'}
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
	<title>Clarity English - Your account expires today</title>
{elseif $useWording == 'one'}
	<title>Clarity English - One program in your account expires today</title>
{elseif $useWording == 'couple'}
	<title>Clarity English - Two programs in your account expire today</title>
{else}
	<title>Clarity English - Some programs in your account expire today</title>
{/if}
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

<img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Clarity English - Your account expires today<" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Clarity English Subscription: {$account->name}</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">
{if $useWording == 'all'}
	Your Clarity English subscription expires today. Your learners no longer have access to the programs listed below. 
	As I mentioned in yesterday's email, if you do intend to renew, please send me an email and I'll arrange for a two-week extension, free of charge, while we renew the account.
{elseif $useWording == 'one'}
	One program in your Clarity English subscription expires today. Your learners no longer have access to the program highlighted below. 
	As I mentioned in yesterday's email, if you do intend to renew, please send me an email and I'll arrange for a two-week extension, free of charge, while we renew the program.
{elseif $useWording == 'couple'}
	Two programs in your Clarity English subscription expire today. Your learners no longer have access to the programs highlighted below. 
	As I mentioned in yesterday's email, if you do intend to renew, please send me an email and I'll arrange for a two-week extension, free of charge, while we renew the programs.
{else}
	Some programs in your Clarity English subscription expire today. Your learners no longer have access to the programs highlighted below.
	As I mentioned in yesterday's email, if you do intend to renew, please send me an email and I'll arrange for a two-week extension, free of charge, while we renew the programs.
{/if}
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
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">In the meantime, if you have any queries or requests, please don't hesitate to get in touch.</p>
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
