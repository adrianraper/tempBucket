<?php

/**
 * You can test like this:
 *  http://dock.projectbench/Software/Common/fakeGateway.php?amount=19.99&orderRef=123456&failUrl=http://dock.claritylifeskills/paymentFailure.php&successUrl=http://dock.claritylifeskills/afterPayment.php
 */
	
// For testing when you send by parameters not POST
if (isset($_POST['amount'])) {
	$amount = $_POST['amount'];
} else if (isset($_GET['amount'])) {
	$amount = $_GET['amount'];
} else {
	$amount = "";
}
if (isset($_POST['orderRef'])) {
	$orderRef = $_POST['orderRef'];
} else if (isset($_GET['orderRef'])) {
	$orderRef = $_GET['orderRef'];
} else {
	$orderRef = "";
}
if (isset($_POST['failUrl'])) {
	$failUrl = $_POST['failUrl'];
} else if (isset($_GET['failUrl'])) {
	$failUrl = $_GET['failUrl'];
} else {
	$failUrl = "";
}
if (isset($_POST['successUrl'])) {
	$successUrl = $_POST['successUrl'];
} else if (isset($_GET['successUrl'])) {
	$successUrl = $_GET['successUrl'];
} else {
	$successUrl = "";
}

// Check mandatory fields
$seemsOK = true;
if ($failUrl == '') $seemsOK = false;
if ($successUrl == '') $seemsOK = false; 

if ($seemsOK) {
} else {
	echo "something missing from passed variables";
}


?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity fake payment gateway</title>
</head>

<body>
<div>
	amount = <?php echo $amount; ?><br/>
	orderRef = <?php echo $orderRef; ?><br/>
</div>
<form id="fakeSuccessForm" action="<?php echo $successUrl; ?>" method="post">
	<input type="text" name="ref" value="123456789"/>
	<input type="submit" id="successButton" value="success"/>
</form>
<form id="fakeFailureForm" action="<?php echo $failUrl; ?>" method="post">
	<input type="text" name="errorCode" value="101"/>
	<input type="submit" id="successButton" value="failure"/>
</form>
</body>
</html>