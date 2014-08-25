<?php
session_start();
//$domain = $_SERVER['HTTP_HOST'];
unset($_SESSION);
if( isset($_GET['code']) ) {
	$errorCode = $_GET['code'];
} else {
	$errorCode="";
}
$errorMessage = "";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>British Council LearnEnglish Level Test - registration</title>
<link rel="shortcut icon" href="favicon.ico" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="css/common.css" type="text/css" />
<link rel="stylesheet" href="css/general.css" type="text/css" />
<link type="text/css" href="/Software/Common/jQuery/development-bundle/themes/base/ui.all.css" rel="stylesheet" />
<script type="text/javascript" src="/Software/Common/jQuery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="/Software/Common/jQuery/js/jquery-ui-1.7.custom.min.js"></script>
<script type="text/javascript" src="/Software/Common/jQuery/ui/ui.core.js"></script>
<script type="text/javascript" src="/Software/Common/jQuery/js/blockUI-2.js"></script>
<script type="text/javascript" src="validation.js"></script>
</head>

<body>
<div id="container_afterlogin">
<div id="userAdminBar"><!--Welcome to British Council | <a href="logout.php">Logout</a> | <a href="mailto:support@clarityenglish.com">Contact us</a>--></div>
<div id="userDetails_form">
	<div id="addlearner_title">
		Welcome to the LearnEnglish Level test!</br></br>
		Please type your name and email below. We will keep a record of your personal details along with your test result. This information will not be made available to any third party unless you have already given us permission to do so. At the end of the test you will receive a test result which you can print out.<br />
	</div>
	<form id="userDetails" name="userDetails" onSubmit="return false;">
	
	<p class="complete_title"></p>
	<!-- Login table Start -->
	<ul>
		<li id="learnerNameField">
		<p class="labelname"><label for="learnerName" id="nameLbl">Your name:</label></p>
		<p class="labeltitle"><input type="text" name="learnerName" id="learnerName" value="" tabindex="1" class="field" /></p>
		<p class="labelnameNote"><label for="learnerName" id="learnerNameNote"  style="display:none">This name will be shown on your result.</label></p>
		</li>
		<li id="learnerEmailField">
		<p class="labelname"><label for="learnerEmail" id="emailLbl">Your email:</label></p>
		<p class="labeltitle"><input type="text" name="learnerEmail" id="learnerEmail" value="" tabindex="2" class="field" /></p>
		<p class="labelemailNote"><label for="learnerEmail" id="learnerEmailNote"  style="display:none">Your email is used to find your result later.</label></p>
		</li>
	</ul>
	<div class="button_area">
		<input id="send" name="send" type="submit" value="Enter" tabindex="2" class="button_short" />
		<input id="clear" name="clear" type="submit" value="Clear" tabindex="3" class="button_short" />
		<div id="responseMessage" class="note"></div>
	</div>
	</form>

</div>
</div>
<div id="userLogin_div">
	<!-- Hidden fields for use in activating login after registration. TODO. work this from validation.js  -->
	<form id="userStart_form" action="action.php" method="post">
	<input type="hidden" id="regMethod" name="method" value="startUser"  />
	<input type="hidden" id="regUserID" name="regUserID" value=""></input>
	</form>
</div>
</body>
</html>