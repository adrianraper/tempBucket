<?php

$commonDomain = 'http://dock.projectbench/';
$debugLog = true;
$debugFile = "logs/PayPal.log";

if ($debugLog)
	error_log("IPN received\n", 3, $debugFile);
	
// read the post from PayPal system and add 'cmd'
$req = 'cmd=' . urlencode('_notify-validate');

$req .= '&mc_gross=19.95&protection_eligibility=Eligible&address_status=confirmed&payer_id=LPLWNMTBWMFAY&tax=0.00&address_street=1+Main+St&payment_date=20%3A12%3A59+Jan+13%2C+2009+PST&payment_status=Completed&charset=windows-1252&address_zip=95131&first_name=Test&mc_fee=0.88&address_country_code=US&address_name=Test+User&notify_version=2.6&custom=&payer_status=verified&address_country=United+States&address_city=San+Jose&quantity=1&verify_sign=AtkOfCXbDm2hu0ZELryHFjY-Vb7PAUvS6nMXgysbElEn9v-1XcmSoGtf&payer_email=gpmac_1231902590_per%40paypal.com&txn_id=61E67681CH3238416&payment_type=instant&last_name=User&address_state=CA&receiver_email=gpmac_1231902686_biz%40paypal.com&payment_fee=0.88&receiver_id=S8XGHLYDW9T3S&txn_type=express_checkout&item_name=&mc_currency=USD&item_number=&residence_country=US&test_ipn=1&handling_amount=0.00&transaction_subject=&payment_gross=19.95&shipping=0.00';

foreach ($_POST as $key => $value) {
	$value = urlencode(stripslashes($value));
	$req .= "&$key=$value";
}

// assign posted variables to local variables
/*
$item_name = $_POST['item_name'];
$item_number = $_POST['item_number'];
$payment_status = $_POST['payment_status'];
$payment_amount = $_POST['mc_gross'];
$payment_currency = $_POST['mc_currency'];
$txn_id = $_POST['txn_id'];
$receiver_email = $_POST['receiver_email'];
$payer_email = $_POST['payer_email'];
$info = json_encode($_POST);
*/
$info = "mc_gross=19.95";

// Send back the data you just got as part of the verification process
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://www.sandbox.paypal.com/cgi-bin/webscr');
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $req);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 1);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 2);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Host: www.paypal.com'));
$res = curl_exec($ch);
curl_close($ch);

echo 'curl return='.$res;

// Then confirm that PayPal likes it all
if (strcmp ($res, "VERIFIED") == 0) {
	
	error_log("IPN verified $info\n", 3, $debugFile);

	// check the payment_status is Completed
	// check that txn_id has not been previously processed
	// check that receiver_email is your Primary PayPal email
	if (stristr(strtolower($receiver_email),'clarity')) {
		// Send email to Clarity accounts
		sendEmailToClarity($info);	
	}
	// check that payment_amount/payment_currency are correct
	// process payment
}
else if (strcmp ($res, "INVALID") == 0) {
	// log for manual investigation
	$debugFile = "logs/PayPal.log";
		error_log("IPN invalid $info\n", 3, $debugFile);
}

function sendEmailToClarity($info) {
	
	global $commonDomain;
	global $debugFile;
	global $debugLog;
	
	$CLSapi = array();
	$CLSapi['method'] = 'sendEmail';
	$CLSapi['from'] = "support@claritylifeskills.com"; 
	$CLSapi['to'] = "accounts@clarityenglish.com";
	$CLSapi['templateID'] = "CLS/PayPalInstantNotification";
	$CLSapi['data'] = $info;
	
	$serializedObj = json_encode($CLSapi);
	$targetURL = $commonDomain."Software/ResultsManager/web/amfphp/services/Emailgateway.php";

	if ($debugLog)
		error_log("IPN to $targetURL\n", 3, $debugFile);
		
	// Initialize the cURL session
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
	curl_setopt($ch, CURLOPT_URL, $targetURL);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $serializedObj);
	
	// Execute the cURL session. 
	// Can I make a setting so that I don't wait for a return?
	$contents = curl_exec($ch);
	curl_close($ch);
}

?>