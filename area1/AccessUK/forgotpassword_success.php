<?PHP 
$email = $_GET['email'];
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>The University of York | Clarity English | Access UK: A Student's Guide | Forgotten your password?</title>


<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/popup.css" />

</head>

<body id="popup_body">

<div id="popup_contatiner">
	<div id="popup_bannar"></div>
    <div id="popup_title">
    	<p class="forgot">Forgotten your password?</p>
  </div>
  <div id="popup_forgotmsg">
    

  
 <!-- <p>We will sent an email to you at <?//PHP echo $email;?> within one working day.</p>-->
  <p>Your password has now been sent to your email address: <?PHP echo $email;?>.</p>
  
  <p>If you don’t receive an email from us, please contact our Support Team at <a href="mailto:support@clarityenglish.com?subject=Access UK forgot password enquiry" target="_blank">support@clarityenglish.com</a></p>
    
		
    

    
  </div>
    <div id="popup_footer">
    
    	 <p>Data &copy; University of York, 2011. Software &copy; Clarity Language Consultants Ltd, 2011. <br />All rights reserved.</p>
    
    </div>


</div>
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
