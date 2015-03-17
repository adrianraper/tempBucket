<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Unsubscribe | Improve your grammar in 6 weeks</title>
<link rel="icon" type="image/png" href="images/favicon.png" />
<link rel="stylesheet" type="text/css" href="css/home.css"/>
<link rel="stylesheet" type="text/css" href="css/colorbox.css"/>

    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <!--include jQuery Validation Plugin-->
    <script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.12.0/jquery.validate.min.js"></script>
    <script src="script/jquery.colorbox-min.js"></script>
    <script src="script/unsubscribe.js"></script>

</head>

<body id="subpage">
	
 <div id="holder">

    
    <div id="header-box">
	<div id="header">
    	<a href="index.php?prefix=<?php echo $_GET["prefix"];?>"><img src="images/banner-TB.jpg" alt="Improve your grammar in 6 weeks!" width="638" height="191" border="0"/></a>
<div id="menu-box">
        
            <div class="menu general">
            	<div class="arrow on"></div>            	
                <div class="title">
                	Unsubscribe
              </div>
            </div>
       
            
      
            </div>
	</div>
   </div>

	<div id="container">
       <div id="content">
           <div class="page" id="unsubscribe-one">

               <form id="loginForm">
                   <div class="title">Unsubscribe from Tense Buster grammar course:</div>
                   <div class="txt">(You can subscribe again at any time.)</div>
                   <div class="box-details" style="width:350px">
                       <div class="col top" >
                           <label for="userEmail" class="name">Email</label><br/>
                           <input class="field" id="userEmail" name="userEmail" type="text"/>
                       </div>
                       <div class="col bottom">
                           <label for="password" class="name">Password</label><br />
                           <input class="field" id="password" name="password" type="password"/>
                       </div>

                      
                   </div>

                   <div id="login-single-button-area">
                       <input id="signIn" class="button go" value="Go" type="submit" />
                      <input id="loadingMsg" class="button loading left" value="Please wait" type="submit" style="margin:0 auto; display:none;"  />
                       <a class="forgot left" href="http://www.clarityenglish.com/support/forgotPassword.php" target="_blank">Forgot your password?</a>
                   </div>

                   <div class="button-below-msg-box" style="margin:15px 0 0 0;">
                       <span id="errorMessage"></span>
                   </div>
                   <div class="clear"></div>
                   <div class="remarks"><strong>Note:</strong> This will unsubscribe you from Tense Buster grammar course only.</div>
               </form>
           </div>

           <div class="page" id="unsubscribe-two">


               <div id="message-box">
                   <div class="title">Unsubscribe completed!</div>
                   <div class="txtbox">Your account is no longer available.</div>

                   <div class="button-page-box">
                       <a class="button back-to-home" href="index.php">Back to home</a>
                   </div>

               </div>

               <div class="clear"></div>
           </div>

       </div>
    </div>
	

 </div>
        <div class="clear"></div>
       <div id="footerline" class="bg-grey">
    		<div class="box">
           	  <a href="http://www.ClarityEnglish.com" target="_blank" id="website">www.ClarityEnglish.com</a>
       	<a href="http://www.ClarityEnglish.com" target="_blank"><img src="images/clarityenglish.jpg" border="0" /></a>           </div>
    </div>


        



</body>
</html>
