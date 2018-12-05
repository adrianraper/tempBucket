<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Change my level | Improve your grammar in 6 weeks</title>
<link rel="icon" type="image/png" href="/images/favicon.ico" />
<link rel="stylesheet" type="text/css" href="css/home.css"/>
<link rel="stylesheet" type="text/css" href="css/colorbox.css"/>

    <script src="https://code.jquery.com/jquery-1.9.1.min.js"></script>
    <!--include jQuery Validation Plugin-->
    <script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.12.0/jquery.validate.min.js"></script>
    <script src="script/jquery.colorbox-min.js"></script>
    <script src="script/changeLevel.js"></script>
	<script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
    
      ga('create', 'UA-873320-17', 'auto');
      ga('send', 'pageview');
    
    </script>
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
                	My subscription
              </div>
            </div>
       
            
      
            </div>
	</div>
   </div>

	<div id="container">
       <div id="content">
       		<div class="page" id="level-change-one">

                <form id="loginForm">
                    <div class="title">Change my level in Tense Buster</div>
                    <div class="txt">(You can do this again at any time.)</div>
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
                        <input id="signIn" class="button go left" value="Go" type="submit" />
               
                        
                         <input id="loadingMsg" class="button loading left" value="Please wait" type="submit" style="margin:0 auto; display:none;"  />
                        
                        <a class="forgot left" href="https://www.clarityenglish.com/support/forgotPassword.php" target="_blank">Forgot your password?</a>
                    </div>

                    <div class="button-below-msg-box" style="margin:15px 0 0 0;">
                       <span id="errorMessage">xx</span>
                    </div>
                    <div class="clear"></div>
                </form>
            </div>

            <div class="page" id="level-change-two">
            	
                    <div id="level-box" class="change">

                        <div class="level-head">Your current level is:</div>
                        <div class="level-bg">
                            <div class="title" id="ClarityLevelMessage"></div>

                            <div class="icons">
                                <div class="box">
                                    <span id="iconELE"></span>
                                    <span id="iconLI"></span>
                                    <span id="iconINT"></span>
                                    <span id="iconUI"></span>
                                    <span id="iconADV"></span>
                                </div>
                            </div>
                            <div class="week" id="weekMessage"></div>
                        </div>
                    </div>

                
               	<div class="level-head">Choose your new level</div>
                
               <div class="radio-line"><input name="changelevel" type="radio" value="ELE" id="Ele" /> <label for="ELE">Elementary</label></div>
               <div class="radio-line"><input name="changelevel" type="radio" value="LI" id="LInt" /> <label for="LI">Lower Intermediate</label></div>
               <div class="radio-line"><input name="changelevel" type="radio" value="INT" id="Int" /> <label for="INT">Intermediate</label></div>
               <div class="radio-line"><input name="changelevel" type="radio" value="UI" id="UInt" /> <label for="UI">Upper Intermediate</label></div>
               <div class="radio-line"><input name="changelevel" type="radio" value="ADV" id="Adv" /> <label for="ADV">Advanced</label></div>
               <div class="radio-line"><a href="/support/user/pdf/tb/TenseBusterV10_Syllabus_6week.pdf" target="_blank" class="dl-link">Download the syllabus for each level (PDF, 321KB)</a></div>

               <div class="button-page-box">
                   <input id="confirm" class="button general" value="Confirm" type="button" />

               <div class="button-below-msg-box">
                    	<img src="images/ico_fail.png" /> Error message here
                    </div>
               
                 
               
               <div class="remarks"><strong>Warning:</strong> By changing your level, your 6-week grammar course will start from week 1 again.</div>
               <div class="clear"></div>



             </div>
             </div>

            <div class="page" id="level-change-three">
            
                
                <div id="message-box">
                	<div class="title">Check your email now!</div>
                    
                    <div class="txtbox">An email has been sent to <span id="sentEmail">you</span>.<br /> Check your email and click to start learning.</div>
                    
                     <div class="txtbox">If you have not received an email from us in 5 minutes, please:<br/>
                        1. Check your spam folder.<br />
        2. If you still can't find the email, email <a href="mailto:support@clarityenglish.com?subject=Tense Buster grammar courses - No reminder emails">support@clarityenglish.com</a>.
                    </div>
                     
                     <div class="button-page-box">
                     	 <a class="button register" href="index.php">Back to home and Log in</a>
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
           	  <a href="https://www.ClarityEnglish.com" target="_blank" id="website">www.ClarityEnglish.com</a>
       	<a href="https://www.ClarityEnglish.com" target="_blank"><img src="images/clarityenglish.jpg" border="0" /></a>           </div>
    </div>


        



</body>
</html>
