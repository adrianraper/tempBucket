{* Name: R2iV2 BC HK registration welcome *}
{* Description: Email sent when you someone from Hong Kong registers for R2IV2 using a serial number/password. *}
{* Parameters: $user *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Welcome to the new Road to IELTS</title>
	<!-- <from>support@roadtoielts.com</from> -->
</head>
<body>
<div style="margin: 8px;">
<table width="610" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td>
	<div style="padding:10px; margin:0;">
	<img src="http://www.clarityenglish.com/images/email/rti2/welcome_banner.jpg" alt="Road to IELTS" width="586" height="117" style="border:0; display:block; text-align:center;"/>
<div style="margin:0; padding:0;">
	<div style="width:290px; float:left;">
	<img src="http://www.clarityenglish.com/images/email/rti2/welcome_left_top.jpg" alt="Advice and tutorials" width="278" height="200" border="0" style="display:block;"/><br style="display:none;"/>
    <img src="http://www.clarityenglish.com/images/email/rti2/welcome_left_mid.jpg" alt="Starting out" width="278" height="167" border="0" style="display:block;"/><br style="display:none;"/>
	</div>    
    <div style="width:300px; float:right; padding:10px 0 10px 0;">
   	  <div style="margin:0; padding:0;">
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:5px 0 5px 0; padding:0; color:#000000; line-height:18px;">Dear {$user->name},</p>
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">Welcome to the new Road to IELTS online preparation platform. You can login at the following URL with your ID and password.</p>
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><a href="http://www.roadtoielts.com/BritishCouncil/login.php" target="_blank">www.roadtoielts.com/BritishCouncil</a></p>
			<div style="margin:10px 50px 30px 10px; padding:0; background-color:#999999;">
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; padding:10px 0 0 0; margin:10px 20px 5px 20px; color:#000000; line-height:18px; ">Login ID: {$user->studentID}</p>
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; padding:0 0 10px 0; margin:0 20px 5px 20px; line-height:18px; ">Password: {$user->password}</p>
			</div>
            <a href="http://www.roadtoielts.com/BritishCouncil/login.php?loginID={$user->studentID}" target="_blank" style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;"><img src="http://www.clarityenglish.com/images/email/rti2/btn_welcome_eng.jpg" width="225" height="45"  border="0" style="display:block; margin:10px 0;" alt="Start using Road to IELTS now"/></a>
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:20px 0 5px 0; padding:0; color:#000000; line-height:18px;">We hope you will find the training useful. Please contact us at <a href="mailto:examinations@britishcouncil.org.hk?subject=New Road to IELTS enquiry">examinations@britishcouncil.org.hk</a> if you have any comments or queries regarding the new platform.</p>
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:20px 0 0 0; padding:0; color:#000000; line-height:18px;">Examinations Services</p>
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">The British Council</p>
       </div>
    </div>
    <div style="clear:both;"></div>
</div>
   <table width="586"  border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="425" height="50" valign="top" nowrap="nowrap" background="http://www.clarityenglish.com/images/email/rti2/welcome_foot_bg.jpg" >
        <div style="padding:0 0 0 30px; margin:0; line-height:40px; color:#FFFFFF;">
        <a href="http://www.takeielts.britishcouncil.org" target="_blank" style="color:#FFFFFF; text-decoration:none; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; ">www.takeielts.britishcouncil.org</a>        
		</div>
    </td>
    <td width="79" height="50" valign="top">
    	<a href="http://www.britishcouncil.org/hongkong" target="_blank" style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;">
        <img src="http://www.clarityenglish.com/images/email/rti2/welcome_foot_bc.jpg" alt="British Council" width="79" height="40" border="0" style="display:block;"/>        </a>
    </td>
    <td width="82" height="50" valign="top">
    	<a href="http://www.clarityenglish.com/" target="_blank" style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;">
    	<img src="http://www.clarityenglish.com/images/email/rti2/welcome_foot_clarity.jpg" alt="Clarity" width="82" height="40" border="0" style="display:block;"/>        </a>        
	</td>
  </tr>
</table>
    </div>
    </td>
  </tr>
</table>
</div>
</body>
</html>