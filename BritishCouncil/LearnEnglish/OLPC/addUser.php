<?php
session_start();
include_once "variables.php";
$thistime = $_SERVER['REQUEST_TIME']*1000;

if (isset($_SESSION['loginID']))
	$loginID = $_SESSION['loginID'];

function redirect ($url) {
	header('Location: ' . $url);
	exit;
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>British Council Global IELTS - registration</title>
<link rel="shortcut icon" href="<?php echo $commonDomain; ?>Software/R2IV2.ico" type="image/x-icon" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="css/general.css" type="text/css" />
<link rel="stylesheet" href="css/datepicker.css" type="text/css" />
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/date.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery-ui-1.7.custom.min.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/ui/ui.core.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery.ui.datepicker.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/blockUI-2.js"></script>
<script type="text/javascript" src="addUserControl.js"></script>
<script type="text/javascript" >
$(document).ready(function(){
	$('.note').hide();
	$( "#datepicker_start" ).datepicker({
	altField: '#expiryDate',
		dateFormat: "yy-mm-dd",
		defaultDate: "+1M",
		maxDate: "+3M",
		minDate: -0	
	});
	
});
</script>
</head>

<body>

<div class="container">
    <div id="header">
        <div id="header_banner"></div>
    
    </div>
    
    
	<form id="RegisterForm" method="post" action="" >
    <div id="container_details">
    	<div id="table_top"></div>
        
        <div id="table_mid">
          <p class="table_title">Type in your details.</p>
            <p class="field_txt_login">All fields must be completed.</p>
  
            
             <div class="line_big">
             	<a id="btn_contact_details" href="mailto:support@roadtoielts.com?subject=Road to IELTS enquiry"></a>             </div>
             
             <div id="container_details_left">
             
               <div class="field_line">
                 <p class="field_title">Login ID:</p>
			<input type="text" name="loginID" id="loginID" size="25" value="<?php echo $loginID; ?>" class="field_reg" readonly="readonly" />
                     <p class="field_txt_tips">(Always use this ID to login.)</p>
                     <div class="clear"></div>
                 </div>
             
                  <div class="field_line">
                    <p class="field_title">Your name:</p>
                     <input type="text" name="learnerName" id="learnerName" value="" tabindex="4" class="field_reg" maxlength="64"/>
                    <p class="field_txt_tips">(For display only, not login)</p>
                     <div class="clear"></div>
              </div>
             
                 <div class="field_line">
                   <p class="field_title">Your new password:</p>
                     <input type="password" name="password" id="password" value="" tabindex="5" class="field_reg" maxlength="32"/>
                   <div class="clear"></div>
              </div>
             
                 <div class="field_line">
                   <p class="field_title">Confirm password:</p>
                     <input type="password" name="password1" id="password1" value="" tabindex="6" class="field_reg" maxlength="32"/>
		     <label for="password" id="passwordNote" class="note">The two passwords must be the same.</label>
                   <div class="clear"></div>
                 </div>
             
                 <div class="field_line">
                   <p class="field_title">Your email:</p>
                    <input type="text" name="email" id="email" size="25"  value="" tabindex="7" class="field_reg" maxlength="128"/>
                   <p class="field_txt_tips">(This email address will only be used
    to send you information about Road to IELTS.)</p>
                     <div class="clear"></div>
                 </div>

			<div class="btn_area">
				<input name="RegisterSubmit" id="RegisterSubmit" type="button" class="btn_submit" value="" />
				<input name="clearFields" id="clearFields" type="button" class="btn_clear" value="" />
				<div class="btn_comment">
					<div id="responseMessage" class="form_ok"></div>
				<div class="clear"></div>
			</div>
                 
                 </div>
                 
                 
             </div>
             
		<div id="container_details_right">
			<p class="field_title">Please select your test date:</p>
			<!--<input type="text" name="expiryDate" id="datepicker" readonly="readonly" />-->
            
             <input type="text" id="expiryDate" name="expiryDate" readonly="readonly" />
            <div id="datepicker_start"></div>
           

       <div id="datepicker"></div>
       
       
		</div>
		<div class="clear"></div>
      </div>
    </div>
</form>
    
    
    
    
</div>

	<div id="footer">
		<div class="container">
			<div class="icon_bc"></div>
			<div class="icon_clarity"></div>
			<div class="txt_area">
			Data &copy; The British Council 2006 - 2012. Software &copy; Clarity Language Consultants Ltd, 2012. All rights reserved.</div>
			<div class="clear"></div>
		</div>
	</div>
</div>
<div id="unexpected" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Sorry, a problem has happened whilst trying to register you.</p>
	<p>Please email us at support@roadtoielts.com with your login ID and let us know the error message below this.</p>
	<p id="errorMessage"></p>
	<input type="button" id="mOK" value="OK" />
</div>

</body>
</html>
