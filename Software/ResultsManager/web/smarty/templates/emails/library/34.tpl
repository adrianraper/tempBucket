{* Name: Subscription reminders, start +6 weeks *}
{* Description: Email 4. One and a half months after starting. *}
{* Variables: $account *}
<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Clarity English - ICT support for librarians</title>
	<!-- <from>%22Clarity English%22 %3Csupport@clarityenglish.com%3E</from> -->
	<!-- <bcc>admin@clarityenglish.com,support@clarityenglish.com</bcc> -->
    	<style type="text/css">
  	    	@import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
		</style>
</head>
<body text="#000000" style="margin:0; padding:0;">
<div style="width:600px; margin:0 auto; padding:0;">
  <img src="http://www.clarityenglish.com/images/email/header_600_img.jpg" alt="Clarity English - ICT support for librarians" style="border:0; margin:0; text-align:center; font-family: 'Oxygen', Arial, Helvetica, sans-serif;   font-weight:400; font-size: 13px;">
    <div style="width:500px; margin:a auto; padding:10px 50px 20px 50px;">
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Dear Librarian</p>
      <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 5px 0; padding:0; color:#151745; font-weight:700;">Clarity English Subscription: {$account->name}</p>

		
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">I hope your Clarity English resources are proving really popular, and that your library members are enjoying them.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">This is just a quick note to check that all is well. If you have any queries, please don't hesitate to contact me or anyone in my support team.</p>
		<p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">Incidentally, did you know 
        we have various resources to help increase usage? For example, you might be interested in using materials on the support site to publicise the programs within your library. These include videos, posters, flyers, web graphics and so on. Most of these items are free to subscribers. </p>
      <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">
      For more details, click <a href="http://www.clarityenglish.com/lib/resources/index.php?program=RoadtoIELTS" target="_blank">here</a> and look at the row of items halfway down the page. It just refers to Road to IELTS now - but everything will also apply to other Clarity titles as well.</p>
      <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif;  font-weight:400; font-size: 13px; line-height:18px; margin:0 0 10px 0; padding:0; color:#000000;">As ever, if you have any queries or requests, please get in touch.</p>
      <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:10px 0 10px 0; padding:0; color:#000000;">Best regards<br>
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