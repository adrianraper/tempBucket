{* Name: Unit 4 It's Your Job *}
{* Description: Email sent when this unit is activated for a particular learner. *}
{* Parameters: $user, $licenceType *}
{* This file works out the start page used as a link later in the email *}
{* I can't seem to put this code into an include file (IYJ_Domain_Name), so leave it here for now *}
{if $licenceType==5}
	{assign var='startPage' value='www.claritylifeskills.com/ItsYourJob'}
{else}
	{assign var='startPage' value='www.clarityenglish.com'}
{/if}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>It's Your Job - Preparation is the key to success at the interview</title>
</head>

<body>
<div style="margin: 8px;">
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" width="600" border="0" cellpadding="0" cellspacing="0">
  
  <!--Header area-->
  <tr>
	<td colspan="5" height="82" background="http://www.clarityenglish.com/itsyourjob/images/email/headerbg.jpg">
    	<img src="http://www.clarityenglish.com/itsyourjob/images/email/header1.jpg" alt="It's Your Job" border="0"/>
	</td>
  </tr>
    <tr>
	<td background="http://www.clarityenglish.com/itsyourjob/images/email/header2.jpg" colspan="5" height="60"  valign="bottom">
    	
        <table width="600" border="0" cellspacing="0" cellpadding="0" >
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-size:12px; font-weight:bold;">Unit 4</span></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-weight:bold; font-size:18px;">Prepare for the interview</span></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="357" height="3" background="http://www.clarityenglish.com/itsyourjob/images/email/title_line.jpg"></td>
            <td width="218"></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-weight:bold; font-size:14px;">Preparation is the key to success at the interview</span></td>
          </tr>
        </table>
        
        
            </td>
  </tr>
  <tr>
	<td colspan="5" height="25"></td>
  </tr>
 
  <tr>
    <td width="25" rowspan="2"></td>
    <td width="435" rowspan="2" valign="top">
   		<p style="margin: 0 0 10px 0; padding:0;">Dear {dynamic_user_name uname=$user->name}</p>
        <p style="margin: 0 0 10px 0; padding:0;">You've been invited to an interview. To give yourself the best chance of succeeding, you need to put in plenty of preparation. But what should you prepare, and how?</p>
         <p style="margin: 0 0 10px 0; padding:0;">In Unit 4 you will look in detail at the psychology of the interview, at how to research the organisation you are applying to, at how to dress for success... and much more!</p>
		{include file='file:includes/IYJ_Email_Signature.tpl'}	
	</td>
    <td width="5" rowspan="2"></td>
    <td width="10" rowspan="2" style="border-left:1px #CCCCCC solid;"></td>
    <td width="105" valign="top">

        <!--Right Column-->
		<table border="0" cellspacing="0" cellpadding="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
        	<!--Start Learning Button-->
        	<tr>
            	<td align="center">
                	<a href="http://{$startPage}" target="_blank"><img src="http://www.clarityenglish.com/itsyourjob/images/email/start_but.jpg" width="105" height="114" border="0" alt="Start Learning Now!"/></a>
                  </td>
             </tr>
             <!--End of Start Learning Button-->
          
       	<tr>
            <td height="10"></td>
          </tr>
          
          <!--Introduce Next unit-->
          <tr>
            <td style="color:#C11D62; font-weight:bold">Next unit:</td>
          </tr>
          <tr>
            <td style="color:#1B1464;">Handling difficult questions</td>
          </tr>
          <tr>
            <td height="5"></td>
          </tr>
          <tr>
            <td style="font-size:9px">You are at a job interview. You've done well so far and answered your questions with confidence. Then the interviewer comes out with this: 'Can you tell me two of your greatest weaknesses?' You just don't know how to answer. In the next unit, we'll look into how to prepare for difficult questions like this one.</td>
          </tr>
          <!--End of Introduce next unit-->
        </table>
		    </td>
  </tr>
  <tr>
    <td width="105" valign="top"></td>
  </tr>
  <tr>
    <td colspan="5" height="10"></td>
  </tr>
  <tr>
    <td colspan="5" height="5"></td>
  </tr>
  <tr>
    <td colspan="5" height="10">
    	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-top:1px #CCCCCC solid;">
              <tr>
                <td width="23"></td>
                <td width="445" style="font-size:9px">
           	      {include file='file:includes/IYJ_Email_Unsubscribe.tpl'}
				  </td>
                <td width="132"></td>
          </tr>
         </table></td>
  </tr>
</table>
</div>


</body>
</html>
