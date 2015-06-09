<?php
if (session_id() == "") session_start();
date_default_timezone_set('UTC');
require_once('../db_login.php');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English | It's Your Job | Join us now!</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<link rel="stylesheet" type="text/css" href="css/job_joinus.css" />

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

    <h1 class="general_heading">Redirecting...</h1>
    <!--Content Area-->
    <div id="general_box_outter">
    <div id="general_box">
    
    


<!--Content-->
        <div class="join_box_content" id="join_box_page">
        
        	<div class="loading_box">
        	
                <p class="loading_img"></p>
                <p class="loading_line">This page will be redirected to Pay Dollar Gateway shortly.</p>
                <p class="loading_line">Please wait for a moment...</p>
                
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
    
        <div id="footer_links_line">  <a href="http://www.clarityenglish.com/itsyourjob/contactus.htm" class="contentpop_iframe">Contact us</a> | <a href="terms.htm">Terms and conditions</a> | <a href="http://www.clarityenglish.com/aboutus/index.php" target="_blank">About Clarity</a></div>
  </div>
    
    <!--End of Footer Area-->


</div>     <!--End of Container-->


</body>
</html>
<?php

$seemsOK = true;
if($_POST['name'] == "") $seemsOK = false;
if($_POST['email'] == "") $seemsOK = false;
if($_POST['country'] == "") $seemsOK = false;
if($_POST['deliveryFrequency'] == "") $seemsOK = false;
if($_POST['contactMethod'] == "") $seemsOK = false;
if($_POST['language'] == "") $seemsOK = false;
if($_POST['productCode'] == "") $seemsOK = false;
//if($_POST['startDate'] == "") $seemsOK = false;
if($_POST['expiryDate'] == "") $seemsOK = false;
if($_POST['checkSum'] == "") $seemsOK = false;
if($_POST['merchantId'] == "") $seemsOK = false;
if($_POST['amount'] == "") $seemsOK = false;
//if($_POST['orderRef'] == "") $seemsOK = false;
if($_POST['currCode'] == "") $seemsOK = false;
if($_POST['successUrl'] == "") $seemsOK = false;
if($_POST['failUrl'] == "") $seemsOK = false;
if($_POST['errorUrl'] == "") $seemsOK = false;
if($_POST['payType'] == "") $seemsOK = false;
if($_POST['lang'] == "") $seemsOK = false;

if ($seemsOK) {
	$_SESSION['IYJreg_name'] = $_POST['name'];
	$_SESSION['IYJreg_email'] = $_POST['email'];
	$_SESSION['IYJreg_country'] = $_POST['country'];
	$_SESSION['IYJreg_deliveryFrequency'] = $_POST['deliveryFrequency'];
	$_SESSION['IYJreg_contactMethod'] = $_POST['contactMethod'];
	$_SESSION['IYJreg_language'] = $_POST['language'];
	$_SESSION['IYJreg_productCode'] = $_POST['productCode'];
	$_SESSION['IYJreg_orderRef'] = session_id();
	// In order to get server time start account
	//$_SESSION['IYJreg_startDate'] = $_POST['startDate'];
	$_SESSION['IYJreg_startDate'] = date('Y-m-d 00:00:00', time());
	//error_log("\r\ntime now for start date=".$_SESSION['IYJreg_startDate'],3,'debug.txt');
	//$_SESSION['IYJreg_expiryDate'] = $_POST['expiryDate'];
	$_SESSION['IYJreg_expiryDate'] = date('Y-m-d 00:00:00', time()+(31 * 24 * 60 * 60));
	$_SESSION['IYJreg_checkSum'] = $_POST['checkSum'];
	$_SESSION['IYJreg_password'] = '';
	
// add data into database
	$sql = "INSERT INTO T_Subscription (F_FullName, F_Email, F_Country, F_DeliveryFrequency, F_ContactMethod, F_LanguageCode, F_ProductCode, F_StartDate, F_ExpiryDate, F_Password, F_CheckSum, F_Status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
	$resultset = $db->Execute($sql,array($_SESSION['IYJreg_name'], $_SESSION['IYJreg_email'], $_SESSION['IYJreg_country'], $_SESSION['IYJreg_deliveryFrequency'], $_SESSION['IYJreg_contactMethod'], $_SESSION['IYJreg_language'], $_SESSION['IYJreg_productCode'], $_SESSION['IYJreg_startDate'], $_SESSION['IYJreg_expiryDate'], $_SESSION['IYJreg_password'], $_POST['checkSum'], "initial" ));
	if (!$resultset) {
		//$errorMsg = $db->ErrorMsg();
		$_SESSION['IYJreg_message'] = 'pre-registration failed.';
		header("location: joinus_failure.php");
	} else {
		sendPost();
	}
	
	$resultset->Close();
	// NOTE can we also close the connection?
	$db->Close();

} else {
	//echo ("Unpredictable errors. Please go process the registration again.");
	$_SESSION['IYJreg_message'] = 'Not Enough Data.';
	header("location: joinus_failure.php" );
}

function sendPost() {
		#Testing URL
		//$targetURL = "https://test.paydollar.com/b2cDemo/eng/payment/payForm.jsp";
		#production URL
		$targetURL = "https://www.paydollar.com/b2c2/eng/payment/payForm.jsp";
		
		echo '<form method="POST" name="toAsiaPay" action='.$targetURL.'>';
		echo '<input type="hidden" name="merchantId" value='.$_POST['merchantId'].'>';
		echo '<input type="hidden" name="amount" value='.$_POST['amount'].'>';
		echo '<input type="hidden" name="orderRef" value='.session_id().'>';
		echo '<input type="hidden" name="currCode" value='.$_POST['currCode'].'>';
		echo '<input type="hidden" name="successUrl" value='.$_POST['successUrl'].'>';
		echo '<input type="hidden" name="failUrl" value='.$_POST['failUrl'].'>';
		echo '<input type="hidden" name="errorUrl" value='.$_POST['errorUrl'].'>';
		echo '<input type="hidden" name="payType" value='.$_POST['payType'].'>';
		echo '<input type="hidden" name="lang" value='.$_POST['lang'].'>';
		echo '</form>';
		
		echo '<script language="javascript" type="text/javascript">';
		echo 'document.toAsiaPay.submit();';
		echo '</script>';
}
?>