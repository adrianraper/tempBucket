{* Name: Expiry in 10 weeks *}
{* Description: Email 14. Expiry in 10 weeks. *}
{* Parameters: $account, $expiryDate, $template_dir *}
{*
	Check that we have been sent expected variables
*}
{if ($expiryDate=='') }
	{* this doesn't work at all
		{assign var='expiryDate' value='{php}echo date("Y-m-d"){/php}'}
	*}
{/if}
{assign var="quotationFile" value="`$template_dir`quotations/`$account->prefix`_`$expiryDate`_quotation.pdf"}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Clarity English - subscription reminder</title>
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

    

        
              <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Clarity English - Subscription reminder" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif;  line-height:18px; font-weight:400; font-size: 13px;">
    
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745; font-weight:700;">Clarity English subscription: {$account->name}</p>

		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">I'm dropping you a quick line because your Clarity English subscription is coming to an end. The subscription has approximately ten weeks to run, and will finish on {format_ansi_date ansiDate=$expiryDate}.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">
		I hope you, your colleagues and your library members have found your Clarity programs both useful and enjoyable – and I hope you are intending to renew. 
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
{* Simpler to handle all resellers in one file
	{assign var="resellerDetails" value="`$template_dir`includes/Reseller_Details_`$account->resellerCode`.tpl"}
	{if ($resellerDetails|file_exists)}
		{include file="file:includes/Reseller_Details_`$account->resellerCode`.tpl"}
	{/if}
*}
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
<!-- 
-- Email signature 
-->
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">As ever, if you have any queries about your subscription, please don't hesitate to get in touch.</p>
	{include file='file:includes/SalesManager_Email_Signature.tpl'}
<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
	{include file='file:includes/Spacer_Before_Title_Details.tpl'}
	{include file="file:includes/Title_Details_Section.tpl'}
<!-- 
-- Email footer
-->
	{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>
</div>
</body>
</html>
