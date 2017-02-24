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
                
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Your Road to IELTS subscription has ended. If you would like to extend your subscription, please log in to  <a href="http://www.IELTSpractice.com?utm_source=EndToday&utm_medium=Link_IP&utm_campaign=IP_ReminderEmail" target="_blank">www.IELTSpractice.com</a>. Click "Extend my subscription" on the page.</P>
      <A style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px" href="http://www.ieltspractice.com?utm_source=EndToday&utm_medium=Btn_LoginExtend&utm_campaign=IP_ReminderEmail"><IMG 
      style="BORDER-RIGHT-WIDTH: 0px; BACKGROUND-COLOR: #f8931f; MARGIN: 0px 0 15px 5px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; COLOR: #3b1a09; BORDER-LEFT-WIDTH: 0px" 
      alt="Log in and extend your subscription now!" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/btn_remind_extend_off.jpg" 
      width=208 height=39></A>
                
              
           
        
               </div></td>
  </tr>
  
  <tr>
    <td colspan="3">
    
    
  

    
   
            
<div style="padding:0 48px;">
           
           		
                
            
                
                
                
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:15px 0; padding:0; color:#000000; line-height:18px;">Please feel free to contact us at <a href="mailto: support@ieltspractice.com">support@ieltspractice.com</a> if you have any questions.</p>

						<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0; padding:0; color:#000000; line-height:18px;">Best wishes</p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:10px 0 5px 0; padding:0; color:#000000; line-height:18px;"><img src="http://www.clarityenglish.com/images/email/ieltspractice/sign_cynthialau.jpg" width="103" height="33" alt="Cynthia Lau"/></p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">
                 	Cynthia Lau<br />
                    IELTSpractice Support Team</p>    
        
        
      
        
        </div>
            
    </td>
  </tr>
  
  
  
   
  

  <tr>
    <td height="81" colspan="3" background="http://www.clarityenglish.com/images/email/ieltspractice/img_btm_plain.jpg">        </td>
  </tr>
  

  
  <TR>
    <TD 
    background=http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_left.jpg 
    width=10></TD>
    <TD bgColor=#343434 width=579>
      <DIV 
      style="PADDING-BOTTOM: 20px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; PADDING-TOP: 20px">
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; FONT-WEIGHT: bold; PADDING-TOP: 0px">Clarity 
      Language Consultants Ltd<BR>(UK and Hong Kong since 1992)</P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; PADDING-TOP: 0px">T: 
      (+852) 2791 1787 | F: (+852) 2791 6484<BR>E: <A style="COLOR: #ffffff" 
      href="mailto:support@ieltspractice.com" 
      target=_blank>support@ieltspractice.com</A> | W: <A style="COLOR: #ffffff" 
      href="http://www.IELTSpractice.com" 
      target=_blank>www.IELTSpractice.com</A> </P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; PADDING-TOP: 0px">Your 
      privacy is important to us. Please review IELTSpractice.com privacy policy 
      by clicking here: <A style="COLOR: #ffffff" 
      href="http://www.ieltspractice.com/terms.php" 
      target=_blank>http://www.ieltspractice.com/terms.php</A></P></DIV></TD>
    <TD 
    background=http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_right.jpg 
    width=11></TD></TR>
</table>
</body>
</html>
