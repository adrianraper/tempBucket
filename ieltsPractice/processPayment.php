<?php
session_start();
date_default_timezone_set('UTC');
include_once "variables.php";

//$presetString = '{"method":"saveSubscriptionDetails","email":"adrian.raper@clarityenglish.com","name":"Adrian\'s Raper","country":"Hong Kong","resellerID":24,"orderRef":"12345678","offerID":10,"status":"initial"}';
// postString= ?method=saveSubscriptionDetails&email=adrian.raper@clarityenglish.com&name=Adrian\'s Raper&country=Hong Kong&resellerID=24&orderRef=12345678&offerID=10&amount=49.99&paymentMethod=Visa

// For testing when you send by parameters not POST
if (isset($_POST['paymentMethod'])) {
	$paymentMethod = $_POST['paymentMethod'];
} else if (isset($_GET['paymentMethod'])) {
	$paymentMethod = $_GET['paymentMethod'];
} else {
	$paymentMethod = "";
}
if (isset($_POST['name'])) {
	$name = $_POST['name'];
} else if (isset($_GET['name'])) {
	$name = $_GET['name'];
} else {
	$name = "";
}
if (isset($_POST['email'])) {
	$email = $_POST['email'];
} else if (isset($_GET['email'])) {
	$email = $_GET['email'];
} else {
	$email = "";
}
if (isset($_POST['password'])) {
	$password = $_POST['password'];
} else if (isset($_GET['password'])) {
	$password = $_GET['password'];
} else {
	$password = "";
}
if (isset($_POST['country'])) {
	$country = $_POST['country'];
} else if (isset($_GET['country'])) {
	$country = $_GET['country'];
} else {
	$country = "";
}
if (isset($_POST['offerID'])) {
	$offerID = $_POST['offerID'];
} else if (isset($_GET['offerID'])) {
	$offerID = $_GET['offerID'];
} else {
	$offerID = "";
}
// amount must be number otherwise cannot get through AsiaPay
if (isset($_POST['amount'])) {
	$amount = round($_POST['amount'], 2);
} else if (isset($_GET['amount'])) {
	$amount = round($_GET['amount'], 2);
} else {
	$amount = "";
}
if (isset($_POST['ageGroup'])) {
	$ageGroup = $_POST['ageGroup'];
} else if (isset($_GET['ageGroup'])) {
	$ageGroup = $_GET['ageGroup'];
} else {
	$ageGroup = "";
}
if (isset($_POST['phone'])) {
	$phone = $_POST['phone'];
} else if (isset($_GET['phone'])) {
	$phone = $_GET['phone'];
} else {
	$phone = "";
}
if (isset($_POST['newsletter'])) {
	$newsletter = $_POST['newsletter'];
} else if (isset($_GET['newsletter'])) {
	$newsletter = $_GET['newsletter'];
} else {
	$newsletter = "";
}
if (isset($_POST['subscriptionPeriod'])) {
	$subscriptionPeriod = $_POST['subscriptionPeriod'];
} else if (isset($_GET['subscriptionPeriod'])) {
	$subscriptionPeriod = $_GET['subscriptionPeriod'];
} else {
	$subscriptionPeriod = "";
}
// Check mandatory fields
$seemsOK = true;
if ( $paymentMethod=='' ) $seemsOK = false;
if ( $name=='' ) $seemsOK = false;
if ( $email=='' ) $seemsOK = false;
// payment gateway must know the amount to pay
if ( $amount=='' ) $seemsOK = false; 

if ($seemsOK) {
	$_SESSION['CLS_paymentMethod'] = $paymentMethod;
	$_SESSION['CLS_name'] = $name;
	$_SESSION['CLS_email'] = $email;
	$_SESSION['CLS_password'] = $password;
	$_SESSION['CLS_country'] = $country;
	$_SESSION['CLS_offerID'] = $offerID;
	
	// Hardcode some stuff
	// Derive some stuff that should come from database
	switch ($offerID) {
		case 59:
			$_SESSION['CLS_offerName'] = 'Road to IELTS 2 Academic 1-month';
			break;
		case 60:
			$_SESSION['CLS_offerName'] = 'Road to IELTS 2 Academic 3-months';
			break;
		case 61:
			$_SESSION['CLS_offerName'] = 'Road to IELTS 2 General Training 1-month';
			break;
		case 62:
			$_SESSION['CLS_offerName'] = 'Road to IELTS 2 General Training 3-months';
			break;
	}
	$_SESSION['CLS_resellerID'] = 21; //Clarity online subscription
	$_SESSION['CLS_contactMethod'] = 'email';
	$_SESSION['CLS_orderRef'] = session_id();
	$_SESSION['CLS_languageCode'] = 'R2IHU'; // Road to IELTS 2 Home User
	$_SESSION['CLS_loginOption'] = 128; // Email login
	//below fields are for displaying in the later pages.
	$_SESSION['CLS_amount'] = $amount;
	$_SESSION['CLS_subscriptionPeriod'] = $subscriptionPeriod;
	//below fields are just for emails and marketing use
	$_SESSION['CLS_ageGroup'] = $ageGroup;
	$_SESSION['CLS_phone'] = $phone;
	$_SESSION['CLS_newsletter'] = $newsletter;
	
	if (insertSubscription()) {
	//echo "added ID=".$_SESSION['CLS_subscriptionID'];
	//echo round($amount, 2);

		switch ($paymentMethod) {
			case 'Visa':
			case 'MC':
				$Gateway = "AsiaPay"; 
				AsiaPaySendPost();
				break;
			case 'PP':
				$Gateway = "PayPal";
				PaypalSendPost();
				break;
			case 'MT':
			case 'DB':
				sendEmail();
				break;
			default:
				$_SESSION['CLS_message'] = "Invalid payment method $paymentMethod";
				header("location: buy_step4_failure.php" );
		}

	} else {
		// Any failure in insertSubscription generates an error from there
	}
		
} else {
	//echo ("Unpredictable errors. Please go process the registration again.");
	//$_SESSION['CLS_message'] = 'Not Enough Data.';
	header("location: buy_step4_failure.php?error=105" );
	//echo ("seems not OK!!");
}

function AsiaPaySendPost() {
	
	global $thisDomain;
	global $startFolder;
	
	$merchantId = '88060532';
	$currCode = '840';
	$successUrl = $thisDomain.$startFolder.'afterPayment.php';
	$failUrl = $thisDomain.$startFolder.'buy_step4_failure.php?error=101';
	$errorUrl = $thisDomain.$startFolder.'buy_step4_failure.php?error=102';
	$payType = 'N';
	$lang = 'E';
	$targetURL = "https://www.paydollar.com/b2c2/eng/payment/payForm.jsp";
	//$targetURL = "https://test.paydollar.com/b2cDemo/eng/payment/payForm.jsp";

	echo '<form method="POST" name="toAsiaPay" action="'.$targetURL.'">';
	echo '<input type="hidden" name="merchantId" value="'.$merchantId.'">';
	echo '<input type="hidden" name="amount" value='.$_SESSION['CLS_amount'].'>';
	// we use subscription ID now
	//echo '<input type="hidden" name="orderRef" value="'.$_SESSION['CLS_orderRef'].'">';
	echo '<input type="hidden" name="orderRef" value="'.$_SESSION['CLS_subscriptionID'].'">';
	echo '<input type="hidden" name="currCode" value="'.$currCode.'">';
	echo '<input type="hidden" name="successUrl" value="'.$successUrl.'">';
	echo '<input type="hidden" name="failUrl" value="'.$failUrl.'">';
	echo '<input type="hidden" name="errorUrl" value="'.$errorUrl.'">';
	echo '<input type="hidden" name="payType" value="'.$payType.'">';
	echo '<input type="hidden" name="lang" value="'.$lang.'">';
	echo '<input type="submit" style="display:none;"/> ';
	echo '</form>';
	echo '<script language="javascript" type="text/javascript">';
	echo 'document.toAsiaPay.submit();';
	echo '</script>';
}

function PaypalSendPost() {
	
	global $thisDomain;
	global $startFolder;
	
	$merchantEmail = 'wan.zahrah@clarityenglish.com';
	//$merchantEmail = 'cetest_1283835607_biz@yahoo.com';
	$subscribedItem = 'Road to IELTS subscription';
	$targetURL = "https://www.paypal.com/cgi-bin/webscr";
	//$targetURL = "https://www.sandbox.paypal.com/us/cgi-bin/webscr";
	$returnURL = $thisDomain.$startFolder."afterPayment.php?session_id=".session_id();
	$cancelUrl = $thisDomain.$startFolder."buy_step4_failure.php?error=103&session_id=".session_id();
	$notify_url = "";

	echo '<form method="POST" name="toPayPal" action="'.$targetURL.'">';
	echo '<input type="hidden" name="cmd" value="_cart">';
	echo '<input type="hidden" name="upload" value="1">';
	echo '<input type="hidden" name="business" value="'.$merchantEmail.'">';
	echo '<input type="hidden" name="item_name_1" value="'.$subscribedItem.'">';
	echo '<input type="hidden" name="amount_1" value='.$_SESSION['CLS_amount'].'>';
	echo '<input type="hidden" name="return" value='.$returnURL.'>';
	echo '<input type="hidden" name="currency_code" value="USD"/>';
	echo '<input type="hidden" name="cancel_return" value='.$cancelUrl.'/>';	
	//echo '<input type="hidden" name="notify_url" value='.$notify_url.'/>';	
	echo '<input type="submit" style="display:none;"/> ';
	//echo '<input type="hidden" name="orderRef" value="'.$_SESSION['CLS_orderRef'].'">';
	echo '</form>';
		
	echo '<script language="javascript" type="text/javascript">';
	echo 'document.toPayPal.submit();';
	echo '</script>';
}

function insertSubscription() {

	global $commonDomain;
	global $startFolder;
	
	$CLSapi = array();
	$CLSapi['method'] = 'saveSubscriptionDetails';
	$CLSapi['email'] = $_SESSION['CLS_email'];
	$CLSapi['name'] = $_SESSION['CLS_name'];
	$CLSapi['country'] = $_SESSION['CLS_country'];
	$CLSapi['resellerID'] = $_SESSION['CLS_resellerID'];
	$CLSapi['orderRef'] = $_SESSION['CLS_orderRef'];
	$CLSapi['offerID'] = $_SESSION['CLS_offerID'];
	$CLSapi['password'] = $_SESSION['CLS_password'];
	$CLSapi['languageCode'] = $_SESSION['CLS_languageCode'];	
	$CLSapi['contactMethod'] = $_SESSION['CLS_contactMethod'];	
	// This is not currently used
	//$CLSapi['discountCode'] = $_SESSION['CLS_discountCode'];
	
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
		$_SESSION['CLS_message'] = "Error code: $errorCode, message: $failReason";
		header("location: buy_step4_failure.php" );
	} else {
		curl_close($ch);
		// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
		if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
			$contents = substr($contents,3);
		}
		//echo $contents;exit(0);
		$returnInfo = json_decode($contents, true);
		if (isset($returnInfo['subscriptionID'])) {
			$_SESSION['CLS_subscriptionID'] = $returnInfo['subscriptionID'];
			//echo "return ID=".$returnInfo['subscriptionID']."<br>";
			return true;
		} else {
			$_SESSION['CLS_message'] = 'Error code:'.$returnInfo['error'].' message:'.$returnInfo['message'];
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
			<p class="title">Redirecting...</p>
			<div id="buy_start_loading_inner">
				<img src="images/ajax-loading.gif">
                            	  <p class="txt">You will be redirected to the payment <?php echo $Gateway?> shortly.<br />(Please do not click any buttons on the navigation bar of your browser.)</p>
			</div>
		</div>

	</div>
</body>
</html>