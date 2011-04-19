{* Name: Online subscription welcome *}
{* Description: Email sent when you have subscribed to a new online subscription. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity Life Skills - new subscription</title>
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
  <tr align="left" valign="top">
    <td height="28" class="style1">Dear {$account->adminUser->name}</td>
    <td height="28"></td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" class="style1">Welcome to your new Clarity Life Skills online subscription.
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
<!-- but don't add a section if this product is a hidden one (created as part of an EMU) -->
	{assign var='thisProductIsHidden' value='false'}
	{foreach from=$hiddenProducts item=blockedCode}
		{if $blockedCode==$title->productCode}
			{assign var='thisProductIsHidden' value='true'}
		{/if}
	{/foreach}
	{if $thisProductIsHidden=='false'}
  <tr align="left" valign="top">
    <td class="style1">
		<b>&#8226;</b>
	</td>
    <td class="style1">
		<strong>{$title->name}</strong><br/>
		Licence type: {get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}<br/>
		Start date: {format_ansi_date ansiDate=$title->licenceStartDate}<br/>
		Expiry date: {format_ansi_date ansiDate=$title->expiryDate}<br/>
		Contact by: {if $account->adminUser->contactMethod=="email"} {$account->adminUser->contactMethod} to {$account->adminUser->email}
					{elseif $account->adminUser->contactMethod=="none"} no contact
					{/if}<br/>
		Delivery of units: {if $title->deliveryFrequency==0}
			All at once
		{elseif $title->deliveryFrequency==1}
			Every day
		{else}
			Every {$title->deliveryFrequency} days
		{/if}<br/>
		Start page: www.ClarityLifeSkills.com/ItsYourJob<br/>
		Login: {$account->adminUser->email}<br/>
		Password: {$account->adminUser->password}<br/>
	</td>
    <td class="style1">
	{if $title->name|stristr:"Tense Buster"}
		<img src="/images/program_logo/tb.jpg" border="0" />
	{elseif $title->name|stristr:"Active Reading"}
		<img src="/images/program_logo/ar.jpg" border="0" />
	{elseif $title->name|stristr:"Study Skills"}
		<img src="/images/program_logo/sss.jpg" border="0" />
	{elseif $title->name|stristr:"Road"}
		<img src="/images/program_logo/rti.jpg" border="0" />
	{elseif $title->name|stristr:"Business Writing"}
		<img src="/images/program_logo/bw.jpg" border="0" />
	{elseif $title->name|stristr:"It's Your Job"}
		<img src="/images/program_logo/iyj.jpg" border="0" />
	{/if}
	</td>
  </tr>
  <tr class="style1">
    <td height="10"></td>
  </tr>
	{/if}
{/foreach}
  </tbody>
</table>
<!-- 
-- Email footer
-->
<table border="0" cellpadding="0" cellspacing="0" width="600" >
  <tbody>
  <tr align="left" valign="top">
    <td width="450" class="style1">When you login you will have access to your My Account page. This is where you can change your password and other settings.</td>
    <td></td>
  </tr>
  <tr align="left" valign="top"><td height="10"></tr>
<!-- 
-- Email signature 
-->
  <tr align="left" valign="top">
    <td height="70" class="style1">
		If you have any queries, please do contact me.<br/>
		Best regards<br/>
		Ms Christine Ng<br/>
		(Accounts Manager)<br/>
	</td>
  </tr>
  </tbody>
</table>
<table width="450" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><hr align="left" width="420" size="1" /></td>
  </tr>
  <tr>
    <td colspan="2" class="style2"><strong>Clarity Guide 2009-10.</strong> Covers 37 carefully selected ELT programs<br /> 
	for General English, Academic English, Business English - and more! <br />
	Get it now at www.ClarityEnglish.com
	</td>
  </tr>
  <tr>
    <td colspan="2"><hr align="left" width="420" size="1" /></td>
  </tr>
  <tr>
    <td colspan="2" class="style1">Clarity Language Consultants Ltd (UK and HK since 1992)</td>
  </tr>
  <tr>
    <td width="200" class="style1">Tel: (+852) 2791 1787</td>
    <td width="250" class="style1">Fax: (+852) 2791 6484</td>
  </tr>
  <tr>
    <td colspan="2" class="style1">Email: accounts@clarityenglish.com</td>
  </tr>
</table>
</body>
</html>
