<?php
require_once('variables.php');

$email = $productCode = $rootID = $loginOption = $template = $error = $message = '';

// gh#487
if (isset($_GET['productCode']))
	$productCode = $_GET['productCode'];
if (isset($_GET['rootID']))
	$rootID = $_GET['rootID'];
if (isset($_GET['loginOption']))
	$loginOption = $_GET['loginOption'];
	
// What is specific for this product?
switch ($productCode) {
	case 52:
	case 53:
		$cssClass = 'rti';
		$cssTheme = 'grey';
		$template = 'ieltspractice_forgot_password';
		break;
	case 54:
		$cssClass = 'ccb';
		$cssTheme = 'grey';
		$template = 'ccb_forgot_password';
		break;
	case 55:
	case 59:
		$cssClass = 'tb';
		$cssTheme = 'grey';
		$template = 'tb_forgot_password';
		break;
	case 56:
		$cssClass = 'ar';
		$cssTheme = 'grey';
		$template = 'ar_forgot_password';
		break;
	case 57:
		$cssClass = 'cp1';
		$cssTheme = 'grey';
		$template = 'cp1_forgot_password';
		break;
	default:
		$cssClass = 'general';
		$cssTheme = 'grey';
		$template = 'forgot_password';
		break;
}
		
if ($_POST['process'] == "performValidation") {
	$email = $_POST['CLS_Email'];	
	
	//$emailPattern = '/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$/i';
	//if (preg_match($emailPattern, $email) === FALSE) {
	if (filter_var($email, FILTER_VALIDATE_EMAIL) === FALSE) {
		$message = "Please fill in a valid email address";
		
	} else {
		// No special licenceType to send from here
		$postXML = "CLS_Email=$email&templateID=$template&rootID=$rootID&loginOption=$loginOption";
		//$serializedObj = json_encode($postXML);
		$targetURL = $commonDomain."Software/ResultsManager/web/amfphp/services/ResendEmailPassword.php";
		
		// Initialize the cURL session
		$ch = curl_init();
		
		// Setup the post variables
		$curlOptions = array(CURLOPT_HEADER => false,
							CURLOPT_FAILONERROR=>true,
							CURLOPT_FOLLOWLOCATION=>true,
							CURLOPT_RETURNTRANSFER => true,
							CURLOPT_POST => true,
							CURLOPT_POSTFIELDS => $postXML,
							CURLOPT_URL => $targetURL
		);
		curl_setopt_array($ch, $curlOptions);
		
		// Execute the cURL session
		$contents = curl_exec($ch);
		if ($contents === false){
			// echo 'Curl error: ' . curl_error($ch);
			$errorCode = 1;
			$failReason = curl_error($ch);
			curl_close($ch);
		} else {
			curl_close($ch);
			// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
			if (substr($contents,0,3)=="\xEF\xBB\xBF")
				$contents = substr($contents,3);
			//echo $contents;exit(0);
			parse_str($contents);

			if ($debugLog)
				error_log("back from ResendEmailPassword with $contents for $email \n", 3, $debugFile);

			// Expecting to get back an error code and a message
			if (is_numeric($error) && intval($error) > 0) {
				$page = 'forgotPassword_failure.php';
			} else {
				$page = 'forgotPassword_success.php';
			}
			header('location: '.$page.'?email='.$email.'&error='.$error.'&message='.$message.'&productCode='.$productCode);
		}
	}
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
<meta name="Description" content="Password reminder email">

<title>Forgot your password?</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="../css/forgotpw.css" />
</head>
<body id="<?php echo $cssClass;?>" class="<?php echo $cssTheme;?>">
<div id="container_position">

	

	<div id="container">

            <div id="bigbox">
            	<div id="clearbox_center">
                    <div id="clearbox">
                    	<div id="top"></div>
                        <div id="mid">
                        	<form id="CLS_forgot_pwd" name="CLS_forgot_pwd" method="post" action="<?php $PHP_SELF ?>">
                            <div id="left">
                            	<h1>Forgot your password?</h1>
                            </div>
                        
                            <div id="right">
                            
                                <p class="text">Please type in your registered email address. The password linked to that email will be sent to you as quickly as our computers can.</p>
                                <p class="title">Registered email:</p>
                                
                                <div id="emailbox">
                                  <input name="CLS_Email" id="CLS_Email" type="text" value="<?php echo $email;?>" class="emailfield"/>
                                </div>
                                <input type="hidden" name="process" value="performValidation" />
                                
                                
                                <div class="form_waiting" style="display:none;">Please wait...</div>
								<div class="form_oops"><?PHP echo $message;?></div>
                                <div class="form_ok" style="display:none;">Sent successfully, please check your email.</div>
                                
                              
                                
                                <input name="input" type="submit" value="Email me" class="btn_submit" />
                            </div>
                            </form>
                            
                            <div class="clear"></div>
                        </div>
                        
                        <div id="btm"></div>
                    </div>
                    
                    <div id="supportline">
                  For help, please contact the Clarity support team at <a href="mailto:support@clarityenglish.com?subject=Forgot Password enquiry (app version)">support@clarityenglish.com</a>.                  </div>
                </div>
            </div>
    </div>
 
    
    <div id="footerbox">
    	<div id="programicon"></div>
        <div id="logoline"><div id="logobox"></div></div>
    </div>
</div>
</body>
</html>
