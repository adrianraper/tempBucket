{* Name: ClarityLifeSkills.com - 1 week left *}
{* Description: Email sent when an individual has 1 week left in their subscription. *}
{* Parameters: $account *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>ClarityLifeSkills.com - Your subscription will expire in a week</title>
		<!-- <from>accounts@clarityenglish.com</from> -->
</head>

<body>
<div style="margin: 8px;">
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" width="600" border="0" cellpadding="0" cellspacing="0">
  
  <!--Header area-->
  <tr>
	<td colspan="5" height="82" background="http://www.ClarityLifeSkills.com/email/header1.jpg">
    <img src="http://www.ClarityLifeSkills.com/email/header1.jpg" alt="www.ClarityLifeSkills.com" border="0" /></td>
  </tr>
    <tr>
	<td colspan="5" height="60" valign="bottom">
    
        <table width="600" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#12384d; font-weight:bold; font-size:18px;">Don't miss out!</span></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="357" height="3" background="http://www.ClarityLifeSkills.com/email/title_line.jpg"></td>
            <td width="218"></td>
          </tr>
          <tr>
            <td width="25"></td>
            <td width="575" colspan="2"><span style="color:#12384d; font-weight:bold; font-size:14px;">Your subscription will expire in a week.</span></td>
          </tr>
        </table>
    
    </td>
	</tr>
  <tr>
	<td colspan="5" height="10"></td>
  </tr>
  <!--End Header area-->
 
  <tr>
    <td width="25"></td>
    <td width="435">
    
    	<p style="margin: 0 0 10px 0; padding:0;">Dear {$account->adminUser->name}</p>
        <p style="margin: 0 0 10px 0; padding:0;">Your subscription to ClarityLifeSkills.com will expire in seven days! Before your subscription ends, log in to ClarityLifeSkills.com and take advantage of what's on offer.</p>
        {include file='file:includes/CLS_Email_Signature.tpl'}
        
	</td>
    <td width="10"></td>
    <td width="5" style="border-left:1px #CCCCCC solid;"></td>
    <td width="105" valign="top">
	<!--Start Learning Button-->
    	<table border="0" cellspacing="0" cellpadding="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
        	<tr>
            	<td align="center">
                	<a href="http://www.claritylifeskills.com/" target="_blank">
                    <img src="http://www.ClarityLifeSkills.com/email/start_but.jpg" alt="Start Learning Now!" border="0"/></a>
                  </td>
             </tr>
        </table>
	<!--End of Start Learning Button-->
	</td>
  </tr>
  <tr>
    <td colspan="5" height="10"></td>
  </tr>
  <tr>
    <td colspan="5" height="5"  style="border-top:1px #CCCCCC solid;"></td>
  </tr>
  <tr>
    <td colspan="5" height="10">
    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="25"></td>
                <td width="441" style="font-size:9px">
        {include file='file:includes/CLS_Privacy.tpl'}
                </td>
                <td width="134"></td>
          </tr>
         </table>
         
    </td>
  </tr>
  
</table>
</div>

</body>
</html>
