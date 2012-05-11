<?php
	session_start();
	include_once "variables.php";
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
                                    <strong>Login name:</strong> <?php echo $_SESSION['CLS_email']?><br />
                                    <strong>Password:</strong> <?php echo $_SESSION['CLS_password']?><br />
                                </p>
                                
                                <p class="buy_start_smtitle">Account details</p>
                                <p class="buy_start_txt">
                                    <strong>User name:</strong> <?php echo $_SESSION['CLS_name']?><br />
                                    <strong>Subscription period:</strong> <?php  ?><br />
                                    <strong>Expires on:</strong> <?php  ?><br />
                                    <strong>Module:</strong> <?php  ?>
                                </p>
                                
                                <p class="buy_start_smtitle">Payment amount</p>
                                <p class="buy_start_txt"><strong>USD $<?php echo $_SESSION['CLS_amount']?></strong></p>
                                
                            	
                                <p class="buy_start_smtitle">Payment details</p>
                              	<p class="buy_start_txt"><strong>Reference number:</strong> <?php echo $_SESSION['CLS_subscriptionID']?></p>
                                
                                <a class="btn_start_learn" target="_blank" href="#">Start learning now!</a>
                             
                          </div>
                                    
                            
                        
                        </div>

</body>
</html>