<?PHP 
$email = $_GET['email'];
$message = $_GET['message'];
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English | It's Your Job | Forgotten your password?</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_popup.css" />

</head>

<body id="popup_body">

<div id="popup_contatiner">
	<div id="popup_bannar"></div>
    <div id="popup_rainbow">
    	
    	<p>Oops...</p>
    </div>
  <div id="popup_forgotmsg">
    

  
  <p>There seems to be something wrong with your email address, <?PHP echo $email; ?>.</p>
<p>Problem: <?PHP echo $message;?></p>
  <p>Please go <a href="forgotpassword.php">back</a> and type in your email again. </p>
        
  <p>If you need further assistance, please contact our Support Team at <a href="mailto:support@clarityenglish.com?subject=Its Your Job forgot password enquiry" target="_blank">support@clarityenglish.com</a></p>
    
		
    

    
  </div>
    <div id="popup_footer">
    
    	<p>Copyright &copy; 1993 -
    <script type="text/javascript">
		var d = new Date()
		document.write(d.getUTCFullYear())
	</script>
    Clarity Language Consultants Ltd. All rights reserved.</p>
    
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
