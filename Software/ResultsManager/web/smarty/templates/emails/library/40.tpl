{* Name: Expiry tomorrow *}
{* Description: Email 18. Expire tomorrow. *}
{* Parameters: $account, $expiryDate, $template_dir *}
{assign var="quotationFile" value="`$template_dir`quotations/`$account->prefix`_`$expiryDate`_quotation.pdf"}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Clarity English - Your account expires tomorrow</title>
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

    
    
      
      <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Clarity English - Your account expires tomorrow" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745; font-weight:700;">Clarity English subscription: {$account->name}</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Just a quick note to remind you that your Clarity English subscription expires <strong>tomorrow</strong>. I would hate for there to be an interruption to your service, so if you intend to renew, please send me an email and I'll arrange for a two-week extension, free of charge.
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
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Do please let me know as soon as possible so that I can ensure the continuity of your service. <br />I'm looking forward to hearing from you.</p>
	{include file='file:includes/SalesManager_Email_Signature.tpl'}
<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
	{include file='file:includes/Spacer_Before_Title_Details.tpl'}
	{include file='file:includes/Title_Details_Section.tpl' enabled='any'}
<!-- 
-- Email footer
-->
	{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>
</div>
</body>
</html>
