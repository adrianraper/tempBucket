{* Name: Forgot password *}
{* Description: Email sent when someone has forgotten their password. *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>ClarityEnglish - password reminder</title>
        <!-- <from>%22ClarityEnglish%22 %3Csupport@clarityenglish.com%3E</from> -->
        <style type="text/css">
  	    	@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
		</style>
    
    </head>
<body text="#000000" style="margin:0; padding:0;">

<div style="width:600px; margin:0 auto; padding:0;">
	       <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Clarity English - Usage Statistics" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px;">

    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">

	 <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400;  line-height:18px; margin: 0 0 10px 0; font-size: 13px;padding:0; color:#000000;">Dear {$user->name}</p>
         <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400;  line-height:18px; margin: 0 0 10px 0; font-size: 13px;padding:0; color:#000000;">We have received your password reminder request. Here are your login details, please keep them safely.</p>
        
          <div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
       <a href="http://www.clarityenglish.com" style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; color:151745; font-weight:700; font-size:13px;" target="_blank">www.ClarityEnglish.com</a>
            <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400;  line-height:18px; margin: 0; font-size: 13px; padding:2px 0 0 0; color:#000000;">Login name: <strong>{$user->name}</strong></p>
            <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400;  line-height:18px; margin: 0; font-size: 13px; padding:2px 0 0 0; color:#000000;">Email: <strong>{$user->email}</strong></p>
            <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400;  line-height:18px; margin: 0; font-size: 13px; padding:2px 0 0 0; color:#000000;">Learner ID: <strong>{$user->studentID}</strong></p>
          <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400;  line-height:18px; margin: 0; font-size: 13px; padding:2px 0 0 0; color:#000000;">Password: <strong>{$user->password}</strong></p>
        </div>

        
         <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400;  line-height:18px; margin: 0 0 10px 0; font-size: 13px;padding:0; color:#000000;">Please feel free to contact us if you have any questions.</p>
      
                    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400;  line-height:18px; margin: 0 0 10px 0; font-size: 13px;padding:0; color:#000000;">Best regards<br/>
		Adrian</p>
		{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
        <!-- 
-- Email footer
-->
{include file='file:includes/Monthly_Email_Footer.tpl'}



    </div>

</div>


</body>
</html>
