
{assign var="quotationFile" value="`$template_dir`quotations/`$account->prefix`_`$expiryDate`_quotation.pdf"}
{assign var='dateDiff' value='+77day'}
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Quotation request for {$account->name}</title>
    	<style type="text/css">
  	    	@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
		</style>
	<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
</head>
<body text="#000000" style="margin:0; padding:0;">
<div style="width:600px; margin:0 auto; padding:0;">
      <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Quotation request for {$account->name}" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif;   font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Sales Team</p>
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">In 1 week's time we will send the first renewal notice to <span style="font-weight:700;">{$account->name}</span>.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">If you want to create a quotation that will be automatically attached to the email, please do it before then.</p>
{assign var="quotationFile" value="`$account->prefix`_`$expiryDate`_quotation.pdf"}
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">You should save the quotation as {$quotationFile} and send it to sales@clarityenglish.com</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">The account details are listed below for your reference.</p>
<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
	{include file='file:includes/Spacer_Before_Title_Details.tpl'}
	{include file="file:includes/Title_Details_Section_Library.tpl' dateDiff=$dateDiff}
<!-- 
-- Email signature 
-->
     <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">As ever, if you have any queries or requests, please get in touch.</p>
     <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
   Christine
    </p>
	{include file='file:includes/AccountsManager_Email_Signature.tpl'}
<!-- 
-- Email footer
-->
	{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>
</div>
</body>
</html>
