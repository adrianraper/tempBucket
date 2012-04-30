{* Name: The new Road to IELTS *}
{* Description: Announcing the release today of Road to IELTS 2 *}
{* Parameters: $account *}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>New Road to IELTS</title>
		<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
<style type="text/css">
{literal}
<!--
.style1 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 12px;}
.style2 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 11px;}
-->
{/literal}
</style>
</head>
<body style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;">
{foreach name=orderDetails from=$account->titles item=title}
	{if $title->productCode==52}
		{assign var='hasAC' value='true'}
	{/if}
	{if $title->productCode==53}
		{assign var='hasGT' value='true'}
	{/if}
{/foreach}
{* Also work out some other stuff about the licences to help with wording *}
{if $hasAC=='true' && $hasGT=='true'}
	{assign var='multipleTitles' value='true'}
{/if}
<body style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;">
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="3">
    	<img src="http://www.clarityenglish.com/images/email/rti2/rtiv2_header.jpg" alt="Road to IELTS" width="600" height="86" style="margin:0 0 20px 0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; "/>
            <div style="padding:0 30px;">
                <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">Dear Colleague</p>
                <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;text-align:center"><b>- {$account->name} -</b></p>
                
                <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">We have switched your subscription of Road to IELTS to a new version today.</p>
                
                <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">If you are accessing Road to IELTS with a direct link, please make sure you switch to
the following URL{if $multipleTitles=='true'}s{/if}:<br />			
{foreach name=orderDetails from=$account->titles item=title}
{if $title->productCode==52}
	<a href="http://www.clarityenglish.com/area1/RoadToIELTS2/Start-AC.php?prefix={$account->prefix}" target="_blank">http://www.clarityenglish.com/area1/RoadToIELTS2/Start-AC.php?prefix={$account->prefix}</a>
{/if}
{if $title->productCode==53}
	<a href="http://www.clarityenglish.com/area1/RoadToIELTS2/Start-GT.php?prefix={$account->prefix}" target="_blank">http://www.clarityenglish.com/area1/RoadToIELTS2/Start-GT.php?prefix={$account->prefix}</a>
{/if}
{/foreach}
			</p>
                </p>
           </div>
            <div align="center"><img src="http://www.clarityenglish.com/images/email/rti2/img_reminder.jpg" width="550" height="216" /> 
            </div>
<div style="padding:0 30px;">
                <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">Your old Road to IELTS direct links will still work for the time being, but they will be disabled eventually so you should replace them as soon as possible.</p>
                
                <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">We at Clarity would like to learn about what you and your learners think of the new Road to IELTS. After a few days of using the new program, it would be very useful if you and your learners could complete a user survey, available at this link: <a href="http://www.clarityenglish.com/questionnaire/rtiv2feedback.php" target="_blank">http://www.clarityenglish.com/questionnaire/rtiv2feedback.php</a></p>
        
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">We hope you enjoy the new Road to IELTS. If you have any enquiries or comments, please
don’t hesitate to write to us.</p>
           <table width="540" border="0" cellspacing="0" cellpadding="0">
             <tr>
             		 <td height="10" colspan="2" valign="top"></td>
             </tr>
             <tr>
               <td width="440" valign="top">
                 <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Best wishes</p>
                     <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:5px 0; padding:0; color:#000000; line-height:18px;"><img src="http://www.clarityenglish.com/images/email/rti2/img_ar.jpg" width="112" height="23" alt="Adrian Raper"/></p>
                 <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Dr Adrian Raper | Technical Director | Hong Kong Office</p>
                     
                     <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Choose Clarity for effective, easy-to-use, enjoyable ICT for English.</p>
					 <p style="font-family: Verdana, Arial, Helvetica, sans-serif;  font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Clarity Language Consultants Ltd (UK and Hong Kong)</p>
					 <p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 10px 0 0 0; font-size:10px"><a href="http://www.clarityenglish.com/" target="_blank">www.ClarityEnglish.com</a><br />
	PO Box 163, Sai Kung, Hong Kong<br />
	Tel: (+852) 2791 1787, Fax: (+852) 2791 6484    </p>    			</td>
               <td width="100" valign="top"></td>
             </tr>
             <tr>
               <td height="15" valign="top"></td>
               <td  valign="top"></td>
             </tr>
           </table>
	  </div>
      
        </td>
  </tr>
  <tr>
    <td height="51" colspan="3" background="http://www.clarityenglish.com/images/email/rti2/rtiv2_footer_circle.jpg"></td>
  </tr>
  
  <tr>
        <td width="436" height="40" bgcolor="#767676">
            <a href="http://www.clarityenglish.com" target="_blank" style="color:#FFFFFF; text-decoration:none; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; padding:0 0 0 30px; margin:0; ">www.ClarityEnglish.com</a>        </td>
<td width="84" bgcolor="#767676">
            <a href="http://www.britishcouncil.org" target="_blank" style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;">
            <img src="http://www.clarityenglish.com/images/email/rti2/welcome_foot_bc.jpg" alt="British Council" width="79" height="40" border="0" style="display:block;"/>
            </a>
        </td>
        <td width="80" bgcolor="#767676">
            <a href="http://www.clarityenglish.com/" target="_blank" style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;">
            <img src="http://www.clarityenglish.com/images/email/rti2/upgrade_foot_clarity.jpg" alt="Clarity" width="69" height="40" border="0" style="display:block;"/>
            </a>
        </td>
  </tr>
</table>
</body>
</html>
