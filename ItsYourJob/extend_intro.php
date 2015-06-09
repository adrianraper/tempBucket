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
	<script type="text/javascript" src="script/dms_datepicker.js">

	/***********************************************
	* Jason's Date Input Calendar- By Jason Moon http://calendar.moonscript.com/dateinput.cfm
	* Script featured on and available at http://www.dynamicdrive.com
	* Keep this notice intact for use.
	***********************************************/

	</script>
	<!--General jquery library: For Fancy box, programs left menu-->
	<script type="text/javascript" src="script/jquery.js"></script>
	<script type="text/javascript" src="script/popup.js"></script>

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
						<h2>Sorry, your subscription has  expired.</h2>
			  <form method="post" action="" name="joinUsForm" id="joinUsForm" style="margin:0; padding:0;">
								<div class="join_box_content_inner">
    
        <div class="left_extend">

            <p class="bodytxt">To continue using It's Your Job, you can extend your subscription for 30 days at just US$14.95! Simply click Extend my subscription below..</p>
            <p class="title" style="margin:15px 0 0 0;">Extension price: Just US$14.95</p>
            
            <div class="im_notes_extend">
            <p class="header">Important:</p>
            <p class="text">HSBC Visa / MasterCard holders please use Internet Explorer (IE) to register.</p>
            
            <p class="clear"></p>
            </div>
            
      </div>
         
         <div class="right_extend">
         
            <p class="title">You will learn to:</p>
         	<ul>
      
                <li>write a winning cover letter</li>
                <li>put together the perfect resume</li>
                <li>answer difficult interview questions</li>
                <li>follow up effectively</li>
                <li>use technology to find the best job</li>
                <li>shine in psychometric tests</li>
                <li>and much more!</li>
              </ul>
         
         
         </div>
         
        
    </div>
							</form>

						<div class="btn_area">
							<div class="btn_extend_subscription"></div>
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