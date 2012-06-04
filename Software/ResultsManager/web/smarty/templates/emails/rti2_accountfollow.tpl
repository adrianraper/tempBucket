{* Name: The new Road to IELTS *}
{* Description: Following up last week's Road to IELTS 2 *}
{* Parameters: $account *}
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Follow up for Road to IELTS</title>
</head>
{literal}
<!--
.style1 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 12px;}
.style2 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 11px;}
-->
{/literal}
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
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="3">
    

    	<img src="http://www.clarityenglish.com/images/email/rti2/rtiv2_header2.jpg" alt="Road to IELTS" width="600" height="86" style="margin:0 0 20px 0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; "/>
            
           
     
           
      <div style="padding:0 20px;">
           
           		<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">Dear Colleague</p>
                           <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;text-align:center"><b>- {$account->name} -</b></p>
           
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">As we promised last week, we have now upgraded your Road to IELTS to the latest version.</p>
        
        <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">For full details, please see <a href="http://www.clarityenglish.com/program/roadtoielts2.php" target="_blank">www.ClarityEnglish.com/RoadtoIELTSv2</a>.</p>
        
                
           <table width="560" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="231" valign="top">
                    
                    <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;"><strong>What are the implications?</strong></p>
                    
                    <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">If your students login through <a href="http://www.ClarityEnglish.com" target="_blank">www.ClarityEnglish.com</a> they will see a new icon for Road to IELTS and will simply go into the new version. Their name and password don't change. Progress records from the old version will NOT be shown to students from within the new version. But Results Manager will show you both versions and you can see all progress records for both.</p>
                    <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">The interface is different and the menus are different, so any guides or lessons you have planned around the old version might need to be adapted.</p>                  </td>
                    <td width="340" valign="top"><img src="http://www.clarityenglish.com/images/email/rti2/img_update_main.jpg" width="337" height="315" style="margin:5px 0 0 0;" /></td>
             </tr>
             
             
                <tr>
                  <td colspan="2" valign="top">
                  
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
                     </td>
                </tr>
                <tr>
                  <td colspan="2" valign="top"><table width="600" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td width="385">
                           <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 5px 0; padding:0; color:#000000; line-height:18px;">If you are a library or school with a customised login screen, these links have probably already been updated.</p>
                      	        
			<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:8px 0 15px 0; padding:0; color:#000000; line-height:18px;">You can also find the support materials <a href="http://www.clarityenglish.com/support/materials/roadtoielts.php" target="_blank">here</a> for the new version of Road to IELTS.</p>
            
            <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0 0 15px 0; padding:0; color:#000000; line-height:18px;">If you have any questions about this, please do let me know. I hope that you and your
students enjoy the brand new Road to IELTS v2!</p>

<p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Best wishes</p>
                     <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:5px 0; padding:0; color:#000000; line-height:18px;"><img src="http://www.clarityenglish.com/images/email/rti2/img_ar.jpg" width="112" height="23" alt="Adrian Raper"/></p>
                 <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Dr Adrian Raper | Technical Director | Hong Kong Office</p>
                     
                     <p style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Choose Clarity for effective, easy-to-use, enjoyable ICT for English.</p>
					 <p style="font-family: Verdana, Arial, Helvetica, sans-serif;  font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">Clarity Language Consultants Ltd (UK and Hong Kong)</p>
					 <p style="font-family: Verdana, Arial, Helvetica, sans-serif; margin: 10px 0 0 0; font-size:10px"><a href="http://www.clarityenglish.com/" target="_blank">www.ClarityEnglish.com</a><br />
	PO Box 163, Sai Kung, Hong Kong<br />
	Tel: (+852) 2791 1787, Fax: (+852) 2791 6484    </p> 
                      
                      
                      </td>
                      <td width="215" valign="top">
                      	 <a href="http://www.clarityenglish.com/support/materials/roadtoielts.php" target="_blank" style="font-family: Verdana, Arial, Helvetica, sans-serif;  font-size: 12px; margin:0; padding:0; color:#000000; border:0;">
                         <img src="http://www.clarityenglish.com/images/email/rti2/img_update_materials.jpg" alt="Click here for new support materials" width="207" height="234" style="border:0;" />                         </a>                      </td>
                    </tr>
                    
                  </table></td>
                </tr>
               <tr>
             		 <td colspan="2" valign="top">
                     
                     
                     
            
             </td>
             </tr>
             
               
             
             
             <tr>
               <td colspan="2" valign="top">
                    			</td>
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
