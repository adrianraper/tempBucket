{* Name: Welcome letter *}
{* Description: Contains licence details, the admin account, direct links to the programs and support information. *}
{* Parameters: $account, $user 
	where $user is the first student in the root, used for AA passwords *}
<!--
-- Script to count the number of titles related to this email for wording selection
-- Note that some bug in smarty adds a space to the start of 
-->
{assign var='dateDiff' value='0day'}
{include file="file:includes/expiringTitles.tpl" assign=useWording}
{assign var='useWording' value=$useWording|strip:''}
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Update Road to IELTS links request</title>
		<!-- <from>%22Clarity English%22 %3Cadmin@clarityenglish.com%3E</from> -->
		<!-- <bcc>admin@clarityenglish.com, accounts@clarityenglish.com</bcc> -->
	<style type="text/css">
    		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
			</style>
	</head>
<body text="#000000" style="margin:0; padding:0;">
{foreach name=orderDetails from=$account->titles item=title}
	{if $title->name|stristr:"Results Manager"}
		{assign var='hasRM' value='true'}
		{if $title->licenceType == 2}
			{assign var='hasAARM' value='true'}
		{/if}
	{/if}
	{if $title->name|stristr:"Author Plus"}
		{assign var='hasAP' value='true'}
	{/if}
{/foreach}
{* Also work out some other stuff about the licences to help with wording *}
{if $account->titles|@count > 1}
	{assign var='multipleTitles' value='true'}
{/if}

<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="3">
    	<table width="600" border="0" cellspacing="0" cellpadding="0">

  
    <tr>
    <td colspan="3">
    		<img src="http://www.clarityenglish.com/images/email/rti2/rtiv2_header.jpg" alt="Road to IELTS" width="600" height="86" style="margin:0 0 20px 0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; "/>
    
    </td>
    </tr>
    
      <tr>
    <td width="50"></td>
    <td width="500">
    	<div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</div>
        <div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#151745;">Your Account: {$account->name}</div>
        
        <div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">      
         We have recently made a number of enhancements to Road to IELTS both at the front end (including a new set of videos) and at the back end for improved performance. This mean one action at you end, which is updating the link on you site. Could you please do this before <u>31st August, 2014</u> when we will be implementing the switchovers.</div>

        
         <div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Road to IELTS is found on your website here:<br> 
           <a href="http://www.monlib.vic.gov.au/oResources/online.php?db=L" target="_blank">http://www.monlib.vic.gov.au/oResources/online.php?db=L</a></div>
    
    
        
        <div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:10px 0 10px 0; color:#151745;">
          <strong>Road to IELTS is using the new domain:</strong><br>
        <table width="450" border="0" cellpadding="0" cellspacing="0" style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0; padding:0; color:#151745;">
  <tr>
    <td height="10" colspan="5"></td>
    </tr>
  <tr>
    <td width="30"><img src="http://www.clarityenglish.com/images/email/rti2/ico_tick.png"></td>
    <td width="183">www.IELTSpractice.com</td>
    <td width="13"></td>
    <td width="30"><img src="http://www.clarityenglish.com/images/email/rti2/ico_fail.png"></td>
    <td width="194">www.ClarityEnglish.com</td>
  </tr>

</table>
</div>
        
        
        <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px;margin:10px 0 5px 0; color:#151745; font-weight:700;">Your action now: Updating the direct link to your Road to IELTS</p>
        
         
        
    	<div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Please copy and paste the following direct {if $multipleTitles=='true'}links{else}link{/if} into your website.</div>
         	{foreach name=orderDetails from=$account->titles item=title}
         {if  $title->productCode=='52' || $title->productCode=='53'}
			<div style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">{$title->name}<br/><a href="http://www.ieltspractice.com/library/{$account->prefix}/index.php?pc={$title->productCode}" target="_blank">http://www.IELTSpractice.com/library/{$account->prefix}/index.php?pc={$title->productCode}</a></div>
		{/if}  
        	{/foreach}

		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Support</p>
	    <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">If at any time you have queries, requests or suggestions, the Clarity Support team is here to help:</p>
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 20px; padding:0; color:#000000;">
	Email: <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a> <br />
	United Kingdom : +44 (0) 845 130 5627<br />
	Hong Kong : +852 2791 1787
	</p>
<!-- 
-- End
-->
<!-- 
-- Resellers' contact details - if any
-->
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
<!-- 
-- Email signature 
-->
	<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Finally, may I take this opportunity to thank you for choosing Clarity programs. We will do everything we can to help you make them a great success with your colleagues and your learners.</p>
    
       <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
    Adrian
    </p>
    {include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
    

        
    
    </td>
    <td width="50"></td>
  </tr>
  
  
      
    	
</table>

    

    
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
