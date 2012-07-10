<?php
	session_start();
	include_once "variables.php";

	// Clear out all existing session variables
	unset($_SESSION['loginID']);
	unset($_SESSION['programVersion']); // deprecate and use productCode instead please
	unset($_SESSION['country']);
	unset($_SESSION['userEmail']);
	unset($_SESSION['userName']);
	unset($_SESSION['password']);
	unset($_SESSION['productCode']);
	unset($_SESSION['groupID']);
	unset($_SESSION['rootID']);
	
	if( isset($_GET['loginID']) ) {
		$loginID = $_GET['loginID'];
	} else {
		$loginID = '';
	}
	if( isset($_GET['error']) ){
		$errorCode = $_GET['error'];
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>British Council Global IELTS - registration</title>
<link rel="shortcut icon" href="<?php echo $commonDomain; ?>Software/R2IV2.ico" type="image/x-icon" />
<link rel="stylesheet" href="css/general.css" type="text/css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/date.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery-ui-1.7.custom.min.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/ui/ui.core.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery-ui-datePicker-2.1.2.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/blockUI-2.js"></script>
<script type="text/javascript" src="loginControl.js"></script>
<script type="text/javascript" src="forgotPassword.js"></script>
</head>

<body>

<div class="container">
	<div id="header">
		<div id="header_banner"></div>	
	</div>
	<div id="container_login">	
		<div id="container_login_left">
			<!-- the action on the form is run by control.js -->
			<form id="LoginForm" method="post" action="">          
       	  <div id="table_mini_top"></div>
            <div id="table_mini_title"></div>
            <div id="table_mini_mid">
               		<p class="field_txt_login">Special last minute practice only for British Council <br /> IELTS candidates!</p>
IELTS candidates!</p>
                <div class="line_small"></div>
            
            	<p class="field_title">Login ID:</p>
            	<div class="field_line">
                	<input name="loginID" type="text" id="loginID" value="<?php echo $loginID ?>" class="field_reg"/>
                    <div class="clear"></div>
                </div>
              <p class="field_txt_login">This is the ID given to you to start Road to IELTS.</p>
                
                <p class="field_txt_login_grey">It looks like this: 1280-8666-1111.</p>
                
          		<p class="field_title">Password:</p>
            	<input name="userPassword" type="password" id="userPassword" value="" class="field_reg"/>
        <p class="field_txt_login">&nbsp;&nbsp;
		<a href="#" onclick="JavaScript:forgotPassword();">Forgot your password?</a>
	</p>
                
              <div class="clear"></div>
	        <div class="btn_area">
                    <input name="LoginSubmit" type="button" id="LoginSubmit" value="" class="btn_login"/>
                    
                  <div class="btn_comment">
			<div id="responseMessage" class="form_ok"></div>

                    
                    <div class="clear"></div>
                    
                    
                    
                </div>
            
          </div>
            <div id="table_mini_upgrade">
            	<a href="http://www.ieltspractice.com?utm_source=RTIcom&utm_medium=Btn_upgrade" target="_blank"></a>
			</div>
				</form>
	
		</div>
		<div id="container_login_right">
			<a id="btn_fb" href="http://www.facebook.com/PractiseforIELTS" target="_blank"></a>
			<a id="btn_contact_login" href="mailto:support@roadtoielts.com?subject=Road to IELTS enquiry"></a>
		</div>
		<div class="clear"></div>
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

<!-- These blocks are used for error messages in jQuery blockUI -->
<div id="passwordForgetMailSent" style="display:none; cursor:default">
	<h1>Note</h1>
	<p>Your password has been sent to your registered email.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="passwordForgetNoLoginID" style="display:none; cursor:default">
	<h1>Note</h1>
	<p>Please type your login ID, and we will send your password to the email address you gave us.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="passwordForgetNoSuchLoginID" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>We can't find this login ID.</p>
	<p>Please contact your local British Council office.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="passwordForgetProblemLoginID" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Sorry, there is a problem with this ID.</p>
	<p>Please contact support@roadtoielts.com.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="passwordForgetNoEmail" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>We can't find any email address linked to this login ID.</p>
	<p>Please contact support@roadtoielts.com and tell us your login ID and we will email your password to you.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="unexpected" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Something unexpected happened and you can't go on. Sorry.</p>
	<p>Please contact support@roadtoielts.com.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="invalidIDorPassword" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Sorry, that login ID or password are wrong.</p>
	<p>Please check that your login ID looks like this: 1280-8666-1111.<br/>It is not your name or your IELTS ID.</p>
	<p>You may also have changed your password from the original one.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="expiredAccount" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Sorry, your account has expired.</p>
	<p>If you would like to subscribe to a full version of Road to IELTS, please visit <a href="http://www.ieltspractice.com" target="_blank">www.ieltspractice.com</a> or send an email to support@roadtoielts.com.</p>
	<input type="button" id="mOK" value="OK" />
</div>

</body>
</html>
