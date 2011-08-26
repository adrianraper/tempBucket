{* Name: Early warning system *}
{* Description: Shows how much the account was used in the last month. 
	This is not actually sent as an email, used just to find active accounts I think.
	$account contains the account with only expiring titles in $account->titles. 
	No. All titles will be in titles. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - subscription reminder</title>
		<!-- <from>accounts@clarityenglish.com</from> -->
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
-- Email header
-->
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="450"></td>
    <td height="10" width="150"></td>
  </tr>
  {* use the licence type to see if this email is going to an individual or an insitution *}
  { * But you only have $account at this point, not $title. It seems safe to assume that an individual will ONLY have individual licences. *}
  { * And from now (May 2010) this template will not be used for individual licences. CLS version will be used instead. *}
  {foreach name=orderDetails from=$account->titles item=title}
	{if $title->licenceType==5} 
		{assign var='individual' value='true'}
	{/if}
  {/foreach}
	{if $individual=='true'} 
	  <tr align="left" valign="top">
		<td height="28" class="style1">Dear {$account->name}</td>
		<td height="28"></td>
	  </tr>
  {else}
	  <tr align="left" valign="top">
		<td height="28" class="style1">Dear Colleague</td>
		<td height="28"></td>
	  </tr>
	  <tr align="left" valign="top">
		<td height="28" class="style1">Account: <strong>{$account->name}</strong></td>
		<td height="28" class="style1"></td>
	  </tr>
  {/if}
  <tr align="left" valign="top">
    <td height="28" class="style1">This email is to let you know that the licence for the following 
	{if $account->titles|@count > 1}programs
	{else}program
	{/if} in your account will expire in 30 days. 
		If you would like to renew your subscription or make any changes to it, please reply to this email to request further details or an invoice.
	</td>
    <td height="28"></td>
  </tr>
  </tbody>
</table>
<!-- 
-- Section containing details of titles, first those that expire then those that don't
-->
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="25"></td>
    <td height="10" width="375"></td>
    <td height="10" width="200" align="left"></td>
  </tr>
{foreach name=orderDetails from=$account->titles item=title}
	{if $expiryDate != $title->expiryDate|truncate:10:""}
		{assign var='otherTitles' value='true'}
	{else}
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
		<a style="background-color:#FFFF00">Expiry date: {format_ansi_date ansiDate=$title->expiryDate}</a><br/>
	</td>
    <td class="style1">
    	{ include file='file:includes/titleTemplateDetails.tpl' method='image'}
	{* <img src="http://www.clarityenglish.com/images/program_logo/bw.jpg" border="0" /> *}
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
	{/if}
{/foreach}
	{if $otherTitles == 'true'}
	<tr align="left" valign="top">
		<td colspan="2"><hr align="left" width="420" size="1" /></td>
	</tr>
	<tr align="left" valign="top">
		<td class="style1"></td>
		<td class="style1">You have other programs with different expiry dates:</td>
	</tr>
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
{foreach name=orderDetails from=$account->titles item=title}
	{if $expiryDate != $title->expiryDate|truncate:10:""}
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
	{/if}
  </tbody>
</table>
<!-- 
-- Email footer
-->
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="450"></td>
    <td height="10" width="150"></td>
  </tr>
  <tr align="left" valign="top">
    <td height="50" class="style1">
		In the absence of any renewal, access will be blocked after the expiry date. 
		{if $individual!='true'}Please contact us before the expiry date to avoid any disruption to your learners.{/if}
	</td>
  </tr>
  </tbody>
</table>
<!-- 
-- Email signature 
-->
	{include file='file:includes/AccountsManager_Email_Signature.tpl'}
</body>
</html>
