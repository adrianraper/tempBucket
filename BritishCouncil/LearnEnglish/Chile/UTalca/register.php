<?php
	session_start();
	include_once "variables.php";

	// Clear out all existing session variables
	unset($_SESSION['loginID']);
	unset($_SESSION['userName']);
	unset($_SESSION['password']);
	
	if( isset($_GET['error']) ){
		$errorCode = $_GET['error'];
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>British Council LearnEnglish Level Test Chile - sign in</title>
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<link rel="stylesheet" href="../css/common.css" type="text/css" />

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

<div id="container_UdT">
<div id="userAdminBar"><!--Welcome to British Council | <a href="logout.php">Logout</a> | <a href="mailto:support@clarityenglish.com">Contact us</a>--></div>
	<div id="userDetails_form">
		<div id="addlearner_title">
			<p>Welcome to the LearnEnglish Level test Chile.</p>
			<p>Por favor escriba su nombre, R.U.T. y correra. Vamos a mantener un registro de su nombre junto con el resultado de su prueba. Al final de la prueba, verá los resultados.</p>
		</div>
		<div>
			<form id="loginForm" name="loginForm" onSubmit="return false;">
                <div class="login_line">
                    <p class="labelname"><label for="learnerID" id="idLbl">R.U.T.</label></p>
                    <p class="labeltitle"><input type="text" name="learnerID" id="learnerID" value="" tabindex="1" class="field" /></p>
                    <div class="clear"></div>
                </div>
				<div class="login_line">
                    <p class="labelname"><label for="learnerPassword" id="passwordLbl">password:</label></p>
                    <p class="labeltitle"><input type="password" name="learnerPassword" id="learnerPassword" value="" tabindex="2" class="field" /></p>
                    <div class="clear"></div>
                </div>
				<div class="button_area">
					<input name="LoginSubmit" type="button" id="LoginSubmit" value="Sign in" class="button_short"/>
					<div id="responseMessage" class="note"></div>
				</div>
			</form>
		</div>
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
<div id="invalidIDorPassword" style="display:none; cursor:default">
	<h1>Sorry</h1>
	<p>That id or password don't match.</p>
	<input type="button" id="mOK" value="OK" />
</div>

</body>
</html>
