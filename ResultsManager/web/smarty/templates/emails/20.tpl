{* Name: Monthly usage statistics *}
{* Description: Monthly usage statistics *}
{* Variables: $account, $securityString *}
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - Usage Statistics</title>
		<!-- <cc>adrian.raper@clarityenglish.com</cc> -->
<style type="text/css">
{literal}
<!--
p {
	margin: 0 0 6px 0; 
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
-->
{/literal}
</style>
</head>
<body style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;">
	
<div style="margin: 8px; 
		background-image:url(http://www.ClarityEnglish.com/images/banner_user_statistics.jpg);
		background-repeat: no-repeat;
		background-position: left top;
		width: 600px;
		">&nbsp;
	<div style="margin-left: 16px; 
				margin-right: 32px;
				margin-top: 115px;
				margin-bottom: 10px;
		">
		<p>Dear Colleague</p>
	  <p>Please click below to see the monthly usage statistics for your account.</p>
	  <div style="margin-left: 16px; 
					margin-right: 32px;
					margin-top: 12px;
					margin-bottom: 12px;
					background-color: #EBEBEB;
					width:500px;">&nbsp;
			<div style="padding: 10px 4px 18px 40px;
				">
				<p><strong><a href="http://www.ClarityEnglish.com/area1/ResultsManager/directUsageStats.php?session={$session}" target='_blank'>{$account->name} statistics<a></strong></p>
			</div>
	  </div>
<p>You can access Results Manager any time on your Clarity English account page using your login name and password, which are shown below.
You can also use this page to change your account details.</p>
		<div style="margin-left: 16px; 
					margin-right: 32px;
					margin-top: 12px;
					margin-bottom: 12px;
					background-color: #EBEBEB;
					width:500px;">&nbsp;
			<div style="padding: 10px 4px 18px 40px;
				">
				<p><strong><a href="http://www.ClarityEnglish.com" target="_blank">www.ClarityEnglish.com</a></strong><br/>
				Login name: <strong>{$account->adminUser->name}</strong><br/>
				Password: <strong>{$account->adminUser->password}</strong><br/>
			</div>
		</div>
<p>Please let me know if you would like other statistics or a different format, we will do our best to help.</p>
{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
	</div>
</div>
</body>
</html>