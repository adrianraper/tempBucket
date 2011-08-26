{* Name: CLS Online subscription welcome *}
{* Description: Email sent when you have subscribed to CLS online. *}
{* Parameters: $account *}
{* Updated for CLS v2 with packages *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Welcome to iLearnIELTS</title>
	<!-- <from>support@ilearnIELTS.com</from> -->
	<!-- <cc>accounts@ilearnIELTS.com</cc> -->
</head>
<body>
	
<div style="margin: 8px;">
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#52414D;" width="611" border="0" cellpadding="0" cellspacing="0">
  
  <!--Header area-->
  <tr>
	<td width="611" height="108">
      <a href="http://www.ilearnIELTS.com/eng/index.php" target="_blank">
      	<img src="http://www.ilearnielts.com/eng/email/images/email_welcome_banner.jpg" alt="www.iLearnIELTS.com" width="611" height="108" border="0"/>
        </a>
     </td>
  </tr>
    <tr>
	<td>
    <!--Start Content-->
    <table width="611" border="0" cellspacing="0" cellpadding="0" style="color:#52414D;">
  <tr>
    <td width="29" rowspan="22"></td>
    <td width="553" height="20">    </td>
    <td width="29" rowspan="22"></td>
  </tr>

  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td>
    <!--Introduction line-->
    	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td style="font-size:12px; font-weight:bold; color:#4D4D4D;">Thank you for your order {$account->adminUser->name}</td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td style="color:#4D4D4D;">
    
    An account has been created for you. Below is a summary of your information.</td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td><a href="http://www.iLearnIELTS.com" target="_blank">www.iLearnIELTS.com</a></td>
  </tr>
  
  <tr>
    <td height="10"></td>
  </tr>

  <tr>
    <td height="10" background="http://www.ilearnielts.com/eng/email/images/dottedlines.jpg"></td>
  </tr>
  
   <tr>
    <td height="10"></td>
  </tr>

  <tr>
    <td style="color:#52412D; font-size:14px; font-weight:bold;">Log in information:</td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
 <tr>
    <td height="10" style="color:#4D4D4D;">Please use the following information to log in:</td>
  </tr>
  
  <tr>
    <td height="10"></td>
  </tr>
  
  <tr>
    <td height="10" style="color:#4D4D4D;"><strong>Login name:</strong> {$account->adminUser->email}</td>
  </tr>
   <tr>
    <td height="5"></td>
  </tr>
  <tr>
    <td height="10" style="color:#4D4D4D;"><strong>Password:</strong> {$account->adminUser->password}</td>
  </tr>
  
    <tr>
    <td height="10"></td>
  </tr>
  
      <tr>
    <td><a href="http://www.ilearnIELTS.com/eng/index.php" target="_blank"><img src="http://www.ilearnielts.com/eng/email/images/btn_startlearning.jpg" alt="Start learning now!" width="126" height="36" style="color:#5F3479; font-weight:bold; font-size:12px; border:0"/></a></td>
  </tr>
  
  
  <tr>
	<td height="10">    </td>
  </tr>
  
    <tr>
    <td height="10" background="http://www.ilearnielts.com/eng/email/images/dottedlines.jpg"></td>
  </tr>
  
   <tr>
	<td height="10">    </td>
  </tr>

  
  
  <tr>
    <td style="color:#52412D; font-size:14px; font-weight:bold;">Your information:</td>
  </tr>

  
    <tr>
    <td height="10"></td>
  </tr>
  
   <tr>
    <td height="10" style="color:#4D4D4D;"><strong>Your name:</strong> {$account->adminUser->name}</td>
  </tr>
   <tr>
    <td height="5"></td>
  </tr>
  <tr>
    <td height="10" style="color:#4D4D4D;"><strong>Email:</strong> {$account->adminUser->email}</td>
  </tr>
   <tr>
    <td height="5"></td>
  </tr>
   <tr>
    <td height="10" style="color:#4D4D4D;"><strong>Country:</strong> {$account->adminUser->country}</td>
  </tr>
   <tr>
    <td height="5"></td>
  </tr>
   <tr>
    <td height="10" style="color:#4D4D4D;"><strong>City:</strong> {$account->adminUser->city}</td>
  </tr>
</table>
 	<!--End of Introduction line-->	</td>
  </tr>
 
  <tr>
    <td height="10"></td>
    </tr>

 <tr>
    <td height="10" background="http://www.ilearnielts.com/eng/email/images/dottedlines.jpg"></td>
  </tr>

  <tr>
    <td height="10"></td>
  </tr>
  
  
  
  <tr>
    <td height="10">
{include file='file:includes/iLearn_Email_Signature.tpl'}	</td>
    </tr>
  <tr>
    <td>        </td>
    </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td height="10" style="font-size:9px">
   		Your privacy is important to us. Please review iLearnIELTS.com privacy policy by clicking here:<br />
<a href="http://www.iLearnIELTS.com/eng/terms.php" target="_blank">http://www.iLearnIELTS.com/Eng/Terms.php</a>    </td>
    </tr>
  <tr>
    <td>    </td>
    </tr>
  <tr>
    <td></td>
    <td width="8"></td>
    <td width="6"></td>
  </tr>
</table>

    
    <!--End of Content--></td>
  </tr>
</table>
</div>
</body>
</html>