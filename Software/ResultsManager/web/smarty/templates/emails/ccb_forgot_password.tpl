{* Name: Forgot password *}
{* Description: Email sent when someone has forgotten their password. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Course Builder password reminder</title>
		<!-- <from>support@clarityenglish.com</from> -->
	    <style>
	    @import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
	    </style>
	</head>
<body bgcolor="#FFFFFF" style="margin:0; padding:0; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; color:#333333;">
<div style="background-color:#FFFFFF; padding:0; margin:0 auto; width:600px;">
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="451" rowspan="2" style="line-height:0;">
    	<img src="http://www.clarityenglish.com/images/email/ccb_banner.jpg" alt="Clarity Course Builder" width="451" height="175" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px;">    </td>
    <td width="149" height="48"  style="line-height:0;">
    	<a href="http://www.clarityenglish.com" target="_blank">
    	<img src="http://www.clarityenglish.com/images/email/ccb_banner_ce.jpg" alt="Clarity English" width="149" height="48" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px;">
        </a>
    </td>
  </tr>
  <tr>
    <td height="127"  style="line-height:0;"><img src="http://www.clarityenglish.com/images/email/ccb_banner_corner.jpg" width="149" height="127" > </td>
  </tr>
  <tr>
    <td height="420" colspan="2" align="left" valign="top" background="http://www.clarityenglish.com/images/email/ccb_bg.jpg">
    <div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 18px; line-height:18px; margin:5px 9px 5px 9px; padding:8px 8px 8px 55px; color:#333333; background-color: #F9C833;"></div>
    <div style="width:360px; margin:0; padding:8px 175px 0 65px;">
	{* Start email *}
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">Dear {$user->name}</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">You asked us to remind you of your password.</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">
{if $loginOption == 1}
	You need to type in your name ({$user->name}) and password.
{elseif $loginOption == 2}
	You need to type in your ID ({$user->studentID}) and password.
{elseif $loginOption == 128}
	You need to type in your email ({$user->email}) and password.
{else}
	Your teacher will have told you how to login.
{/if}
	Your password is {$user->password}.
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
