﻿{* Name: CLS Online subscription welcome *}
{* Description: Email sent when you have subscribed to CLS online. *}
{* Parameters: $account *}
{* Updated for CLS v2 with packages *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Welcome to ClarityLifeSkills.com</title>
	<!-- <from>%22ClarityLifeSkills%22 %3Cadmin@claritylifeskills.com%3E</from> -->
	<!-- <bcc>admin@claritylifeskills.com,accounts@clarityenglish.com</bcc> -->
</head>
<body style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 0 0; padding:0; color:#000000;">
<div style="width:600px; margin:0 auto; padding:0;">

	<img src="http://www.claritylifeskills.com/email/header_purple.jpg" alt="www.ClarityLifeSkills.com" style="border:0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; text-align:center"/>
        
    
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin:0; padding:0 0 2px 0; color:#12384d; font-weight:bold; font-size:18px; background:url(http://www.ClarityLifeSkills.com/email/title_line.jpg) no-repeat bottom left;">Welcome to ClarityLifeSkills</p>
	
	  <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0; padding:0; color:#000000;">Dear {$account->adminUser->name}</p>
		
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">An account has been created for you. To access the account, please go to this URL:
<a href="http://www.claritylifeskills.com/members/login.php" target="_blank">www.ClarityLifeSkills.com</a></p>

        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Enter your login details as follows:</p>
        
        
	<div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Login name: {$account->adminUser->email}</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Password: {$account->adminUser->password}</p>
	</div>
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">You have subscribed to:</p>
<!--Subscription details-->
{* We currently only have two mutually exclusive packages. So if they have ordered TB it means they have package 1, if IYJ then package 2 *}
{* Not at all sure how we would work this out if more packages become overlapping. Will need a package ID(s) somewhere in T_AccountRoot *}
{* It is now based on offerID, which we store in T_Subscription. How to get that? *}
{foreach name=orderDetails from=$account->titles item=title}
    {if ($title->productCode==9)} 
		{assign var='generalEnglishpackage' value='true'}
    {elseif ($title->productCode==1001)} 
		{assign var='careerEnglishpackage' value='true'}
	{/if}
{/foreach}

{if $generalEnglishpackage=='true'}
	{assign var='thisImage' value='title_GE_email.jpg'}
	{assign var='thisName' value='General English'}
	{assign var='thisPackageList' value='9,33,39,49'}
	{include file='file:includes/CLS_welcome_package_details.tpl'}	
{/if}
{if $careerEnglishpackage=='true'}
	{assign var='thisImage' value='title_CE_email.jpg'}
	{assign var='thisName' value='Career English'}
	{assign var='thisPackageList' value='10,40,43,1001'}
	{include file='file:includes/CLS_welcome_package_details.tpl'}	
{/if}
<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Below are the details you have entered while registering for ClarityLifeSkills. Please keep this email for later reference.</p>
	<div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Your name: <strong>{$account->adminUser->name}</strong></p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Email: <strong>{$account->adminUser->email}</strong></p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Country: <strong>{$account->adminUser->country}</strong></p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">Contact method: <strong>{$account->adminUser->contactMethod}</strong></p>
	</div>
<!-- 
-- Email signature 
-->
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Please feel free to contact us if you have any quesitons.</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000;">With best wishes</p>
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Nicole Lung</p>
	{include file='file:includes/CLS_Email_Signature.tpl'}
<!--
-- Privacy and terms and conditions
-->
	<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:10px 0 10px 0; padding:0; color:#000000;">
	{include file='file:includes/CLS_Privacy.tpl'}
	</p>
    </div>
</div>
</body>
</html>
