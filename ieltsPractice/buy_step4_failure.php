<?php
	session_start();
	include_once "variables.php";
	if (isset($_GET['error'])) {
		switch($_GET['error']) {
			case "101":
				$_SESSION['CLS_message'] = "Your payment was not successful."; //errorCode: 101
				break;
			case "102":
				$_SESSION['CLS_message'] = "There was an error during the payment."; //errorCode: 102
				break;
			case "103":
				$_SESSION['CLS_message'] = "Your payment has been canceled."; // errorCode: 103
				break;
			case "104":
				$_SESSION['CLS_message'] = "Your account has not been created successfully."; // errorCode: 104
				break;
			case "105":
				$_SESSION['CLS_message'] = "Not enough information to send to the payment gateway."; // errorCode: 105
				break;
		}
	}
	
	if (isset($_SESSION['CLS_afterPayment'])==true) {
		$errorMsgTitle = "We are sorry. Your account cannot be created at the moment.";
	} else {
		$errorMsgTitle = "We are sorry. The transaction was not completed successfully.";
	}
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
<title>Road to IELTS: IELTS preparation and practice | Start studying</title>
<link rel="stylesheet" type="text/css" href="css/home.css" />
<link rel="stylesheet" type="text/css" href="css/buy.css" />
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-873320-10']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</head>

<body id="buy_page">

    <div id="header_outter">
       <?php include ( 'header.php' ); ?>
	</div>
	<div id="container_outter">
		<div id="container">

			<div id="content_box_msg">
				

				<div id="buy_start_error">
					<p class="buy_start_error_title"><?php echo $errorMsgTitle;?></p>
					<p class="buy_start_error_subtitle"></p>

					<div class="buy_start_error_box">
						<p class="buy_start_smtitle">Possible cause(s):</p>
						<p class="buy_start_txt"><?php echo $_SESSION['CLS_message'];?></p>
					</div>

					<div class="buy_start_error_box">
						<p class="buy_start_smtitle">Possible solution(s):</p>
							<?php if ($_SESSION['CLS_afterPayment']) { ?>
							<p>Your reference number is: <strong><?php echo $_SESSION['CLS_subscriptionID'];?></strong>.</p>
							<p class="buy_start_txt">Please contact the Clarity Support Team at <a href="mailto:support@clarityenglish.com?Subject=IELTSPractice.com Payment error. Reference number: <?php echo $_SESSION['CLS_subscriptionID'];?>">support@clarityenglish.com</a>, stating your reference number in the subject. We will reply to you within one working day.</p>
							<?php } else {?>
							<p class="buy_start_txt">You have not been charged for payment. <br>Please click <a href="buy.php" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step4fail_txt_buyagain']);">here</a> to try buying again. You may want to use a different method of payment.</p>
							<p class="buy_start_txt">If you have any queries, please contact the Clarity Support Team at <a href="mailto:support@clarityenglish.com?Subject=IELTSPractice.com payment error">support@clarityenglish.com</a>. We will reply to you within one working day.</p>
							<?php } ?>
					</div>
					<?php if ($_SESSION['CLS_afterPayment']) { ?>
					<div class="buy_button_area">
						<!--a class="btn_blue_general" href="Buy.php">Try again</a-->
						<a class="btn_blue_general" href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Payment error. Reference number: <?php echo $_SESSION['CLS_subscriptionID'];?>">Send us an email</a>
						<div class="clear"></div>
					</div>
					<?php } else { ?>
					<div class="buy_button_area">
						<a class="btn_blue_general" href="buy.php"  onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step4fail_btn_buyagain']);">Try again</a>
						<div class="clear"></div>
					</div>                    
                    <?php }?>
				</div>
			</div>

		</div>
	</div>

</body>
</html>