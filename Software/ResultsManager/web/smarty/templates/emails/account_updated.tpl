{* Name: Update letter *}
{* Description: Contains licence details, the admin account, direct links to the programs and support information. *}
{* Parameters: $account, $user 
	where $user is the first student in the root, used for AA passwords *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - Your account update</title>
		<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
		<!-- <bcc>admin@clarityenglish.com, accounts@clarityenglish.com</bcc> -->
	</head>
<body>
{foreach name=orderDetails from=$account->titles item=title}
	{if $title->name|stristr:"Results Manager"}
		{assign var='hasRM' value='true'}
		{if $title->licenceType == 2}
			{assign var='hasAARM' value='true'}
		{/if}
	{/if}
	{if $title->name|stristr:"Author Plus"}
		{assign var='hasAP' value='true'}
	{/if}
{/foreach}
{* Also work out some other stuff about the licences to help with wording *}
{if $account->titles|@count > 1}
	{assign var='multipleTitles' value='true'}
{/if}
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.clarityenglish.com/images/email/email_banner.jpg" alt="Clarity English - Account information" style="border:0; margin:0; text-align:center"/>
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585; font-weight:bold;">Updated account: {$account->name}</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">This email is to confirm that your Clarity English account has been updated. The email has reminders of some technical and administrative aspects of your account, so please keep it in a safe place, as you may want to refer to it later.</p>

        <div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">In this email we deal with the following areas.</p>
        	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">1. Licence details</p>
			<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">2. The functions of your Administrator account</p>
        	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">3. Setting up a direct link to your Clarity English programs</p>
        	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">5. Support</p>
        </div>
	
<!-- 
-- 1. Licence Details
-->
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585; font-weight:bold;">1. Licence details</p>
	{include file='file:includes/Title_Details_Section.tpl' enabled='on' dateDiff='0day'}
<!-- 
-- 2. Administrator account details
-- 	Different sections for AA and LT
-->
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585; font-weight:bold;">2. The functions of your Administrator account</p>
	<div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Login name: {$account->adminUser->name}</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Password: {$account->adminUser->password}</p>
	</div>
{if $hasAARM==true}
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Note that you should restrict access to the Administrator account to a single person. 
		It should not be given out to learners, as this account gives access to usage statistics for all your programs.</p> 
{else}
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Note that you should restrict access to the Administrator account to a single person. 
		This account gives access to all teacher and learner records and to all add and delete functions. It is the master account. The Administrator can set up Teacher, Author, Reporter and Learner accounts which you can allocate to others
		within your instiitution. (The exact nature of these accounts is explained in the Results Manager User Manual, see the link below.)</p>
{/if}
<!-- 
-- 3. Setting up a direct link to your Clarity English programs
-->
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585; font-weight:bold;">3. Setting up a direct link to your Clarity English programs</p>
{if $hasAARM==true}
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Learners can access your Clarity English programs from <a href="http://www.clarityenglish.com/shared/{$account->prefix}" target="_blank">www.clarityenglish.com/shared/{$account->prefix}</a>.</p>
	<div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Shared password: {$user->password}</p>
	</div>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">
			But many institutions find it more convenient to simply paste a link on their own website or within their own LMS, to give learners one-click access. 
			Please note that a direct link should only be pasted in a password-protected area of your website. This is to prevent access from unlicensed learners.</p>
{else}
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Learners can access your Clarity English programs from <a href="http://www.clarityenglish.com" target="_blank">www.clarityenglish.com</a>. 
			But many institutions find it more convenient to simply paste a link on their own website or within their own LMS, to give learners one-click access. 
			Please note that a direct link should only be pasted in a password-protected area of your website. This is to prevent access from unlicensed learners.</p>
{/if}
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Copy and paste the following direct {if $multipleTitles=='true'}links{else}link{/if} into your website:</p>
{foreach name=orderDetails from=$account->titles item=title}
{if $title->expiryDate|truncate:10:"" >= $oneMonthAgo && !$title->name|stristr:"Practice Centre" && $title->productCode!=12 && $title->productCode!=13}
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; margin:0 0 10px 0; padding:0; color:#000000;">{include file='file:includes/titleTemplateDetails.tpl' method='startPage'}</p>
{/if}
{/foreach}
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">You can also use the following URL for direct access to Results Manager from a teachers' page.</p>
{foreach name=orderDetails from=$account->titles item=title}
{if $title->name|stristr:"Results Manager"}
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; margin:0 0 10px 0; padding:0; color:#000000;">{include file='file:includes/titleTemplateDetails.tpl' method='startPage'}</p>
{/if}
{/foreach}
<!-- 
-- 4. Support
-->
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585; font-weight:bold;">4. Support</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">If at any time you have queries, requests or suggestions, please do not hesitate to contact the Clarity Support team:</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">
	Email: <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a> <br />
	United Kingdom : 0845 130 5627<br />
	Hong Kong : (+852) 2791 1787
	</p>
<!-- 
-- End
-->
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
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 10px 0; padding:0; color:#000000;">Finally, may I take this opportunity to thank you for choosing Clarity programs. We will do everything we can to help you make them a great success with your colleagues and your learners.</p>
	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
	</div>
</div>
</body>
</html>
