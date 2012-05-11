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
                            
                          <div id="buy_start_error">
                           	<p class="buy_start_error_title">We’re sorry,</p>
                                <p class="buy_start_error_subtitle">your payment was not successful.</p>
                                
                              
                                <div class="buy_start_error_box">
                                    <p class="buy_start_smtitle">Possible cause(s) :</p>
                                    <p class="buy_start_txt">
                                        <?php echo $_SESSION['CLS_message']?>
                                    </p>
                            </div>
                                
                                
                                <div class="buy_start_error_box">
                                    <p class="buy_start_smtitle">Possible solution(s):</p>
                                    <ul>
                                        <li>Please check the information entered and see if you can continue your registration.</li>
                                        <li>Please contact the Clarity Support Team at support@clarityenglish.com. We will get back to you within
                                        one working day.</li>
                                        <li>If payment by credit card has failed, please use PayPal to complete the purchase.</li>
                                    </ul>
                                </div>
                                
                            <div class="buy_start_error_box">
                                    <p class="buy_start_smtitle">Error details:</p>
                                    <ul>
                                        <li>Your reference number is: <?php echo $_SESSION['CLS_subscriptionID']?>.</li>
                                        <!--li>Please check the information entered and see if you can continue your registration.</li-->
                                        <li>Please contact the Clarity Support Team at support@clarityenglish.com. We will get back to you within
one working day.</li>
                                     
                                    </ul>
                            </div>
                                
                                
                                <div class="buy_button_area">
                                        <!--a class="btn_blue_general" href="Buy.php">Try again</a-->
                                        <a class="btn_blue_general" href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Payment error">Send us an email</a>
                            
                                    
                                        
                                        <div class="clear"></div>
                            </div>
                                
                                
                                
                               
                                
                                
                             
                          </div>
                                    
                            
                        
                        </div>

</body>
</html>