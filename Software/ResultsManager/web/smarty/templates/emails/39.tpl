{* Name: Expiry in 2 weeks *}
{* Description: Email 16. Two weeks before expiry.
	$account, $expiryDate, $template_dir *}
{assign var="quotationFile" value="`$template_dir`quotations/`$account->prefix`_`$expiryDate`_quotation.pdf"}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Clarity English - subscription reminder, 14 days left!</title>
	<!-- <from>info@clarityenglish.com</from> -->
	<!-- <xcc>adrian.raper@clarityenglish.com</cc> -->
	<!-- <cc>accounts@clarityenglish.com</cc> -->
	<!-- <bcc>andrew.stokes@clarityenglish.com</bcc> -->
	{if ($quotationFile|file_exists)}
		<!-- <attachment>{$quotationFile}</attachment> -->
	{/if}
</head>
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.clarityenglish.com/images/email/email_banner.jpg" alt="Clarity English - Subscription reminder" style="border:0; margin:0; text-align:center"/>
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585; font-weight:bold;">Clarity English subscription: {$account->name}</p>

		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">This is a quick reminder that your subscription for the programs below will end in just 14 days. I hope that you have found these Clarity resources useful and enjoyable over the last year, and that you will renew your subscription. If you would like to do this, please send me a quick email and I’ll arrange for your account to be updated.</p>
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
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 10px 0; padding:0; color:#000000;">I’m looking forward to hearing from you.</p>
{include file='file:includes/SalesManager_Email_Signature.tpl'}
<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
	{include file="file:includes/Title_Details_Section.tpl'}
<!-- 
-- Email footer
-->
{include file='file:includes/Monthly_Email_Footer.tpl'}
</div>
</body>
</html>
