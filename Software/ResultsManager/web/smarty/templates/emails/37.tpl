{* Name: Internal quotation request *}
{* Description: Email 14a. Internal quotation request *}
{* Variables: $account, $template_dir *}
{assign var="quotationFile" value="`$template_dir`quotations/`$account->prefix`_`$expiryDate`_quotation.pdf"}
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Quotation request for {$account->name}</title>
		<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
</head>
<body style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;">
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.clarityenglish.com/images/email/email_banner.jpg" alt="Clarity English - Quotation request" style="border:0; margin:0; text-align:center"/>
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Sales Team</p>
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585;">In 1 weeks time we will send the first renewal notice to <strong>{$account->name}</strong>.</p>
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">If you want to create a quotation that will be automatically attached to the email, please do it before then.</p>
{assign var="quotationFile" value="`$account->prefix`_`$expiryDate`_quotation.pdf"}
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">You should save the quotation as {$quotationFile} and send it to sales@clarityenglish.com</p>
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">The account details are listed below for your reference.</p>
<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
	{include file="file:includes/Title_Details_Section.tpl'}
<!-- 
-- Email signature 
-->
{include file='file:includes/AccountsManager_Email_Signature.tpl'}
<!-- 
-- Email footer
-->
{include file='file:includes/Monthly_Email_Footer.tpl'}
</div>
</div>
</body>
</html>
