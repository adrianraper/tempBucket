{* Name: R2iV2 BC HK registration welcome *}
{* Description: Email sent when you someone from Hong Kong registers for R2IV2 using a serial number/password. *}
{* Parameters: $user, $api *}
{if $api->rootID==100} 
	{assign var='prefix' value='India'}
{elseif $api->rootID==167} 
	{assign var='prefix' value='AMESA'}
{elseif $api->rootID==168} 
	{assign var='prefix' value='SEAsia'}
{elseif $api->rootID==169} 
	{assign var='prefix' value='Europe'}
{elseif $api->rootID==170} 
	{assign var='prefix' value='Americas'}
{elseif $api->rootID==14030} 
	{assign var='prefix' value='GLOBAL'}
{else} 
	{assign var='prefix' value='Error'}
{/if}
{if $api->productCode==12 || $api->productCode==52} 
	{assign var='module' value='AC'}
{else} 
	{assign var='module' value='GT'}
{/if}
{if $user->password==""} 
	{assign var='password' value='(no password necessary)'}
{else} 
	{assign var='password' value=$user->password}
{/if}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>IELTS test preparation from the British Council</title>
<!-- <from>%22Road to IELTS%22 %3Csupport@roadtoielts.com%3E</from> -->
</head>

<body>

<div style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; margin: 0; padding:0 0 10px 0; text-align: center; color:#333333; line-height:16px;">If the content of this message is not displayed properly, please click<br />
<a href="http://www.roadtoielts.com/email/welcome-ielts-last-minute.php?prefix={$prefix}&module={$module}&studentID={$user->studentID}&email={$user->email}&password={$password}" target="_blank">http://www.roadtoielts.com/email/welcome-ielts-last-minute.php</a></div>

<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" style="font-family:Arial, Helvetica, sans-serif; color:#333333; font-size:14px; min-width:600px; line-height:16px;" background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-bg.jpg">
  <tr>
    <td background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-bg.jpg">
    	<img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-banner.jpg" alt="Road to IELTS: IELTS preparation and practice" width="600" height="160"/>    </td>
  </tr>
  <tr valign="middle">
    <td background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-header.jpg" height="47" style="font-weight:bold; text-align:center; color:#FFFFFF;" bgcolor="#00426B" valign="middle">
    	Free IELTS test preparation from the British Council
    </td>
  </tr>
  
  
  
  
  <tr>
    <td background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-bg.jpg">
    <table width="600" border="0" cellspacing="0" cellpadding="0" style="font-family:Arial, Helvetica, sans-serif; color:#333333; font-size:14px; line-height:16px;">
  <tr>
    <td width="41"></td>
    <td width="515">
    
    
    <div style="margin:12px 8px; line-height:1.4em;">Dear Candidate,</div>

<div style="margin:0 8px 12px 8px; line-height:1.4em;">Welcome to the Road to IELTS online preparation platform. Road to IELTS is designed to help you get the best possible band score in IELTS. Read the instructions below to sign in to your account and start accessing exercises, practice tests and videos designed by IELTS examiners and experts.</div>
    
		<table width="505" border="0" cellspacing="0" cellpadding="0" background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-table-bg.jpg"  style="font-family:Arial, Helvetica, sans-serif; color:#333333; font-size:14px; margin-bottom:10px;">
          <tr>
            <td background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-table-top.jpg" height="35" valign="middle" align="center" bgcolor="#00426B" style="padding-top:8px;">
            	<img src="http://www.clarityenglish.com/images/email/rti2/ico-desktop.png"  style="vertical-align:middle; margin-right:5px;"/><span style="margin-left:5px; color:#FFFFFF; font-weight:bold;">Starting the laptop/desktop version</span>
            
            
            </td>
          </tr>
          <tr> 
            <td background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-table-bg.jpg" >
            	<div style="padding:10px 40px; color:#333333; line-height:1.4em; font-family:Arial, Helvetica, sans-serif; font-size:1em;">
                	<strong>Your sign in details:</strong><br />
                    {if $api->rootID==14030} 
					email: {$user->email}<br />
					{else} 
                    login ID: {$user->studentID}<br />
					{/if}
                    password: {$password}
                 </div>
            	
            
            </td>
          </tr>
          
           <tr> 
            <td height="16">
            	<img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-table-border.jpg" />
            </td>
          </tr>
          
             <tr> 
            <td align="center" style="padding-top:5px;">
            	<a href="http://www.clarityenglish.com/area1/RoadToIELTS2/Start-{$module}.php?prefix={$prefix}" target="_blank" style="line-height:30px;  color:#3B2314; text-align:center; font-size:1.3em; font-weight:bold; text-align:center;"><img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-start.jpg" alt="Start" width="367" height="30" border="0" style="border:0; margin:0; background-color:#FFD300; color:#3B2314; text-align:center;"/></a></td>
          </tr>
         
          <tr>
            <td colspan="4" background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-tablet-btm.jpg" height="16">
            </td>
          </tr>
        </table>
        
        <table width="505" border="0" cellspacing="0" cellpadding="0" style="font-family:Arial, Helvetica, sans-serif; color:#333333; font-size:14px; line-height:16px;"  background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-table-bg.jpg">
          <tr>
            <td height="35" colspan="4" align="center" valign="middle" background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-table-top.jpg" bgcolor="#00426B" style="padding-top:8px;">
            	<img src="http://www.clarityenglish.com/images/email/rti2/ico-tablet.png"  style="vertical-align:middle; margin-right:5px;"/><span style="margin-left:5px;  color:#FFFFFF; font-weight:bold;">Starting the tablet version*</span>            </td>
          </tr>
          <tr> 
            <td colspan="4" background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-table-bg.jpg">
            	<div style="padding:10px 40px; color:#333333; line-height:1.4em; font-family:Arial, Helvetica, sans-serif; font-size:1em;">
                	<strong>Your sign in details:</strong><br />
                    email: {$user->email}<br />
                    password: {$password}                </div>
               </td>
          </tr>
          
           <tr> 
            <td height="16" colspan="4">
            	<img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-table-border.jpg" />
            </td>
          </tr>
          
             <tr > 
            <td width="40"></td>
            <td width="268" style="color:#333333; line-height:1.2em; font-family:Arial, Helvetica, sans-serif; font-size:0.9em;">*First download the app from the App Store or Google Play Store and install the app onto your tablet.</td>
            <td width="182" align="right">
            	<a href="https://itunes.apple.com/us/app/road-to-ielts/id560055517?mt=8&amp;ign-mpt=uo%3D4" target="_blank" style=" font-size:0.9em;"><img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-apple-store.jpg" alt="App store" width="90" height="27" border="0"/></a>
                <a href="https://play.google.com/store/apps/details?id=air.com.clarityenglish.ielts.app" target="_blank" style=" font-size:0.9em;"><img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-google-play.jpg" alt="Google play" width="79" height="27" border="0"/></a>           </td>
            <td width="22"></td>
             </tr>
         
          <tr >
            <td colspan="4" background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-tablet-btm.jpg" height="16">
            	        </td>
          </tr>
        </table>

    	
    	<div style="margin:12px 8px; line-height:1.4em;">We hope you will find the training useful and easy to use. Please contact us at <a href="mailto:support@roadtoielts.com">support@roadtoielts.com</a> if you have any comments or queries regarding Road to IELTS.</div>

	<div style="margin:0 8px; line-height:1.4em;">Good luck with your IELTS test!</div>


    	
    
    </td>
    <td width="44"></td>
  </tr>
  
  
  
  
</table>

    
    </td>
  </tr>
  <tr>
    <td background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-footer-img.jpg" height="83">
    
    
    <table width="600" border="0" cellspacing="0" cellpadding="0" style="font-family:Arial, Helvetica, sans-serif; color:#333333; font-size:14px; line-height:16px;">
  <tr valign="top">
    <td width="41"></td>
    <td width="515">
    
 	<div style="margin:0 8px; line-height:1.4em;">Best wishes,</div>
  <div style="margin:0 8px; line-height:1.4em;">Road to IELTS Support Team</div>
    
    </td>
    <td width="44"></td>
  </tr>
</table>

    
 	
    
    
    </td>
  </tr>
  
  <tr>
    <td height="70" background="http://www.clarityenglish.com/images/email/rti2/ielts-lm-footer-line-bg.jpg">
    	<a href="http://www.clarityenglish.com/" target="_blank" style="text-align:center; font-size:1em; margin:0;" ><img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-footer-line.jpg" alt="www.ClarityEnglish.com" width="600" height="70" border="0" /></a></td>
  </tr>
  
</table>



</body>
</html>