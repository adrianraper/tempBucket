<?php
	session_start();
	include_once "variables.php";
/*
# Fill in the details below
$_SESSION['CLS_name'] = 'Rickson Lo';
$_SESSION['CLS_email'] = 'haleruyalal@clarityenglish.com';
$_SESSION['CLS_password'] = 'ihateraining';
$_SESSION['CLS_country'] = 'Hong Kong';
$_SESSION['OfferID'] = '59';
$_SESSION['resellerID'] = '21';
$_SESSION['CLS_contactMethod'] = 'email';
$_SESSION['CLS_orderRef'] = session_id();
$_SESSION['CLS_paymentMethod'] = 'Visa';
//below fields are just for emails and marketing use
$_SESSION['CLS_ageGroup'] = '18-25';
$_SESSION['CLS_phone'] = '9999-9090';
$_SESSION['CLS_subscriptionID'] = 1015;
*/
if (session_is_registered('CLS_name') == 0) {
	//session variable is not registered, go back to the main page
	$_SESSION['CLS_message'] = 'No Session.';
	//echo 'No session';
	header("location: buy_step4_failure.php");
	exit(0);
}
if($_SESSION['CLS_orderRef']!= session_id()) {
	//session id not matching, go back to the main page
	$_SESSION['CLS_message'] = 'Session not matched.';
	//echo 'Session not match';
	header("location: buy_step4_failure.php");
	exit(0);
}

########## #action!
	//maybe we should continue to add account even if the subscription not updated successfully
	updateSubscription("paid");
	addAccount();

function updateSubscription($status) {

	global $commonDomain;
	// as JSON
	$CLSapi = array();
	$CLSapi['method'] = 'updateSubscriptionStatus';
	$CLSapi['subscriptionID'] = $_SESSION['CLS_subscriptionID'];
	$CLSapi['status'] = $status;
	//these are not used by now?
	//CLSapi['discountCode'] = $SESSION['CLS_discountCode'];
	//CLSapi['emailID'] = $SESSION['CLS_emailID'];
	//CLSapi['password'] = $SESSION['CLS_password'];
	//CLSapi['languageCode'] = $SESSION['CLS_languageCode'];	
	$serializedObj = json_encode($CLSapi);
	$targetURL = $commonDomain."Software/ResultsManager/web/amfphp/services/CLSgateway.php";
	
	#Initialize the cURL session
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
	curl_setopt($ch, CURLOPT_URL, $targetURL);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $serializedObj);
	
	// Execute the cURL session
	$contents = curl_exec ($ch);
	if ($contents === false){
		// echo 'Curl error: ' . curl_error($ch);
		curl_close($ch);
		$errorCode = 1;
		$failReason = curl_error($ch);
	} else {
		curl_close($ch);
		// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
		if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
			$contents = substr($contents,3);
		}
		//echo $contents;exit(0);
		$returnInfo = json_decode($contents, true);
		//maybe we should continue to add account even if the subscription not updated successfully
		// so do nothing here
		/*
		if (isset($returnInfo['subscriptionID'])) {
			//echo "return ID=".$returnInfo['subscriptionID']."<br>";
		} else {
			//maybe we should continue to add account even if the subscription not updated successfully
			$_SESSION['CLS_message'] = 'Error Code:'.$returnInfo['error'].' message:'.$returnInfo['message'];
			//header("location: buy_step4_failure.php" );
		}*/
	}
}

function addAccount() {

	global $commonDomain;
	// as JSON
	$CLSapi = array();
	$CLSapi['method'] = 'addSubscription';
	$CLSapi['subscriptionID'] = $_SESSION['CLS_subscriptionID'];
	$CLSapi['emailTemplateID'] = 'ieltspractice_welcome';
	$CLSapi['paymentMethod'] = $_SESSION['CLS_paymentMethod'];
	//these are not used by now?
	$serializedObj = json_encode($CLSapi);
	$targetURL = $commonDomain."Software/ResultsManager/web/amfphp/services/CLSgateway.php";
	
	#Initialize the cURL session
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
	curl_setopt($ch, CURLOPT_URL, $targetURL);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $serializedObj);
	
	// Execute the cURL session
	$contents = curl_exec ($ch);
	if ($contents === false){
		// echo 'Curl error: ' . curl_error($ch);
		curl_close($ch);
		$errorCode = 1;
		$failReason = curl_error($ch);
	} else {
		curl_close($ch);
		// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
		if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
			$contents = substr($contents,3);
		}
		//echo $contents;exit(0);
		$returnInfo = json_decode($contents, true);
		if (isset($returnInfo['subscriptionID'])) {
			//echo "return ID=".$returnInfo['subscriptionID']."<br>";
			header("location: buy_step4_success_start.php" );
			//exit(0);
		} else {
			$_SESSION['CLS_message'] = 'Error Code:'.$returnInfo['error'].' message:'.$returnInfo['message'];
			header("location: buy_step4_failure.php" );
			//exit(0);
		}
	}

}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Road to IELTS: IELTS preparation and practice</title>
<link rel="stylesheet" type="text/css" href="css/home.css" />
<link rel="stylesheet" type="text/css" href="css/buy.css" />
</head>

<body id="buy_page">
            <div id="header_outter">
        	    <?php include ( 'header.php' ); ?>
        
            </div>
			<div id="content_box_buy">
                            <div id="buy_box">
                                <p class="title">Step 3: Review and pay</p>
                                <div id="buy_step_1" class="buy_off"><span class="num">1</span>Enter your subscription details</div>
                                <div id="buy_step_2" class="buy_off"><span class="arrow"></span><span class="num">2</span>Choose your payment method</div>
                                <div id="buy_step_3" class="buy_on"><span class="arrow"></span><span class="num">3</span>Review and pay</div>
                                <div id="buy_step_4" class="buy_off"><span class="arrow"></span><span class="num">4</span>Start studying</div>
                                <div class="clear"></div>
                            </div>
                            
                            <div id="buy_start_loading">
                             <p class="title">You're almost there...</p>
                            	<div id="buy_start_loading_inner">
                                <img src="images/ajax-loading.gif" />
                            	  <p class="txt">Please wait while we create your account...<br />
 (Do not click any buttons on the navigation bar of your browser.)</p>
                              
</div>

                          </div>
                                    
                            
                        
                        </div>


</body>
</html>