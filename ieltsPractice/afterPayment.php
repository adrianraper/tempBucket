<?php
	session_start();
	date_default_timezone_set('UTC');
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

$justDebug = false;
if ($justDebug) {
	$contents = '{"account":{"_explicitType":"com.clarityenglish.dms.vo.account.Account","name":"Douglas Engelbert","prefix":"1346","tacStatus":2,"accountStatus":2,"accountType":1,"invoiceNumber":"1021","resellerCode":"21","reference":null,"logo":null,"selfHost":false,"selfHostDomain":null,"optOutEmails":null,"optOutEmailDate":null,"loginOption":65,"verified":null,"selfRegister":null,"adminUser":{"_explicitType":"com.clarityenglish.common.vo.manageable.User","userID":"251600","password":"sweetcustard","userType":0,"studentID":null,"expiryDate":"","email":"douglas.engelbert.2@clarityenglish.com","birthday":null,"country":"Hong Kong","city":"","startDate":" 00:00:00","contactMethod":null,"fullName":null,"custom1":null,"custom2":null,"custom3":null,"custom4":null,"registrationDate":null,"userProfileOption":null,"registerMethod":null,"name":"Douglas Engelbert","id":"26283.251600"},"titles":[{"_explicitType":"com.clarityenglish.common.vo.content.Title","courses":[],"productCode":"52","maxStudents":1,"maxTeachers":0,"maxReporters":0,"maxAuthors":0,"expiryDate":"2012-06-13 23:59:59","licenceStartDate":"2012-05-13 00:00:00","languageCode":"R2IHU","startPage":null,"licenceFile":null,"contentLocation":null,"dbContentLocation":null,"licenceType":5,"licenceClearanceDate":null,"licenceClearanceFrequency":null,"indexFile":null,"name":"Road to IELTS 2 Academic","licencedProductCodes":null,"deliveryFrequency":null,"checksum":null,"enabledFlag":null,"id":null,"contactMethod":null}],"licenceAttributes":[],"id":"14461"},"subscriptionID":1021,"password":"sweetcustard","orderRef":"201200085","CLSreference":"1021","emailSentTo":"douglas.engelbert.2@clarityenglish.com","prefix":"1346"}';
	$returnInfo = json_decode($contents, true);
	$errorCode = 0;
	
	// Expecting to get back an error or a user and account object
	if (isset($returnInfo['error'])) {
		
		$_SESSION['CLS_message'] = 'Error Code:'.$returnInfo['error'].' message:'.$returnInfo['message'];
		header("location: buy_step4_failure.php" );
		
	} elseif (isset($returnInfo['account'])) {
		
		$accountInfo = $returnInfo['account'];
		$userInfo = $accountInfo['adminUser'];
		$titleInfo = $accountInfo['titles'][0];
	
		// We have the user and account information here, so put what you need into session
		// to save getting it all again in the next stage!
		// But this still should be CLS session variables
		$_SESSION['CLS_userID'] = $userInfo['userID'];
		$_SESSION['CLS_prefix'] = $accountInfo['prefix'];
		$_SESSION['CLS_expiryDate'] = $titleInfo['expiryDate'];
		
		header("location: buy_step4_success_start.php" );
		
	} else {
		
		$_SESSION['CLS_message'] = 'Error Code:'.$returnInfo['error'].' message:'.$returnInfo['message'];
		header("location: buy_step4_failure.php" );
		
	}
	exit(0);
}

// The subscription ID is the key to all other information - you must have it
if (!isset($_SESSION['CLS_subscriptionID'])) {
		
	//session variable is not registered, go back to the main page
	$_SESSION['CLS_message'] = 'Session has lost the subscription key';
	//echo 'No session';
	header("location: buy_step4_failure.php");
	exit(0);
}

if ($_SESSION['CLS_orderRef']!= session_id()) {
	//session id not matching, go back to the main page
	$_SESSION['CLS_message'] = 'Session not matched.';
	//echo 'Session not match';
	header("location: buy_step4_failure.php");
	exit(0);
}

// You have come back from the payment gateway with success, so create the user's account
// Try to update the subscription table, though ignore whatever comes back
$rc = updateSubscription("paid");
$rc = addAccount();

function updateSubscription($status) {

	global $commonDomain;
	global $debugLog;
	global $debugFile;
	
	$CLSapi = array();
	$CLSapi['method'] = 'updateSubscriptionStatus';
	$CLSapi['subscriptionID'] = $_SESSION['CLS_subscriptionID'];
	$CLSapi['status'] = $status;
	$serializedObj = json_encode($CLSapi);
	$targetURL = $commonDomain."Software/ResultsManager/web/amfphp/services/CLSgateway.php";
	
	// Initialize the cURL session
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
		return false;
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
		return true;
	}
}

function addAccount() {

	global $commonDomain;
	global $debugLog;
	global $debugFile;
	
	$CLSapi = array();
	$CLSapi['method'] = 'addSubscription';
	$CLSapi['subscriptionID'] = $_SESSION['CLS_subscriptionID'];
	// The following are fields that are NOT saved in subscription table, but we need to create the account
	$CLSapi['emailTemplateID'] = 'ieltspractice_welcome';
	$CLSapi['paymentMethod'] = $_SESSION['CLS_paymentMethod'];
	$CLSapi['loginOption'] = $_SESSION['CLS_loginOption'];
	
	$serializedObj = json_encode($CLSapi);
	$targetURL = $commonDomain."Software/ResultsManager/web/amfphp/services/CLSgateway.php";
	
	//Initialize the cURL session
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
		$_SESSION['CLS_message'] = 'Error Code:'.$errorCode.' message:'.$failReason;
		header("location: buy_step4_failure.php" );
	} else {
		curl_close($ch);
		// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
		if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
			$contents = substr($contents,3);
		}
		//echo $contents;exit(0);
		$returnInfo = json_decode($contents, true);
		if ($debugLog) {
			error_log("back from LoginGateway with $contents\n", 3, $debugFile);
		}

		$errorCode = 0;
		
		// Expecting to get back an error or a user and account object
		if (isset($returnInfo['error'])) {
			
			$_SESSION['CLS_message'] = 'Error Code:'.$returnInfo['error'].' message:'.$returnInfo['message'];
			header("location: buy_step4_failure.php" );
			
		} elseif (isset($returnInfo['account'])) {
			
			$accountInfo = $returnInfo['account'];
			$userInfo = $accountInfo['adminUser'];
			// TODO. Dangerous assumption that the first title is the one you just purchased
			$titleInfo = $accountInfo['titles'][0];
		
			// We have the user and account information here, so put what you need into session
			// to save getting it all again in the next stage!
			// But this still should be CLS session variables
			$_SESSION['CLS_userID'] = $userInfo['userID'];
			$_SESSION['CLS_prefix'] = $accountInfo['prefix'];
			$_SESSION['CLS_expiryDate'] = $titleInfo['expiryDate'];
						
			header("location: buy_step4_success_start.php" );
			
		} else {
			
			$_SESSION['CLS_message'] = 'Error Code:'.$returnInfo['error'].' message:'.$returnInfo['message'];
			header("location: buy_step4_failure.php" );
			
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