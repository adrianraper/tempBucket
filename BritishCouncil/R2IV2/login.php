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
</head>

<body>
<div id="header">
	<div id="userAdminBar"><a href="mailto:support@roadtoielts.com">Contact us</a></div>
</div>

<div id="container_login">
<div id="container_left">
	<div id="beforelogin_left">
    </div>
	<div id="beforelogin_mid">
	<div id="login_details">
    <div id="version_icon"></div>
	<p class="login_title">Road to IELTS - Last Minute</p>
	<p class="version_caption">Special last minute practice only for British Council IELTS candidates!</p>
	<div class="horizontal_dotted_line"></div>

	<!-- the action on the form is run by control.js -->
	<form id="LoginForm" method="post" action="" style="margin:0; padding:0;">
	
	<!-- Login table Start -->
	<ul>
		<li>
            <p class="login_label">Login ID :</p>
            <p class="login_field"><input name="loginID" type="text" id="loginID" value="<?php echo $loginID ?>" size="32" class="field"/></p>
            <p class="login_note">
                <label for="loginID" id="loginIDNote" class="note">
                      This is the ID given to you to start Road to IELTS.
                      <br/><span class="grey">It looks like this: 1280-8666-1111.</span>
				</label>
			</p>
		</li>
        <li>
            <p class="login_label">Password :</p>
			<p class="login_field">
				<input name="userPassword" type="password" id="userPassword" value="" size="32" class="field"/>
			</p>
        <p class="forgot_line">
		<a href="#" onclick="JavaScript:getEmailFromServer();">Forgot your password?</a>
	</p>
		</li>
		<div class="complete_login">
		<input name="LoginSubmit" type="submit" id="LoginSubmit" value="" class="button_login"/>
		</div>
		<div class="complete_login"></div>
		<div id="responseMessage" class="note"></div>
	</ul>
	</form>
	<!-- Login table End -->
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
	<input type="button" id="mDEFOK" value="OK" />
</div>
<div id="passwordForgetNoEmail" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>We can't find any email address linked to this login ID.</p>
	<p>Please contact your local British Council office.</p>
	<input type="button" id="mDEFOK" value="OK" />
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
</div>
<div id="container_right"></div>
</div>
</body>
</html>
