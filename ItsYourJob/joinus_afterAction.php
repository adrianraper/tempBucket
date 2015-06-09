<?php

if (session_id() == "") session_start();
if(session_is_registered('IYJreg_name') == 0) {
	//session variable is not registered, go back to the main page
	$_SESSION['IYJreg_message'] = 'No Session.';
	header("location: joinus_failureAfterPayment.php");
	exit(0);
}
if($_SESSION['IYJreg_orderRef']!= session_id()) {
	//session id not matching, go back to the main page
	$_SESSION['IYJreg_message'] = 'Session not matched.';
	header("location: joinus_failureAfterPayment.php");
	exit(0);
}
require_once('Variables.php');

function addAccount()
{	
	global $domain;
	//header("Content-Type: text/xml");
	$postXML = "name=".$_SESSION['IYJreg_name']
			."&email=".$_SESSION['IYJreg_email']
			."&country=".$_SESSION['IYJreg_country']
			."&deliveryFrequency=".$_SESSION['IYJreg_deliveryFrequency']
			."&contactMethod=".$_SESSION['IYJreg_contactMethod']
			."&languageCode=".$_SESSION['IYJreg_language']
			."&productCode=".$_SESSION['IYJreg_productCode']
			."&orderRef=".$_SESSION['IYJreg_orderRef']
			."&startDate=".$_SESSION['IYJreg_startDate']
			."&expiryDate=".$_SESSION['IYJreg_expiryDate']
			."&checkSum=".$_SESSION['IYJreg_checkSum'];
	//$postXML = '<query method="'.$values['name'].'" email="'.$values['email'].'/>'
	//$postXML='name=Rickson Lo&email=test08@clarityenglish.com&country=Hawaii&deliveryFrequency=1&contactMethod=Email&language=EN&productCode=1001&orderRef=hp56tim2b11k808dnal7grqss5&startDate=2009-10-27&expiryDate=2010-1-5&checkSum=123123';
	//echo $postXML;
	
	#Initialize the cURL session
	$ch = curl_init();
	
	//curl_setopt($ch, CURLOPT_HEADER, 1);
	curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
	
	#Set the URL of the page or file to download.
	//$targetURL = $domain."/Software/ResultsManager/web/amfphp/services/AddAccountFromScript.php";
	$targetURL = "http://ClarityMain/Software/ResultsManager/web/amfphp/services/AddAccountFromScript.php";
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
			$_SESSION['IYJreg_password'] = $password;
			header('location: joinus_success.php');
			break;
			
		default:
			$_SESSION['IYJreg_message'] = $error.': '.$message;
			header('location: joinus_failureAfterPayment.php');
			break;
	}
	//echo $error.', '.$message.', '.$password;
	/*
	# Close cURL session
	if (curl_errno($ch)) {
		print curl_error($ch);
	} else {
		curl_close($ch);
		//echo "<br>NO ERROR!";
		$_SESSION['IYJreg_password'] = 
		header ('location: joinus_success.php');
	}
	*/
	

}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English | It's Your Job | Join us now!</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<link rel="stylesheet" type="text/css" href="css/job_joinus.css" />

<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="css/fancybox.css" />

<!--General jquery library: For Fancy box, programs left menu-->
<script type="text/javascript" src="script/jquery.js"></script>
<script type="text/javascript" src="script/popup.js"></script>

<!--Fancy Popup Box-->
<script type="text/javascript" src="script/fancybox.js"></script>
<script type="text/javascript" src="script/fancybox_custom.js"></script>
<script type="text/javascript" src="script/reg_validation.js"></script>
</head>

<body>

<div id="container">


	<!--Bannar Area-->
<div id="bannar_before_login" class="ban_join">
	<a href="./joinus.php" class="ban_link"></a>
	<a href="./index.php" class="ban_home"></a>
</div>
    <div class="bannar_rainbow_line" id="welcome_line">

    

    
  </div>
<!--End of Bannar Area-->


    <div id="content_container">

    <h1 class="general_heading">You're almost there...</h1>
    <!--Content Area-->
    <div id="general_box_outter">
    <div id="general_box">
    
    


<!--Content-->
        <div class="join_box_content" id="join_box_page">
        
        	<div class="loading_box">
        	
                <p class="loading_img"></p>
              <p class="loading_line">Please wait while we create your account...</p>

                
                <p class="loading_subline">(Do not click any buttons on the navigation bar of your browser)</p>
            
          </div>

		</div>

<!--End of content-->


      </div>
    </div>
    </div>
    
    
    
    
  <!--End of Content Area-->
    
  <!--Footer Area-->
<div id="footer">
    	<div id="footer_clarity_logo"><a href="http://www.ClarityEnglish.com/" target="_blank"></a></div>
        
        <div id="footer_clarity_line">Copyright &copy; 1993 -
    <script type="text/javascript">
		var d = new Date()
		document.write(d.getUTCFullYear())
	</script>
    Clarity Language Consultants Ltd. All rights reserved.</div>

        <div id="footer_links_line">
        
            <a href="http://www.clarityenglish.com/itsyourjob/contactus.htm" class="contentpop_iframe">Contact us</a> | 
        
        <a href="terms.htm">Terms and conditions</a> | <a href="http://www.clarityenglish.com/aboutus/index.php" target="_blank">About Clarity</a></div>
  </div>
    
    <!--End of Footer Area-->


</div>     <!--End of Container-->


</body>
</html>
<?PHP
#action!
addAccount();
?>