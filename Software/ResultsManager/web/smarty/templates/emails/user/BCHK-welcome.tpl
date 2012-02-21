{* Name: R2iV2 BC registration welcome *}
{* Description: Email sent when you have first used R2iV2. *}
{* Parameters: $user *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Welcome to Road to IELTS V2</title>
	<!-- <from>support@roadtoielts.com</from> -->
	<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
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
    <td>Dear {$user->name}</td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td>Thank you for trying out Road to IELTS V2. An account has been created for you. To access the account, please go to this URL:</td>
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
       Login name: <strong>{$user->studentID}</strong></td>
  </tr>

  <tr>
    <td width="15"></td>
    <td width="305" height="15">Password: <strong>{$user->password}</strong></td>
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
{include file='file:includes/BCHK_Email_Signature.tpl'}

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