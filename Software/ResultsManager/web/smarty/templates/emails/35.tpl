{* Name: Subscription reminders, start +6months *}
{* Description: Email x. Six and a half months after starting. *}
{* Variables: $account *}
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Clarity English - Feedback</title>
	<!-- <from>%22Clarity English%22 %3Csupport@clarityenglish.com%3E</from> -->
	<!-- <bcc>admin@clarityenglish.com</bcc> -->
    	       <style>
    		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
			</style>
</head>
<body text="#000000" style="margin:0; padding:0;">
<div style="width:600px; margin:0 auto; padding:0;">
		<img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Clarity English - Feedback" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Clarity English Subscription: {$account->name}</p>

		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">I thought I would drop you a quick note as you are now just over six months into your Clarity English subscription. I hope everything is running smoothly and you are continuing to find the programs useful.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">I wanted to take this opportunity to invite you to fill in a quick questionnaire. It shouldn't take more than ten minutes, and the objective is to enable us to enhance the service we are providing to you.  If you'd like to do this, please click <a href="http://www.clarityenglish.com/questionnaire/cefeedback.php" target="_blank">here</a>.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Incidentally, you might be interested to know that we are constantly improving the online support for all our programs. To find out more, please click <a href='http://www.clarityenglish.com/support' target='_blank'>here</a>.</p>
		 <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">As ever, if you have any queries or requests, please get in touch.</p>
        
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
