{* Name: Forgot password *}
{* Description: Email sent when someone has forgotten their password. *}

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Tense Buster grammar course password reminder</title>
<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
<style>@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);</style>

</head>

<body style="margin:10px 0 0 0; padding:0;" bgcolor="#ffffff" >




	<table width="598" border="0" align="center" cellpadding="0" cellspacing="0" style="min-width:598px; border:1px #333333 solid;font-family:Arial, Helvetica, sans-serif; font-size:14px; color:#333333; line-height:20px;" >


  <tr>
    <td width="100%" style="line-height:0;"><a href="http://www.clarityenglish.com" target="_blank"><img src="http://www.clarityenglish.com/images/email/email15_banner.jpg" alt="ClarityEnglish" width="598" height="70" border="0" /></a></td>
    </tr>
    
   <tr>
      <tr>
    <td width="100%" height="10">    </td>
    </tr>
   
    <tr>
    <td width="100%" style="line-height:0;">
    	<div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; line-height:18px; padding:10px 68px; color:#333333; background-color: #EFEFEF;">Forgot your password?</div>    </td>
    </tr>
    
      <tr>
      <tr>
    <td width="100%" height="10">    </td>
    </tr>
    
   <tr>
   
    <td width="100%" background="http://www.clarityenglish.com/images/email/email15_header.jpg">
    	<div style="padding:0 68px;">
        		<div style="font-family:Arial, Helvetica, sans-serif; font-size:1em; color:#333333; margin:0; padding:28px 0 15px 0;">Dear {$user->name}</div>
                
                {* Start email *}
               
    
	<div style="font-family:Arial, Helvetica, sans-serif; font-size:1em; color:#333333; margin:0; padding:0 0 15px 0; line-height:20px;">You asked us to remind you of your password.</div>
    
    	<div style="font-family:Arial, Helvetica, sans-serif; font-size:1em; color:#333333; margin:0; padding:0 0 5px 0; line-height:20px;">Sign-in with these details:</div>
	
    
    <div style="background-color:#E8E3F0;  padding:10px; margin:0 0 10px 0;">
		
        
        <div style="font-family:Arial, Helvetica, sans-serif; font-size:1em; color:#333333; margin:0; padding:0; line-height:20px;">
        {if $loginOption == 1}
	<strong>Name: </strong>{$user->name}
{elseif $loginOption == 2}
	<strong>ID: </strong>{$user->studentID}
{elseif $loginOption == 128}
	<strong>Email:</strong> {$user->email}
{else}
	Ask your teacher how to sign-in.
{/if}</div>
	<div style="font-family:Arial, Helvetica, sans-serif; font-size:1em; color:#333333; margin:0; padding:0; line-height:20px;"><strong>Password:</strong> {if $user->password == ''}you have no password{else}{$user->password}{/if}</div>
	</div>
      </div>
      
      </td>
    </tr>
    
  
    
 
    <tr>
    	<td height="206" align="left" valign="top" background="http://www.clarityenglish.com/images/email/email15_footer.jpg">					
        	<div style="padding:0 68px;">
    	<div style="font-family:Arial, Helvetica, sans-serif; font-size:1em; color:#333333; margin:0; padding:15px 0 0 0; line-height:20px;">Best wishes<br />
        <img src="http://www.clarityenglish.com/images/email/AdrianRaper.jpg" alt="Adrian Raper" width="110" height="54" /><br />
            Dr Adrian Raper<br />
             Technical Director<br />
            <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a> </div>
            </div>        </td>
    </tr>
    
    <tr>
    	<td height="41" align="left" valign="top" style="line-height:0;">
        	<a href="http://www.clarityenglish.com" target="_blank"><img src="http://www.clarityenglish.com/images/email/email15_clarityenglish_foot.jpg" width="598" height="41" border="0" /></a>        </td>
    </tr>
    
       <tr>
    	<td height="41" align="left" valign="top" bgcolor="#FFFFFF"></td>
    </tr>
</table>

<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" style="min-width:600px;" >
    
    <tr>
    <td height="10">
    </td>
    </tr>
    
    	<tr>
    <td>
    
    
    <div style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; margin: 0; padding:0 0 10px 0; text-align: center; color:#333333; line-height:16px;">To ensure delivery of our email to your inbox rather than to your spam folder, <br />please add <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a> to your address book.</div></td>
    </tr>
    
    </table>



</body>
</html>
