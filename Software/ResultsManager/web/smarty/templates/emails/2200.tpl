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
	<title>Extend your Road to IELTS subscription</title>
	<!-- <from>%22IELTSPractice.com%22 %3Csupport@ieltspractice.com%3E</from> -->
</head>
<BODY style="BACKGROUND-COLOR: #e5e5e5; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; FONT-SIZE: 13px">
<TABLE border=0 cellSpacing=0 cellPadding=0 width=600 background="http://www.clarityenglish.com/images/email/ieltspractice/bg.jpg"
bgColor="#ffffff" align="center" style="min-width:600px;">
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
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 53px; MARGIN: 0px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #ffffff; FONT-SIZE: 13px; FONT-WEIGHT: bold; PADDING-TOP: 0px">Extend your subscription!</P></TD></TR>
  <TR>
    <TD colSpan=3>
      <DIV style="PADDING-BOTTOM: 0px; PADDING-LEFT: 48px; PADDING-RIGHT: 48px; PADDING-TOP: 0px">
      <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
      Dear {$account->adminUser->name}</P>
      <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Thank 
      you for choosing Road to IELTS. We hope it has improved your skills and helped you develop your confidence in taking the IELTS test.</P>
      <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
      Your subscription will end on  <strong>{format_ansi_date ansiDate=$expiryDate format='%d %B %Y'}</strong>.</P>
      <P style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">
     If you would like to extend your subscription, please log in to  <a href="http://www.IELTSpractice.com" target="_blank">www.IELTSpractice.com</a>. Click "Extend my subscription" on the page.</P>
     
     <A style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px" href="http://www.ieltspractice.com"><IMG 
      style="BORDER-RIGHT-WIDTH: 0px; BACKGROUND-COLOR: #f8931f; MARGIN: 0px 0px 15px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; COLOR: #3b1a09; BORDER-LEFT-WIDTH: 0px; font-size:13px;" 
      alt="Log in and extend now!" 
      src="http://www.clarityenglish.com/images/email/ieltspractice/btn_remind_extend_off.jpg" 
      width=208 height=39></A>
     
     
     <P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Please feel free to contact us at <A 
      href="mailto:support@ieltspractice.com">support@ieltspractice.com</A> if you have any questions.</P>

<P 
      style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 18px; MARGIN: 0px 0px 15px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; FONT-FAMILY: Arial, Verdana,  Helvetica, sans-serif; COLOR: #000000; FONT-SIZE: 13px; PADDING-TOP: 0px">Best wishes</P>

<p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:10px 0 5px 0; padding:0; color:#000000; line-height:18px;"><img src="http://www.clarityenglish.com/images/email/ieltspractice/sign_cynthialau.jpg" width="103" height="33" alt="Cynthia Lau"/></p>
      <p style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#000000; line-height:18px;">
                 	Cynthia Lau<br />
                    IELTSpractice Support Team</p>
     
     
      </DIV></TD></TR>
  
  <TR>
    <TD height=81 
    background=http://www.clarityenglish.com/images/email/ieltspractice/img_btm_plain.jpg 
    colSpan=3></TD></TR>
  
  
  <TR>
    <TD colspan="3">
    	<table width="600" border="0" cellpadding="0" cellspacing="0" style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0; color:#FFFFFF; line-height:18px;">
  <tr>
    <td width="10" rowspan="13" valign="top" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_left.jpg"></td>
    <td width="48" rowspan="13" valign="top" bgcolor="#343434"></td>
    <td height="20" colspan="2" valign="top" bgcolor="#343434"></td>
    <td width="48" rowspan="13" valign="top" bgcolor="#343434"></td>
    <td width="11" rowspan="13" valign="top" background="http://www.clarityenglish.com/images/email/ieltspractice/bg_btm_right.jpg"></td>
  </tr>
  <tr>
    <td colspan="2" valign="top" bgcolor="#343434">
    	 <strong>Clarity Language Consultants Ltd</strong> (UK and Hong Kong since 1992)</td>
    </tr>
  <tr>
    <td height="5" colspan="2" valign="top" bgcolor="#343434"></td>
    </tr>
  <tr>
    <td width="20" height="20" valign="top" bgcolor="#343434"><img src="http://www.clarityenglish.com/images/email/rti2/winner.jpg" alt="Winner" width="16" height="20"/></td>
    <td width="463"  valign="top" bgcolor="#343434" style="line-height:20px;"><strong>2014 WINNER</strong> of the Hong Kong ICT awards, Best Product (Road to IELTS)</td>
    </tr>
   <tr>
     <td height="5" colspan="2" valign="top" bgcolor="#343434"></td>
     </tr>
   <tr>
     <td  height="20" valign="top" bgcolor="#343434"><img src="http://www.clarityenglish.com/images/email/rti2/winner.jpg" alt="Winner" width="16" height="20"/></td>
     <td valign="top" style="line-height:20px;" bgcolor="#343434"><strong>2013 WINNER</strong> of the Hong Kong Business Award (SME)</td>
   </tr>
   <tr>
     <td  height="5" colspan="2" valign="top" bgcolor="#343434"></td>
     </tr>
   <tr>
     <td  height="20" valign="top" bgcolor="#343434"><img src="http://www.clarityenglish.com/images/email/rti2/winner.jpg" alt="Winner" width="16" height="20"/></td>
    <td width="463" valign="top" style="line-height:20px;" bgcolor="#343434"><strong>2012 WINNER</strong> of the English Speaking Union President's Award</td>
    </tr>
  <tr>
    <td height="8" colspan="2" valign="middle" bgcolor="#343434"></td>
    </tr>
  <tr>
    <td height="20" colspan="2" valign="middle" background="http://www.clarityenglish.com/images/email/rti2/ielts_foot_line.jpg" bgcolor="#343434"></td>
    </tr>
   <tr>
     <td height="8" colspan="2" valign="middle" bgcolor="#343434"></td>
     </tr>
      <tr>
        <td height="45" colspan="2" valign="top" bgcolor="#343434">
                T: (+852) 2791 1787 | F: (+852) 2791 6484<br />
                E: <a href="mailto:support@ieltspractice.com" style="color:#FFFFFF; font-family: Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0;">support@ieltspractice.com</a> | W: <a href="http://www.IELTSpractice.com/" target="_blank" style="color:#FFFFFF; font-family: Arial, Helvetica, sans-serif; font-size: 12px; margin:0; padding:0;">www.IELTSpractice.com</a>        </td>
        </tr>
      <tr>
        <td  colspan="2" valign="top" style="padding:0 0 15px 0;" bgcolor="#343434">
                Your privacy is important to us. Please review the IELTSpractice.com privacy policy <br />by clicking
here: <a href="http://www.ieltspractice.com/terms.php" target="_blank" style="color:#FFFFFF;">http://www.ieltspractice.com/terms.php</a>    </td>
     </tr>
  <tr>
    <td height="10" colspan="6" background="http://www.clarityenglish.com/images/email/rti2/ielts_foot_bottom.jpg" ></td>
    </tr>
</table>
    </TD>
    </TR>
    </TBODY>
    </TABLE>
</BODY>
</html>
