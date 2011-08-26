{* Name: CLS Online subscription welcome *}
{* Description: Email sent when you have subscribed to CLS online. *}
{* Parameters: $account, $api *}
{* Updated for CLS v2 with packages *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Welcome to iLearnIELTS</title>
	<!-- <from>support@iLearnIELTS.com</from> -->
	<!-- <cc>sales@iLearnIELTS.com</cc> -->
	<!-- <bcc>support@iLearnIELTS.com</bcc> -->
</head>
<body>
	
<div style="margin: 8px;">
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" width="600" border="0" cellpadding="0" cellspacing="0">
  
  <!--Header area-->
  <tr>
	<td width="600" height="96" background="http://www.ilearnielts.com/images/email/header.jpg">
      <a href="http://www.ilearnielts.com" style="display:block; width:600px; height:96px; margin:0; padding:0;" target="_blank"></a>      </td>
  </tr>
    <tr>
	<td>
    <!--Start Content-->
    <table width="600" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="17" rowspan="28"></td>
    <td height="20" colspan="3"></td>
    <td width="3" rowspan="28"></td>
  </tr>
  <tr>
    <td colspan="3" background=""><p style="font-size: 14px; font-weight: bold; color: #6e0041; text-decoration:underline;">Welcome to iLearnIELTS </p></td>
  </tr>
  <tr>
    <td height="10" colspan="3"></td>
  </tr>
  <tr>
    <td colspan="3">
    <!--Introduction line-->
    	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td><p style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px; margin:0; padding:0;">Dear {$account->adminUser->name}</p></td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td><p style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px; margin:0; padding:0;"> Thank you for subscribing to iLearnIELTS. An account has been created for you. To access the account, please go to this URL:</td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td><a href="http://www.iLearnIELTS.com" target="_blank" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">www.iLearnIELTS.com</a></td>
  </tr>
  <tr>
    <td height="10"></td>
  </tr>
  <tr>
    <td> <p style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px; margin:0; padding:0;"> Enter your login details as follows:</p></td>
  </tr>
  <tr>
    <td height="10"><table border="0" cellspacing="0" cellpadding="0" bgcolor="#EBEBEB" width="100%" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td width="64%">
    	<!--Login details-->
        <table width="100%" height="60" border="0" cellpadding="0" cellspacing="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
  <tr>
    <td colspan="2" height="5"></td>
  </tr>
  <tr>
    <td width="15"></td>
    <td width="305" height="15">
       <span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">Login name:</span>
       <span style="color:#000000; margin:0; padding:0; font-weight:bold; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">{$account->adminUser->email}</span></td>
  </tr>

  <tr>
    <td width="15"></td>
    <td width="305" height="15">
    <span style="color:#000000; margin:0; padding:0; font-size: 11px;">Password:</span> <span style="color:#000000; margin:0; padding:0; font-weight:bold; font-size: 11px;">{$account->adminUser->password}</span></td>
  </tr>
 <tr>
    <td colspan="2" height="5"></td>
  </tr>
</table>
		<!--End of Login details-->	</td>

   <td><a href="http://www.iLearnIELTS.com" target="_blank">
<img src="http://www.ilearnielts.com/images/email/btn_startlearning.jpg" width="196" height="30" border="0" alt="Start learning now!" style="color:#000000; text-align:center; padding:0; margin:0;"/></a>    </td>
  </tr>
</table></td>
  </tr>
  
    <tr>
    <td height="5"></td>
  </tr>
</table>
 	<!--End of Introduction line-->	</td>
  </tr>
    <tr>
    <td height="10" width="579" colspan="3" background="http://www.ilearnielts.com/images/email/box_line.jpg"><img src="http://claritydevelop:855/email/WelcomeEmail_template/img_line.jpg" width="579" height="3"/></td>
  </tr>
  <tr>
    <td height="0" colspan="3"></td>
  </tr>
  <tr>
    <td colspan="3"><p style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px; margin:0; padding:0;">You have subscribed to:</p></td>
  </tr>
<tr>
    <td height="5" colspan="3" bgcolor="#EBEBEB"></td>
  </tr>
  <tr>
    <td height="30" background="" bgcolor="#EBEBEB"></td>
    <td height="30" colspan="2" background="" bgcolor="#EBEBEB">
	{if $api->offerID==8}
		<p style="color: #5b5a0a; font-weight: bold; font-size: 12px; font-family: Verdana,Arial,Helvetica,sans-serif; margin:0; padding:5px 0;">iLearnIELTS General Training package</p>
		{assign var='IELTSversion' value='General Training'}
	{else}
		<p style="color: #0099C6; font-weight: bold; font-size: 12px; font-family: Verdana,Arial,Helvetica,sans-serif; margin:0; padding:5px 0">iLearnIELTS Academic package</p>
		{assign var='IELTSversion' value='Academic'}
	{/if}
	</td>
    </tr>
  <tr>
    <td width="19" height="15" bgcolor="#EBEBEB"><p></p>
    <td colspan="2" bgcolor="#EBEBEB">
    	<span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">- Road to IELTS</span>
        <span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">({$IELTSversion} version)</span>
        <span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">*</span>
      </tr>
      <tr>
    <td height="15" bgcolor="#EBEBEB"><p></p>        
    <td height="15" colspan="2" bgcolor="#EBEBEB">
    	<span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">- Study Skills Success V9</span>
        </tr>
          <tr>
    <td height="17" bgcolor="#EBEBEB"><p></p>        
    <td height="17" colspan="2" bgcolor="#EBEBEB">
    	<span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">- TopTips for IELTS</span>
        <span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">({$IELTSversion} version)</span>
     </tr>
     <tr>
    <td height="15" bgcolor="#EBEBEB"><p></p>        
    <td height="15" colspan="2" bgcolor="#EBEBEB">
    	<span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">- Official IELTS Practice Materials</span>
     </tr>
          <tr>
    <td height="15" bgcolor="#EBEBEB">      
    <td height="15" colspan="2" bgcolor="#EBEBEB">
    	<span style="color:#000000; margin:0; padding:0; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">- Access to an IELTS Expert*</span></tr>
    
          <tr>
    <td height="5" colspan="3" bgcolor="#EBEBEB"></tr>
        <tr>
    <td height="3" bgcolor="#EBEBEB">      
    <td height="3" colspan="2" bgcolor="#EBEBEB">
    	<p style="color: #00000; margin:0; padding:5px 0; font-family: Verdana,Arial,Helvetica,sans-serif; font-weight:bold; font-size:11px;">*Note: Please note that Road to IELTS and Ask an Expert are avaliable for a 4 month period.</p>
     </tr>    
        <tr>
    <td height="5" bgcolor="#EBEBEB"><p></p>        
    <td width="8" height="5" bgcolor="#EBEBEB">
    <td width="553" bgcolor="#EBEBEB">
    	<span style="color: #00000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px; margin:0; font-weight:bold; padding:0;">Your online resources will expire on {$api->expiryDate|truncate:10:""}</span>
     </tr>
    <tr>
    <td height="7" colspan="3" bgcolor="#EBEBEB"></tr>
<!--Choose either dependening on what user purchased-->  
    
    
    
        <tr>
    <td height="2" colspan="3"></tr>
        <tr>
          <td height="1" colspan="3"><img src="http://www.ilearnielts.com/images/email/img_line.jpg" width="579" height="3" /></tr>
        <tr>
          <td height="5" colspan="3"></tr>
  <tr>
    <td colspan="3">
    <!--End user details-->
    <table width="100%" border="0" cellpadding="0" cellspacing="0" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;">
   
   <tr>
    <td width="443"><p style="color: #00000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:5px 0;">Below are the shipping details that will be used for your package. Please keep this email for later reference.</p>
    </td>
    </tr>
         <tr>
    <td>
    <table width="100%" height="60" border="0" cellpadding="0" cellspacing="0" bgcolor="#EBEBEB" style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; color:#000000;" >
  <tr>
    <td colspan="3" height="15"></td>
  </tr>
  <tr>
    <td width="17"></td>
    <td width="140" height="15">
       <span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">Order number:</span></td>
    <td width="423"><span style="color:#000000; font-size:10px; margin:0; padding:0; font-weight:normal;">{$api->orderRef}</span></td>
  </tr>

  <tr>
    <td width="17"></td>
    <td width="140" height="15"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">Full name:</span></td>
    <td width="423" height="15"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;">{$account->adminUser->name}</span></td>
  </tr>
  
    <tr>
    <td width="17"></td>
    <td width="140" height="15"><p style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">Shipping address:</strong></td>
    <td width="423" ><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;">{$api->fullAddress}</span></td>
    </tr>
  
   <tr>
    <td width="17"></td>
    <td width="140" height="15"><p style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">Phone number</strong>:</td>
    <td width="423" height="15"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;">{$api->phone}</span></td>
   </tr>
   <tr>
    <td width="17"></td>
    <td width="140" height="15"><p style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">Mobile</strong>:</td>
    <td width="423" height="15"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;">{$api->mobile}</span></td>
   </tr>
      <tr>
    <td width="17"></td>
    <td width="140" height="15"><p style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">Delivery status:</span></td>
    <td width="423" height="15"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;">Your package will be sent to you within 2 to 5 working days.</span></td>
   </tr>
 <tr>
    <td colspan="3" height="15"></td>
  </tr>
</table>    </td>
    </tr>
</table>
	<!--End of End user details-->	</td>
  </tr>
  <tr>
    <td height="5" colspan="3"></td>
  </tr>
  <tr>
    <td height="13" colspan="3"><img src="http://www.ilearnielts.com/images/email/box_line.jpg" width="579" height="3" /></td>
  </tr>
 <tr>
    <td height="5" colspan="3" background=""><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;">If you have any questions, please do not hesitate to contact our Support Team at</span></td>
  </tr>
 <tr>
   <td height="5" colspan="3" background=""><table width="553" border="0" cellspacing="0" cellpadding="0">
     <tr>
       <td height="5" colspan="3"></td>
       </tr>
     <tr>
       <td height="5" colspan="2"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">Customer Service hotline:</span></td>
       <td width="365"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;">+44 208 384 2847</span></td>
     </tr>
     <tr>
       <td colspan="2"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">DHL direct email:</span></td>
       <td><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;"><a href="ilearnielts@dhl.com">ilearnielts@dhl.com</a></span></td>
     </tr>
     <tr>
       <td colspan="2"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:bold;">Technical support email:</span></td>
       <td><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;"><a href="support@clarityenglish.com">support@clarityenglish.com</a></span></td>
     </tr>
     <tr>
       <td height="20" colspan="3"></td>
       </tr>
     <tr>
       <td height"20" colspan="3"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px; margin:0; padding:0; font-weight:normal;">Best wishes</span></td>
       </tr>
     <tr>
       <td colspan="3"><span style="color:#000000; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 12px; margin:0; padding:0; font-weight:bold; font-style:italic">iLearnIELTS Support Team</span></td>
       </tr>
    
     <tr>
       <td width="78"></td>
       <td width="110"></td>
       <td></td>
     </tr>
   </table></td>
 </tr>
 <tr>
   <td height="10" colspan="3" background=""></td>
 </tr>
  
</table>

    
    <!--End of Content--></td>
  </tr>
</table>
</div>
</body>
</html>