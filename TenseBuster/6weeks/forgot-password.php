<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Improve your grammar in 6 weeks | Forgot your password</title>
<link rel="stylesheet" type="text/css" href="css/home.css"/>
  <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
	<script>
      $(document).ready(function() {
            //POPUP: Forgot password 
            $("#btn-forgot-submit").click(function() {
                $("#box-forgot-front").fadeOut();			
                $("#box-forgot-back").show();
    
                });
                
            });
    </script>
</head>

<body id="popup">
	<div class="popup-small" id="box-forgot-front">
    	<div class="body-box">
        	<div class="box"><strong>Forgot your password?</strong><br />
            Please tell us your registered email address:<br />
             <input name="input" type="text" class="field popup" />
             
             <div class="msg-box">
             <img src="images/ico_fail.png" /> Error message here
             </div>

            </div>
      
            
         </div>
      <div class="button-box">
      	<a class="popup-button single" id="btn-forgot-submit">Submit</a>

      
      </div>
       
    </div>
    
    <div class="popup-small" id="box-forgot-back">
        <div class="body-box">
            <div class="box"><strong>Please check your email now!</strong></div>
            
     
            
         </div>
      <div class="button-box">
        <a class="popup-button single" onclick="parent.$.colorbox.close(); return false;">Close</a>

      
      </div>
       
    </div>
    
    
</body>
</html>
