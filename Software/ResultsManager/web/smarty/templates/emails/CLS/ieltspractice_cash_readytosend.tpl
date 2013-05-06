{* Name: IELTSPractice.com welcome *}
{* Description: Email sent to Road to IELTS home user purchaser *}
{* Parameters: $account, $api *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>IELTSpractice - Your payment method ({$body.refNo})</title>
	<!-- <from>support@ieltspractice.com</from> -->
	<!-- <bcc>accounts@clarityenglish.com,support@ieltspractice.com</bcc> -->
</head>
<body style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; background-color:#E5E5E5;">
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/ieltspractice/bg.jpg" bgcolor="#FFFFFF">
  <tr>
    <td colspan="3"><a href="http://www.ieltspractice.com" target="_blank"><img src="http://www.clarityenglish.com/images/email/ieltspractice/header.jpg" alt="Road to IELTS: IELTS preparation and practice" width="600" height="173" border="0" style="margin:0; font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; "/></a></td>
  </tr>
        
        
        
        
  <tr>
    <td colspan="3">
        
	  <div style="padding:0 48px; margin:0;">
           
           		<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Dear {$body.name}</p>
           
        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Thank you for subscribing to IELTSpractice.com! Please follow the steps below to make payment. Login details will be sent to you as soon as the payment has been confirmed.</p>
        
         
        	 <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Below are the details you have entered while registering for IELTSpractice.com.
Please keep this email for later reference.</p>


<div style="border:#CCCCCC 1px solid; padding:10px; margin:0;">
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 14px; margin:0 0 5px 0; padding:0; color:#0399D6; font-weight:bold;line-height:18px;">Personal details</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Reference number: </strong>{$body.refNo}</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Name: </strong>{$body.name}</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Email: </strong>{$body.email}</p>
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Module: </strong> {$body.offerDetail}</p>
                
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Subscription price:</strong> US${$body.amount}</p>
                
                <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;"><strong>Payment method: </strong>{$api->paymentMethod}</p>
			</div>
			</div>
            
      <table width="600" border="0" cellspacing="0" cellpadding="0" style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; line-height:18px;">
  <tr>
    <td height="15" colspan="4"></td>
    </tr>
  <tr>
    <td colspan="4"><p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 14px; margin:0 0 5px 0; padding:0 48px; color:#0399D6; font-weight:bold;line-height:18px;">Pay by money transfer</p></td>
    </tr>
  <tr>
    <td width="55"></td>
    <td width="22" align="left" valign="top">1.</td>
    <td width="465">Locate your nearest Western Union money transfer agent. <BR />
      (Go to <a href="http://www.westernunion.com" target="_blank">www.westernunion.com</a>).</td>
    <td width="58"></td>
  </tr>
  <tr>
    <td height="10" colspan="4"></td>
    </tr>
  <tr>
    <td></td>
    <td align="left" valign="top">2.</td>
    <td>Go to the agent's office and pay ${$body.amount} in <span style="color:#0A436E; font-weight:bold;">US Dollars</span>.</td>
    <td></td>
  </tr>
  <tr>
    <td height="10" colspan="4"></td>
    </tr>
  <tr>
    <td></td>
    <td align="left" valign="top">3.</td>
    <td>Give the agent the special instruction: <span style="color:#0A436E; font-weight:bold;">Recipient must receive money in US$ (not Hong Kong Dollars)</span>.</td>
    <td></td>
  </tr>
  <tr>
    <td height="10" colspan="4"></td>
    </tr>
  <tr>
    <td></td>
    <td align="left" valign="top">4.</td>
    <td>Fill in the receiver's details on the Send Money form as below:
    
    <ol style="margin:5px 0 0 0; padding:0; list-style-type: none;  line-height:18px;">
              	<li  style="margin:0; padding:0;">First name: Ka Pui</li>
<li style="margin:0; padding:0;">Middle name: Christine</li>
<li style="margin:0; padding:0;">Last name: Ng</li>
<li style="margin:0; padding:0;">City: Hong Kong</li>
<li style="margin:0; padding:0;">Country: Hong Kong</li>
<li style="margin:0; padding:0;">Click <a href="http://www.clarityenglish.com/images/email/ieltspractice/WesternUnionSample_Clarity.jpg" target="_blank">here</a> to see a sample</li>
</ol>    </td>
    <td></td>
  </tr>
  <tr>
    <td height="10" colspan="4"></td>
    </tr>
  <tr>
    <td background="http://www.clarityenglish.com/images/email/ieltspractice/list_arrow_left.jpg"></td>
    <td align="left" valign="top" background="http://www.clarityenglish.com/images/email/ieltspractice/list_top_bg.jpg">
    	<p style="padding:8px 0 0 0; margin:0;">5.</p>
    </td>
    <td background="http://www.clarityenglish.com/images/email/ieltspractice/list_top_bg.jpg">
    	<p style="padding:8px 0 5px 0; margin:0;">Send us an email when you have completed the payment so we know it has been sent. In the email please provide:</p>
                
                <ol style="margin:0; padding:0 0 0 25px; list-style-type: lower-roman;  line-height:18px;">
                	<li>Sender name</li>
                    <li>Sender country</li>
                    <li>Money Control Transfer Number (10-digit)</li>
                    <li>The reference number at the top of this email</li>
                </ol>    </td>
    <td background="http://www.clarityenglish.com/images/email/ieltspractice/list_right_bg.jpg"></td>
  </tr>
  <tr>
    <td height="9" colspan="4" background="http://www.clarityenglish.com/images/email/ieltspractice/list_btm_bg.jpg"></td>
    </tr>
  
</table>

<table width="600" border="0" cellspacing="0" cellpadding="0" style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; line-height:18px;">
  <tr>
    <td height="15" colspan="3"></td>
  </tr>
  <tr>
    <td colspan="3"><p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 14px; margin:0 0 5px 0; padding:0 48px; color:#0399D6; font-weight:bold;line-height:18px;">Pay by direct bank deposit</p></td>
    </tr>
  <tr>
    <td width="55"></td>
    <td width="487"><p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">
                   <strong> Bank transfer</strong><br />
                    Payable to: Clarity Language Consultants Ltd<br />
                    SWIFT number: HSBC HKHH<br />
                    Bank code: 004<br />
                    Branch code: 055<br />
                    Account number: 055 808 729 838 USD savings<br />
				
                    Bank address:<br />
                    HSBC, Sai Kung Office, Shop 9,<br />
                    Sai Kung Gardens,<br />
                    Sai Kung, Hong Kong                    </p></td>
    <td width="58"></td>
  </tr>
  <tr>
    <td height="10" colspan="3"></td>
    </tr>
  <tr>
    <td></td>
    <td>Please note that the sum received in payment must be nett of bank charges.</td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td height="10" colspan="3"></td>
    </tr>
  <tr>
    <td background="http://www.clarityenglish.com/images/email/ieltspractice/list_arrow_left.jpg"></td>
    <td  background="http://www.clarityenglish.com/images/email/ieltspractice/list_top_bg.jpg">
    	<p style="padding:8px 0 5px 0; margin:0;">Send us an email when you have completed the payment so we know it has been sent.<br /> In the email please provide:</p>
        <ol style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0 0 0 25px; list-style-type: lower-roman;  line-height:18px;">
                	<li>Sender name</li>
                    <li>Sender country</li>
                    <li>Bank transaction reference number</li>
                    <li>Payment advice / receipt</li>
                  <li>The reference number at the top of this email</li>
                </ol>    </td>
    <td background="http://www.clarityenglish.com/images/email/ieltspractice/list_right_bg.jpg"></td>
  </tr>
  
  <tr>
    <td height="9" colspan="3" background="http://www.clarityenglish.com/images/email/ieltspractice/list_btm_bg.jpg"></td>
    </tr>
  <tr>
    <td height="15" colspan="3"></td>
  </tr>
</table>

		
        
<div style="padding:0 48px; margin:0;">
                
               		<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Please feel free to contact us if you have any questions.</p>

						<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Best wishes</p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:15px 0; padding:0; color:#000000; line-height:18px;"><img src="http://www.clarityenglish.com/images/email/ieltspractice/sign_christianng.jpg" width="103" height="25" alt="Christine Ng"/></p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">
                 	Ms Christine Ng<br />
                   Accounts Manager, Clarity</p>
                   </div>
    </td>
  </tr>
  
  <tr>
    <td height="81" colspan="3" background="http://www.clarityenglish.com/images/email/ieltspractice/img_btm_plain.jpg">        </td>
  </tr>
  
  
  <tr>
        <td width="10" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_left.jpg">            </td>
        <td width="579"  bgcolor="#343434">
       <div style="padding:20px 48px; color:#FFFFFF;">
         
            
            
             <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#FFFFFF; line-height:18px; font-weight:bold;">Clarity Language Consultants Ltd<br />(UK and Hong Kong since 1992)</p>
			  
			 <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#FFFFFF; line-height:18px;">
                T: (+852) 2791 1787 | F: (+852) 2791 6484<br />
              E: <a href="mailto:support@ieltspractice.com" style="color:#FFFFFF;">support@ieltspractice.com</a> | W: <a href="http://www.IELTSpractice.com" target="_blank" style="color:#FFFFFF;">www.IELTSpractice.com</a>              </p> 
              
               <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; 0; padding:0; color:#FFFFFF; line-height:18px;">Your privacy is important to us. Please review IELTSpractice.com privacy
policy by clicking here: <a href="http://www.ieltspractice.com/terms.php" target="_blank" style="color:#FFFFFF;">http://www.ieltspractice.com/terms.php</a></p>
    </div>
        
        
        </td>
        <td width="11" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_right.jpg"></td>
  </tr>
</table>



</body>
</html>
