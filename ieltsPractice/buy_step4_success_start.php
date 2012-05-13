<?php
	session_start();
	include_once "variables.php";
	
	// Checking for data
	$email = $_SESSION['CLS_email'];
	$name = $_SESSION['CLS_name'];
	$password = $_SESSION['CLS_password'];
	$offerName = $_SESSION['CLS_offerName'];
	$expiryDate = strftime('%d %B %Y',strtotime($_SESSION['CLS_expiryDate']));
	$userID = $_SESSION['CLS_userID'];
	$amount = $_SESSION['CLS_amount'];
	$ref = $_SESSION['CLS_subscriptionID'];
	
?>
<DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
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
                                <p class="title">Step 4: Start studying</p>
                                <div id="buy_step_1" class="buy_on"><span class="num">1</span>Enter your subscription details</div>
                                <div id="buy_step_2" class="buy_off"><span class="arrow"></span><span class="num">2</span>Choose your payment method</div>
                                <div id="buy_step_3" class="buy_off"><span class="arrow"></span><span class="num">3</span>Review and pay</div>
                                <div id="buy_step_4" class="buy_on"><span class="arrow"></span><span class="num">4</span>Start studying</div>
                                <div class="clear"></div>
                            </div>
                            
                            <div id="buy_start_learn">
                            	<p class="buy_start_title">Thank you!</p>
                                <p class="buy_start_subtitle">We have successfully created your account.<br />
An email will also be sent to you with your login details.</p> 
                                
                              
                                
                                <p class="buy_start_smtitle">Login details</p>
                                <p class="buy_start_txt">
                                    <strong>Login name:</strong> <?php echo $email; ?><br />
                                    <strong>Password:</strong> <?php echo $password; ?><br />
                                </p>
                                
                                <p class="buy_start_smtitle">Account details</p>
                                <p class="buy_start_txt">
                                    <strong>Member name:</strong> <?php echo $name; ?><br />
                                    <strong>Expires on:</strong> <?php echo $expiryDate; ?><br />
                                    <strong>Package:</strong> <?php echo $offerName; ?>
                                </p>
                                
                                <p class="buy_start_smtitle">Payment amount</p>
                                <p class="buy_start_txt"><strong>USD $<?php echo $amount; ?></strong></p>
                                
                            	
                                <p class="buy_start_smtitle">Payment details</p>
                              	<p class="buy_start_txt"><strong>Reference number:</strong> <?php echo $ref; ?></p>
                                
                                <a class="btn_start_learn" target="_blank" href="myaccount.php">Start learning now!</a>
                             
                          </div>
                                    
                            
                        
                        </div>

</body>
</html>