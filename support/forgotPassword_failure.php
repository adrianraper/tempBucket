<?php
$email = $productCode = $rootID = $loginOption = $template = $error = $message = '';

if (isset($_GET['email']))
	$email = $_GET['email'];
if (isset($_GET['message']))
	$message = $_GET['message'];
if (isset($_GET['productCode']))
	$productCode = $_GET['productCode'];

// What is specific for this product?
switch ($productCode) {
    case 52:
    case 53:
        $cssClass = 'rti';
        $cssTheme = 'grey';
        $template = 'ieltspractice_forgot_password';
        break;
    case 54:
        $cssClass = 'ccb';
        $cssTheme = 'grey';
        $template = 'ccb_forgot_password';
        break;
    case 55:
    case 59:
        $cssClass = 'tb';
        $cssTheme = 'grey';
        $template = 'tb_forgot_password';
        break;
    case 56:
        $cssClass = 'ar';
        $cssTheme = 'grey';
        $template = 'ar_forgot_password';
        break;
    case 57:
        $cssClass = 'cp1';
        $cssTheme = 'grey';
        $template = 'cp1_forgot_password';
        break;
    default:
        $cssClass = 'general';
        $cssTheme = 'grey';
        $template = 'forgot_password';
        break;
}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Forgot your password?</title>
<!--CSS General-->
<link rel="stylesheet" type="text/css" href="../css/forgotpw.css" />
</head>
<body id="<?php echo $cssClass;?>" class="grey">
<div id="container_position">

	<div id="container">

            <div id="bigbox">
            	<div id="clearbox_center">
                    <div id="clearbox">
                    	<div id="top"></div>
                        <div id="mid">
                
                            <div id="left">
                            	 <h1>Oops...</h1>
                            </div>
                        
                            <div id="right">
                            
                              <p class="para">There seems to be something wrong with your email address, <?php echo $email; ?>.</p>
                              <p class="para">Problem: <?php echo $message;?></p>
                              <p class="para">Please go <a href="forgotPassword.php?email=<?php echo $email; ?>&productCode=<?php echo $productCode; ?>">back</a> and type in your email again.</p>
                                        
                                 
                        
                            </div>
                
                            
                            <div class="clear"></div>
                        </div>
                        
                        <div id="btm"></div>
                    </div>
                    
                    <div id="supportline">
                  For help, please contact the Clarity support team at <a href="mailto:support@clarityenglish.com?subject=forgot password enquiry">support@clarityenglish.com</a>.                 </div>
                </div>
            
            </div>
   </div> 
   
   <div id="footerbox">
    	<div id="programicon"></div>
        <div id="logoline"><div id="logobox"></div></div>
    </div>     


  

    
		
    


    


</div>

	

</body>
</html>
