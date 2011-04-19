{* Name: Trial nearly over *}
{* Description: Email sent when titles in a TRIAL account are going to expire. $account contains the account with only expiring titles in $account->titles. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - trial account</title>
		<!-- <from>info@clarityenglish.com</from> -->
		<!-- <cc>accounts@clarityenglish.com</cc> -->
		<!-- <bcc>andrew.stokes@clarityenglish.com</bcc> -->
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
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="450"></td>
    <td height="10" width="150"></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" class="style1">Dear Colleague</td>
    <td height="28"></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" class="style1">Trial account: <strong>{$account->name}</strong></td>
    <td height="28" class="style1"></td>
  </tr>
  <tr align="left" valign="top">
	<td class="style1">
	There's just one day left on your trial account! You can have a look at the Clarity programs now by clicking <a href="http://www.ClarityEnglish.com">here</a> to login in as follows:
  <tr align="left" valign="top">
    <td height="4"></td>
  </tr>
  <tr align="left" valign="top">
    <td class="style1">
		Login name: {$account->adminUser->name}<br/>
		Password: {$account->adminUser->password}<br/>
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="4"></td>
  </tr>
  <tr align="left" valign="top">
    <td class="style1">
	The trial gives you full access to the 
	{if $account->titles|@count > 1}programs
	{else}program
	{/if} listed below.
	</td>
  </tr>
	<tr align="left" valign="top">
		<td colspan="2"><hr align="left" width="420" size="1" /></td>
	</tr>
	</tbody>
</table>
<!-- 
-- Section containing details of titles trialled
-->
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="25"></td>
    <td height="10" width="375"></td>
    <td height="10" width="200" align="left"></td>
  </tr>
{foreach name=orderDetails from=$account->titles item=title}
 {* Just totally skip IYJ Practice Centre *}
 {if !$title->name|stristr:"Practice Centre"}
  <tr align="left" valign="top">
    <td class="style1">
		<b>&#8226;</b>
	</td>
    <td class="style1">
		<strong>{$title->name}</strong><br/>
		Licence type: {get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}<br/>
		{if $title->name == "Results Manager"}
			Number of teachers: {$title->maxTeachers}<br/>
			Number of reporters: {$title->maxReporters}<br/>
		{else}
			Number of students: {$title->maxStudents}<br/>
		{/if}
		Hosted by: Clarity<br/>
		Start date: {format_ansi_date ansiDate=$title->licenceStartDate}<br/>
		Expiry date: {format_ansi_date ansiDate=$title->expiryDate}<br/>
	</td>
    <td class="style1">
		{include file='file:includes/titleTemplateDetails.tpl' method='image'}
		{* <img src="http://www.clarityenglish.com/images/englishonline/{$titleImage}" border="0" /> *}
		{* <img src="http://www.clarityenglish.com/images/program_logo/rm.jpg" border="0" /> *}
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
 {/if}	
{/foreach}
  </tr>
  </tbody>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="450"></td>
    <td height="10" width="150"></td>
  </tr>
  <tr align="left" valign="top">
    <td class="style1">
		If you have any queries, please don't hesitate to email me.<br/>
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
  </tbody>
</table>
<!-- 
-- Email signature 
-->
	{include file='file:includes/Sales_Email_Signature.tpl'}
</body>
</html>