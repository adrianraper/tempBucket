{* Name: EmailMeUnitStart *}
{* Description: Email sent when a new unit becomes active to all users in groups assigned to this course *}
{* gh#704 *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>New unit from {$course->caption}</title>
	<!-- <from>support@clarityenglish.com</from> -->
	<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->		
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
	{* Course title in banner *}
    <div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 18px; line-height:18px; margin:5px 9px 5px 9px; padding:8px 8px 8px 55px; color:#333333; background-color: #F9C833;">{$course->caption}</div>
    <div style="width:360px; margin:0; padding:8px 175px 0 65px;">
	{* Start email *}
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">Dear {$user->name}</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">A new unit in the course <b>{$course->caption}</b> is available from {$course->startDate|date_format:"%B %e, %Y"}.</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">It's called: <b>{$course->unitName}</b></p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">You can start it directly from <a href="http://www.clarityenglish.com/area1/CCB/Player.php?prefix={$course->prefix}&course={$course->id}">this link</a></p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0 0 15px 0; padding:0; color:#000000;">
{if $course->loginOption == 1}
	You need to type in your name ({$user->name}) and password.
{elseif $course->loginOption == 2}
	You need to type in your ID ({$user->studentID}) and password.
{elseif $course->loginOption == 128}
	You need to type in your email ({$user->email}) and password.
{else}
	Your teacher will have told you how to login.
{/if}
	If you don't know or have forgotten your password, you can choose to have it sent by email from the login page.
	</p>
{if $course->author}
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0; padding:0; color:#000000;">Best regards<br/>{$course->author}</p>
{/if}
{if $course->email|stristr:'@'}
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 14px; line-height:18px; margin:0; padding:0; color:#000000;">Email: {$course->email}</p>
{/if}
    </div>
    </td>
  </tr>
</table>
</div>
</body>
</html>
	