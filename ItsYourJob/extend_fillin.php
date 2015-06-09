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
						<h2>Fill in your details</h2>
							<form method="post" action="" name="joinUsForm" id="joinUsForm" style="margin:0; padding:0;">
								<div class="join_box_content_inner">
									<p>Please complete all fields using the standard English alphabet.</p>

									<ul class="fielding">
										<li style="height:25px">
										<strong>
											<p class="field_title">Extension price :</p>
											<p class="field_line">Just US$14.95 for 1 month's unlimited access</p>
										  </strong>
										</li>
										<li style="height:25px">
											<p class="field_title">Subscription period : </p>
											<p class="field_line">From <label id="IYJreg_startDate" name="IYJreg_startDate"></label>&nbsp;to&nbsp;<label id="IYJreg_expiryDate" name="IYJreg_expiryDate"></label></p>
										</li>
										<li>
											<p class="field_title">User email address :</p>
											<p class="field_line">
											<input name="IYJreg_uEmail" type="text" class="field" id="IYJreg_uEmail" tabindex="1" onblur="checkEmail()" />
											</p>
										</li>
										<li>
											<p class="field_msg_line">(Your original login name.)</p>
										</li>
										<li><p class="field_warn_line"><label id="IYJreg_uEmailNote" name="IYJreg_uEmailNote"></label></p></li>
										<li>
											<p class="field_title">Password : </p>
											<p class="field_line">
											<input type="password" name="IYJreg_uPassword" id="IYJreg_uPassword" tabindex="2" class="field" onblur="checkPassword()" />
											</p>
										</li>
										<li><p class="field_msg_line">(Your original password.)</p></li>
										<li><p class="field_warn_line"><label id="IYJreg_uPasswordNote" name="IYJreg_uPasswordNote"></label></p></li>
									</ul>

							

									
							  </div>
							</form>

						<div class="btn_area">
							<div class="btn_save_submit" tabindex="5" onclick="javascript:checkRegData();"></div>
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