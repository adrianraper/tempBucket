
<!--
-- Script to count the number of titles related to this email for wording selection
-- Note that some bug in smarty adds a space to the start of 
-->
{assign var='dateDiff' value='+1day'}
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
	<title>ClarityEnglish - Your account expires tomorrow</title>
{elseif $useWording == 'one'}
	<title>ClarityEnglish - One program in your account expires tomorrow</title>
{elseif $useWording == 'couple'}
	<title>ClarityEnglish - Two programs in your account expire tomorrow</title>
{else}
	<title>ClarityEnglish - Some programs in your account expire tomorrow</title>
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
	<img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="ClarityEnglish - Your account expires tomorrow" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">ClarityEnglish Subscription: {$account->name}</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">
	Just a quick note to remind you that
{if $useWording == 'all'}
	your ClarityEnglish subscription expires
{elseif $useWording == 'one'}
	one program in your account expires 
{elseif $useWording == 'couple'}
	two programs in your account expire 
{else}
	some titles in your account expire 
{/if}
	 <strong>tomorrow</strong>. 
	I would hate for there to be an interruption to your service, so if you intend to renew, please send me an email and I'll arrange for a two-week extension, free of charge. Please note that the two-week extension is only available once.
		
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
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Do please let me know as soon as possible so that I can ensure the continuity of your service.</p>
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">I'm looking forward to hearing from you.</p>
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br />
	Adrian</p>
    
	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
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
