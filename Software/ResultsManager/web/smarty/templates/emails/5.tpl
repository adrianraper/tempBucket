
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>ClarityEnglish - Trial account expires tomorrow</title>
		<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
		<!-- <bcc>admin@clarityenglish.com</bcc> -->
        	       <style>
    		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
			</style>
	</head>
<body style="margin:0; padding:0;">

{if $account->titles|@count > 1}
	{assign var='multipleTitles' value='true'}
{/if}
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="ClarityEnglish - trial account expires tomorrow" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Trial Account: {$account->name}</p>

		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">There's just one day left on your trial account! You can have a look at the ClarityEnglish programs now by clicking <a href="http://www.clarityenglish.com/online/login.php">here</a> to sign in as follows:</p>
	<div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">Login name: {$account->adminUser->name}</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0; color:#000000;">Password: {$account->adminUser->password}</p>
	</div>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">The trial gives you full access to the {if multipleTitles}programs{else}program{/if} listed below. Meanwhile, don't forget that if you have any queries, difficulties, requests or feedback, you are very welcome to contact your Account Manager at any time.</p>
<!-- 
-- Resellers' contact details - if any
-->

	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
<!-- 
-- Email signature 
-->
    
    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
   
    </p>
    
    
{include file='file:includes/SalesManager_Email_Signature.tpl'}
<!-- 
-- Section containing details of titles, highlighting those that are expiring related to this email
-->
{include file='file:includes/Spacer_Before_Trial_Details.tpl'}
	{include file="file:includes/Title_Details_Section.tpl'}
<!-- 
-- Email footer
-->
{include file='file:includes/Monthly_Email_Footer.tpl'}
</div>
</div>
</body>
</html>
