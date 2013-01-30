{* Name: Subscription reminders, start +7days *}
{* Description: Email 2. One week after starting. *}
{* Variables: $account *}
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - Your subscription</title>
		<!-- <from>%22Clarity English%22 %3Csupport@clarityenglish.com%3E</from> -->
		<!-- <bcc>admin@clarityenglish.com,support@clarityenglish.com</bcc> -->
	</head>
<body>
{* Also work out some other stuff about the licences to help with wording *}
{if $account->titles|@count > 1}
	{assign var='multipleTitles' value='true'}
{/if}
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.clarityenglish.com/images/email/email_banner.jpg" alt="Clarity English - Support information" style="border:0; margin:0; text-align:center"/>
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#1A6585; font-weight:bold;">Clarity English subscription: {$account->name}</p>

		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Your Clarity English subscription started a week ago. This is just a quick note to check that it is up and running smoothly, and your colleagues and library members have been able to access the learning resources.</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Once a month we will send you usage statistics, so you can see, with a couple of clicks, how many learners are using the program{if $multipleTitles=='true'}s{/if}, and what they are doing. I hope you find this useful.</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">You may also find it useful to visit the Clarity Support site: <a href='http://www.clarityenglish.com/lib/resources/' target='_blank'>www.clarityenglish.com/lib/resources/</a></p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">You will find a member of support rerouces, including posters, videos, web images, screenshots, and more.</p>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 10px 0; padding:0; color:#000000;">Meanwhile, don't forget that if you have any queries, difficulties, requests or feedback, you are very welcome to contact me at any time.</p>
	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
	</div>
</div>
</body>
</html>