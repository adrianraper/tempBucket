{* Name: Expiry today *}
{* Description: Email sent when titles in an account are going to expire in an account. 
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
  {assign var='countOtherTitles' value=0}
  {assign var='countExpiringTitles' value=0}
  {foreach name=orderDetails from=$account->titles item=title}
	{if $title->licenceType==5} 
		{assign var='individual' value='true'}
	{/if}
	{* Also move the otherTitles checking here so that you can correctly say program or programs *}
	{if $expiryDate != $title->expiryDate|truncate:10:""}
		{assign var='countOtherTitles' value=$countOtherTitles+1}
	{else}
		{assign var='countExpiringTitles' value=$countExpiringTitles+1}
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
	{* {if $account->titles|@count > 1} *}
	{if $countExpiringTitles>1 }{$countExpiringTitles} programs
	{else}program
	{/if}expires TODAY. Your learners will NOT be able to get access after today, so if you would like to renew, 
		please email or call me now to request a temporary extension while we process your new subscription.
	{if $countOtherTitles>0 }You also have {$countOtherTitles} other 
		{if $countOtherTitles>1 }programs with different expiry dates which are
		{else}program with a different expiry date which is
		{/if}listed below the line. 
	{/if}
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
	{* Just totally skip IYJ Practice Centre *}
 {if !$title->name|stristr:"Practice Centre"}
	{if $expiryDate == $title->expiryDate|truncate:10:""}
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
 {/if}
{/foreach}
	{if $countOtherTitles>0}
	<tr align="left" valign="top">
		<td colspan="2"><hr align="left" width="420" size="1" /></td>
	</tr>
	{* 
	<tr align="left" valign="top">
		<td class="style1"></td>
		<td class="style1">You have other programs with different expiry dates:</td>
	</tr>
	*}
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
{foreach name=orderDetails from=$account->titles item=title}
 {* Just totally skip IYJ Practice Centre *}
 {if !$title->name|stristr:"Practice Centre"}
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
		In the absence of any renewal, access will be blocked tomorrow. 
		{if $individual!='true'}Please contact us today to avoid any disruption to your learners.{/if}
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
