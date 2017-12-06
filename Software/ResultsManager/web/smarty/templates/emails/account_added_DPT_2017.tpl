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
	<title>Clarity English - Your new Dynamic Placement Test account</title>
	<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
	<!-- <bcc>admin@clarityenglish.com, accounts@clarityenglish.com</bcc> -->
	<style type="text/css">
		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
	</style>
    
    </head>
<body text="#000000" style="margin:0; padding:0; font-family:Arial, Helvetica, sans-serif; font-size:12px;">

<div style="max-width:600px; margin:0 auto; padding:0;">

       <img src="http://www.clarityenglish.com/images/email/email15_banner.jpg" alt="Clarity English - Your new account" style="border:0; margin:0; text-align:center; font-family: Arial, Helvetica, sans-serif;font-size: 1em; width: 100%;">
   
<div style="padding:30px 8% 20px 8%;">
		<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Dear Colleague</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 5px 0;color:#151745; font-weight:700;">New Account: {$account->name}</p>
		<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">This email is to welcome you as the administrator of this new ClarityEnglish account. It deals with the technical and administrative aspects of your account, so please keep it in a safe place, as you may want to refer to it later.</p>

        <div style="background-color:#E8E3F0;  padding:10px 20px; margin:0 auto 10px auto;">
            <p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding:0; color:#000000;">In this email we deal with the following areas:</p>
        	<ol style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding: 0 0 0 20px;  color:#000000;">
                <li>Licence details</li>
                <li>The functions of your administrator account</li>
                <li>Accessing the Dynamic Placement Test (DPT) for the first time</li>
                <li>Support</li>
     		</ol>
      </div>
	
<ol style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding: 0 0 0 15px;  color:#000000;">
<!-- 
-- 1. Licence Details
-->
	<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Licence details</li>

{foreach name=orderDetails from=$account->titles item=title}
	{if ($title->productCode=='63')}
	<div style="background:url(http://www.clarityenglish.com/images/email/dot_line.jpg) no-repeat bottom left; padding:5 0 10px 0; margin:0 0 10px 0">
		   	{include file='file:includes/titleTemplateDetails.tpl' method='image' enabled='on'}
			{assign var='enabledColor' value='#000000'}
			{assign var='highlightColor' value='#FFFF00'}
	        <p style="font-family:  Arial, sans-serif;  font-size: 1em; margin:5px 0 0 0; padding:0; color:{$enabledColor}; line-height:18px;">{$title->name}</p>
			<p style="font-family:  Arial, sans-serif;  font-size: 1em; margin:0; padding:0; color:{$enabledColor};">
			Number of tests purchased: {$title->maxStudents} <br/>
			Hosted by: Clarity<br/>
			Start date: {format_ansi_date ansiDate=$title->licenceStartDate}<br/>
			Expiry date: {format_ansi_date ansiDate=$title->expiryDate}</p>
	</div>
	{/if}
{/foreach}	
	
<!-- 
-- 2. Administrator account details
-- 	Different sections for AA and LT
-->
<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 5px 0; color:#151745; font-weight:700;">The functions of your administrator account</li>
	<div style="background-color:#E8E3F0;  padding:10px 20px; margin:0 auto 10px auto;">
		<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding:0; color:#000000;">Login name: {$account->adminUser->name}</p>
		<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding:0; color:#000000;">Password: {$account->adminUser->password}</p>
	</div>
	   <p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Note that you should restrict access to the administrator account to a single person. This account gives access to all teacher and learner records and to all Add and Delete functions. It is the master account. The administrator can set up Teacher and Learner accounts, which you can allocate to others within your school. (The exact nature of these accounts is explained in the Results Manager for DPT user manual. Click <a href="http://www.clarityenglish.com/Software/ResultsManager/web/Help/Results Manager Guide.pdf" target="_blank">here</a> to read the User Guide.)</p>
     
  
<!-- 
-- 3. Starting for the first time
-- Different sections for AA and LT
-->
<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 5px 0; color:#151745; font-weight:700;">Accessing the Admin Panel for the first time</li>
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">First login at <a href="http://www.clarityenglish.com" target="_blank">www.ClarityEnglish.com</a>, using your administrator account. In order to activate the program, the first thing you need to do is to accept the terms and conditions, which  will automatically be shown to you.</p>

<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Once you have done this, click on the Admin Panel icon. This is where you add groups, learners and teachers and where you create a test for the test takers. Click <a href="http://www.clarityenglish.com/support/user/pdf/dpt/DPT_TestAdminGuide.pdf" target="_blank">here</a> to read the Test Admin User Guide.</p>

<!-- 
-- 4. Support
-->
<li style="font-family:'Oxygen',   Arial, Helvetica, sans-serif;  font-size: 1em; line-height:18px;margin:10px 0 5px 0; color:#151745; font-weight:700;">Support</li>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">If you want to send your test takers instructions on how to access the DPT, click <a href="http://www.clarityenglish.com/support/user/pdf/dpt/DPT_UserGuide.pdf" target="_blank">here</a> to download the User Guide.</p>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">If at any time you have queries, requests or suggestions, the Clarity Support team is here to help:</p>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 20px; padding:0; color:#000000;">
	Email: <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a> <br />
	United Kingdom : +44 (0) 845 130 5627<br />
	Hong Kong : +852 2791 1787	</p>
<!-- 
-- End
-->
    </ol>
<!-- 
-- Resellers' contact details - if any
-->
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
<!-- 
-- Email signature 
-->
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Finally, may I take this opportunity to thank you for choosing Dynamic Placement Test. We will do everything we can to help you make it a great success with your colleagues and test takers.</p>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
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
