<?php
session_start();
if(session_is_registered('IYJreg_name') == 0) {
	$_SESSION['IYJreg_message'] = 'Session timeout.';
	//session variable is not registered, go back to the main page
}

if (isset($_GET['error'])) {
	switch ($_GET['error']) {
		case 'PaymentFailure':
			$_SESSION['IYJreg_message'] = 'Your transaction failed. Please check with your bank about the status of your card.';
			break;
		default:
			$_SESSION['IYJreg_message'] = 'An error occurred during processing of payment. The transaction is not completed.';
			break;
	}
}

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English | It's Your Job | Join us now!</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" media="screen"/>
<link rel="stylesheet" type="text/css" href="css/job_joinus.css" media="screen"/>

<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="css/fancybox.css" />

<!--General jquery library: For Fancy box, programs left menu-->
<script type="text/javascript" src="script/jquery.js"></script>
<script type="text/javascript" src="script/popup.js"></script>

<!--Fancy Popup Box-->
<script type="text/javascript" src="script/fancybox.js"></script>
<script type="text/javascript" src="script/fancybox_custom.js"></script>
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

	<div id="print_details">

    <div id="content_container">


    

    <h1 class="general_heading">We're sorry, your checkout was not successful.</h1>
    <!--Content Area-->
        <div id="general_box_outter">
    <div id="general_box">
    
    
    

<!--Content-->
<form method="post" action="" name="joinUsForm" id="joinUsForm" class="join_formfailure">



        <div class="join_box_content" id="join_box_page">
        
          	<h2>Possible cause(s):</h2>      
            <ul class="fielding_fail">        
                <li><?php echo $_SESSION['IYJreg_message']?></li>
            </ul>

		<h2>Possible solution(s):</h2>
         <ul class="fielding_fail">
            
                <li>Please check the information entered and see if you can continue your registration. Otherwise, please contact the Clarity Support Team at <a href="mailto:support@clarityenglish.com">support@clarityenglish.com</a>. We will get back to you within one working day.</li>
               

            </ul>
 <div class="btn_area_check">
                <div class="btn_try_again" onclick="window.location='joinus.php'; javascript:pageTracker._trackPageview('/ItsYourJob/joinus_failure_tryagain');"></div>
    		</div>
			

		</div>
        

   
</form>
<!--End of content-->
        </div>
    </div><!--End of General box outter-->
    
    
    </div> <!--End of Content Container -->
    
       </div>  <!--End of Print line-->
    

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

<!--Google analytics-->
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-873320-5");
pageTracker._trackPageview();
} catch(err) {}</script>
<!--End of Google analytics-->


</body>
</html>
