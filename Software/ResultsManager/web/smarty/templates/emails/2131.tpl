{* Name: Unit 1 It's Your Job *}
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
<title>Getting to know It's Your Job</title>
	<!-- <cc>adrian.raper@clarityenglish.com</cc> -->
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
	<td background="http://www.clarityenglish.com/itsyourjob/images/email/header2.jpg" colspan="5" height="60" valign="bottom">
    	
        <table width="600" border="0" cellspacing="0" cellpadding="0" >
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-size:12px; font-weight:bold;">Unit 1</span></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-weight:bold; font-size:18px;">Find the ideal job… for you</span></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="357" height="3" background="http://www.clarityenglish.com/itsyourjob/images/email/title_line.jpg"></td>
            <td width="218"></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#1B1464; font-weight:bold; font-size:14px;">Getting to know Clarity's It's Your Job</span></td>
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
        <p style="margin: 0 0 10px 0; padding:0;">Welcome to It's Your Job. We wish you all the best in your ongoing job search!</p>
        <p style="margin: 0 0 10px 0; padding:0;">It's Your Job features ten units. You can access the units by using the menu on the left of the My Course page.  In each unit there are 4 main sections, located in the centre of the page. In order to understand better how to take full advantage of the wealth of content in It's Your Job, please read on.</p>
         
        <table  width="422" border="0" cellspacing="0" cellpadding="0" background="http://www.clarityenglish.com/itsyourjob/images/email/content_bg.jpg" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td width="10"  height="6"></td>
    <td colspan="7" height="6"></td>
    <td width="8"  height="6"  background="http://www.clarityenglish.com/itsyourjob/images/email/content_top.jpg"></td>
  </tr>
  <tr>
    <td width="10"></td>
    <td colspan="7"background="http://www.clarityenglish.com/itsyourjob/images/email/content_title.jpg" height="20" valign="top"><span style="color:#1B1464; font-size:14px; font-weight:bold;">My Course</span></td>
    <td width="8"></td>
  </tr>
  <tr valign="top">
    <td width="10"></td>
    <td width="36"><img src="http://www.clarityenglish.com/itsyourjob/images/email/icon_ebook.jpg" alt="Ebook"/></td>
    <td width="5"></td>
    <td width="159"><span style="color:#1B1464; font-weight:bold;">Career Library</span><br />
            Read the eBooks in the Career Library and gain knowledge in different aspects of the job-seeking process. </td>
    <td width="5"></td>
    <td width="36"><img src="http://www.clarityenglish.com/itsyourjob/images/email/icon_video.jpg" alt="Video"/></td>
    <td width="5"></td>
    <td width="158"><span style="color:#1B1464; font-weight:bold;">Advice Zone</span><br />
            Watch videos in the Advice Zone to see how HR professionals judge a job-seeker.</td>
    <td width="8"></td>
  </tr>
  <tr>
    <td colspan="9" height="18"></td>
  </tr>
  
  <tr valign="top">
    <td width="10"></td>
    <td width="36"><img src="http://www.clarityenglish.com/itsyourjob/images/email/icon_audio.jpg" alt="Audio"/></td>
    <td width="5"></td>
    <td width="159"><span style="color:#1B1464; font-weight:bold;">Story Point</span><br />
            Audios feature experiences from job-seekers as well as HR professionals on various aspects of a job hunt.</td>
    <td width="5"></td>
    <td width="36"><img src="http://www.clarityenglish.com/itsyourjob/images/email/icon_exe.jpg" alt="Exercise"/></td>
    <td width="5"></td>
    <td width="158"><span style="color:#1B1464; font-weight:bold;">Practice Centre</span><br />
            Try the activities here to put the knowledge you have learnt into practice.</td>
    <td width="8"></td>
  </tr>
  <tr>
    <td colspan="9" height="10"></td>
  </tr>
  
  <tr>
    <td></td>
    <td colspan="7">You will also discover there are smaller but useful tools on the right of the My Course page.</td>
    <td></td>
  </tr>
  
  <tr>
    <td colspan="9" height="10"></td>
  </tr>
  
  <tr valign="top">
    <td width="10"></td>
    <td width="36"><img src="http://www.clarityenglish.com/itsyourjob/images/email/icon_recorder.jpg" alt="Recorder"/></td>
    <td width="5"></td>
    <td width="159"><span style="color:#1B1464; font-weight:bold;">Recorder</span><br />
           Rehearse the main points you want to bring up in the interview with the Recorder.</td>
    <td width="5"></td>
    <td width="36"><img src="http://www.clarityenglish.com/itsyourjob/images/email/icon_links.jpg" alt="Links"/></td>
    <td width="5"></td>
    <td width="158"><span style="color:#1B1464; font-weight:bold;">Quotes, Links and Tips</span><br />
            Features inspiring quotes, interesting links and useful tips.</td>
    <td width="8"></td>
  </tr>
  <tr>
    <td colspan="9" height="18"></td>
  </tr>
    
  <tr>
    <td width="10"></td>
    <td colspan="7"background="http://www.clarityenglish.com/itsyourjob/images/email/content_title.jpg" height="20" valign="top"><span style="color:#1B1464; font-size:14px; font-weight:bold;">My Progress</span></td>
    <td width="8"></td>
  </tr>
  <tr>
    <td></td>
    <td colspan="7">Go to the My Progress tab to see how much you have completed in It's Your Job. You can also compare yourself with other It's Your Job users around the world!</td>
    <td></td>
  </tr>
  <tr>
    <td colspan="9" height="18"></td>
  </tr>
  
   <tr>
    <td width="10"></td>
    <td colspan="7" background="http://www.clarityenglish.com/itsyourjob/images/email/content_title.jpg" height="20" valign="top"><span style="color:#1B1464; font-size:14px; font-weight:bold;">My Account</span></td>
    <td width="8"></td>
  </tr>
  <tr>
    <td></td>
    <td colspan="7">Go to the My Account tab to manage account options.</td>
    <td></td>
  </tr>
  <tr>
    <td colspan="9" height="18"></td>
  </tr>
  
  
   <tr>
    <td width="10"  height="6"></td>
    <td colspan="7"  height="6"></td>
    <td width="8"  height="6"  background="http://www.clarityenglish.com/itsyourjob/images/email/content_footer.jpg"></td>
  </tr>
</table>
{* The following line should only used for personal accounts. You can test that either by domain or by licence type (would need to be passed from TriggerOps) *}
{if $licenceType==5}
	<p style="margin: 10px 0 10px 0; padding:0;">With so much for you to discover, log in to It's Your Job now with the following link:
<a href="http://{$startPage}" target="_blank">{$startPage}</a>.
{/if}
</p>
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
            <td style="color:#C11D62; font-weight:bold;">Next unit:</td>
          </tr>
          <tr>
            <td style="color:#1B1464;">The perfect resume</td>
          </tr>
          <tr>
            <td height="5"></td>
          </tr>
          <tr>
            <td style="font-size:9px">In the next unit, we will look at the purpose of the resume - to persuade employers to invite you to the interview. But most employers take less than half a minute to go through a resume. How can you impress them in just 30 seconds?</td>
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
         </table>
	</td>
  </tr>
</table>
</div>

</body>
</html>
