<?php
if ($_POST['process'] == "performValidation") {
	require_once('Variables.php');
	$email = $_POST['IYJ_ForgetEmail'];
	
	$emailPattern = "^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$";
	if (!eregi($emailPattern,$email)) {
		$errorMsg = "Please fill in a valid email address";
	} else {
		//header("Content-Type: text/xml");
		$postXML = "IYJ_Email=".$email
				."&IYJ_productCode=1001";
		//$postXML = '<query method="'.$values['name'].'" email="'.$values['email'].'/>'
		//echo $postXML;
		
		#Initialize the cURL session
		$ch = curl_init();
		
		//curl_setopt($ch, CURLOPT_HEADER, 1);
		curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
		
		#Set the URL of the page or file to download.
		$targetURL = $domain."/Software/ResultsManager/web/amfphp/services/ResendEmailPassword.php";
		curl_setopt($ch, CURLOPT_URL, $targetURL);
			
		# Ask cURL to return the contents in a variable
		# instead of simply echoing them to the browser.
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		
		# Setup the post variables
		curl_setopt($ch, CURLOPT_POST, 1);
		//curl_setopt($ch, CURLOPT_POSTFIELDS, $values);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $postXML);
		
		# Execute the cURL session
		$contents = curl_exec ($ch);
		//echo $contents.'<Br>';
		
		parse_str($contents);
		//echo $errCode.', '.$message;
		
		switch ($error) {
			case '0':
				//$_SESSION['ForgetPwd_email'] = $email;
				header('location: forgotpassword_success.php?email='.$email);
				break;
			case '210':
				//$_SESSION['ForgetPwd_email'] = $email;
				//$_SESSION['ForgetPwd_message'] = $message;
				header('location: forgotpassword_failure.php?email='.$email.'&message='.$message);
				break;
			case '211':
				//$_SESSION['ForgetPwd_email'] = $email;
				//$_SESSION['ForgetPwd_message'] = $message;
				header('location: forgotpassword_failure.php?email='.$email.'&message='.$message);
				break;
			default:
				//$_SESSION['ForgetPwd_email'] = $email;
				//$_SESSION['ForgetPwd_message'] = $message;
				header('location: forgotpassword_failure.php?email='.$email.'&message=Interal error');
				break;
		}
	}
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English | It's Your Job | Forgotten your password?</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<link rel="stylesheet" type="text/css" href="css/job_popup.css" />

<!--General jquery library: For Fancy box, programs left menu-->
<script type="text/javascript" src="script/jquery.js"></script>

</head>

<body id="popup_body">

<div id="popup_contatiner">
	<div id="popup_bannar"></div>
    <div id="popup_rainbow">
    	
    	<p>Forgot your password?</p>
    </div>
  <div id="popup_forgotmsg">
    
	<form id="IYJ_forgetpwd" name="IYJ_forgetpwd" method="post" action="<?php $PHP_SELF ?>">
    <p>Please type in your registered email address below.</p>
    
    
		<div id="popup_forgotmsg_fieldbox">
          <p class="left">Registered email address: *</p>
          <p class="right">
            <input name="IYJ_ForgetEmail" id="IYJ_ForgetEmail" type="text" value="" class="emailfield"/>
          </p>


          <div class="save_but">
            <input name="input" type="submit" value="" class="btn_submit" />
			<input type="hidden" name="process" value="performValidation" />
          </div>
          
          <div class="error_msg" name="IYJ_ForgetEmailNote" id="IYJ_ForgetEmailNote"><?PHP echo $errorMsg;?></div>
            
          
          
          
          
	</div>
        
        
        <p>For security reasons, your password will be sent to your registered email address.</p>
        
		<p class="popup_forgotmsg_footer">For further assistance, please contact the Clarity Support Team at <a href="mailto:support@ClarityEnglish.com">support@clarityenglish.com</a></p>
    

	</form>
  </div>
    <div id="popup_footer">
    
    	<p>Copyright &copy; 1993 -
    <script type="text/javascript">
		var d = new Date()
		document.write(d.getUTCFullYear())
	</script>
    Clarity Language Consultants Ltd. All rights reserved.</p>
    
    </div>


</div>
<!--Google analytics-->
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-873320-5");
pageTracker._trackPageview();
} catch(err) {}</script>
<!--End of Google analytics-->
	

</body>
</html>
