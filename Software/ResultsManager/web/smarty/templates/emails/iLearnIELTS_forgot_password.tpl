{* Name: Forgot password *}
{* Description: Email sent when someone has forgotten their password. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>iLearnIELTS password reminder</title>
		<!-- <from>support@ilearnielts.com</from> -->
		<!-- <bcc>support@ilearnielts.com</bcc> -->
	</head>
<body>
<!-- 
-- Email header
-->
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" width="600" border="0" cellpadding="0" cellspacing="0">
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="450"></td>
    <td height="10" width="150"></td>
  </tr>
  <tr align="left" valign="top">
    <td>
	<p style="margin: 0 0 10px 0; padding:0;">Dear {$user->name}</p>
	<p style="margin: 0 0 10px 0; padding:0;">Thank you for your membership of iLearnIELTS.</p>
	<p style="margin: 0 0 10px 0; padding:0;">You asked us to remind you of your login details, so they are printed below.</p>
	<p style="margin: 0 0 10px 0; padding:0;">Login name: <b>{$user->email}</b></br>
	Password: <b>{$user->password}</b></br></p>
	<p style="margin: 0 0 10px 0; padding:0;">If you wish to change this, you can do so at any time by logging into iLearnIELTS and going to the My package page.</p>
	{include file='file:includes/iLearn_Email_Signature.tpl'}
	</td>
	</tr>
</tbody>
</table>
</body>
</html>
