{* Name: _Updating Clear Pronunciation *}
{* Description: Use DMS to select all accounts with Clear Pronunciation. Then send this email to them *}
{* Parameters: No. All titles will be in titles. *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - Upgrade for Clear Pronunciation</title>
		<!-- <from>support@clarityenglish.com</from> -->
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
		<td height="28" class="style1">Dear Colleague</td>
		<td height="28"></td>
	  </tr>
	  <tr align="left" valign="top">
		<td height="28" class="style1">Account: <strong>{$account->name}</strong></td>
		<td height="28" class="style1"></td>
	  </tr>
  <tr align="left" valign="top">
    <td height="28" class="style1">
		You will be pleased to hear that on Monday 30 August we will release a brand new version of Clear Pronunciation. This will be automatically integrated into your account as part of your subscription.
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="10" class="style1">
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" class="style1">
		The new Version 2 includes all the content in Version 1, but additionally:
		<li>An introduction unit</li>
		<li>An enhanced interface</li>
		<li>Animations of mouth movements</li>
		<li>Enhanced audio, and a greater variety of voices</li>
		<li>Indication of different accents in Ex 4 (British, North American, Australasian...)</li>
		<li>Elimination of some small usability problems</li>
	</td>
  </tr>  
  <tr align="left" valign="top">
    <td height="10" class="style1">
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" class="style1">
		The only impact on existing student data is that a few exercises have been completely rewritten, so old progress records for these will be dropped.
	</td>
  </tr>  
  <tr align="left" valign="top">
    <td height="10" class="style1">
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="28" class="style1">
		Also, don't forget that there is a new version of the Clarity Recorder that integrates with Clear Pronunciation (and other Clarity programs). To find out more, visit our <a href="/support/support_recorder.php" _target="blank">Support site</a>.
	</td>
  </tr>  

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
    <td class="style1">
	I hope you enjoy the Clear Pronunciation V2 - as always, please feel free to contact me if you have any queries.
	</td>
  </tr>
  <tr align="left" valign="top">
    <td height="10" class="style1">
	</td>
  </tr>
  </tbody>
</table>
<!-- 
-- Email signature 
-->
	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
</body>
</html>


