{* Name: Library welcome letter *}
{* Description: Contains licence details, the admin account, direct links to the programs and support information. *}
{* Parameters: $account, $user 
	where $user is the first student in the root, used for AA passwords *}
<!--
-- Script to count the number of titles related to this email for wording selection
-- Note that some bug in smarty adds a space to the start of 
-->
{assign var='dateDiff' value='0day'}
{include file="file:includes/expiringTitles.tpl" assign=useWording}
{assign var='useWording' value=$useWording|strip:''}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Clarity English - Your new account</title>
	<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
	<!-- <bcc>admin@clarityenglish.com, accounts@clarityenglish.com</bcc> -->
	<style type="text/css">
		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
	</style>
    
    </head>
<body text="#000000" style="margin:0; padding:0;">
{*
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
*}
{* Also work out some other stuff about the licences to help with wording *}
{if $account->titles|@count > 1}
	{assign var='multipleTitles' value='true'}
{/if}
<div style="width:600px; margin:0 auto; padding:0;">
      <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Clarity English - Your new account" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
   
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">Dear Colleague</p>
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px;margin:0 0 5px 0;color:#151745; font-weight:700;">New Account: {$account->name}</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">This email is to welcome you as the Administrator of this new Clarity English account. It deals with the technical and administrative aspects of your account, so please keep it in a safe place, as you may want to refer to it later.</p>

        <div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
            <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">In this email we deal with the following areas.</p>
        	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">1. Licence details</p>
			<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">2. The functions of your Administrator account</p>
        	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">3. Accessing your Clarity English programs the first time</p>
        	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">4. Setting up a direct link to your Clarity English programs</p>
        	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">5. Promotional items</p>
        	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">6. Support</p>
        </div>
	
<!-- 
-- 1. Licence Details
-->
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">1. Licence details</p>
	{include file='file:includes/Title_Details_Section.tpl' dateDiff=$dateDiff useWording=$useWording}
<!-- 
-- 2. Administrator account details
-- 	Different sections for AA and LT
-->
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px;margin:0 0 5px 0; color:#151745; font-weight:700;">2. The functions of your Administrator account</p>
	<div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">Login name: {$account->adminUser->name}</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">Password: {$account->adminUser->password}</p>
	</div>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">Note that you should restrict access to the Administrator account to a single person. 
		It should not be given out to library members, as this account gives access to usage statistics for all your programs.</p> 

<!-- 
-- 3. Starting for the first time
-- Different sections for AA and LT
-->
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px;margin:0 0 5px 0; color:#151745; font-weight:700;">3. Accessing your Clarity English programs the first time</p>
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">First log in at <a href="http://www.clarityenglish.com" target="_blank">www.ClarityEnglish.com</a>, using your Administrator account. In order to activate the programs, the first thing you need to do is to accept the terms and conditions, which you will automatically be shown.</p>
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">Once you have done this, you and your library users will have full access to your Clarity programs.</p>

<!-- 
-- 4. Setting up a direct link to your Clarity English programs
-->
{foreach name=licenceStuff from=$account->licenceAttributes item=licenceAttribute}
	{if $licenceAttribute->licenceKey == "IPrange"}
		{assign var='hasIP' value='true'}
		{assign var='IPrange' value=$licenceAttribute->licenceValue}
	{/if}
	{if $licenceAttribute->licenceKey == "barcode"}
		{assign var='hasBarcode' value='true'}
		{assign var='barcode' value=$licenceAttribute->licenceValue}
	{/if}
{/foreach}
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px;margin:10px 0 5px 0; color:#151745; font-weight:700;">4. Setting up a direct link to your Clarity English programs</p>
{if $hasBarcode == 'true'}
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">Use the following direct {if $multipleTitles=='true'}links{else}link{/if} to access the programs through your barcode page:</p>
	{foreach name=orderDetails from=$account->titles item=title}
		{if !$title->name|stristr:"Results Manager" && !$title->name|stristr:"Practice Centre" && $title->productCode!='3' && $title->productCode!='12' && $title->productCode!='13'}
			<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">{$title->name}<br/><a href="http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}" target="_blank">http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}</a>
		{/if}
	{/foreach}
{else}
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">Use the following direct {if $multipleTitles=='true'}links{else}link{/if} to access the programs:</p>
	{foreach name=orderDetails from=$account->titles item=title}
		{if !$title->name|stristr:"Results Manager" && !$title->name|stristr:"Practice Centre" && $title->productCode!='3' && $title->productCode!='12' && $title->productCode!='13'}
			<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;font-size: 13px; margin:0 0 10px 0;">{include file='file:includes/titleTemplateDetails.tpl' method='startPage'}</p>
		{/if}
	{/foreach}
{/if}
{if $hasIP == 'true' && $hasBarcode == 'true'}
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">On this page, if your IP matches the range {$IPrange}, you will go straight through to the program.</p>
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">
    If not, you have to type a barcode. 
	This must match the pattern:<br/>{$barcode}.</p>
{elseif $hasIP == 'true'}
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">You will only gain access to the program if your IP (directly or through a proxy) matches the range {$IPrange}.</p>
{else}
	<div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0; border:2px solid">
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">IMPORTANT NOTE:
	A direct link must only be pasted in a password-protected area of your website. 
	This is to protect your licence and to prevent access from unlicensed learners. If you have any queries about this, please contact us or check the online support pages.</p>
	</div>
{/if}
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0;">You can also use the following URL to access Results Manager to see usage stats.</p>
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0;"><a href="http://www.ClarityEnglish.com/area1/ResultsManager/Start.php?prefix={$account->prefix}" target="_blank">http://www.ClarityEnglish.com/area1/ResultsManager/Start.php?prefix={$account->prefix}</a></p>
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  line-height:18px; font-size: 13px; margin:0 0 10px 0;">For more information, click <a href="http://www.clarityenglish.com/lib/resources/faq.php" target="_blank">here</a> to see the FAQ on our library site, or <a href="mailto:support@clarityenglish.com">email</a> us.</p>

<!-- 
-- 5. Promotional materials
-->
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:10px 0 5px 0; color:#151745; font-weight:700;">5. Promotional items</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">Click on the link below to link to support videos, to download web graphics, flyers and syllabus documents, and to request posters<br />
<a href="http://www.clarityenglish.com/lib/resources/" target="_blank">http://www.clarityenglish.com/lib/resources/</a></p>

<!-- 
-- 6. Support
-->
<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-size: 13px; line-height:18px;margin:10px 0 5px 0; color:#151745; font-weight:700;">6. Support</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">If at any time you have queries, requests or suggestions, the Clarity Support team is here to help:</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 20px; padding:0; color:#000000;">
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
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
<!-- 
-- Email signature 
-->
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px;margin:0 0 10px 0;">Finally, may I take this opportunity to thank you for choosing Clarity programs. We will do everything we can to help you make them a great success in your library.</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
    Adrian
    </p>
	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
<!-- 
-- Email footer
-->
	{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>
</div>
</body>
</html>