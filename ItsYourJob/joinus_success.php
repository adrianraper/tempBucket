<?php
session_start();
if(session_is_registered('IYJreg_name') == 0) {
	//session variable is not registered, go back to the main page
	$_SESSION['IYJreg_message'] = 'Session timeout.';
	header("location: joinus_failure.php");
	exit(0);
}
date_default_timezone_set('UTC');

switch($_SESSION['IYJreg_deliveryFrequency']) {
	case '1':
		$deliveryFrequency = 'One unit every day';
		break;
	case '3':
		$deliveryFrequency = 'One unit every three days';
		break;
	default :
		$deliveryFrequency = 'All at once';
		break;
}
switch($_SESSION['IYJreg_language']) {
	case 'NAMEN':
		$language = 'North American English';
		break;
	case 'INDEN':
		$language = 'Indian English';
		break;
	default :
		$language = 'International English';
		break;
}

$displayStartDate = date('F j, Y', strtotime($_SESSION['IYJreg_startDate']));
$displayExpiryDate = date('F j, Y', strtotime($_SESSION['IYJreg_expiryDate']));


?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English | It's Your Job | Join us now!</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<link rel="stylesheet" type="text/css" href="css/job_joinus.css" />

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


	  <!--Header Area-->
  <div id="header_container"><?php include 'header.php'; ?></div>
  <!--End of Header Area-->


    <div id="content_container">

    <h1 class="general_heading">Thank you, <?php echo $_SESSION['IYJreg_name']; ?>. We have successfully created your account. <br />Welcome to It's Your Job!</h1>
    <!--Content Area-->
    <div id="general_box_outter">
    
    <form method="POST" name="startLession" id="startLession" action="login.php?langcode=<? echo $_SESSION['IYJreg_language']; ?>" style="margin:0; padding:0;">
    
    <div id="general_box">
    
    
    <div id="print_details">

<!--Content-->
        <div class="join_box_content" id="join_box_page">
        
          	<h2>My login details</h2>
        
            <ul class="fielding_check">
            
                <li>
                    <p class="field_title">Login name :</p>
                    <p class="field_line"><?PHP echo $_SESSION['IYJreg_email']; ?></p>
                    <span class="clear"></span>                </li>
            
                <li>
                    <p class="field_title">Password :</p>
                    <p class="field_line"><?PHP echo $_SESSION['IYJreg_password']; ?></p>
                    <span class="clear"></span>                </li>
            </ul>

		<h2>My account details</h2>
         <ul class="fielding_check">
            
                 <li>
            <p class="field_title">Subscription period : </p>
            <p class="field_line">From <?PHP echo $displayStartDate; ?> to <?PHP echo $displayExpiryDate; ?></p>
            <span class="clear"></span>    
    	</li>
                
                <li>
                    <p class="field_title">Your user name :</p>
                    <p class="field_line"><?PHP echo $_SESSION['IYJreg_name']; ?></p>
                    <span class="clear"></span>                </li>
            
                <li>
                    <p class="field_title">Your Email :</p>
                    <p class="field_line"><?PHP echo $_SESSION['IYJreg_email']; ?></p>
                    <span class="clear"></span>                </li>
            
                <li>
                    <p class="field_title">Your Country :</p>
                    <p class="field_line"><?PHP echo $_SESSION['IYJreg_country']; ?></p>
                    <span class="clear"></span>                </li>
            
                
                <li>
                    <p class="field_title">Program version :</p>
                    <p class="field_line"><?PHP echo $language; ?></p>
                    <span class="clear"></span>                 </li>
                 
                 <li>
                   
                    
                   <a onclick="window.open('print.htm','mywindow','width=625,height=425')" href="#" class="print_line">Printer-friendly version</a>                 </li>
            </ul>
		

            <div class="btn_area_check">
            
            	<input name="" type="submit" value="" class="btn_start_lesson"/>
   
    		</div>
		</div>
		<input type="hidden" name="id" value="<?PHP echo $_SESSION['IYJreg_email']; ?>">
		<input type="hidden" name="pwd" value="<?PHP echo $_SESSION['IYJreg_password']; ?>">
		<input type="hidden" name="version" value="<?PHP echo $language; ?>">

<!--End of content-->

</div>

        </div>
        
        </form>
        
    </div>
    </div>
    
    
    
    
  <!--End of Content Area-->
    
    
  <!--Footer Area-->
  <div id="footer_container"><?php include 'footer.php'; ?></div>
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
<?PHP
	session_unset();
	session_destroy();
	$_SESSION = array();
?>