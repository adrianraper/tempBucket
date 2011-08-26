{* Name: IYJ Online subscription welcome *}
{* Description: Email sent when you have subscribed to IYJ online. *}
{* Parameters: $account *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Welcome to Clarity's It's Your Job</title>
	<!-- <cc>accounts@clarityenglish.com</cc> -->
	<!-- <bcc>andrew.stokes@clarityenglish.com</bcc> -->
</head>
<body>
{foreach name=orderDetails from=$account->titles item=title}
{* but don't add a section if this title is a hidden one (created as part of an EMU) *}
	{assign var='thisProductIsHidden' value='false'}
	{foreach from=$hiddenProducts item=blockedCode}
		{if $blockedCode==$title->productCode}
			{assign var='thisProductIsHidden' value='true'}
		{/if}
	{/foreach}
	{if $thisProductIsHidden=='false'} 
	
<div style="margin: 8px;">
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" width="600" border="0" cellpadding="0" cellspacing="0">
  <!--Header area-->
  <tr>
	<td colspan="5" height="82" background="http://www.clarityenglish.com/itsyourjob/images/email/headerbg.jpg">
    	<img src="http://www.clarityenglish.com/itsyourjob/images/email/header1.jpg" alt="It's Your Job" border="0"/>
	</td>
  </tr>
    <tr>
	<td background="http://www.clarityenglish.com/itsyourjob/images/email/header2.jpg"  colspan="5" height="60" valign="middle">
        <table width="600" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-weight:bold; font-size:18px;">Welcome to It's Your Job</span></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="357" height="3" background="http://www.clarityenglish.com/itsyourjob/images/email/title_line.jpg"></td>
            <td width="218"></td>
          </tr>
        </table>
        </td>
  </tr>
  <tr>
	<td colspan="5" height="10"></td>
  </tr>
  <tr>
    <td width="25"></td>
    <td width="435">
   		<p style="margin: 0 0 10px 0; padding:0;">Dear {$account->adminUser->name}</p>
        <p style="margin: 0 0 10px 0; padding:0;">Thank you for subscribing to It's Your Job. It's Your Job is ten-unit online course which will provide you with the skills and knowledge necessary for a successful job search. An account has been created for you. To access the account, please go to this URL:</p>
        <p style="margin: 0 0 10px 0; padding:0;"><a href="http://www.ClarityLifeSkills.com/ItsYourJob" target="_blank">www.ClarityLifeSkills.com</a></p>
        
        <p style="margin: 0 0 5px 0; padding:0; font-weight:bold">Enter your login details as follows:</p>

       <!--Login details-->
        <table border="0" cellspacing="0" cellpadding="0" background="http://www.clarityenglish.com/itsyourjob/images/email/wel_bg.jpg" width="400" height="60" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td colspan="2" height="15"></td>
  </tr>
  <tr>
    <td width="15"></td>
    <td width="385" height="15">
        <span style="font-weight:bold; color:#1B1464;">Login name:</span> {$account->adminUser->email}</td>
  </tr>

  <tr>
    <td width="15"></td>
    <td width="385" height="15"><span style="font-weight:bold; color:#1B1464;">Password:</span>
              {$account->adminUser->password}</td>
  </tr>
 <tr>
    <td colspan="2" height="15"></td>
  </tr>
</table>
          <!--Subscription details-->
         <table width="100%" border="0" cellpadding="0" cellspacing="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td colspan="2" height="15"></td>
    </tr>
   <tr>
    <td colspan="2">Your subscription starts and ends on the following dates:</td>
    </tr>
    <tr>
    <td colspan="2" height="5"></td>
    </tr>
  <tr>
    <td width="15"></td>
    <td width="428" height="15">
        <span style="font-weight:bold; color:#1B1464;">Subscription start date:</span> {$title->licenceStartDate|date_format:"%B %e, %Y"}</td>
  </tr>

  <tr>
    <td width="15"></td>
    <td width="428" height="15"><span style="font-weight:bold; color:#1B1464;">Subscription end date:</span>
              {$title->expiryDate|date_format:"%B %e, %Y"}</td>
  </tr>
</table>
        <!--User details-->
        <table width="100%" border="0" cellpadding="0" cellspacing="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
   <tr>
    <td colspan="2" height="15"></td>
    </tr>
   <tr>
    <td colspan="2">Below are the details you have entered while registering for It's Your Job.  Please keep this email for future reference.</td>
    </tr>
     <tr>
    <td colspan="2" height="5"></td>
    </tr>
  <tr>
    <td width="15"></td>
    <td width="428" height="15">
        <span style="font-weight:bold; color:#1B1464;">User's  full name:</span> {$account->adminUser->name}</td>
  </tr>

  <tr>
    <td width="15"></td>
    <td width="428" height="15"><span style="font-weight:bold; color:#1B1464;">Email:</span>
              {$account->adminUser->email}</td>
  </tr>
  
    <tr>
    <td width="15"></td>
    <td width="428" height="15"><span style="font-weight:bold; color:#1B1464;">Country:</span>
              {$account->adminUser->country}</td>
  </tr>
    <tr>
      <td></td>
      <td width="428" height="15"><span style="font-weight:bold; color:#1B1464;">Contact method:</span>
                        {$account->adminUser->contactMethod}</td>
    </tr>
</table>
        <p style="margin: 10px 0 10px 0; padding:0;">If you wish to change this information, you can do so at any time by logging in to It's Your Job and clicking on the My Account tab.</p>

        {include file='file:includes/IYJ_Email_Signature.tpl'}
		</td>
    <td width="10"></td>
    <td width="5" style="border-left:1px #CCCCCC solid;"></td>
    <td width="105" valign="top">
    	<table border="0" cellspacing="0" cellpadding="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
        	<!--Start Learning Button-->
        	<tr>
            	<td align="center">
                	<a href="http://www.ClarityLifeSkills.com/ItsYourJob" target="_blank"><img src="http://www.clarityenglish.com/itsyourjob/images/email/start_but.jpg" width="105" height="114" border="0" alt="Start Learning Now!"/></a>
                  </td>
             </tr>
             <!--End of Start Learning Button-->
        </table>
</td>
  </tr>
  <tr>
    <td colspan="5" height="10"></td>
  </tr>
  <tr>
    <td colspan="5" height="5"  style="border-top:1px #CCCCCC solid;"></td>
  </tr>
  <tr>
    <td colspan="5" height="10">
    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="25"></td>
                <td width="441" style="font-size:9px">
           	      {include file='file:includes/IYJ_Email_Unsubscribe.tpl'}  
                </td>
                <td width="134"></td>
          </tr>
         </table>
         </td>
  </tr>
{/if} 
{/foreach}
</table>
</div>
</body>
</html>