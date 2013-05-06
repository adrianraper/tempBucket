{* Name: IELTSPractice.com - 1 week left *}
{* Description: Email sent when an individual has 1 week left in their subscription. *}
{* Parameters: $account *}
{foreach name=orderDetails from=$account->titles item=title}
	{if $title->productCode==52 || $title->productCode==53}
		{assign var='expiryDate' value=$title->expiryDate}
	{/if}
{/foreach}

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Renew your IELTSpractice subscription?</title>
	<!-- <from>%22IELTSPractice.com%22 %3Csupport@ieltspractice.com%3E</from> -->
	<!-- <bcc>alfred.ng@clarityenglish.com</bcc> -->
</head>
<BODY style="BACKGROUND-COLOR: #e5e5e5; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; FONT-SIZE: 13px">
<TABLE border=0 cellSpacing=0 cellPadding=0 width=600 background=http://www.clarityenglish.com/images/email/ieltspractice/bg.jpg 
bgColor=#ffffff align=center>
  <TBODY>
  <TR>
    <TD colSpan=3><A href="http://www.ieltspractice.com" target=_blank><IMG 
      style="MARGIN: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; FONT-SIZE: 13px" 
      border=0 alt="Road to IELTS: IELTS preparation and practice" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/header.jpg" 
      width=600 height=173></A> </TD></TR>
  <TR>
    <TD height=53 
    background=http://www.clarityenglish.com/images/email/ieltspractice/subtitle.jpg 
    colSpan=3>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 53px; MARGIN: 0px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; FONT-WEIGHT: bold; PADDING-TOP: 0px">Renew 
      your subscription?</P></TD></TR>
  <TR>
    <TD colSpan=3>
      <DIV style="PADDING-BOTTOM: 0px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; PADDING-TOP: 0px">
      <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
      Dear {$account->adminUser->name}</P>
      <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Thank 
      you for choosing Road to IELTS. We hope it has improved your skills and helped you develop your confidence in taking the IELTS test.</P>
      <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
      We are sad to inform you that your subscription will be ending in&nbsp;7 days,<br/>on {format_ansi_date ansiDate=$expiryDate format='%d %B %Y'}.</P>
       
       
       <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
     If you would like to renew, please log in to  <a href="http://www.IELTSpractice.com" target="_blank">www.IELTSpractice.com</a>. Click "Renew my licence" on the page.</P>
     
     <A style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px" href="http://www.ieltspractice.com" target="_blank">
     <IMG 
      style="BORDER-RIGHT-WIDTH: 0px; BACKGROUND-COLOR: #f8931f; MARGIN: 0px 0px 15px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; COLOR: #3b1a09; BORDER-LEFT-WIDTH: 0px" 
      alt="Log in and resubscribe now!" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/btn_reminder_renew.jpg" 
      width=183 height=40></A>
     
     
       
        
       
     
     
     <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Please feel free to contact us at <a href="mailto:support@ieltspractice.com">support@ieltspractice.com</a> if you have any questions.</P>

<P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Best wishes</P>

<P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 5px 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px"><IMG 
      alt="Nicole Lung" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/sign_nicolelung.jpg" 
      width=103 height=25></P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Nicole 
      Lung<BR>Marketing Executive, Clarity</P>
     
     
      </DIV></TD></TR>
  
  <TR>
    <TD height=81 
    background=http://www.clarityenglish.com/images/email/ieltspractice/img_btm_plain.jpg
    colSpan=3></TD></TR>
  
  
  <TR>
    <TD 
    background=http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_left.jpg 
    width=10></TD>
    <TD bgColor=#343434 width=579>
      <DIV 
      style="PADDING-BOTTOM: 20px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; PADDING-TOP: 20px">
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; FONT-WEIGHT: bold; PADDING-TOP: 0px">Clarity 
      Language Consultants Ltd<BR>(UK and Hong Kong since 1992)</P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; PADDING-TOP: 0px">T: 
      (+852) 2791 1787 | F: (+852) 2791 6484<BR>E: <A style="COLOR: #ffffff" 
      href="mailto:info@clarityenglish.com" 
      target=_blank>info@clarityenglish.com</A> | W: <A style="COLOR: #ffffff" 
      href="http://www.ClarityEnglish.com" 
      target=_blank>www.ClarityEnglish.com</A> </P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; PADDING-TOP: 0px">Your 
      privacy is important to us. Please review IELTSpractice.com privacy policy 
      by clicking here: <A style="COLOR: #ffffff" 
      href="http://www.clarityenglish.com/disclaimer.php" 
      target=_blank>http://www.clarityenglish.com/disclaimer.php</A></P></DIV></TD>
    <TD 
    background=http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_right.jpg 
    width=11></TD></TR>
    </TBODY>
    </TABLE>
</BODY>
</html>
