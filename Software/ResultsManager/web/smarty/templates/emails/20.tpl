
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>ClarityEnglish - Usage statistics</title>
		<!-- <from>%22ClarityEnglish%22 %3Csupport@clarityenglish.com%3E</from> -->
		<!-- <bcc>admin@clarityenglish.com</bcc> -->
        	<style type="text/css">
    		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
			</style>
</head>
<body text="#000000" style="margin:0; padding:0;">
{assign var='hasDPT' value='false'}
{if $account->titles|@count > 2}
    {assign var='multipleTitles' value='true'}
{else}
    {assign var='multipleTitles' value='false'}
{/if}
{foreach name=orderDetails from=$account->titles item=title}
    {if ($title->productCode=='63')}
        {assign var='hasDPT' value='true'}
    {/if}
{/foreach}
{if $hasDPT=='true' and $multipleTitles=='false'}
    {assign var='adminProgName' value='Admin Panel'}
{elseif $hasDPT=='true'}
    {assign var='adminProgName' value='Results Manager and Admin Panel'}
{else}
    {assign var='adminProgName' value='Results Manager'}
{/if}
<div style="width:600px; margin:0 auto; padding:0;">
		<img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="ClarityEnglish - Usage Statistics" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:400; font-size: 13px; line-height:18px; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:400; font-size: 13px; line-height:18px; padding:0; color:#000000;">Please click below to see the monthly usage statistics for your account.</p>
        <!-- both RM and AP -->
        {if $hasDPT=='true' and $multipleTitles=='true'}
            <div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
                <span style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:700; font-size: 13px; line-height:18px; padding:0; color:#151745;"><a href="https://www.ClarityEnglish.com/area1/ResultsManager/directUsageStats.php?session={$session}" target="_blank" style="color:#151745; font-weight:bold;">{$account->name} statistics</a></span>
            </div>
            <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:400; font-size: 13px; line-height:18px; padding:0; color:#000000;">And here for your Dynamic Placement Test usage.</p>
            <div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
                <span style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:700; font-size: 13px; line-height:18px; padding:0; color:#151745;"><a href="https://dpt.ClarityEnglish.com/admin" target="_blank" style="color:#151745; font-weight:bold;">{$account->name} DPT Admin Panel</a></span>
            </div>
        <!-- just AP -->
        {elseif $hasDPT=='true'}
            <div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
                <span style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:700; font-size: 13px; line-height:18px; padding:0; color:#151745;"><a href="https://dpt.ClarityEnglish.com/admin" target="_blank" style="color:#151745; font-weight:bold;">{$account->name} DPT Admin Panel</a></span>
            </div>
        <!-- just RM -->
        {else}
            <div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
                <span style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:700; font-size: 13px; line-height:18px; padding:0; color:#151745;"><a href="https://www.ClarityEnglish.com/area1/ResultsManager/directUsageStats.php?session={$session}" target="_blank" style="color:#151745; font-weight:bold;">{$account->name} statistics</a></span>
            </div>
        {/if}
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:400; font-size: 13px; line-height:18px; padding:0; color:#000000;">Or you can use {$adminProgName} to get the full reports. Sign in with your Admin account, shown below. If you would like us to remind you of your password, please just email us, or use the 'Forgot password' link on www.ClarityEnglish.com.</p>
        
        <div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
            <span style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-size: 13px; line-height:18px; padding:0; color:#000000;">
            <!-- both RM and AP -->
            {if $hasDPT=='true' and $multipleTitles=='true'}
                Go to: <a href="https://www.clarityenglish.com?utm_source=auto_email&utm_medium=edu_20&utm_term=link_home&utm_campaign=auto_statistics&utm_content=statistics_signin" style="color:#151745; font-weight:700;" target='_blank'>www.ClarityEnglish.com</a>
                and <a href="https://dpt.clarityenglish.com/admin?utm_source=auto_email&utm_medium=edu_20&utm_term=link_home&utm_campaign=auto_statistics&utm_content=statistics_signin" style="color:#151745; font-weight:700;" target='_blank'>dpt.ClarityEnglish.com/admin</a>
            <!-- just AP -->
            {elseif $hasDPT=='true' and $multipleTitles=='false'}
                Go to: <a href="https://dpt.clarityenglish.com/admin?utm_source=auto_email&utm_medium=edu_20&utm_term=link_home&utm_campaign=auto_statistics&utm_content=statistics_signin" style="color:#151745; font-weight:700;" target='_blank'>dpt.ClarityEnglish.com/admin</a>
            <!-- just RM -->
            {else}
                Go to: <a href="https://www.clarityenglish.com?utm_source=auto_email&utm_medium=edu_20&utm_term=link_home&utm_campaign=auto_statistics&utm_content=statistics_signin" style="color:#151745; font-weight:700;" target='_blank'>www.ClarityEnglish.com</a>
            {/if}
            </span>
            <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; color:#000000; padding:2px 0 0 0; margin:0">Login name: <span style="font-weight:700;">{$account->adminUser->name}</span></p>
	  </div>
	  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:400; font-size: 13px; line-height:18px; padding:0; color:#000000;">Please let us know if you would like other statistics or a different format. We will do our best to help. Alternatively, please feel free to contact your Account Manager to discuss usage statistics and any other matters connected to your account. </p>

<!-- 
-- Resellers' contact details - if any
-->
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}	  
	  
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; margin: 0 0 10px 0; font-weight:400; font-size: 13px; line-height:18px; padding:0; color:#000000;">Best regards<br/>
		</p>
		{include file='file:includes/SalesManager_Email_Signature.tpl'}
        <!-- 
-- Email footer
-->
{include file='file:includes/Monthly_Email_Footer.tpl'}
    </div>
</div>
</body>
</html>
</html>