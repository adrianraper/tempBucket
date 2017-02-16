{* Name: ClarityLifeSkills.com - last day *}
{* Description: Email sent on the last subscription day for an individual *}
{* Parameters: $account *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>ClarityLifeSkills.com - Your subscription expires today</title>
	<!-- <from>%22ClarityLifeSkills%22 %3Cadmin@claritylifeskills.com%3E</from> -->
	<!-- <bcc>admin@claritylifeskills.com</bcc> -->
</head>
<body style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 0 0; padding:0; color:#000000;">
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.claritylifeskills.com/email/header_purple.jpg" alt="ClarityLifeSkills - Your subscription will expire in a week." style="border:0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; text-align:center"/>
	<div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin:0; padding:0 0 2px 0; color:#12384d; font-weight:bold; font-size:18px; background:url(http://www.ClarityLifeSkills.com/email/title_line.jpg) no-repeat bottom left;">Don't miss your last chance!</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin:0 0 10px 0; padding:0; font-weight:bold; font-size:14px; color:#12384d;">Your subscription expires today.</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Dear {$account->adminUser->name}</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">This email is to remind you that your subscription for ClarityLifeSkills.com will end today at midnight. After that time, you will not be able to access content in ClarityLifeSkills.com. If you'd like to renew your subscription, please send a quick reply to this email.</p>
<!-- 
-- Email signature 
-->
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Please feel free to contact us if you have any quesitons.</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">With best wishes</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Cynthia Lau</p>
	{include file='file:includes/CLS_Email_Signature.tpl'}
<!--
-- Privacy and terms and conditions
-->
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 10px 0; padding:0; color:#000000;">
	{include file='file:includes/CLS_Privacy.tpl'}
	</p>
    </div>
</div>
</body>
</html>
