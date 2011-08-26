{* Name: Monthly usage statistics *}
{* Description: Monthly usage statistics *}
{* Variables: $account, $securityString *}
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - Usage Statistics</title>
		<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
</head>
<body>
<div style="width:600px; margin:0 auto; padding:0;">
	<img src="http://www.clarityenglish.com/images/email/email_banner.jpg" alt="Clarity English - Usage Statistics" style="font-family: Verdana, Arial, Helvetica, sans-serif; border:0; margin:0; text-align:center"/>
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-size: 12px; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-size: 12px; padding:0; color:#000000;">Please click below to see the monthly usage statistics for your account.</p>
        <div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
        	<span style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-size: 12px; padding:0; color:#000000;"><a href="http://www.ClarityEnglish.com/area1/ResultsManager/directUsageStats.php?session={$session}" target='_blank'>{$account->name} statistics</a></span>
        </div>
        
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-size: 12px; padding:0; color:#000000;">You can also use Results Manager on your Clarity English account page to see your usage statistics. Login with your admin account, shown below. If you would like us to remind you of your password, please just email us, or use the 'Forgot password' link on www.ClarityEnglish.com.</p>
        
        <div style="background-color:#EBEBEB; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
        	<span style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-size: 12px; padding:0; color:#000000;"><a href="http://www.ClarityEnglish.com" style="color:#003366; font-weight:bold;" target='_blank'>www.ClarityEnglish.com</a></span>
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; color:#000000; padding:2px 0 0 0; margin:0">Login name: <strong>{$account->adminUser->name}</strong></p>
		</div>
		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-size: 12px; padding:0; color:#000000;">Please let me know if you would like other statistics or a different format, we will do our best to help.</p>
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-size: 12px; padding:0; color:#000000;">Best regards<br/>
		Adrian</p>
		{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
    </div>
</div>
</body>
</html>
</html>