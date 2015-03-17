{* Name: Forgot password *}
{* Description: Email sent when someone has forgotten their password. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity password reminder</title>
		<!-- <from>support@clarityenglish.com</from> -->
	    <style>
	    @import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
	    </style>
	</head>
<body bgcolor="#FFFFFF" style="margin:0; padding:0; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; color:#333333;">
<div style="background-color:#FFFFFF; padding:0; margin:0 auto; width:600px;">
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
      <td colspan="4" valign="top">
          <img src="http://www.clarityenglish.com/images/email/tbv10/tbv10_header.jpg" alt="Tense Buster" width="600" height="88" style="margin:0; font-family: Arial, Helvetica, sans-serif; font-size: 12px; "/>
      </td>
  </tr>
  <tr>
    <td height="420" colspan="2" align="left" valign="top" >
    <div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 18px; line-height:18px; margin:5px 9px 5px 9px; padding:8px 8px 8px 55px; color:#333333; background-color: #F9C833;">Forgot your password?</div>
    <div style="width:360px; margin:0; padding:8px 175px 0 65px;">
	{* Start email *}
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">Dear {$user->name}</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">You asked us to remind you of your password.</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">Sign-in with these details:</p>
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">
{if $loginOption == 1}
	Name: <strong>{$user->name}</strong>
{elseif $loginOption == 2}
	ID: <strong>{$user->studentID}</strong>
{elseif $loginOption == 128}
	Email: <strong>{$user->email}</strong>
{else}
	Ask your teacher how to sign-in.
{/if}<br/>
	Password: {if $user->password == ''}you have no password{else}<strong>{$user->password}</strong>{/if}
	</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0; padding:0; color:#000000;">Best regards<br/>Clarity support team</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0; padding:0; color:#000000;">support@clarityenglish.com</p>
    </div>
    </td>
  </tr>
</table>
</div>
</body>
</html>
