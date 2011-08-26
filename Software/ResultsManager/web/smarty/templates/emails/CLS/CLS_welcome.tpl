{* Name: CLS Online subscription welcome *}
{* Description: Email sent when you have subscribed to CLS online. *}
{* Parameters: $account *}
{* Updated for CLS v2 with packages *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Welcome to ClarityLifeSkills</title>
	<!-- <from>support@claritylifeskills.com</from> -->
	<!-- <cc>accounts@clarityenglish.com</cc> -->
	<!-- <bcc>andrew.stokes@clarityenglish.com</bcc> -->
</head>
<body>
	
<div style="margin: 8px;">
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" width="600" border="0" cellpadding="0" cellspacing="0">
  
  <!--Header area-->
  <tr>
	<td width="600" height="96" background="http://www.claritylifeskills.com/email/header_purple.jpg">
      <a href="http://www.ClarityLifeSkills.com/">
      	<img src="http://www.claritylifeskills.com/email/header_purple.jpg" alt="www.ClarityLifeSkills.com" width="600" height="96" border="0"/>
      </a>
      </td>
  </tr>
    <tr>
	<td>
    <!--Start Content-->
    <table width="600" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="24" rowspan="22"></td>
    <td height="20">    </td>
    <td width="24" rowspan="22"></td>
  </tr>
  <tr>
    <td background="http://www.claritylifeskills.com/email/title_text.jpg">
    	<img src="http://www.claritylifeskills.com/email/title_text.jpg" alt=" Welcome to ClarityLifeSkills" width="550" height="27" border="0" style="color:#5F3479; font-weight:bold; font-size:18px; border:0"/>        </td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td>
    <!--Introduction line-->
    	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td>Dear {$account->adminUser->name}</td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td>Thank you for subscribing to ClarityLifeSkills. An account has been created for you. To access the account, please go to this URL:</td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td><a href="http://www.ClarityLifeSkills.com" target="_blank">www.ClarityLifeSkills.com</a></td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td>Enter your login details as follows:</td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td height="10"><table border="0" cellspacing="0" cellpadding="0" bgcolor="#EBEBEB" width="100%" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td width="64%">
    	<!--Login details-->
        <table width="100%" height="60" border="0" cellpadding="0" cellspacing="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td colspan="2" height="15"></td>
  </tr>
  <tr>
    <td width="15"></td>
    <td width="305" height="15">
       Login name: <strong>{$account->adminUser->email}</strong></td>
  </tr>

  <tr>
    <td width="15"></td>
    <td width="305" height="15">Password: <strong>{$account->adminUser->password}</strong></td>
  </tr>
 <tr>
    <td colspan="2" height="15"></td>
  </tr>
</table>
		<!--End of Login details-->	</td>
    <td width="36%"><a href="http://www.claritylifeskills.com/members/login.php"><img src="http://www.claritylifeskills.com/email/start_but_purple.jpg" alt="Start learning now!" style="color:#5F3479; font-weight:bold; font-size:12px; border:0"/></a></td>
  </tr>
</table></td>
  </tr>
  
    <tr>
    <td height="5"></td>
  </tr>
</table>
 	<!--End of Introduction line-->	</td>
  </tr>
    <tr>
    <td height="10" background="http://www.claritylifeskills.com/email/box_line.jpg"></td>
  </tr>
  <tr>
    <td height="5"></td>
  </tr>
  <tr>
    <td>You have subscribed to:</td>
  </tr>
<!--Subscription details-->
{* We currently only have two mutually exclusive packages. So if they have ordered TB it means they have package 1, if IYJ then package 2 *}
{* Not at all sure how we would work this out if more packages become overlapping. Will need a package ID(s) somewhere in T_AccountRoot *}
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
	{assign var='thisPackageList' value='3,9,33,39'}
	{include file='file:includes/CLS_welcome_package_details.tpl'}	
{/if}
{if $careerEnglishpackage=='true'}
	{assign var='thisImage' value='title_CE_email.jpg'}
	{assign var='thisName' value='Career English'}
	{assign var='thisPackageList' value='10,40,43,1001'}
	{include file='file:includes/CLS_welcome_package_details.tpl'}	
{/if}
  
  <tr>
    <td height="5"></td>
  </tr>
  <tr>
    <td height="10" background="http://www.claritylifeskills.com/email/box_line.jpg"></td>
  </tr>
  <tr>
    <td height="5"></td>
    </tr>
  <tr>
    <td>
    <!--End user details-->
    <table width="100%" border="0" cellpadding="0" cellspacing="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
   
   <tr>
    <td width="443">Below are the details you have entered while registering for ClarityLifeSkills. Please keep this email for later reference.</td>
    </tr>
     <tr>
       <td height="5"></td>
     </tr>
     <tr>
    <td>
    <table width="100%" height="60" border="0" cellpadding="0" cellspacing="0" bgcolor="#EBEBEB" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" >
  <tr>
    <td colspan="2" height="15"></td>
  </tr>
  <tr>
    <td width="15"></td>
    <td width="305" height="15">
       Your name: <strong>{$account->adminUser->name}</strong></td>
  </tr>

  <tr>
    <td width="15"></td>
    <td width="305" height="15">Email: <strong>{$account->adminUser->email}</strong></td>
  </tr>
  
    <tr>
    <td width="15"></td>
    <td width="305" height="15">Country: <strong>{$account->adminUser->country}</strong></td>
  </tr>
  
   <tr>
    <td width="15"></td>
    <td width="305" height="15">Contact method: <strong>{$account->adminUser->contactMethod}</strong></td>
  </tr>
 <tr>
    <td colspan="2" height="15"></td>
  </tr>
</table>    </td>
    </tr>
</table>
	<!--End of End user details-->	</td>
  </tr>
  <tr>
    <td height="5"></td>
  </tr>
 <tr>
    <td height="10" background="http://www.claritylifeskills.com/email/box_line.jpg"></td>
  </tr>
  <tr>
    <td height="5"></td>
  </tr>
  
  
  
  <tr>
    <td height="10">
{include file='file:includes/CLS_Email_Signature.tpl'}

	</td>
    </tr>
  <tr>
    <td>        </td>
    </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td height="10" style="font-size:9px">
   		Your privacy is important to us. Please review ClarityLifeSkills.com privacy policy by clicking here:<br />
<a href="http://www.ClarityLifeSkills.com/disclaimer.php" target="_blank">www.ClarityLifeSkills.com/disclaimer.php</a>    </td>
    </tr>
  <tr>
    <td>    </td>
    </tr>
  <tr>
    <td></td>
    <td></td>
    <td></td>
  </tr>
</table>

    
    <!--End of Content--></td>
  </tr>
</table>
</div>
</body>
</html>