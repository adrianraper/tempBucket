<?php
    session_start();
    include_once "variables.php";

// Picking up passed data
    require_once '../readPassedVariables.php';

    // Handling no prefix
    if (!$prefix) {
        header("location: /error/noPrefix.htm");
        exit;
    }

	// Clear out all existing session variables
	unset($_SESSION['prefix']);
	unset($_SESSION['userName']);
	unset($_SESSION['password']);
	
	if(isset($_GET['error'])) $errorCode = $_GET['error'];
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>Clarity's Results Manager bulk import</title>
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<link rel="stylesheet" href="css/common.css" type="text/css" />

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
<h1>Welcome to the Results Manager bulk importer.</h1>
<div id="container_afterlogin">
    <div id="userDetails_form">
        <div id="addlearner_title">

            <p>You must be the administrator of your account to run this program, please sign-in below.</p>
        </div>
        <div>
            <form id="loginForm" name="loginForm" onSubmit="return false;">
                <div class="login_line">
                    <p class="labelname"><label for="learnerName" id="nameLbl">Your name:</label></p>
                    <p class="labeltitle"><input type="text" name="learnerName" id="learnerName" value="clarity" tabindex="1" class="field" /></p>
                    <div class="clear"></div>
                </div>
                <div class="login_line">
                    <p class="labelname"><label for="learnerPassword" id="passwordlLbl">Password:</label></p>
                    <p class="labeltitle"><input type="password" name="learnerPassword" id="learnerPassword" value="ceonlin787e" tabindex="2" class="field" /></p>
                    <div class="clear"></div>
                </div>
                <input name="prefix" value="<?echo $prefix;?>" style="display: none" />
                <div class="button_area">
                    <input name="LoginSubmit" type="button" id="LoginSubmit" value="Sign in" class="button_short"/>
                    <div id="responseMessage" class="note"></div>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- These blocks are used for error messages in jQuery blockUI -->
<div id="unexpected" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Something unexpected happened and you can't go on. Sorry.</p>
	<p>Please contact support@clarityenglish.com.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="notAdministrator" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Sorry, you are not an administrator of your account.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="invalidIDorPassword" style="display:none; cursor:default">
    <h1>Error</h1>
    <p>Sorry, the name or password are wrong.</p>
    <input type="button" id="mOK" value="OK" />
</div>

</body>
</html>
