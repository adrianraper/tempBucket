{* Name: Trial has a week to go *}
{* Description: Email sent when titles in a TRIAL account one week from expiring.  *}
{* Parameters: $account, $expiryDate, $template_dir *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - trial expires in one week</title>
		<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
		<!-- <bcc>admin@clarityenglish.com</bcc> -->
	</head>
<body>
{* Also work out some other stuff about the licences to help with wording *}
{if $account->titles|@count > 1}
	{assign var='multipleTitles' value='true'}
{/if}
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.clarityenglish.com/images/email/email_banner.jpg" alt="Clarity English - Subscription reminder" style="border:0; margin:0; text-align:center"/>
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585; font-weight:bold;">Trial account: {$account->name}</p>

		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">I hope you have found the Clarity trial account useful. If you haven't had a chance to look at it yet, click <a href="http://www.ClarityEnglish.com">here</a> and login in as follows:</p>
	<div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Login name: {$account->adminUser->name}</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Password: {$account->adminUser->password}</p>
	</div>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">The trial gives you full access to the {if multipleTitles}programs{else}program{/if} listed below, and is open for <b>one more week</b>.</p>
<!-- 
-- Resellers' contact details - if any
-->
{* Simpler to handle all resellers in one file
	{assign var="resellerDetails" value="`$template_dir`includes/Reseller_Details_`$account->resellerCode`.tpl"}
	{if ($resellerDetails|file_exists)}
		{include file="file:includes/Reseller_Details_`$account->resellerCode`.tpl"}
	{/if}
*}
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
<!-- 
-- Email signature 
-->
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 10px 0; padding:0; color:#000000;">I'm looking forward to hearing from you.</p>
{include file='file:includes/SalesManager_Email_Signature.tpl'}
<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
	{include file="file:includes/Title_Details_Section.tpl'}
<!-- 
-- Email footer
-->
{include file='file:includes/Monthly_Email_Footer.tpl'}
</div>
</div>
</body>
</html>
