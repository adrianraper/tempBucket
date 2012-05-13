<?php
	session_start();

	// All these variables would be in session when you come back from the payment gateway
	$_SESSION['CLS_subscriptionID'] = 1021;
	//$_SESSION['CLS_email'] = 'mimi.rahima.8@clarityenglish.com';
	//$_SESSION['CLS_paymentMethod'] = 'credit card';
	//$_SESSION['CLS_name'] = 'Douglas Engelbert';
	//$_SESSION['CLS_password'] = 'sweetcustard';
	//$_SESSION['CLS_country'] = 'Hong Kong';
	//$_SESSION['CLS_offerID'] = 59;
	//$_SESSION['CLS_resellerID'] = 21; //Clarity online subscription
	//$_SESSION['CLS_contactMethod'] = 'email';
	//$_SESSION['CLS_orderRef'] = session_id();
	//$_SESSION['CLS_languageCode'] = 'R2IHU'; // Road to IELTS 2 Home User
	//below fields are for displaying in the later pages.
	$_SESSION['CLS_offerName'] = 'Road to IELTS 2 General Training 1-month';
	$_SESSION['CLS_amount'] = 49.99;
	
	//$_SESSION['CLS_subscriptionPeriod'] = '3 months';

	// Go to the afterPayment page
	if (isset($_GET['success'])) {
		$success = $_GET['success'];
	} else {
		$success = 'true';
	}
	
	if ($success == 'true') {
		header("location: afterPayment.php" );
	} else {
		if (isset($_GET['reason'])) {
			$failReason = $_GET['reason'];
		} else {
			$failReason = 'PaymentFailure';
		}
		header("location: buy_step4_failure.php?error=$failReason" );
	}
	
	exit(0);