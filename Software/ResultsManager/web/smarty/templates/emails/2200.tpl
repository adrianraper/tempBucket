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
	<title>Extend your IELTSpractice subscription?</title>
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
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 53px; MARGIN: 0px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; FONT-WEIGHT: bold; PADDING-TOP: 0px">Extend 
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
      Write us a testimonial and we will extend your subscription for another week.</P></DIV></TD></TR>
  <TR>
    <TD colSpan=3><IMG alt="Extend your subscription by 1 FREE WEEK!" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/img_reminder_wk.jpg" 
      width=600 height=318> 
      <DIV 
      style="PADDING-BOTTOM: 0px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; PADDING-TOP: 0px">
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 15px 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #0399d6; FONT-SIZE: 18px; FONT-WEIGHT: bold; PADDING-TOP: 0px">Instructions</P>
      <UL 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; LIST-STYLE-TYPE: decimal; MARGIN: 0px 0px 15px; PADDING-LEFT: 20px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
        <LI 
        style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Write 
        us 50 words or more on how Road to IELTS has helped you prepare for the 
        IELTS test. 
        <LI 
        style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Send 
        your photo to <A 
        href="mailto: support@ieltspractice.com?subject=Write a testimonial with your photo to extend your subscription!">support@ieltspractice.com</A> 
        so we can present your comment to others. 
        <LI 
        style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">By 
        sending your comments and photo you confirm that you have read and agree 
        to the <a href="#terms">terms and conditions</a>. </LI>
      </UL><A 
      style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px" 
      href="mailto: support@ieltspractice.com?subject=Write a testimonial with your photo to extend your subscription!"><IMG 
      style="BORDER-RIGHT-WIDTH: 0px; BACKGROUND-COLOR: #facc38; MARGIN: 0px 0px 15px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; COLOR: #37250d; BORDER-LEFT-WIDTH: 0px" 
      alt="Write a testimonial with your photo to extend your subscription!" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/btn_reminder_testimonial.jpg" 
      width=507 height=79></A> <A 
      style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px" 
      href="mailto: support@ieltspractice.com?subject=Renew IELTSpractice subscription"><IMG 
      style="BORDER-RIGHT-WIDTH: 0px; BACKGROUND-COLOR: #f8931f; MARGIN: 0px 0px 15px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; COLOR: #3b1a09; BORDER-LEFT-WIDTH: 0px" 
      alt="Renew subscription for USD49.99" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/btn_reminder_renew.jpg" 
      width=276 height=41></A> 
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Please 
      feel free to contact us at <A 
      href="mailto: support@ieltspractice.com">support@ieltspractice.com</A> if 
      you have any questions.</P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Best 
      wishes</P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 5px 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px"><IMG 
      alt="Nicole Lung" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/sign_nicolelung.jpg" 
      width=103 height=25></P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Nicole 
      Lung<BR>Marketing Executive, Clarity</P></DIV></TD></TR>
  <TR>
    <TD height=81 
    background=http://www.clarityenglish.com/images/email/ieltspractice/reminder_line.jpg 
    colSpan=3></TD></TR>
  <TR>
    <TD colSpan=3>
      <DIV 
      style="PADDING-BOTTOM: 0px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; PADDING-TOP: 0px">
      <a name="terms"></a>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 20px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #0399d6; FONT-SIZE: 18px; FONT-WEIGHT: bold; PADDING-TOP: 0px">Terms 
      and Conditions</P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Please 
      remember that, by submitting photograph(s) and comments you confirm that 
      you agree to the terms and conditions below.</P>
      <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; FONT-WEIGHT: bold; PADDING-TOP: 0px">Terms 
      and conditions for submitting photographs to IELTSpractice.com</P>
      <UL 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; LIST-STYLE-TYPE: decimal; MARGIN: 0px 0px 15px; PADDING-LEFT: 20px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
        <LI 
        style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">By 
        submitting your photograph and comments you agree to grant Clarity 
        Language Consultants Ltd. a perpetual, royalty-free, non-exclusive, 
        sub-licenseable right and license to use, reproduce, modify, adapt, 
        publish, create derivative works from, distribute, make available to the 
        public, and exercise all copyright and publicity rights with respect to 
        your photograph and comments worldwide and/or to incorporate your 
        photograph and comments in other works and publications in any media now 
        known or later developed for the full term of any rights that may exist 
        in your photograph. If you do not want to grant to Clarity Language 
        Consultants Ltd. the rights set out above, please do not submit your 
        photograph and comments to IELTSpractice.com. 
        <LI 
        style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Further 
        to paragraph 1 above, by submitting your photograph and comments to 
        IELTSpractice.com you: 
        <UL 
        style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; LIST-STYLE-TYPE: lower-roman; MARGIN: 0px 0px 15px; PADDING-LEFT: 25px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
          <LI 
          style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">warrant 
          that your photograph is your true self and that you have the right to 
          make it available to Clarity Language Consultants Ltd. for all the 
          purposes specified above; 
          <LI 
          style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">warrant 
          that your photograph and comments do not infringe any law. 
          <LI 
          style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">agree 
          to indemnify Clarity Language Consultants Ltd. against all legal fees, 
          damages and other expenses that may be incurred by Clarity Language 
          Consultants Ltd. as a result of your breach of the above warranties; 
          and 
          <LI 
          style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">agree 
          to waive any moral rights in your photograph and comments for the 
          purposes of their submission to and publication on IELTSpractice.com 
          and for the purposes specified above. </LI></UL>
        <LI 
        style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 10px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">These 
        terms and conditions will be governed by the laws of England and Wales 
        and the parties agree to submit to the exclusive jurisdiction of the 
        English Courts. </LI></UL></DIV></TD></TR>
  <TR>
    <TD height=81 
    background=http://www.clarityenglish.com/images/email/ieltspractice/img_btm_bubble.jpg 
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
