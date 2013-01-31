{* Name: EmailMeUnitStart *}
{* Description: Email sent when a new unit becomes active to all users in groups assigned to this course *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity Course Builder new unit</title>
		<!-- <from>support@clarityenglish.com</from> -->
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
	<p style="margin: 0 0 10px 0; padding:0;">A new unit in the course {$course->caption} is active today.</p>
	<p style="margin: 0 0 10px 0; padding:0;">You'd better do it soon.</p>
	<p style="margin: 0 0 10px 0; padding:0;">It's called: <b>{$course->unitName}</b></br>
	Password: <b>{$user->password}</b></br></p>
	{include file='file:includes/CLS_Email_Signature.tpl'}
	</td>
	</tr>
</tbody>
</table>
</body>
</html>
