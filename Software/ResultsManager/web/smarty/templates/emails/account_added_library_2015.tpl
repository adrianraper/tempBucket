
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

    
	<title>ClarityEnglish - Your new account</title>
	<!-- <from>%22ClarityEnglish%22 %3Cadmin@clarityenglish.com%3E</from> -->
	<!-- <bcc>admin@clarityenglish.com, accounts@clarityenglish.com</bcc> -->
	<style type="text/css">
		@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
	</style>
    
    </head>
<body text="#000000" style="margin:0; padding:0; font-family:Arial, Helvetica, sans-serif; font-size:12px;">

{if $account->titles|@count > 1}
	{assign var='multipleTitles' value='true'}
{/if}
{assign var='hasR2I' value='false'}
{assign var='hasTBv10' value='false'}
{foreach name=orderDetails from=$account->titles item=title}
	{if $title->productCode=='52' || $title->productCode=='53'}
		{assign var='hasR2I' value='true'}
	{/if} 
	{if $title->productCode=='55'}
		{assign var='hasTBv10' value='true'}
	{/if}
    
    {if $title->productCode=='56'}
		{assign var='hasARv10' value='true'}
	{/if} 
    
    {if $title->productCode=='57'}
		{assign var='hasCP1v10' value='true'}
	{/if} 
{/foreach}

<div style="max-width:600px; margin:0 auto; padding:0;">
 
      
      <img src="http://www.clarityenglish.com/images/email/email15_banner.jpg" alt="ClarityEnglish - Your new account"  style="border:0; margin:0; text-align:center; font-family: Arial, Helvetica, sans-serif; font-size: 1em; width:100%;">
   
<div style="padding:30px 8% 20px 8%;">
		<p style="font-family: Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Dear Colleague</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 5px 0;color:#151745; font-weight:700;">New Account: {$account->name}</p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">This email is to welcome you as the Administrator of this new ClarityEnglish account. It deals with the technical and administrative aspects of your account, so please keep it in a safe place, as you may want to refer to it later.</p>

        <div style="background-color:#E8E3F0;  padding:10px 20px; margin:0 auto 10px auto;">
            <p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding:0; color:#000000;">In this email we deal with the following areas:</p>
        	<ol style="font-family: Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding: 0 0 0 20px;  color:#000000;">
                <li>Licence details</li>
                <li>The functions of your Administrator account</li>
                <li>Accessing your ClarityEnglish programs for the first time</li>
                <li>Setting up a direct link to your ClarityEnglish programs</li>
				 
                 {if $hasTBv10=='true'}
                 <li>Tense Buster 6-week grammar course</li>
                 	{/if}
                
     {if $hasR2I=='true' || $hasTBv10=='true' ||  $hasARv10=='true' ||  $hasCP1v10=='true'}
                
         
          		<li>Downloading the app to tablets</li>
                     <li>Using the app in and outside the library</li>
				{/if}
              	<li>Promotional items</li>
                <li>Support</li>
     		</ol>
      </div>
	
<ol style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding: 0 0 0 15px;  color:#000000;">
<!-- 
-- 1. Licence Details
-->
	<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745;">Licence details</li>
	{include file='file:includes/Title_Details_Section_withRM_Library.tpl' dateDiff=$dateDiff useWording=$useWording}
<!-- 
-- 2. Administrator account details
-- 	Different sections for AA and LT
-->
<li style="font-family:  'Oxygen',Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 5px 0; color:#151745; font-weight:700;">The functions of your Administrator account</li>
	<div style="background-color:#E8E3F0;  padding:10px 20px; margin:0 auto 10px auto;">
		<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding:0; color:#000000;">Login name: {$account->adminUser->name}</p>
		<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding:0; color:#000000;">Password: {$account->adminUser->password}</p>
	</div>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Note that you should restrict access to the Administrator account to a single person. 
		It should not be given out to library members, as this account gives access to usage statistics for all your programs.</p> 

<!-- 
-- 3. Starting for the first time
-- Different sections for AA and LT
-->
<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 5px 0; color:#151745; font-weight:700;">Accessing your ClarityEnglish programs for the first time</li>
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">First log in at <a href="http://www.clarityenglish.com?utm_source=auto_email&utm_medium=lib_acct_add&utm_term=link_home&utm_campaign=auto_welcome&utm_content=1st_ce_home" target="_blank">www.ClarityEnglish.com</a>, using your Administrator account. In order to activate the programs, the first thing you need to do is to accept the terms and conditions, which  will automatically be shown to you.</p>
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Once you have done this, you and your library users will have full access to your Clarity programs.</p>

<!-- 
-- 4. Setting up a direct link to your ClarityEnglish programs
-->
{foreach name=licenceStuff from=$account->licenceAttributes item=licenceAttribute}
	{if isset($licenceAttribute->licenceKey)}	<!-- For Email 	-->
	{if $licenceAttribute->licenceKey == "IPrange"}
		{assign var='hasIP' value='true'}
		{assign var='IPrange' value=$licenceAttribute->licenceValue}
	{/if}
	{if $licenceAttribute->licenceKey == "barcode"}
		{assign var='hasBarcode' value='true'}
		{assign var='barcode' value=$licenceAttribute->licenceValue}
		{/if}
	{else} 		<!-- For preview -->
		{if $licenceAttribute.licenceKey == "IPrange"}
			{assign var='hasIP' value='true'}
			{assign var='IPrange' value=$licenceAttribute.licenceValue}
		{/if}
		{if $licenceAttribute.licenceKey == "barcode"}
			{assign var='hasBarcode' value='true'}
			{assign var='barcode' value=$licenceAttribute.licenceValue}
		{/if}
	{/if}
{/foreach}
<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:10px 0 5px 0; color:#151745; font-weight:700;">Setting up a direct link to your ClarityEnglish programs</li>

	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Use the following direct {if $multipleTitles=='true'}links{else}link{/if} to access the programs:</p>
	{foreach name=orderDetails from=$account->titles item=title}
	
    {if ($title->productCode=='9' && $hasTBv10 == 'true') || ($title->productCode=='33' && $hasARv10 == 'true') ||
		($title->productCode=='39' && $hasCP1v10 == 'true') ||
		($title->productCode=='63') || ($title->productCode=='65')}
	{else}
    
    
    	{if !$title->name|stristr:"Results Manager" && !$title->name|stristr:"Practice Centre" && $title->productCode!='3' && $title->productCode!='12' && $title->productCode!='13' && $title->productCode!='52' && $title->productCode!='53' && $title->productCode!='55' && $title->productCode!='59' && $title->productCode!='45' && $title->productCode!='46'}
        
	  <p style="font-family:  Arial, Helvetica, sans-serif;font-size: 1em; line-height:18px;margin:0 0 10px 0;">{$title->name}<br/><a href="http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}" target="_blank">http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}</a>
		{/if}
		
    	{if $title->productCode=='45' || $title->productCode=='46'}
        
	  <p style="font-family:  Arial, Helvetica, sans-serif;font-size: 1em; line-height:18px;margin:0 0 10px 0;">{$title->name}<br/><a href="http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}&version={$title->languageCode}" target="_blank">http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}&version={$title->languageCode}</a>
		{/if}
        
        	{if  $title->productCode=='52' || $title->productCode=='53'}
			<p style="font-family:  Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em;  margin:0 0 10px 0;">{$title->name}<br/><a href="http://www.ieltspractice.com/library/{$account->prefix}/index.php?pc={$title->productCode}" target="_blank">http://www.IELTSpractice.com/library/{$account->prefix}/index.php?pc={$title->productCode}</a>
		{/if}  
        
        {if $title->productCode=='59'}
	  <p style="font-family:  Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em;  margin:0 0 10px 0;">Tense Buster: Create your 6-week course<br/><a href="http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}" target="_blank">http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}</a>
		{/if}  
        
       {if $title->productCode=='55'}
	  <p style="font-family:  Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em;  margin:0 0 10px 0;">Tense Buster: Access the full version any time<br/><a href="http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}" target="_blank">http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc={$title->productCode}</a>
		{/if}  
     {/if}
        
	{/foreach}

{if $hasIP == 'true' && $hasBarcode == 'true'}
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">On this page, if your IP matches the range {$IPrange}, you will go straight through to the programs.</p>
    <p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">
    If not, you have to type a barcode. 
	This must match the pattern: <br/>{$barcode}.</p>
{elseif $hasIP == 'true'}
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">You will only gain access to the program if your IP (directly or through a proxy) matches the range {$IPrange}.</p>
    {elseif $hasBarcode == 'true'}
	 <p style="font-family:  Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em; margin:0 0 10px 0;">On this page, you have to type a barcode. This must match the pattern:<br/>{$barcode}.</p>
{else}
	<div style="background-color:#E8E3F0;  padding:10px 20px; margin:0 auto 10px auto; border:2px solid">
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding:0; color:#000000;">IMPORTANT NOTE:
	A direct link must only be pasted in a password-protected area of your website. 
	This is to protect your licence and to prevent access from unlicensed users. If you have any queries about this, please contact us or check the online support pages.</p>
	</div>
{/if}
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0; padding:0;">You can also use the following URL to access Results Manager to see usage stats.</p>
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:0 0 10px 0; padding:0;"><a href="http://www.ClarityEnglish.com/area1/ResultsManager/Start.php?prefix={$account->prefix}" target="_blank">http://www.ClarityEnglish.com/area1/ResultsManager/Start.php?prefix={$account->prefix}</a></p>


{if $hasTBv10=='true'}
<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:10px 0 5px 0; color:#151745; font-weight:700;">Tense Buster 6-week grammar course</li>

<p style="font-family:  Arial, Helvetica, sans-serif;font-size: 1em; line-height:18px;margin:0 0 10px 0;">
The Tense Buster library version gives users two options:</p>

<p style="font-family:  Arial, Helvetica, sans-serif;font-size: 1em; line-height:18px;margin:0 0 10px 0;">
<strong>Option 1) Access content weekly, with level test and practice guidance</strong><br>They can take a quick level test, input their email address and receive a link to a new unit at their level every week for six weeks. At the end of the process, they can choose to delete their email address. (In any case they will never be sent anything other than links to the six units).
<p style="font-family:  Arial, Helvetica, sans-serif;font-size: 1em; line-height:18px;margin:0 0 20px 0;">Create your 6-week course here:<br/>
  <a href="http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc=59" target="_blank">http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc=59</a></p>


<p style="font-family:  Arial, Helvetica, sans-serif;font-size: 1em; line-height:18px;margin:0 0 10px 0;"><strong>Option 2) Access the full version any time!</strong><br>Simply click "Start" under Just practise to access the full version.</p>

<p style="font-family:  Arial, Helvetica, sans-serif;font-size: 1em; line-height:18px;margin:0 0 10px 0;">Access Full Version:<br/>
 <a href="http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc=55" target="_blank">http://www.ClarityEnglish.com/library/{$account->prefix}/index.php?pc=55</a></p>

Please click <a href="http://www.clarityenglish.com/resources/?utm_source=auto_email&utm_medium=lib_acct_add&utm_campaign=auto_welcome&utm_term=link_resources&utm_content=welcome_TB6WK" target="_blank">here</a> to download web images, including banners and buttons.

{/if}


     {if $hasR2I=='true' || $hasTBv10=='true' ||  $hasARv10=='true' ||  $hasCP1v10=='true'}

<!-- 
-- Download the app
-->

<li style="font-family:  'Oxygen', Arial, Helvetica, sans-serif;margin:10px 0 5px 0; color:#151745; font-size: 1em; font-weight:700;">Downloading the app to tablets</li>

<p style="font-family:  Arial, Helvetica, sans-serif;margin:0; font-size: 1em; ">You can either search for the program in the Apple App Store / Google Play Store or use the direct links below:</p>
{if $hasR2I=='true'}
<p style="font-family:  Arial, Helvetica, sans-serif;margin:10px 0 5px 0; font-size: 1em; font-weight:700;">Search for "Road to IELTS" or download from:</p>

<a href="https://itunes.apple.com/us/app/road-to-ielts/id560055517?mt=8&ign-mpt=uo%3D4" target="_blank"><img src="http://www.clarityenglish.com/images/email/badge_appstore.jpg" alt="App Store" border="0"></a>
<a href="https://play.google.com/store/apps/details?id=air.com.clarityenglish.ielts.app" target="_blank"><img src="http://www.clarityenglish.com/images/email/badge_googleplay.jpg" alt="Google play" border="0"></a>
{/if}
{if $hasTBv10=='true'}
<p style="font-family:  Arial, Helvetica, sans-serif;margin:10px 0 5px 0; font-size: 1em; font-weight:700;">Search for "Tense Buster" or download from:</p>
<a href="https://itunes.apple.com/us/app/tense-buster/id696619890?mt=8" target="_blank"><img src="http://www.clarityenglish.com/images/email/badge_appstore.jpg" alt="App Store" border="0"></a>
<a href="https://play.google.com/store/apps/details?id=air.com.clarityenglish.tensebuster.app" target="_blank"><img src="http://www.clarityenglish.com/images/email/badge_googleplay.jpg" alt="Google play" border="0"></a>
{/if}

{if $hasCP1v10=='true'}
<p style="font-family:  Arial, Helvetica, sans-serif;margin:10px 0 5px 0; font-size: 1em; font-weight:700;">Search for "Clear Pronunciation 1 Sounds" or download from:</p>

<a href="https://itunes.apple.com/us/app/clear-pronunciation-1-sounds/id937667661?mt=8" target="_blank"><img src="http://www.clarityenglish.com/images/email/badge_appstore.jpg" alt="App Store" border="0"></a>
<a href="https://play.google.com/store/apps/details?id=air.com.clarityenglish.clearpronunciation.app" target="_blank"><img src="http://www.clarityenglish.com/images/email/badge_googleplay.jpg" alt="Google play" border="0"></a>
{/if}

{if $hasARv10=='true'}
<p style="font-family:  Arial, Helvetica, sans-serif;margin:10px 0 5px 0; font-size: 1em; font-weight:700;">Search for "Active Reading" or download from:</p>

<a href="https://itunes.apple.com/us/app/active-reading/id940295009?ls=1&mt=8" target="_blank"><img src="http://www.clarityenglish.com/images/email/badge_appstore.jpg" alt="App Store" border="0"></a>
<a href="https://play.google.com/store/apps/details?id=air.com.clarityenglish.activereading" target="_blank"><img src="http://www.clarityenglish.com/images/email/badge_googleplay.jpg" alt="Google play" border="0"></a>
{/if}
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; margin:10px 0;">
<strong>*NOTE: </strong>The app is only compatible with iPad & Android tablets, not mobile phones due to screen size limitations.</p>
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; margin:0 0 10px 0;">System requirements as below:</p>


<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; margin:0 0 10px 0;"><u>For iPad</u><br />
- iOS v6.1.3 or later</p>

<p style="font-family:  Arial, Helvetica, sans-serif;font-size: 1em; margin:0 0 10px 0;"><u>For Android</u><br />

- Android OS 4.1.1 or higher<br />
- xlarge screens (960dp x 720dp)<br />
</p>


<!-- 
-- Using the app
-->

<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:10px 0 5px 0; color:#151745; font-weight:700;">Using the app in and outside the library</li>

<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">
If you are using a tablet within the library, the tablet needs to be connected using the library's wifi. If the program can connect and find the library account, the learner will then be able to use the program with the same login account or by anonymous access.</p>

<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">
  If your wifi IP matches{if $hasIP == 'true'} ({$IPrange}){/if}, you will go straight through to the login screen for your library. {if $hasIP == 'true'}Please contact the Clarity Support team (<a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a>)  if you have updated your IP address ranges.{else}Please note that  we do not have an IP address for your library on record.   If you would like to provide us with one, please contact the Clarity Support team (<a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a>).{/if}</p>
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:10px 0;">
If the learner uses a tablet outside the library, they can sign in using their email address PROVIDED they have already registered it using the tablet inside the library or their desktop browser from home.</p>
{/if}

<!-- 
-- 7. Promotional materials
-->
<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:10px 0 5px 0; color:#151745; font-weight:700;">Promotional items</li>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Click on the link below to see support videos, or to download web graphics, flyers and syllabus documents, and to request posters.<br />
<a href="http://www.clarityenglish.com/resources/?utm_source=auto_email&utm_medium=lib_acct_add&utm_campaign=auto_welcome&utm_term=link_resources&utm_content=welcome_promote" target="_blank">http://www.ClarityEnglish.com/resources/</a></p>

<!-- 
-- 8. Support
-->
<li style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-size: 1em; line-height:18px;margin:10px 0 5px 0; color:#151745; font-weight:700;">Support</li>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">If at any time you have queries, requests or suggestions, the Clarity Support team is here to help:</p>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 20px; padding:0; color:#000000;">
	Email: <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a> <br />
	United Kingdom : +44 (0) 845 130 5627<br />
	Hong Kong : +852 2791 1787	</p>
<!-- 
-- End
-->
    </ol>
<!-- 
-- Resellers' contact details - if any
-->
	{include file='file:includes/Reseller_Details.tpl' resellerCode=$account->resellerCode}
    

    
    
<!-- 
-- Email signature 
-->
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Finally, may I take this opportunity to thank you for choosing Clarity programs. We will do everything we can to help you make them a great success in your library.</p>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
    Adrian
    </p>
	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>    
</div>
</body>
</html>
