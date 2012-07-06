<?php
	require_once(dirname(__FILE__)."/../../domainVariables.php");

	if ($_POST['process'] == "performValidation") {
	$email = $_POST['AUK_ForgetEmail'];
	
	$emailPattern = "^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$";
	if (!eregi($emailPattern,$email)) {
		$errorMsg = "Please fill in a valid email address";
	} else {
		//header("Content-Type: text/xml");
		$postXML = "CLS_Email=".$email."&CLS_LicenceType=1&templateID=CE_forgot_password";
		//$postXML = '<query method="'.$values['name'].'" email="'.$values['email'].'/>'
		//echo $postXML;
		
		#Initialize the cURL session
		$ch = curl_init();
		
		//curl_setopt($ch, CURLOPT_HEADER, 1);
		curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
		
		#Set the URL of the page or file to download.
		$targetURL = $RMServicesPath."ResendEmailPassword.php";
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
<title>The University of York | Clarity English | Access UK: A Student's Guide | Forgotten your password?</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/popup.css" />

<!--General jquery library: For Fancy box, programs left menu-->
<script type="text/javascript" src="script/jquery.js"></script>



</head>

<body id="popup_body">

<div id="popup_contatiner">
	<div id="popup_bannar"></div>
    <div id="popup_title">
    	<p class="forgot">Forgotten your password?</p>
  </div>
  
     <div id="popup_forgotmsg">
     	<form id="AUK_forgetpwd" name="AUK_forgetpwd" method="post" action="<?php $PHP_SELF ?>" style="margin:0; padding:0;">
    <p>Please type in your registered email address below.</p>
    
    
		<div id="popup_forgotmsg_fieldbox">
          <p class="left">Registered email address: *</p>
          <p class="right">
            <input name="AUK_ForgetEmail" id="AUK_ForgetEmail" type="text" value="" class="emailfield"/>
          </p>


          <div class="save_but">
            <input name="input" type="submit" value="Submit" class="btn_submit" />
			<input type="hidden" name="process" value="performValidation" />
          </div>
          
          <div class="error_msg" name="AUK_ForgetEmailNote" id="AUK_ForgetEmailNote"><?PHP echo $errorMsg;?></div>
            
          
          
          
          
	</div>
        
        
        <p>For security reasons, your password will be sent to your registered email address.</p>
        
		<p class="popup_forgotmsg_footer">For further assistance, please contact the Clarity Support Team at <a href="mailto:support@ClarityEnglish.com">support@clarityenglish.com</a></p>
    

	</form>
     
     
     </div>
  
  
  
    <div id="popup_footer">
    <p>Data &copy; University of York, 2011. Software &copy; Clarity Language Consultants Ltd, 2011. <br />All rights reserved.</p>
    	
    
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
