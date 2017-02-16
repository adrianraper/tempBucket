{* Name: IELTSPractice.com welcome *}
{* Description: Email sent to Road to IELTS home user purchaser *}
{* Parameters: $account, $api *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>IELTSpractice - Your payment method ({$body->refNo})</title>
	<!-- <from>support@ieltspractice.com</from> -->
	<!-- <bcc>accounts@clarityenglish.com,support@ieltspractice.com</bcc> -->
</head>
<body style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; background-color:#E5E5E5;">
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/ieltspractice/bg.jpg" bgcolor="#FFFFFF">
  <tr>
    <td colspan="3"><a href="http://www.ieltspractice.com" target="_blank"><img src="http://www.clarityenglish.com/images/email/ieltspractice/header.jpg" alt="Road to IELTS: IELTS preparation and practice" width="600" height="173" border="0" style="margin:0; font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; "/></a></td>
  </tr>
  
  <tr>
        	<td height="53" colspan="3" background="http://www.clarityenglish.com/images/email/ieltspractice/subtitle.jpg" style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0 48px; color:#FFFFFF; line-height:53px; font-weight:bold;">
            	Your payment methods
             </td>
        </tr>
        
        
        
        
  <tr>
    <td colspan="3">
        
	  <div style="padding:0 48px; margin:0;">
           
           		<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Dear {$body->name}</p>
           
        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 13px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Thank you for subscribing to IELTSpractice.com! Please follow the steps below to make payment. Login details will be sent to you as soon as the payment has been confirmed.</p>
        
         
        	 <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Below are the details you have entered while registering for IELTSpractice.com.
Please keep this email for later reference.</p>


<div style="border:#CCCCCC 1px solid; padding:10px; margin:0;">

	<table width="484" border="0" cellspacing="0" cellpadding="0" style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">
  <tr>
    <td colspan="2">
    	<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 14px; margin:0; padding:0; color:#0399D6; font-weight:bold;line-height:18px;">Personal details</p>    </td>
    </tr>
  <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Name: </strong>{$body->name}</p></td>
  </tr>
  
  <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Email: </strong>{$body->email}</p></td>
  </tr>
  
  
  <tr>
    <td width="64" valign="top"><p style="margin:0 0 5px 0; padding:0;"><strong>Package: </strong> </p></td>
    <td width="420"><p style="margin:0 0 5px 0; padding:0;">
	{if in_array($body->offerID, array(59,60,63,65,66,67,68,69,70,71,72,73,83,84,85,86,87,88,89,90,91,92,93,94))}
		Road to IELTS Academic Module<br />
	{/if}
	{if in_array($body->offerID, array(61,62,64,74,75,76,77,78,79,80,81,82,95,96,97,98,99,100,101,102,103,104,105,106))}
		Road to IELTS General Training Module<br />
	{/if}
	{if in_array($body->offerID, array(68,69,70,71,72,73,77,78,79,80,81,82,86,87,88,92,93,94,98,99,100,104,105,106))}
		Tense Buster<br />
	{/if}
	{if in_array($body->offerID, array(65,66,67,71,72,73,74,75,76,80,81,82,89,90,91,92,93,94,101,102,103,104,105,106))}
		Study Skills Success<br />
	{/if}
	{if in_array($body->offerID, array(83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106))}
		Practical Writing<br />
	{/if}
	
	</p></td>
  </tr>
  
  <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Payment method: </strong>Cash</p></td>
  </tr>
  
 <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Payment amount: </strong>US${$body->amount}</p></td>
  </tr>
  
  <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Reference number: </strong>{$body->refNo}</p></td>
  </tr>
  
  
</table>
                
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
    <td>Go to the agent's office and pay ${$body->amount} in <span style="color:#0A436E; font-weight:bold;">US dollars</span>.</td>
    <td></td>
  </tr>
  <tr>
    <td height="10" colspan="4"></td>
    </tr>
  <tr>
    <td></td>
    <td align="left" valign="top">3.</td>
   
    <td>Tell the agent that the recipient must receive money in <span style="color:#0A436E; font-weight:bold;">US dollars </span>(not Hong Kong dollars).</td>
    
    
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


<li  style="margin:0; padding:0;">First name: Yiu Leung</li>
<li style="margin:0; padding:0;">Last name: Shek</li>
<li style="margin:0; padding:0;">City: Hong Kong</li>
<li style="margin:0; padding:0;">Country: Hong Kong</li>
<li style="margin:0; padding:0;">Click <a href="http://www.clarityenglish.com/images/email/ieltspractice/WesternUnionSample_Clarity_Brian.jpg" target="_blank">here</a> to see a sample</li>
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
                    <li>Money control transfer number (10-digit)</li>
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
  
  
  <tr>
    <td colspan="3">
    
    	<table width="600" border="0" cellpadding="0" cellspacing="0" style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#FFFFFF; line-height:18px;">
  <tr>
    <td width="10" rowspan="13" valign="top" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_left.jpg"></td>
    <td width="48" rowspan="13" valign="top" bgcolor="#343434"></td>
    <td height="20" colspan="2" valign="top" bgcolor="#343434"></td>
    <td width="48" rowspan="13" valign="top" bgcolor="#343434"></td>
    <td width="11" rowspan="13" valign="top" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_right.jpg"></td>
  </tr>
  <tr>
    <td colspan="2" valign="top" bgcolor="#343434">
    	 <strong>Clarity Language Consultants Ltd</strong> (UK and Hong Kong since 1992)</td>
    </tr>
  <tr>
    <td height="5" colspan="2" valign="top" bgcolor="#343434"></td>
    </tr>
  <tr>
    <td width="20" height="20" valign="top" bgcolor="#343434"><img src="http://www.clarityenglish.com/images/email/rti2/winner.jpg" alt="Winner" width="16" height="20"/></td>
    <td width="463"  valign="top" bgcolor="#343434" style="line-height:20px;"><strong>2014 WINNER</strong> of the Hong Kong ICT awards, Best Product (Road to IELTS)</td>
    </tr>
   <tr>
     <td height="5" colspan="2" valign="top" bgcolor="#343434"></td>
     </tr>
   <tr>
     <td  height="20" valign="top" bgcolor="#343434"><img src="http://www.clarityenglish.com/images/email/rti2/winner.jpg" alt="Winner" width="16" height="20"/></td>
     <td valign="top" style="line-height:20px;" bgcolor="#343434"><strong>2013 WINNER</strong> of the Hong Kong Business Award (SME)</td>
   </tr>
   <tr>
     <td  height="5" colspan="2" valign="top" bgcolor="#343434"></td>
     </tr>
   
   <tr>
     <td  height="20" valign="top" bgcolor="#343434"><img src="http://www.clarityenglish.com/images/email/rti2/winner.jpg" alt="Winner" width="16" height="20"/></td>
    <td width="463" valign="top" style="line-height:20px;" bgcolor="#343434"><strong>2012 WINNER</strong> of the English Speaking Union President's Award</td>
    </tr>
    
    
    
  <tr>
    <td height="8" colspan="2" valign="middle" bgcolor="#343434"></td>
    </tr>
    
    
    
  <tr>
    <td height="20" colspan="2" valign="middle" background="http://www.clarityenglish.com/images/email/rti2/ielts_foot_line.jpg" bgcolor="#343434"></td>
    </tr>
   <tr>
     <td height="8" colspan="2" valign="middle" bgcolor="#343434"></td>
     </tr>
   
      <tr>
        <td height="45" colspan="2" valign="top" bgcolor="#343434">
        	
                T: (+852) 2791 1787 | F: (+852) 2791 6484<br />
                E: <a href="mailto:support@ieltspractice.com" style="color:#FFFFFF; font-family: Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0;">support@ieltspractice.com</a> | W: <a href="http://www.IELTSpractice.com/" target="_blank" style="color:#FFFFFF; font-family: Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0;">www.IELTSpractice.com</a>        </td>
        </tr>
      <tr>
        <td  colspan="2" valign="top" style="padding:0 0 15px 0;" bgcolor="#343434">
    	
                Your privacy is important to us. Please review the IELTSpractice.com privacy policy <br />by clicking
here: <a href="http://www.www.ieltspractice.com/terms.php" target="_blank" style="color:#FFFFFF;">http://www.ieltspractice.com/terms.php</a>    </td>
     </tr>
  
  
  
  
 
 
  <tr>
    <td height="10" colspan="6" background="http://www.clarityenglish.com/images/email/rti2/ielts_foot_bottom.jpg" ></td>
    </tr>
</table>
    
    </td>
  </tr>
</table>



</body>
</html>
