{* Name: IELTSPractice.com welcome *}
{* Description: Email sent to Road to IELTS home user purchaser *}
{* Parameters: $account, $api *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>IELTSpractice - Your account update ({$api->subscription->id}/{$api->paymentRef})</title>
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
        	<td height="53" colspan="3" background="http://www.clarityenglish.com/images/email/ieltspractice/subtitle.jpg" style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0 48px; color:#FFFFFF; line-height:53px; font-weight:bold;">
            	Your IELTSpractice account has been updated
             </td>
        </tr>
        
        
  <tr>
    <td colspan="3">
        
	  <div style="padding:0 48px;">
           
           		<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Dear {$api->subscription->name}</p>
           
        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">This email is to confirm that your IELTSpractice.com account has been updated. To access the account, please go to this URL:
        <a href="http://www.ieltspractice.com/login.php" target="_blank">www.IELTSpractice.com/login.php</a>.</p>
        
        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Your login details are as below:</p>
        
        <div style="border:#CCCCCC 1px solid; padding:10px; margin:0 0 15px 0;">
       	  <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 14px; margin:0 0 5px 0; padding:0; color:#0399D6; font-weight:bold;line-height:18px;">Member login details</p>
            <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">
            	<strong>Email: </strong>{$account->adminUser->email}</p>
            <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">
            	<strong>Password: </strong>{$account->adminUser->password}</p>
            <a href="http://www.ieltspractice.com/login.php" target="_blank">
            <img src="http://www.clarityenglish.com/images/email/ieltspractice/btn_learn.jpg" width="190" height="42" border="0" />
            </a>
          </div>
        	 <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Below are the details you entered while purchasing at IELTSpractice.com.
Please keep this email for later reference.</p>
             
             <div style="border:#CCCCCC 1px solid; padding:10px; margin:0 0 20px 0;">
             
             <table width="484" border="0" cellspacing="0" cellpadding="0" style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">
  <tr>
    <td colspan="2">
    	<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 14px; margin:0; padding:0; color:#0399D6; font-weight:bold;line-height:18px;">Renewal details</p>    </td>
    </tr>
  <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Name: </strong>{$api->subscription->name}</p></td>
  </tr>
  
  <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Email: </strong>{$api->subscription->email}</p></td>
  </tr>
  
  <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Now expires on: </strong>{format_ansi_date ansiDate=$account->titles[0]->expiryDate format='%d %B %Y'}</p></td>
    </tr>
  <tr>
    <td width="64" valign="top"><p style="margin:0 0 5px 0; padding:0;"><strong>Package: </strong> </p></td>
    <td width="420"><p style="margin:0 0 5px 0; padding:0;">
	{if in_array($api->subscription->offerID, array(59,60,63,65,66,67,68,69,70,71,72,73,83,84,85,86,87,88,89,90,91,92,93,94))}
		Road to IELTS Academic Module<br />
	{/if}
	{if in_array($api->subscription->offerID, array(61,62,64,74,75,76,77,78,79,80,81,82,95,96,97,98,99,100,101,102,103,104,105,106))}
		Road to IELTS General Training Module<br />
	{/if}
	{if in_array($api->subscription->offerID, array(68,69,70,71,72,73,77,78,79,80,81,82,86,87,88,92,93,94,98,99,100,104,105,106))}
		Tense Buster<br />
	{/if}
	{if in_array($api->subscription->offerID, array(65,66,67,71,72,73,74,75,76,80,81,82,89,90,91,92,93,94,101,102,103,104,105,106))}
		Study Skills Success<br />
	{/if}
	{if in_array($api->subscription->offerID, array(83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106))}
		Practical Writing<br />
	{/if}
	
	
	</p></td>
  </tr>
 <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Payment amount: </strong>US$	 
			{if $api->subscription->offerID == '59'} 
				49.99
			{/if} 
			{if $api->subscription->offerID == '60'} 
				99.99
			{/if}
			{if $api->subscription->offerID == '61'} 
				49.99
			{/if}
			{if $api->subscription->offerID == '62'} 
				99.99
			{/if}
			{if $api->subscription->offerID == '63'} 
				24.99
			{/if}
			{if $api->subscription->offerID == '64'} 
				24.99
			{/if}
			{if $api->subscription->offerID == '65'} 
				34.98
			{/if}
			{if $api->subscription->offerID == '66'} 
				59.98
			{/if}
			{if $api->subscription->offerID == '67'} 
				119.98
			{/if}
			{if $api->subscription->offerID == '68'} 
				34.98
			{/if}
			{if $api->subscription->offerID == '69'} 
				59.98
			{/if}
			{if $api->subscription->offerID == '70'} 
				119.98
			{/if}
			{if $api->subscription->offerID == '71'} 
				44.97
			{/if}
			{if $api->subscription->offerID == '72'} 
				69.97
			{/if}
			{if $api->subscription->offerID == '73'} 
				139.97
			{/if}
			{if $api->subscription->offerID == '74'} 
				34.98
			{/if}
			{if $api->subscription->offerID == '75'} 
				59.98
			{/if}
			{if $api->subscription->offerID == '76'} 
				119.98
			{/if}
			{if $api->subscription->offerID == '77'} 
				34.98
			{/if}
			{if $api->subscription->offerID == '78'} 
				59.98
			{/if}
			{if $api->subscription->offerID == '79'} 
				119.98
			{/if}
			{if $api->subscription->offerID == '80'} 
				44.97
			{/if}
			{if $api->subscription->offerID == '81'} 
				69.97
			{/if}
			{if $api->subscription->offerID == '82'} 
				139.97
			{/if}
			{if $api->subscription->offerID == '83'} 
				34.98
			{/if}
			{if $api->subscription->offerID == '84'} 
				59.98
			{/if}
			{if $api->subscription->offerID == '85'} 
				119.98
			{/if}
			{if $api->subscription->offerID == '86'} 
				44.97
			{/if}
			{if $api->subscription->offerID == '87'} 
				69.97
			{/if}
			{if $api->subscription->offerID == '88'} 
				139.97
			{/if}
			{if $api->subscription->offerID == '89'} 
				44.97
			{/if}
			{if $api->subscription->offerID == '90'} 
				69.97
			{/if}
			{if $api->subscription->offerID == '91'} 
				139.97
			{/if}
			{if $api->subscription->offerID == '92'} 
				54.96
			{/if}
			{if $api->subscription->offerID == '93'} 
				79.96
			{/if}
			{if $api->subscription->offerID == '94'} 
				159.96
			{/if}
			{if $api->subscription->offerID == '95'} 
				34.98
			{/if}
			{if $api->subscription->offerID == '96'} 
				59.98
			{/if}
			{if $api->subscription->offerID == '97'} 
				119.98
			{/if}
			{if $api->subscription->offerID == '98'} 
				44.97
			{/if}
			{if $api->subscription->offerID == '99'} 
				69.97
			{/if}
			{if $api->subscription->offerID == '100'} 
				139.97
			{/if}
			{if $api->subscription->offerID == '101'} 
				44.97
			{/if}
			{if $api->subscription->offerID == '102'} 
				69.97
			{/if}
			{if $api->subscription->offerID == '103'} 
				139.97
			{/if}
			{if $api->subscription->offerID == '104'} 
				54.96
			{/if}
			{if $api->subscription->offerID == '105'} 
				79.96
			{/if}
			{if $api->subscription->offerID == '106'} 
				159.96
			{/if}
	</p></td>
  </tr>
  
   <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Payment method: </strong>{$api->paymentMethod}</p></td>
  </tr>
  
  <tr>
    <td colspan="2"><p style="margin:0 0 5px 0; padding:0;"><strong>Reference number: </strong>{$api->subscription->id}/{$api->paymentRef}</p></td>
  </tr>
  
  
</table>
           
                
		</div>
            
            <div  style="margin:0 0 20px 0; padding:0;">
          <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px; font-weight:bold;">Using an iPad or tablet? Download our app here. It's free!</p>
             
             <a href="https://itunes.apple.com/us/app/road-to-ielts/id560055517?mt=8&ign-mpt=uo%3D4" target="_blank" >
                 <img src="http://www.clarityenglish.com/images/email/ieltspractice/badge_appstore.jpg" border="0" width="135" height="40" style="margin:0 5px 0 0;" /></a>
                 <a href="https://play.google.com/store/apps/details?id=air.com.clarityenglish.ielts.app" target="_blank"><img src="http://www.clarityenglish.com/images/email/ieltspractice/badge_googleplay_small.jpg" border="0" width="117" height="40" style="margin:0 5px 0 0;" /></a>
                 <a href="http://www.clarityenglish.com/downloads/apk/RoadToIELTS.php?utm_campaign=APP-APK&utm_source=RTI&utm_medium=IP-Renew-Email" target="_blank"><img src="http://www.clarityenglish.com/images/email/ieltspractice/badge_cestore.png" border="0" width="117" height="40" /></a>
             
        </div>
        
        <div style="clear:both;"></div>
            
            
      </div>	 </td>
  </tr>
  
  <tr>
    <td colspan="3">
    
    <table width="600" height="176" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/ieltspractice/img_btm_study.jpg">
<tr>
                      <td width="48">                              </td>
                      <td width="367" height="233" valign="top">
                   	    <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Please feel free to contact us at <a href='mailto:support@ieltspractice.com'>support@ieltspractice.com</a> if you have any questions.</p>

						<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Best wishes</p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:10px 0 5px 0; padding:0; color:#000000; line-height:18px;"><img src="http://www.clarityenglish.com/images/email/ieltspractice/sign_cynthialau.jpg" width="103" height="33" alt="Cynthia Lau"/></p>
                        <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">
                 	Cynthia Lau<br />
                    IELTSpractice Support Team</p>
                    </td>
                      <td width="185" valign="top"></td>
                    </tr>
                  </table>    </td>
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
here: <a href="http://www.ieltspractice.com/terms.php" target="_blank" style="color:#FFFFFF;">http://www.ieltspractice.com/terms.php</a>    </td>
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
