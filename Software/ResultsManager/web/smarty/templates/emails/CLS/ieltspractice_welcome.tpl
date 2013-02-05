{* Name: IELTSPractice.com welcome *}
{* Description: Email sent to Road to IELTS home user purchaser *}
{* Parameters: $account, $api *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>IELTSpractice - Your new account ({$api->subscription->id})</title>
	<!-- <from>support@ieltspractice.com</from> -->
	<!-- <bcc>accounts@clarityenglish.com,support@ieltspractice.com</bcc> -->
</head>
<body style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; background-color:#E5E5E5;">
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/ieltspractice/bg.jpg" bgcolor="#FFFFFF">
  <tr>
    <td colspan="3">
		<a href="http://www.ieltspractice.com" target="_blank"><img src="http://www.clarityenglish.com/images/email/ieltspractice/header.jpg" alt="Road to IELTS: IELTS preparation and practice" width="600" height="173" border="0" style="margin:0; font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; "/></a>        </td>
  </tr>
        
        <tr>
        	<td height="53" colspan="3" background="http://www.clarityenglish.com/images/email/ieltspractice/subtitle.jpg">
            	<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0 48px; color:#FFFFFF; line-height:53px; font-weight:bold;">Welcome to IELTSpractice.com</p>                </td>
        </tr>
        
        
  <tr>
    <td colspan="3">
        
	  <div style="padding:0 48px;">
           
           		<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Dear {$api->subscription->name}</p>
           
        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">An account has been created for you. To access the account, please go to this URL:
        <a href="http://www.IELTSpractice.com" target="_blank">www.IELTSpractice.com</a>.</p>
        
        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Your login details are as below:</p>
        
        <div style="border:#CCCCCC 1px solid; padding:10px; margin:0 0 15px 0;">
       	  <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 14px; margin:0 0 5px 0; padding:0; color:#0399D6; font-weight:bold;line-height:18px;">Login details</p>
            <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">
            	<strong>Member name: </strong>{$api->subscription->email}</p>
            <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">
            	<strong>Password: </strong>{$api->subscription->password}</p>
            <a href="http://www.IELTSPractice.com" target="_blank">
            <img src="http://www.clarityenglish.com/images/email/ieltspractice/btn_learn.jpg" width="190" height="42" border="0" />
            </a>
          </div>
        	 <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Below are the details you  entered while registering at IELTSpractice.com.
Please keep this email for later reference.</p>
             
             <div style="border:#CCCCCC 1px solid; padding:10px; margin:0 0 15px 0;">
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 14px; margin:0 0 5px 0; padding:0; color:#0399D6; font-weight:bold;line-height:18px;">Personal details</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Reference number: </strong>{$api->subscription->id}</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Name: </strong>{$api->subscription->name}</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Email: </strong>{$api->subscription->email}</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Subscription: </strong> {$api->offerName}</p>
                
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Expires on: </strong>{format_ansi_date ansiDate=$api->subscription->expiryDate format='%d %B %Y'}</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Payment method: </strong>{$api->paymentMethod}</p>
			</div>
           </div>	 </td>
  </tr>
  
  <tr>
    <td colspan="3">
    
    <table width="600" height="219" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/ieltspractice/img_btm_study.jpg">
                    <tr>
                      <td width="48">                              </td>
                      <td width="367" height="233" valign="top">
                   	    <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Please feel free to contact us at <a href='mailto:support@ieltspractice.com'>support@ieltspractice.com</a> if you have any questions.</p>

						<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Best wishes</p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:15px 0; padding:0; color:#000000; line-height:18px;"><img src="http://www.clarityenglish.com/images/email/ieltspractice/sign_nicolelung.jpg" width="103" height="25" alt="Nicole Lung"/></p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">
                 	Nicole Lung<br />
                    Marketing Executive, Clarity</p>                    </td>
                      <td width="185" valign="top"></td>
                    </tr>
                  </table>    </td>
  </tr>
  
  
  <tr>
        <td width="10" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_left.jpg">            </td>
        <td width="579"  bgcolor="#343434">
       <div style="padding:20px 48px;">
         
            
            
             <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#FFFFFF; line-height:18px; font-weight:bold;">Clarity Language Consultants Ltd<br />(UK and Hong Kong since 1992)</p>
			  
			 <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#FFFFFF; line-height:18px;">
                T: (+852) 2791 1787 | F: (+852) 2791 6484<br />
              E: <a href="mailto:support@ieltspractice.com" style="color:#FFFFFF;">support@ieltspractice.com</a> | W: <a href="http://www.IELTSpractice.com" target="_blank" style="color:#FFFFFF;">www.IELTSpractice.com</a>              </p> 
              
               <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; 0; padding:0; color:#FFFFFF; line-height:18px;">
               Your privacy is important to us. Please review IELTSpractice.com privacy
policy by clicking here: <a href="http://www.ieltspractice.com/terms.php" target="_blank" style="color:#FFFFFF;">http://www.ieltspractice.com/terms.php</a></p>
    </div>
        
        
        </td>
        <td width="11" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_right.jpg"></td>
  </tr>
</table>



</body>
</html>
