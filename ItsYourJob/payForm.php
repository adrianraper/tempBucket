<?php
session_start();
	include_once "Variables.php";
	
	function redirect ($url) {
		header('Location: ' . $url);
		exit;
	}
	
	if (isset($_GET['errorMsg'])) {
		$errorMsg = $_GET['errorMsg'];
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>It's Your Job registration</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<link rel="stylesheet" href="css/general.css" type="text/css" />

</head>

<body>
<div id="container_paymentForm">

<div id="userAdminBar">
	<!-- RL we don't have logout -->
	<a href="mailto:support@clarityenglish.com">Contact us</a>
	<!--Welcome to RoadToIELTS | <a href="logout.php">Logout</a> | <a href="mailto:support@clarityenglish.com">Contact us</a>-->
</div>

<div id="payment_form">
	<div id="addlearner_title">Payment Information</div>
	<!-- For Demo, just go directly into the register page-->
    <!--<form id="payForm" name="payForm" method="post" action="https://test.paydollar.com/b2cDemo/eng/dPayment/payComp.jsp" >-->
	<form id="payForm" name="payForm" method="post" action="userDetails.php" >
    <fieldset>
		<p class="complete_title">Please fill in your credit card infromartion. All fields must be completed.</p>
		<div id="responseMessage" class="note"><font color="red"><b><?php echo $errorMsg ?></b></font></div>
<!-- Login table Start -->
<ul>
	<li id="amount"><!-- Amount that customer should pay -->
		<p class="labelname"><label for="amount" id="amountLbl" >Pay amount:</label></p>
		<p class="labeltitle">USD $<input type="text" name="amount" id="amount" size="6"  value="999" tabindex="5" class="field" readonly/></p>
		<p class="labeltitle"><label for="amount" id="amountNote" class="note">This is the amount that you will pay for It's Your Job.</label></p>
	</li>

	<li id="amount">
		<p class="labelname"><label for="pMethod" id="pMethodLbl" >Payment card type:</label></p>
		<input type="radio" id="VISA" name="pMethod" value="VISA" tabindex="6" checked="checked"><label for="VISA" id="VISALbl" >VISA</label>
		<input type="radio" id="Master" name="pMethod" value="Master" tabindex="7">	<label for="Master" id="MasterLbl">Master</label>
		<input type="radio" id="Diners" name="pMethod" value="Diners" tabindex="8"><label for="Diners" id="DinersLbl" >VISA</label>
		<input type="radio" id="JCB" name="pMethod" value="JCB" tabindex="9"><label for="JCB" id="JCBLbl">JCB</label>
		<input type="radio" id="AMEX" name="pMethod" value="AMEX" tabindex="10"><label for="AMEX" id="AMEXLbl">American Express</label>
		<p class="labeltitle"><label for="pMethod" id="pMethodNote" class="note">Please choose the card you wish to pay.</label></p>
	</li>

	<li id="cardHolder">
		<p class="labelname"><label for="cardHolder" id="cardHolderLbl" >Name:</label></p>
		<p class="labeltitle"><input type="text" name="cardHolder" id="cardHolder" size="20"  value="" tabindex="11" class="field"/></p>
		<p class="labeltitle"><label for="cardHolder" id="cardHolderNote" class="note">The name should be exactly the same with your card.</label></p>
	</li>

	<li id="cardNo">
		<p class="labelname"><label for="cardNo" id="cardNoLbl" >Card number:</label></p>
		<p class="labeltitle"><input type="text" name="cardNo" id="cardNo" size="16"  value="" tabindex="12" class="field"/></p>
		<p class="labeltitle"><label for="cardNo" id="cardNoNote" class="note">Your unique credit card number.</label></p>
	</li>

	<li id="ccXDateField">
		<p class="labelname"><label for="ccXDate" id="ccXDateLbl" >Expiry date:</label></p>
		<p class="labeltitle"><input type="text" name="epMonth" id="epMonth" size="2"  value="" tabindex="13" class="field"/> / <input type="text" name="epYear" id="epYear" size="4"  value="" tabindex="14" class="field"/></p>
		<p class="labeltitle"><label for="ccXDate" id="ccXDateNote" class="note">Your unique credit card number.</label></p>
	</li>

	<li id="securityCode">
		<p class="labelname"><label for="securityCode" id="securityCodeLbl" >Card Verfication Code:</label></p>
		<p class="labeltitle"><input type="text" name="securityCode" id="securityCode" size="4"  value="" tabindex="15" class="field"/></p>
		<p class="labeltitle"><label for="securityCode" id="securityCodeNote" class="note">The Card Verficaition Code (CVC) is used as a security precaution, insuring that you have possession of your card.<br>For Master Card, Visa, Discover: CVC is the last three digits printed on the back on your card in the signature panel.<br>For Amercian Express: CVC is the four small number printed on the front of your American Express card, abovethe last few embossed numbers.</label></p>
	</li>

	<!-- hidden information -->
	<!-- Now can only pay as US dollar-->
	<input type="hidden" id="currCode" name="currCode" value="840"></input>
	<!-- Lanugage of the Asia Pay page -->
	<input type="hidden" id="lang" name="lang" value="E"></input>
	<!--merchantID, provided by Asia Pay -->
	<input type="hidden" id="merchantId" name="merchantId" value="1234567890"></input>
	<!-- Success Page return -->
	<input type="hidden" id="successUrl" name="successUrl" value="<?php echo $domain.$startFolder ?>userDetails.php"></input>
	<!-- Fail page return -->
	<input type="hidden" id="failUrl" name="failUrl" value="<?php echo $domain.$startFolder ?>payForm.php"></input>
	<!-- Error Page return -->
	<input type="hidden" id="errorUrl" name="errorUrl" value="<?php echo $domain.$startFolder ?>payForm.php"></input>
</ul>

		<div class="button_area">
			<input id="send" name="send" type="submit" value="Submit" tabindex="7" class="button_long"/>
		</div>

	</fieldset>
	</form>
</div>
</div>
</body>
</html>