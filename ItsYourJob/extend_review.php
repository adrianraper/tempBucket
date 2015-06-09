<?php
	session_start();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Clarity English | It's Your Job |Terms and conditions</title>

	<!--CSS General-->
	<link rel="stylesheet" type="text/css" href="css/job_general.css" />
	<link rel="stylesheet" type="text/css" href="css/job_joinus.css" />
    
    <!--CSS Fancy pop up box-->
	<link rel="stylesheet" type="text/css" href="css/fancybox.css" />
    
	<script type="text/javascript" src="script/dms_datepicker.js">

	/***********************************************
	* Jason's Date Input Calendar- By Jason Moon http://calendar.moonscript.com/dateinput.cfm
	* Script featured on and available at http://www.dynamicdrive.com
	* Keep this notice intact for use.
	***********************************************/

	</script>
	<!--General jquery library: For Fancy box, programs left menu-->
	<script type="text/javascript" src="script/jquery.js"></script>
        
    <!--Fancy Popup Box-->
    <script type="text/javascript" src="script/fancybox.js"></script>
    <script type="text/javascript">
    $(document).ready(function() { 
		/* Demo verison popup frame */ 
		$("a.extendIM_iframe").fancybox({ 
			'centerOnScroll':false,
			'frameWidth':672,
			'frameHeight':478
		});
		}); 
  	</script>

	<!-- Use in registration -->
	<script type="text/javascript" src="script/dateFormat.js"></script>
	<script type="text/javascript" src="script/ext_validation.js"></script>
</head>

<body>
	<!--container-->
	<div id="container">
		<!--header area-->
              <div id="header_container"><?php include 'header.php'; ?></div>
        <!--End of header area-->

		<!--Content Area-->
		<div id="content_container">
			<h1 class="general_heading">Extend your subscription</h1>
			<div id="general_box_outter">
				<div id="general_box">
					<div class="join_box_content">
						<h2>Review and Pay</h2>
							<form method="post" action="" name="joinUsForm" id="joinUsForm" style="margin:0; padding:0;">
								<div class="join_box_content_inner">
    
    <div class="join4_left">
    
    <ul class="fielding_step4">
    
    	<li class="Subheader_print">What you are about to buy:</li>
    
      <li>
            <p class="field_title">Subscription period : </p>
            <p class="field_line"> From <label id="IYJreg_startDate" name="IYJreg_startDate"></label>&nbsp;to&nbsp;<label id="IYJreg_expiryDate" name="IYJreg_expiryDate"></label>



</p>
            <span class="clear"></span>    
    	</li>
        
   
        <li>
            <p class="field_title">Your user name :</p>
            <p class="field_line"><label id="IYJreg_uFullName_review" name="IYJreg_uFullName_review"></Label></p>
            <span class="clear"></span>    </li>
    
        <li>
            <p class="field_title">Your email :</p>
            <p class="field_line"><label id="IYJreg_uEmail_review" name="IYJreg_uEmail_review"></Label></p>
            <span class="clear"></span>    </li>
    
        <li>
            <p class="field_title">Your country :</p>
            <p class="field_line"><label id="IYJreg_uCountry_review" name="IYJreg_uCountry_review"></Label></p>
            <span class="clear"></span>    </li>
    
        <!--<li>
            <p class="field_title">Delivery frequency:</p>
            <p class="field_line"><label id="IYJreg_dFreq_review" name="IYJreg_dFreq_review"></Label></p>
            <span class="clear"></span>    </li>-->
    
        <!--<li>
            <p class="field_title">Contact method:</p>
            <p class="field_line"><label id="IYJreg_contact_review" name="IYJreg_contact_review"></Label></p>
            <span class="clear"></span>    </li>-->
    
        <li>
            <p class="field_title">Program version :</p>
            <p class="field_line"><label id="IYJreg_language_review" name="IYJreg_language_review"></Label></p>
            <span class="clear"></span></li>
        
        <li>
            <p class="price_title">Total amount :</p>
            <p class="price_line">Just US$14.95 for 1 month's unlimited access</p>
            <span class="clear"></span>
        </li>
        
   		<li><a onclick="window.open('print.htm','mywindow','width=625,height=425'); return false;" href="#" class="print_line"> Preview and print</a></li>
          
       
    
    </ul>
    
    
 
    
    </div>
    
     <div class="join4_buybtn_area">
     	<div class="btn_important"><a href="joinus_beforebuy.htm" class="extendIM_iframe"></a></div>
	</div>
    
    
    <div class="join4_right">
    
    <h2>We accept:</h2>
    <div class="img_card"></div>
    
    Online transaction processing is provided by PayDollar using Extended Validation 256-bit SSL encryption. All confidential information is encrypted before it is transmitted, to protect the data from being read and interpreted. 3-D Secure authentication is also supported:<br />
  
     <div class="img_secure"></div>
     
     Gateway powered by:<br />
     <img src="images/pay_dollar_small.jpg"  style="margin:5px 0 0 0"/>    </div>
    
    </div>
							</form>

<div class="btn_area">
  <div class="btn_back"></div>
  
  <div class="btn_buy_now"></div>
  <div class="btn_cancel"><a href="index.php"></a></div>
</div>
					</div>
				</div>
			</div>
		</div>
		<!--End of Content Area-->

		<!--Footer area-->
            <div id="footer_container" style="position:relative;">
               
              <?php include 'footer.php'; ?>
            </div>
          <!--End of Footer area-->

	</div>     
	<!--End of Container-->

	<script type="text/javascript">
		setLabelText("IYJreg_startDate",startDate);
		setLabelText("IYJreg_expiryDate",expiryDate);
	</script>

	<script type="text/javascript">
		var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
		document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
	</script>

	<script type="text/javascript">
		try {
			var pageTracker = _gat._getTracker("UA-873320-5");
			pageTracker._trackPageview();
		} catch(err) {}</script>

</body>
</html>