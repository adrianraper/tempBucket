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
<title>British Council LearnEnglish Level Test OLPC - registration</title>
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

<div id="container_afterlogin">
<div id="userAdminBar"><!--Welcome to British Council | <a href="logout.php">Logout</a> | <a href="mailto:support@clarityenglish.com">Contact us</a>--></div>
	<div id="userDetails_form">
		<div id="addlearner_title">
			<p>Welcome to the LearnEnglish Level test OLPC.</p>
			<p>Please type your name and email below. We will keep a record of your personal details along with your test result. This information will not be made available to any third party unless you have already given us permission to do so. At the end of the test you will see your results.</p>
			<p>Por favor escriba su nombre y correo electrónico. Vamos a mantener un registro de su nombre junto con el resultado de su prueba. Esta información no será puesto a disposición de terceros a menos que usted ya nos ha dado permiso para hacerlo. Al final de la prueba, verá los resultados.</p>
		</div>
		<div>
			<form id="loginForm" name="loginForm" onSubmit="return false;">
				<div class="login_line">
                    <p class="labelname"><label for="learnerName" id="nameLbl">Your name:</label></p>
                    <p class="labeltitle"><input type="text" name="learnerName" id="learnerName" value="" tabindex="1" class="field" /></p>
                    <p class="labelNote"><label for="learnerName" id="learnerNameNote">This name will be shown on your results.</label></p>
                    <div class="clear"></div>
                </div>
                <div class="login_line">
                    <p class="labelname"><label for="learnerEmail" id="emailLbl">&nbsp;</label></p>
                    <p class="labeltitle">
						<select name="learnerLanguage" id="learnerLanguage" class="field" />
							<option value="English" selected="true">English</option>
							<option value="Spanish">español</option>
						</select>
					</p>
                    <p class="labelNote"><label for="learnerLanguage" id="learnerLanguageNote" >Instructions will be in this language.</label></p>
                      <div class="clear"></div>
                </div>
				<div class="button_area">
					<input name="LoginSubmit" type="button" id="LoginSubmit" value="Register" class="button_short"/>
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
<div id="emailAlreadyExists" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Sorry, that email address has already been used.</p>
	<input type="button" id="mOK" value="OK" />
</div>

</body>
</html>
