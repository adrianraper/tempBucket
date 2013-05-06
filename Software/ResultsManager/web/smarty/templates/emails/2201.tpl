{* Name: IELTSPractice.com - expired yesterday *}
{* Description: Email sent when an individual's subscription expired yesterday. *}
{* Parameters: $account *}
{foreach name=orderDetails from=$account->titles item=title}
	{if $title->productCode==52 || $title->productCode==53}
		{assign var='expiryDate' value=$title->expiryDate}
	{/if}
{/foreach}

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Your IELTSpractice subscription has ended.</title>
	<!-- <from>%22IELTSPractice.com%22 %3Csupport@ieltspractice.com%3E</from> -->
	<!-- <bcc>alfred.ng@clarityenglish.com</bcc> -->
</head>
<body style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; background-color:#E5E5E5;">
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/ieltspractice/bg.jpg" bgcolor="#FFFFFF">
  <tr>
    <td colspan="3">
		<a href="http://www.ieltspractice.com" target="_blank"><img src="http://www.clarityenglish.com/images/email/ieltspractice/header.jpg" alt="Road to IELTS: IELTS preparation and practice" width="600" height="173" border="0" style="margin:0; font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; "/></a>        </td>
  </tr>
        
        <tr>
        	<td height="53" colspan="3" background="http://www.clarityenglish.com/images/email/ieltspractice/subtitle.jpg">
            	<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0; padding:0 48px; color:#FFFFFF; line-height:53px; font-weight:bold;">Your subscription has ended.</p>
             </td>
        </tr>
        
        
  <tr>
    <td colspan="3">
        
	  <div style="padding:0 48px;">
           
           		<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Dear {$account->adminUser->name}</p>
                
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Your Road to IELTS subscription has ended. If you would like to extend your subscription, please log in to  <a href="http://www.IELTSpractice.com" target="_blank">www.IELTSpractice.com</a>. Click "Renew my licence" on the page.</p>
                
              
                
                
                
           
        
        <A style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px" href="http://www.ieltspractice.com" target="_blank">
     <IMG 
      style="BORDER-RIGHT-WIDTH: 0px; BACKGROUND-COLOR: #f8931f; MARGIN: 0px 0px 15px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; COLOR: #3b1a09; BORDER-LEFT-WIDTH: 0px" 
      alt="Log in and resubscribe now!" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/btn_reminder_renew.jpg" 
      width=183 height=40></A>       </div></td>
  </tr>
  
  <tr>
    <td colspan="3">
    
    
    <table width="600" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/ieltspractice/img_reminder_next.jpg">
  <tr>
    <td width="66" height="82">&nbsp;</td>
    <td>&nbsp;</td>
    <td width="90">&nbsp;</td>
  </tr>
  <tr>
    <td height="60"></td>
    <td valign="top">
    	<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 15px; margin:0; padding:0; color:#FFFFFF; line-height:18px;">Your learning doesn’t stop here. Enhance your career<br />
prospects by learning essential English skills for your daily life!</p>
	</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="140">&nbsp;</td>
    <td valign="top">
    	<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0; padding:0 220px 0 0; color:#FFFFFF; line-height:18px;">ClarityLifeSkills is the ideal place to improve your English in general, and prepare for English language exams. A variety of online programs and courses enable you to practise your reading, writing, grammar, listening, speaking, vocabulary and pronunciation.</p>
	</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="59">&nbsp;</td>
    <td valign="top"> <a href="http://www.claritylifeskills.com?utm_source=EndToday&utm_medium=Btn_Findmore&utm_campaign=ReminderEmail" target="_blank"><img src="http://www.clarityenglish.com/images/email/ieltspractice/btn_reminder_cls_more.jpg" alt="Find out more" width="149" height="40" style="margin:0 0 15px 0; border:0; background-color:#EFB32F; color:#4B2808;"/></a></td>
    <td>&nbsp;</td>
  </tr>
  
</table>

    
   
            
<div style="padding:0 48px;">
           
           		
                
            
                
                
                
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:15px 0; padding:0; color:#000000; line-height:18px;">Please feel free to contact us at <a href="mailto: support@ieltspractice.com">support@ieltspractice.com</a> if you have any questions.</p>

						<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0; padding:0; color:#000000; line-height:18px;">Best wishes</p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:5px 0; padding:0; color:#000000; line-height:18px;"><img src="http://www.clarityenglish.com/images/email/ieltspractice/sign_nicolelung.jpg" width="103" height="25" alt="Nicole Lung"/></p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0; padding:0; color:#000000; line-height:18px;">
                 	Nicole Lung<br />
                    Marketing Executive, Clarity</p>    
        
        
      
        
        </div>
            
    </td>
  </tr>
  
  
  
   
  

  <tr>
    <td height="81" colspan="3" background="http://www.clarityenglish.com/images/email/ieltspractice/img_btm_plain.jpg">        </td>
  </tr>
  

  
  <tr>
        <td width="10" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_left.jpg">            </td>
        <td width="579"  bgcolor="#343434">
       <div style="padding:20px 48px;">
         
            
            
             <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0 0 15px 0; padding:0; color:#FFFFFF; line-height:18px; font-weight:bold;">Clarity Language Consultants Ltd<br />(UK and Hong Kong since 1992)</p>
			  
			 <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0 0 15px 0; padding:0; color:#FFFFFF; line-height:18px;">
                T: (+852) 2791 1787 | F: (+852) 2791 6484<br />
               E: <a href="mailto:info@clarityenglish.com" target="_blank"  style="color:#FFFFFF;">info@clarityenglish.com</a> | W: <a href="http://www.ClarityEnglish.com" target="_blank"  style="color:#FFFFFF;">www.ClarityEnglish.com</a>
              </p> 
              
               <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0; padding:0; color:#FFFFFF; line-height:18px;">
               Your privacy is important to us. Please review IELTSpractice.com privacy
policy by clicking here: <a href="http://www.clarityenglish.com/disclaimer.php" target="_blank" style="color:#FFFFFF;">http://www.clarityenglish.com/disclaimer.php</a></p>
    </div>
        
        
        </td>
        <td width="11" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_right.jpg"></td>
  </tr>
</table>
</body>
</html>
