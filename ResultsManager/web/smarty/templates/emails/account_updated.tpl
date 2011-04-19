{* Name: Account updated letter *}
{* Description: Contains licence details, the admin account, direct links to the programs and support information. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - subscription update</title>
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
    <td height="28" class="style1">Updated account: <strong>{$account->name}</strong></td>
    <td height="28" class="style1"></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" class="style1">This email is to confirm that your account has been updated.
	Listed below are licence details of the
	{if $account->titles|@count > 1}programs
	{else}program
	{/if} you have subscribed to. There is a section explaining how to get the support you and your colleagues need.
	{foreach name=orderDetails from=$account->titles item=title}
		{if $title->name|stristr:"Results Manager"}
			{assign var='hasRM' value='true'}
			Finally, as you have subscribed to Results Manager, the admin account details to start this program are included.
		{/if}
		{if $title->name|stristr:"Author Plus"}
			{assign var='hasAP' value='true'}
		{/if}
	{/foreach}
	</td>
    <td height="28"></td>
  </tr>
	<tr align="left" valign="top">
		<td colspan="2"><hr align="left" width="420" size="1" /></td>
	</tr>
	</tbody>
</table>
<!-- 
-- Section containing details of titles ordered
-->
<br/><a style="background-color:#FFFF00"><b>1. Licence details</b></a><br/>
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

  {* Make this a more generic function that sets stuff the templates need for each title, but that isn't part of the php title class *}
  {* But I can't get the variables that I set in the include file to come back to here. So see clumsy method below. *}

  <tr align="left" valign="top">
    <td class="style1">
		<b>&#8226;</b>
	</td>
    <td class="style1">
		<strong>{$title->name}</strong><br/>
		{if in_array($title->productCode, array(3,9,10,33,38,45,46))}
			{if $title->languageCode=='EN'} 
				{assign var='languageName' value='International English'}
			{elseif $title->languageCode=='NAMEN'} 
				{assign var='languageName' value='North American English'}
			{elseif $title->languageCode=='BREN'} 
				{assign var='languageName' value='British English'}
			{elseif $title->languageCode=='INDEN'} 
				{assign var='languageName' value='Indian English'}
			{elseif $title->languageCode=='ZHO'} 
				{assign var='languageName' value='with Chinese instruction'}
			{else} 
				{assign var='languageName' value=$title->languageCode}
			{/if}
			Version: {$languageName}<br/>
		{/if}
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
<!-- 
-- Information about starting
-->
	<br/><a style="background-color:#FFFF00"><b>2. Using the titles</b></a><br/>
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="450"></td>
    <td height="10" width="150"></td>
  </tr>
<!-- 
-- This is for Anonymous Access login at CE.com
-->
{if $account->loginOption&128}
  <tr align="left" valign="top">
    <td class="style1">
		<b>Login at www.ClarityEnglish.com/shared/{$account->prefix}</b>. This website will let your colleagues and learners
		log in to use all the titles. As your account is set for Anonymous Access there is no login name. The password that everybody
		should use is the same as your admin account listed below.<br/>
		Password: {$account->adminUser->password}<br/>
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="4"></td>
  </tr>
  <tr align="left" valign="top">
    <td class="style1">
		You also have an admin account at <b>www.ClarityEnglish.com</b>. This is purely for you as the administrator and should not be
		shared with anyone. You can use this account to change the password that everyone uses, and to change language versions.
	</td>
  </tr>
  <tr align="left" valign="top">
    <td class="style1">
		Your admin account:<br/> 
		Login name: {$account->adminUser->name}<br/>
		Password: {$account->adminUser->password}<br/>
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="4"></td>
  </tr>
{else}
<!-- 
-- This section for Learner Tracking login at CE.com
-->
  <tr align="left" valign="top">
    <td class="style1">
		<b>Login at www.ClarityEnglish.com</b>. This website will let you, your colleagues and learners
		log in to use all the titles.<br/>
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="4"></td>
  </tr>
  <tr align="left" valign="top">
    <td class="style1">
		Your admin account:<br/> 
		Login name: {$account->adminUser->name}<br/>
		Password: {$account->adminUser->password}<br/>
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="4"></td>
  </tr>
  <tr align="left" valign="top">
    <td class="style1">
	Note that the admin account should be restricted to a single administrator. It enables the user to access
	all teacher and learner details and to delete everything.
	</td>
  </tr>
{/if}
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
{if $hasAP == 'true'}
  <tr align="left" valign="top">
    <td class="style1">
		<b>Author Plus</b> has two parts - the Teacher tool that teachers use to create material and the Learner tool
		that delivers the material. Only people that you designate in Results Manager as teachers will be able to use
		the authoring tool. So teachers will see two icons when they login to www.ClarityEnglish.com for Author Plus.
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
{/if}
{if $hasRM == 'true'}
  <tr align="left" valign="top">
    <td class="style1">
		<b>Results Manager</b> is the tool that you will use to add groups, teachers and learners to your account.
		You will find a Results Manager icon on your account page once you login to www.ClarityEnglish.com.
		If you want to read the user guide directly, you can <a href="http://www.ClarityEnglish.com/Software/ResultsManager/Help/Guide.pdf" target="_blank">follow this link</a>.
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
{/if}
  <tr align="left" valign="top">
    <td class="style1">
	If you have your own website and you want learners to link directly to the titles without going through www.ClarityEnglish.com, use the following direct links:
	</td>
  </tr>
  </tbody></table>
  <table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="4" width="600"></td>
  </tr>
{foreach name=orderDetails from=$account->titles item=title}
	{if !$title->name|stristr:"Results Manager" && !$title->name|stristr:"Practice Centre"}
  <tr align="left" valign="top">
    <td class="style1">
		{include file='file:includes/titleTemplateDetails.tpl' method='startPage'}
		{* http://www.ClarityEnglish.com/area1/{$startPageFolder}/Start.php?prefix={$account->prefix}<br/> *}
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="10"></td>
  </tr>
  {/if}
{/foreach}
  </tbody></table>

<!-- 
-- Information about admin
-->
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td height="10" width="450"></td>
    <td height="10" width="150"></td>
  </tr>

<!-- 
-- Support information
-->
  <tr align="left" valign="top">
    <td class="style1">
		<br/><a style="background-color:#FFFF00"><b>3. Support.</b></a><br/>
		If at any time you have any queries, please do not hesitate to contact our Technical Support team:<br/>
		Email: <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a><br/>
		Phone: (UK) 0845 130 5627; (Hong Kong) +852 2791 1787<br/>
		<br/>
		Please also visit <a href="www.ClaritySupport.com">www.ClaritySupport.com</a> for user guides, tutorials and other support.<br/>
		<br/>
	</td>
  </tr>
<!-- 
-- Email signature 
-->
	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
</body>
</html>