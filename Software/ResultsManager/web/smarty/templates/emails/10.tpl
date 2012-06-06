{* Name: EmailMe - Trial reminder - 2 days left *}
{* Description: Email sent when an individual has 2 days left in their trial. *}
{* Parameters: $user *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>ClarityEnglish.com - Your trial expires shortly</title>
	<!-- <from>%22Clarity English%22 %3Cnicole.lung@clarityenglish.com%3E</from> -->
	<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
</head>
<body style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 0 0; padding:0; color:#000000;">
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.claritylifeskills.com/email/header_purple.jpg" alt="ClarityLifeSkills - Your subscription will expire in a week." style="border:0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; text-align:center"/>
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin:0; padding:0 0 2px 0; color:#12384d; font-weight:bold; font-size:18px; background:url(http://www.ClarityLifeSkills.com/email/title_line.jpg) no-repeat bottom left;">Don't miss out!</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin:0 0 10px 0; padding:0; font-weight:bold; font-size:14px; color:#12384d;">Your subscription will expire in a week.</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Dear {$user->name}</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Your trial account is about to run out.</p>
<!-- 
-- Email signature 
-->
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Please feel free to contact us if you have any quesitons.</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">With best wishes</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Nicole Lung</p>
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
