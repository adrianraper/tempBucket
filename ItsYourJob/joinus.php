<?php
session_start();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English | It's Your Job | Join us now!</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<link rel="stylesheet" type="text/css" href="css/job_joinus.css" />
<link rel="stylesheet" type="text/css" href="css/print.css" media="print"/>

<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="css/fancybox.css" />

<!--General jquery library: For Fancy box, programs left menu-->
<script type="text/javascript" src="script/jquery.js"></script>
<script type="text/javascript" src="script/popup.js"></script>

<!--Fancy Popup Box-->
<script type="text/javascript" src="script/fancybox.js"></script>
<script type="text/javascript" src="script/fancybox_custom.js"></script>

<!-- Use in registration -->
<script type="text/javascript" src="script/dateFormat.js"></script>
<script type="text/javascript" src="script/reg_validation.js"></script>
</head>

<body>

<div id="container">

  <!--Header Area-->
  <div id="header_container"><?php include 'header.php'; ?></div>
  <!--End of Header Area-->

  <div id="content_container">

    <h1 class="general_heading"><a href="index.php">Home</a> > Join us now!</h1>
    <!--Content Area-->
    <div id="general_box_outter">
    <div id="general_box">
    	<div id="join_box_menu">
        	<ul id="join_box_ind">
            	<li class="head"></li>
            	
                <li>
                	
                        <p class="number">1</p>
                        <p id="join_box_step1" class="graph_on"></p>
                        <p class="title">Check the terms</p>
                </li>
                
                <li>
                	
                        <p class="number">2</p>
                        <p id="join_box_step2" class="graph_off"></p>
                        <p class="title">Fill in your details</p>
                </li>
                
                 <li>
                
                        <p class="number">3</p>
                        <p id="join_box_step3" class="graph_off"></p>
                        <p class="title">Course settings</p>
                 </li>
                
                 <li>
                 	
                        <p class="number">4</p>
                        <p id="join_box_step4" class="graph_off"></p>
                        <p class="title">Review and pay</p>
                 </li>
            </ul>
        </div>
        
        <!--Step one-->
		<form method="post" action="" name="joinUsForm" id="joinUsForm" style="margin:0; padding:0;">
        <div class="join_box_content_outter" id="join_box_page">		</div>
		</form>
        <!-- End of Step one-->
        </div>
    </div>
    </div>
    
    
    
    
  <!--End of Content Area-->
    
  <!--Footer Area-->
  <div id="footer_container"><?php include 'footer.php'; ?></div>
  <!--End of Footer Area-->
</div>     
<!--End of Container-->

<script type="text/javascript">
nextStep("1");
</script>

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
