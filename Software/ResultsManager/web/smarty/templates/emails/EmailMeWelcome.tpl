{* Name: EmailMeWelcome *}
{* Description: Email sent to users in a selected group to tell them about a new course *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>{$course->caption} will start soon</title>
		<!-- <from>support@clarityenglish.com</from> -->
		<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->		
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
	<p style="margin: 0 0 10px 0; padding:0;">== Please note that this email is send as part of beta-testing the Clarity Course Builder ==</p>
	<p style="margin: 0 0 10px 0; padding:0;">Dear {$user->name}</p>
	<p style="margin: 0 0 10px 0; padding:0;">A new course called {$course->caption} will be available from {$course->startDate}.</p>
	<p style="margin: 0 0 10px 0; padding:0;">You can start it directly from 
<a href="http://ccb.clarityenglish.com/area1/CCB/Player.php?prefix={$course->prefix}&course={$course->id}">http://ccb.clarityenglish.com/area1/CCB/Player.php?prefix={$course->prefix}&course={$course->id}</a>
</p>
<p style="margin: 0 0 10px 0; padding:0;">
{if $course->loginOption == 1}
	You need to type in your name ({$user->name}) and password.
{elseif $course->loginOption == 2}
	You need to type in your ID ({$user->studentID}) and password.
{elseif $course->loginOption == 128}
	You need to type in your email ({$user->email}) and password.
{else}
	Your teacher will have told you how to login.
{/if}
	</p>
	{include file='file:includes/CCB_Email_Signature.tpl' course=$course }
	</td>
	</tr>
</tbody>
</table>
</body>
</html>
