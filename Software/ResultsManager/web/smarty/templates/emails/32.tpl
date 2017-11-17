
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>ClarityEnglish - Your subscription</title>
		<!-- <from>%22Clarity English%22 %3Csupport@clarityenglish.com%3E</from> -->
		<!-- <bcc>admin@clarityenglish.com,support@clarityenglish.com</bcc> -->
        	<style type="text/css">
    		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
			</style>
	</head>
<body text="#000000" style="margin:0; padding:0;">

{if $account->titles|@count > 1}
	{assign var='multipleTitles' value='true'}
{/if}
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="ClarityEnglish - Your subscription" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:0 auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">ClarityEnglish Subscription: {$account->name}</p>

		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Your ClarityEnglish subscription started a week ago. This is just a quick note to check that it is up and running smoothly, and your learners and colleagues have been able to access the learning resources.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Once a month we will send you usage statistics, so you can see, with a couple of clicks, how many learners are using the program{if $multipleTitles=='true'}s{/if}, and what they are doing. I hope you find this useful.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">You may also find it useful to visit the Clarity Support site: <a href='http://www.clarityenglish.com/resources/?utm_source=auto_email&utm_medium=edu_32&utm_term=link_resource&utm_campaign=welcome_firstweek&utm_content=visit_resource' target='_blank'>www.ClarityEnglish.com/resources</a></p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">You will find the syllabus for each Clarity program as well as handy activities to help teachers familiarise themselves with the programs.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Meanwhile, don't forget that if you have any queries, difficulties, requests or feedback, you are very welcome to contact either your Account Manager or me at any time.</p>
		
<!-- 
-- Resellers' contact details - if any
-->

	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}		
		
           <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
    Adrian
    </p>

	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>
</div>
</body>
</html>