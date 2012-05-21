<?php
	session_start();
	include_once "variables.php";
	if(!isset($_SESSION['CLS_userID'])) {
		//session variable is not registered, go back to the main page
		header("location: index.php");
		exit;
	}
	
	// Do any manipulation of session variables for display
	if (isset($_SESSION['CLS_productCode'])) {
		switch ($_SESSION['CLS_productCode']) {
			case 52:
				$productLetters = 'AC';
				$productName = 'Academic';
				break;
			case 53:
				$productLetters = 'GT';
				$productName = 'General Training';
				break;
			default:
				$_SESSION['CLS_message'] = 'Unknown product code - please contact support@clarityenglish.com';
				header("location: index.php");
				exit(0);
		}
	} else {
		$_SESSION['CLS_message'] = 'Unknown product code - please contact support@clarityenglish.com';
		header("location: index.php");
		exit(0);
	}
	
	$expiryDate = strftime('%d %B %Y',strtotime($_SESSION['CLS_expiryDate']));
	
	// Set session variables that the start page will use
	$_SESSION['Email'] = $_SESSION['CLS_email'];
	$_SESSION['Password'] = $_SESSION['CLS_password'];
	$_SESSION['Prefix'] = $_SESSION['CLS_prefix'];
	$prefix = $_SESSION['CLS_prefix'];
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
<title>Road to IELTS: IELTS preparation and practice | Home</title>

<link rel="stylesheet" type="text/css" href="css/home.css" />

<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="css/jquery.fancybox-1.3.4.css" />

<!--Jquery Library-->
<script type="text/javascript" src="script/jquery-1.4.3.min.js"></script>
<script type="text/javascript" src="script/jquery.fancybox-1.3.4.pack.js"></script>
<script type="text/javascript" src="script/jquery.fancybox.custom.js"></script>
<script type="text/javascript" src="script/controlLogin.js"></script>
<script type="text/javascript" src="script/common.js"></script>

<!--Google Tracking-->
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

<body id="account_page">

      	<div id="header_outter">
        	    <?php include ( 'header.php' ); ?> 
        
        </div>
        	<div id="container_outter">
        <div id="container">
            
            
            <div id="content_box_account">
            	<div id="account_title">Welcome back, <?php echo $_SESSION['CLS_name']; ?>!</div>
            
            	<div id="account_left">
                	<div id="account_start_course"><a href="<?php echo $thisDomain?>area1/RoadToIELTS2/Start-<?php echo $productLetters?>.php?prefix=<?php echo $prefix?>" target="_blank"></a></div>
                </div>
                
                <div id="account_right">
                	<div id="edit_details_box">
                         <div class="field_line">
                             <div class="title_box">Member name:</div>
                             <div class="fill_box"><?php echo $_SESSION['CLS_name']; ?></div>
                             <div class="clear"></div>
                        </div>
                
                        <div class="field_line">
                              <div class="title_box">Email:</div>
                              <div class="fill_box"><?php echo $_SESSION['CLS_email']; ?></div>
                              <div class="clear"></div>
         
                        </div>
                    
                        <div class="field_line">
                              <div class="title_box">Expiry date:</div>
                              <div class="fill_box">
                              	<div class="date"><?php echo $expiryDate; ?></div>
                                <div class="btn_renew" style="display:none">Renew</div>
                               </div>
                              <div class="clear"></div>
         
                        </div>
                    
                        <div class="field_line">
                              <div class="title_box">Module:</div>
                              <div class="fill_box">
                                <div class="module"><?php echo $productName; ?> </div>
                              
                              </div>
                              <div class="clear"></div>
         
                        </div>
            
                    <div class="field_line" style="display:none">
                        <div class="title_box">Original password:</div>
                        <div class="fill_box"><input  name="changePwdOriginal" id="changePwdOriginal" type="text" class="edit_field"/></div>
						<div class="clear"></div>
      					<p class="edit_error">Error message</p>
                  
                    
                    </div>
            	
                <div class="field_line" style="display:none">
                	<div class="title_box">New password:</div>
                    <div class="fill_box"><input name="changePwdNew" id="changePwdNew"  type="text" class="edit_field"/></div>
					<div class="clear"></div>
                    <p class="edit_error">Error message</p>
				</div>
                
                <div class="field_line" style="display:none">
                	<div class="title_box">Confirm password:</div>
                  <div class="fill_box"><input name="changePwdRetype" id="changePwdRetype" type="text" class="edit_field"/></div>
                  <div class="clear"></div>
                  <p class="edit_error">Error message</p>
           
                </div>
              
                </div>
                
                
                <div class="buy_button_area" style="display:none">
                                        <div class="btn_blue_small">Save Changes</div>
                                       
                                    
                                        <div id="edit_button_comment">
                                            <div class="form_waiting" name="RTIMsgWait" id="RTIMsgWait" style="display:none">Please wait...</div>
                                            <div class="form_oops" name="RTIMsgError" id="RTIMsgError" style="display:none">Please fill in the required fields</div>
                                         </div>
                                        <div class="clear"></div>
                                    </div>
                
                
                </div>
 

               
                
        
                   <div class="clear"></div>
            </div>
            
        
        
      </div>
        <div id="footer">
        Data &copy; The British Council 2006 - 2012. Software &copy; Clarity Language Consultants Ltd, 2012. All rights reserved.
        </div>
    </div>


</body>
</html>
