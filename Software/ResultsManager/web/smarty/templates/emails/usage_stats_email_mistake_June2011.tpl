{* Name: _Apology for usage stats email splurge *}
{* Description: Apology for usage stats email splurge *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Mistake with yesterday's usage statistics emails</title>
		<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
<style type="text/css">
{literal}
<!--
.style1 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 12px;}
.style2 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 11px;}
-->
{/literal}
</style>
</head>
<body>
<div style="margin: 8px;">
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 12px;" width="600" border="0" cellpadding="0" cellspacing="0" align="left">
<tr>
	<td style="padding: 5px 0 5px 0;">
        <p style="padding:0 24px 0 24px;">Dear Colleague</p>
        <p style="padding:0 24px 0 24px;">Your account: <strong>{$account->name}</strong></p>
		<p style="padding:0 24px 0 24px;">Yesterday you probably received duplicate copies from us of your monthly statistics email. For some people it was a flood of such emails. I wanted to apologise for this and to assure you that it was not a spam or hacker attack that caused it - just an old fashioned human/computer error.</p>
        <p style="padding:0 24px 10px 24px;">The reason that the email was going out yesterday is that a glitch stopped the emails at the beginning of the month. By the first of next month we should be back to a smooth process with just a single email!</p>
	</td>
</tr>
<tr>	<td style="padding: 5px 24px 5px 24px;">

{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
</td></tr>
</table>
</div>
</body>
</html>
