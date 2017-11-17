
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>ClarityEnglish - Your account update</title>
		<!-- <from>%22ClarityEnglish%22 %3Cadmin@clarityenglish.com%3E</from> -->
		<!-- <bcc>admin@clarityenglish.com, accounts@clarityenglish.com</bcc> -->
		<style type="text/css">
  	    	@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
		</style>
	</head>
<body text="#000000" style="margin:0; padding:0; font-family:Arial, Helvetica, sans-serif; font-size:12px;">

<div style="max-width:600px; margin:0 auto; padding:0;">

      <img src="http://www.clarityenglish.com/images/email/email15_banner.jpg" alt="ClarityEnglish - Your account update" style="border:0; margin:0; text-align:center; font-family: Arial, Helvetica, sans-serif;font-size: 1em; width: 100%;">
     
<div style="padding:30px 8% 20px 8%;">
		<p style="font-family:  Arial, Helvetica, sans-serif;  line-height:18px;  font-size: 1em; margin:0 0 10px 0; padding:0; color:#000000;">Dear Colleague</p>
        <p style="font-family: Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em; margin:0 0 5px 0; padding:0; color:#151745; font-weight:700;">Updated Account: {$account->name}</p>
		<p style="font-family:  Arial, Helvetica, sans-serif;  line-height:18px;  font-size: 1em; margin:0 0 10px 0; padding:0; color:#000000;">This email is to confirm that your ClarityEnglish account has been updated as follows:</p>

<ol style="font-family:  Arial, Helvetica, sans-serif;  font-size: 1em; line-height:18px; margin:0; padding: 0 0 0 15px;  color:#000000;">
<!-- 
-- 1. Licence Details
-->
	<li style="font-family:  'Oxygen',  Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em; margin:0 0 5px 0; padding:0; color:#151745; font-weight:700;">Licence details</li>
    {foreach name=orderDetails from=$account->titles item=title}
        {if ($title->productCode=='63')}
					<div style="background:url(http://www.clarityenglish.com/images/email/dot_line.jpg) no-repeat bottom left; padding:5 0 10px 0; margin:0 0 10px 0">
                        {include file='file:includes/titleTemplateDetails.tpl' method='image' enabled='on'}
                        {assign var='enabledColor' value='#000000'}
                        {assign var='highlightColor' value='#FFFF00'}
						<p style="font-family:  Arial, sans-serif;  font-size: 1em; margin:5px 0 0 0; padding:0; color:{$enabledColor}; line-height:18px;">{$title->name}</p>
						<p style="font-family:  Arial, sans-serif;  font-size: 1em; margin:0; padding:0; color:{$enabledColor};">
						Tests purchased: {$title->maxStudents}<br/>
						Hosted by: Clarity<br/>
						Valid until: {format_ansi_date ansiDate=$title->expiryDate}<br/>
                        </p>
					</div>
        {/if}
    {/foreach}
<!--
-- 7. Support
-->
<li style="font-family: 'Oxygen',  Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em; margin:10px 0 5px 0; color:#151745; font-weight:700;">Support</li>
	<p style="font-family:  Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em;  margin:0 0 10px 0;">If at any time you have queries, requests or suggestions, the Clarity Support team is here to help:</p>
	<p style="font-family:  Arial, Helvetica, sans-serif;  line-height:18px; font-size: 1em;  margin:0 0 10px 20px; padding:0; color:#000000;">
	Email: <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a> <br />
United Kingdom : +44 (0) 845 130 5627<br />
	Hong Kong : +852 2791 1787	</p>
    </ol>
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
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">Finally, may I take this opportunity to thank you for choosing Clarity programs. We will do everything we can to help you make them a great success with your colleagues and your learners.</p>
	<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
    Adrian
    </p>
	{include file='file:includes/TechnicalDirector_Email_Signature.tpl'}
<!-- 
-- Email footer
-->
	{include file='file:includes/Monthly_Email_Footer.tpl'}
	</div>
</div>
</body>
</html>
