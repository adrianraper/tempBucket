{* Name: Global R2IV2 forgot password *}
{* Description:  *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Welcome to Road to IELTS 2</title>
		<!-- <bcc>support@ieltspractice.com</bcc> -->
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
<body class="style1">
<!-- 
-- Introduction
-->
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="450"></td>
    <td height="10" width="150"></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" >Dear {$user->name}</td>
    <td height="28"></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" >You asked us to remind you of your login details for Road toIELTS.</td>
    <td height="28" ></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" >Login id: <b>{$user->studentID}</b><br/>
	Password: <b>{$user->password}</b><br/>
	URL: <a href="http://www.roadtoielts.com/BritishCouncil/R2IV2/login.php?loginID={$body.loginID}">www.roadtoielts.com/BritishCouncil/R2IV2</a><br/>
	Expiry date: {$user->expiryDate}
	</td>
    <td height="28" ></td>
  </tr>
  <tr align="left" valign="top">
    <td height="10" />
  </tr>
  </tbody>
</table>
<!-- 
-- Email signature 
-->
	{include file='file:includes/R2IV2_Email_Signature.tpl'}
</body>
</html>