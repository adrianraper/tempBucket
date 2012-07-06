<?php
	session_start();
	include_once "variables.php";

	// Clear out all existing session variables
	unset($_SESSION['userEmail']);
	unset($_SESSION['groupID']);
	unset($_SESSION['rootID']);
	
	if( isset($_GET['email']) ) {
		$email = $_GET['email'];
	} else {
		$email = '';
	}
	if( isset($_GET['error']) ){
		$errorCode = $_GET['error'];
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Access: Living and learning in the UK</title>

<link rel="stylesheet" type="text/css" href="css/home.css" />
<link rel="shortcut icon" href="/Software/AUK.ico" type="image/x-icon" />
<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="css/jquery.fancybox-1.3.1.css" />

<script type="text/javascript" src="script/jquery.V1.4.2.js"></script>

<!--Fancy Popup Box-->
<script type="text/javascript" src="script/jquery.fancybox-1.3.1.pack.js"></script>
<script type="text/javascript" src="script/jquery.fancybox.custom.js"></script>

<!-- ui block -->
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/blockUI-2.js"></script>

<!-- login control -->
<script type="text/javascript" src="loginControl.js"></script>

</head>

<body>

<div id="container">
	<div id="header"></div>
	<div id="content">
		<div id="front_banner"></div>
		<div class="clear"></div>
		
		<div class="login_box_outter">
			<div class="describe_box">
				<p class="txt">Please type your email address to create an account to use Access UK.</p>
				<p class="txt">We will not send you any emails.</p>
				<p class="txt">This account is provided by the Student Recruitment and Admissions office of The University of York.</p>  
			</div>
		    
			<div class="describe_box">
				<h1>Log in to start Access UK</h1>
				
				<div class="login_content_box">
					<form id="LoginForm" method="post" action="">          
						<div class="describe_box_actual">
							<div class="describe_box_actual_field">
								<div class="fieldname">Your email:</div>
								<input id="email" name="email" type="text" class="fieldblank" />
					
								<div class="clear"></div>
							</div>
		
							<div class="describe_box_effect_field">
								<input name="LoginSubmit" type="button" id="LoginSubmit" value="Start" class="btn_loginstart" />
                               <div id="responseMessage"></div>
							</div>
							<div class="clear"></div>
						</div>
					</form>
				</div>
			</div>
		</div>
		<div class="clear"></div>
	</div>
	<div id="footer">
		<div id="footer_line">
			Data &copy; University of York, 2011. Software &copy; Clarity Language Consultants Ltd, 2011. All rights reserved.<br />
			<a href="/area1/AccessUK/contactus.htm" class="contact">Contact us</a> | <a href="http://www.clarityenglish.com/support/user/pdf/cs/CS_Terms_OfficialPDF.pdf" target="_blank">Terms and conditions</a>
		</div>
		<a href="http://www.york.ac.uk/" id="logo_york" target="_blank"></a>
		<a href="http://www.clarityenglish.com/" id="logo_clarity" target="_blank"></a>
	</div>
</div>

<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-873320-5");
pageTracker._trackPageview();
} catch(err) {}</script>

</body>
</html>
