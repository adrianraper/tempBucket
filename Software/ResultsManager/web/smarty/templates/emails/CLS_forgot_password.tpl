{* Name: Forgot password *}
{* Description: Email sent when someone has forgotten their password. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>ClarityLifeSkills password reminder</title>
		<!-- <from>support@claritylifeskills.com</from> -->
		<!-- <bcc>support@claritylifeskills.com</bcc> -->
	</head>
<body style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 0 0; padding:0; color:#000000;">
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.claritylifeskills.com/email/header_purple.jpg" alt="www.ClarityLifeSkills.com" style="border:0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; text-align:center"/>
    <div style="width:500px; margin:a auto; padding:20px 50px 20px 50px;">
    <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Dear {$user->name}</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Thank you for subscribing to ClarityLifeSkills.</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">You asked us to remind you of your login details, so they are printed below.</p>
    <div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Login name: <strong>{$user->email}</strong></p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Password: <strong>{$user->password}</strong></p>
	</div>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">If you wish to change this info, you can do so at any time by logging into ClarityLifeSkills and go to the My Account page.</p>
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
