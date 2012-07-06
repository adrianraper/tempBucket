<?php
	session_start();
	include_once "Variables.php"; 
	// also clear out all existing session variables
	//$_SESSION = array();
	//session_destroy();
	//include_once "registrationVariables-1.php";
	$errorCode = $_GET['code'];
	$studentID = $_GET['studentID'];
	//echo $errorCode;
	if ($errorCode>200) {
		$errorMessage = "Sorry that login id or password are wrong";
	} else {
		$errorMessage = "";
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr"> 
<head>
<title>British Council Global IELTS - learner registration</title>
<link rel="stylesheet" href="css/general.css" type="text/css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/date.js"></script>
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/jquery-ui-1.7.custom.min.js"></script>
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/ui/ui.core.js"></script>
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/jquery-ui-datePicker-2.1.2.js"></script>
<!-- <script type="text/javascript" src="../Software/Common/jQuery/js/thickBox-3.1.js"></script> -->
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/blockUI-2.js"></script>
<script type="text/javascript" src="getpwd.js"></script>
</head>

<body>
<div id="container_beforelogin">
	<div id="userAdminBar"><a href="mailto:support@clarityenglish.com">Contact us</a></div>
	<div id="login_details">
	<p class="login_title">User login</p>

	<form id="LoginForm" method="post" action="action.php" style="margin:0; padding:0;">
	<input name="method" type="hidden" id="method" value="userLogin"  style="display:none"/>
	<!-- Login table Start -->
	<ul>
		<li>
            <p class="login_label">Login ID :</p>
            <p class="login_field"><input name="studentID" type="text" id="studentID" value="<?php echo $studentID ?>" size="32" class="field"/></p>
            <p class="login_note">
                <label for="loginID" id="loginIDNote" class="note">
                      This is the ID given to you to start<br/>
                      Road to IELTS.<br/>
                      <span class="grey">It looks like 1280-8666-1111.</span>
				</label>
            </p>
		</li>
		
        <li>
            <p class="login_label">Password :</p>
            <p class="login_field"><input name="userPassword" type="password" id="userPassword" value="" size="32" class="field"/></p>
            
            <p class="forgot_line" style="display:none">
            	<a href="#" onClick="JavaScript:getEmailFromServer()">Forgot your password?</a>
			</p>
		</li>
		<div class="complete_login">
		  <input name="LoginSubmit" type="submit" id="LoginSubmit" value="" class="button_login"/>
		</div>
		
		<div class="complete_login"><?php echo $errorMessage ?></div>
		<div id="responseMessage" class="note"></div>
	</ul>
	</form>
	<!-- Login table End -->
	</div>
</div>
<div id="mailSendSuccess" style="display:none; cursor:default"> 
        <h1>Note</h1> 
	<p>Your password has been sent to your e-mail. Please check it.</p>
        <input type="button" id="mDSOK" value="OK" /> 
</div>
<div id="specialIDNote" style="display:none; cursor:default"> 
        <h1>Note</h1> 
	<p>Please input your ID, so we can sent you password</p>
        <input type="button" id="mOK" value="OK" /> 
</div>
<div id="modalDialogEmailFailed" style="display:none; cursor:default"> 
        <h1>Error</h1> 
	<p>We don't find your id or you didn't input e-mail when you first login.</p>
	<p>Please contract administrator.</p>
        <input type="button" id="mDEFOK" value="OK" /> 
</div>
</body>
</html>
