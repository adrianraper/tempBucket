{* Name: Forgot password *}
{* Description: Email sent when someone has forgotten their password. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>It's Your Job password reminder</title>
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
	<p style="margin: 0 0 10px 0; padding:0;">Thank you for subscribing to It's Your Job.</p>
	<p style="margin: 0 0 10px 0; padding:0;">You asked us to remind you of your login details, so they are printed below.</p>
	<p style="margin: 0 0 10px 0; padding:0;">Login name: <b>{$user->email}</b></br>
	Password: <b>{$user->password}</b></br></p>
	<p style="margin: 0 0 10px 0; padding:0;">If you wish to change this info, you can do so at any time by logging into It's Your Job and go to the My Account tab.</p>
		{include file='file:includes/IYJ_Email_Signature.tpl'}
	</td>
	</tr>
</tbody>
</table>
</body>
</html>
