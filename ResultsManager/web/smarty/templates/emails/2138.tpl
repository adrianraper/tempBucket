{* Name: Unit 8 It's Your Job *}
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
<title>It's Your Job - Project the right image to the interviewer</title>
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
            <td width="575" colspan="2"><span style="color:#1B1464; font-size:12px; font-weight:bold;">Unit 8</span></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-weight:bold; font-size:18px;">Body language: why it matters</span></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="357" height="3" background="http://www.clarityenglish.com/itsyourjob/images/email/title_line.jpg"></td>
            <td width="218"></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-weight:bold; font-size:14px;">Project the right image to the interviewer</span></td>
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
        <p style="margin: 0 0 10px 0; padding:0;">First impressions count. The interviewer will make their initial judgment of you as you walk into the room, shake hands and sit down. Using body language effectively can give you a huge boost – or get you off on the wrong foot.  There are many aspects to this: eyes, hands, facial expression, posture... do you understand what impression you are giving?</p>
         <p style="margin: 0 0 10px 0; padding:0;">In Unit 8 you will learn how to enter the interview room looking like a winner.</p>
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
            <td style="color:#1B1464;">Perform in group discussions</td>
          </tr>
          <tr>
            <td height="5"></td>
          </tr>
          <tr>
            <td style="font-size:9px">Group and panel interviews and group discussions are very different from one-to-one interviews. In the next unit, we will go through different types of group interviews and their purposes, and we'll look into how you can present yourself in the best possible way.</td>
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
