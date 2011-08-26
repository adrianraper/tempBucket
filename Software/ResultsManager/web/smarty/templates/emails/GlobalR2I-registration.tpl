{* Name: Global R2I Registration welcome *}
{* Description: Sent to new candidates who register for Road to IELTS *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Welcome to The Road to IELTS</title>
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
    <td height="28" >Dear {$body.name}</td>
    <td height="28"></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" >You have been registered for Road to IELTS. The start page for your account is: <a href="http://www.ieltspractice.com/BritishCouncil/RoadToIELTS/">www.ieltspractice.com/BritishCouncil/RoadToIELTS.</a></strong></td>
    <td height="28" ></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" >Login id: {$body.loginID}<br/>Password: {$body.password}</td>
    <td height="28" ></td>
  </tr>
  </tbody>
</table>
<!-- 
-- Email signature 
-->
	{include file='file:includes/GlobalR2I_Email_Signature.tpl'}
</body>
</html>