<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Level Test | Improve your grammar in 6 weeks</title>
    <link rel="icon" type="image/png" href="images/favicon.png" />
    <link rel="stylesheet" type="text/css" href="css/home.css"/>
    <link rel="stylesheet" type="text/css" href="css/colorbox.css"/>

    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <!--include jQuery Validation Plugin-->
    <script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.12.0/jquery.validate.min.js"></script>
    <script src="script/jquery.colorbox-min.js"></script>
    <script src="script/6weeks.js"></script>

</head>

<body id="subpage">

<div id="holder" class="level-test">




    <div id="header-box">
        <div id="header">
            <a href="index.php?prefix=<?php echo $_GET["prefix"];?>"><img src="images/banner-TB.jpg" alt="Improve your grammar in 6 weeks!" width="638" height="191" border="0"/></a>

      <div id="menu-box">

                <div class="menu level-test" id="menu-level-test">
                    <div class="arrow on"></div>
                    <div class="num">1</div>
                    <div class="step select">
                        <div class="icon"></div>
                        Level Test
                    </div>
                </div>


                <div class="menu register" id="menu-register">
                    <div class="arrow off"></div>
                    <div class="num">2</div>
                    <div class="step off">
                        <div class="icon"></div>
                        Register
                    </div>
                </div>


                <div class="menu results" id="menu-results">
                    <div class="arrow off"></div>
                    <div class="num">3</div>
                    <div class="step off">
                        <div class="icon"></div>
                        Result
                    </div>
                </div>
            </div>
        </div>
  </div>

    <div id="container">
        <div id="content">
            <div class="page" id="level-test">

                <div id="testPlaceholder" class="scrollable">
                
                
                
                        <div class="spinner">
                          <div class="spinner-container container1">
                            <div class="circle1"></div>
                            <div class="circle2"></div>
                            <div class="circle3"></div>
                            <div class="circle4"></div>
                          </div>
                          <div class="spinner-container container2">
                            <div class="circle1"></div>
                            <div class="circle2"></div>
                            <div class="circle3"></div>
                            <div class="circle4"></div>
                          </div>
                          <div class="spinner-container container3">
                            <div class="circle1"></div>
                            <div class="circle2"></div>
                            <div class="circle3"></div>
                            <div class="circle4"></div>
                          </div>
                          <div id="loadingText" class="txt">Loading questions<br />
                      
                          </div>
                        </div>  
                                  
                
              </div>
                <div id="codeHolder" style="display:none"></div>
                <div class="button-page-box">
                    <input type="button" class="button get-my-level" value="Get my level" id="btn-go-to-register" style="display:none;" />
                    
                </div>
                <div class="clear"></div>
            </div>
            
                   <!-- Zero question answered warning -->
                <div style="display:none">
                    <div id="inline-zero-warning">
                        <div class="popup-small">
                            <div class="body-box">
                                <div class="box"><strong>You haven't answered any of the questions.</strong><br>
                                	Please complete all the questions and click "Get my level". 
                                </div>
                            </div>
                            <div class="button-box">
                                <a class="popup-button single" onclick="$.colorbox.close(); return false;">Back to the test</a>
                               
                            </div>
                        </div>
                    </div>
                </div>
            

            <div class="page" id="register">

                <form id="loginForm">
                    <div class="line" >
                        <label for="userEmail">Enter your email address.</label><br/>
                        <input class="field" id="userEmail" name="userEmail" type="text"/>
                    </div>
                    <div class="line" >
                        <label for="userName">Enter your name (optional).</label><br/>
                        <input class="field" id="userName" name="userName" type="text"/>
                    </div>
                    <div class="line" >
                        <label for="password">Enter a password.</label><br/>
                        <input class="field" id="password" name="password" type="password"/>
						 
                    </div>
                    
                     
                    
                    <div class="line" >
                        <label for="confirmPassword">Re-enter your password.</label><br/>
                        <input class="field" id="confirmPassword" name="confirmPassword" type="password"/>
                    </div>

					<div class="button-box">
                        <input id="signIn" class="button signin left" value="Register" type="submit" />
                       <input id="loadingMsg" class="button loading left" value="Please wait" type="submit" style="margin:0 auto; display:none;"  />
                      <div class="line-forgot"><a class="forgot left" href="http://www.clarityenglish.com/support/forgotPassword.php" target="_blank">Forgot your password?</a></div>
                  	</div>

                    <div class="button-below-msg-box"   style="margin:15px 0 0 0;">
                       <span id="errorMessage"></span>
                    </div>
                </form>
                <div class="clear"></div>

                <!-- existing subscription warning -->
                <div style="display:none">
                    <div id="inline-level-reset">
                        <div class="popup-small">
                            <div class="body-box">
                                <div class="box"><strong>You are already subscribed to this title <Br />
                                
                                (<span id="ClarityLevelMessagePopUp"></span>, week <span id="weekMessage"></span>).</strong><br/>
                                    By changing your level, <Br/>your 6-week grammar course will start from week 1 again!
                                </div>
                            </div>
                            <div class="button-box">
                                <a class="popup-button left btn-go-to-results continue">YES, RESET my level.</a>
                                <a class="popup-button cancel" href="index.php?prefix=<?php echo $_GET["prefix"];?>">
                                
                             
                                NO,
                                    KEEP my level.</a>
                            </div>
                        </div>
                    </div>
                </div>


            </div>

            <div class="page" id="results">
                <div id="level-box">

                    <div class="level-head">Your level is:</div>
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
                    </div>
                </div>

                <div id="message-box">
                    <div class="title">Check your email now!</div>

                    <div class="txtbox">An email has been sent to <span id="sentEmail">you</span>.<br/> Check your email
                        and click to start learning.
                    </div>

                    <div class="txtbox">If you have not received an email from us in 5 minutes, please:<br/>
                        1. Check your spam folder.<br />
        2. If you still can't find the email, email <a href="mailto:support@clarityenglish.com?subject=Tense Buster grammar courses - No reminder emails">support@clarityenglish.com</a>.
                    </div>

                    <div class="button-page-box">
                        <a class="button general" href="index.php">Sign in</a>
                    </div>

                </div>
                <div class="clear"></div>
            </div>
            <div class="clear"></div>
        </div>
    </div>


</div>
<div class="clear"></div>


<div id="footerline">

    <div style="height: 45px; width:100%;" id="leveltest-complete-bar-box">
        <div id="leveltest-complete-bar"  style="display:none;">
            <div id="widthbox">
                <div class="title">Completed <span id="lcb-total-done">0 of 25</span> questions:</div>
                <div class="content">
                    <span id="lcb-1" class="num">1</span>
                    <span id="lcb-2" class="num">2</span>
                    <span id="lcb-3" class="num">3</span>
                    <span id="lcb-4" class="num">4</span>
                    <span id="lcb-5" class="num five">5</span>

                    <span id="lcb-6" class="num">6</span>
                    <span id="lcb-7" class="num">7</span>
                    <span id="lcb-8" class="num">8</span>
                    <span id="lcb-9" class="num">9</span>
                    <span id="lcb-10" class="num five">10</span>

                    <span id="lcb-11" class="num">11</span>
                    <span id="lcb-12" class="num">12</span>
                    <span id="lcb-13" class="num">13</span>
                    <span id="lcb-14" class="num">14</span>
                    <span id="lcb-15" class="num five">15</span>

                    <span id="lcb-16" class="num">16</span>
                    <span id="lcb-17" class="num">17</span>
                    <span id="lcb-18" class="num">18</span>
                    <span id="lcb-19" class="num">19</span>
                    <span id="lcb-20" class="num five">20</span>

                    <span id="lcb-21" class="num">21</span>
                    <span id="lcb-22" class="num">22</span>
                    <span id="lcb-23" class="num">23</span>
                    <span id="lcb-24" class="num">24</span>
                    <span id="lcb-25" class="num">25</span>

                </div>
            </div>


        </div>
    </div>


             
    <div class="clear"></div>

       		
            <div id="box-grey">
    		<div class="box">
           	  <a href="http://www.ClarityEnglish.com" target="_blank" id="website">www.ClarityEnglish.com</a>
       	<a href="http://www.ClarityEnglish.com" target="_blank"><img src="images/clarityenglish.jpg" border="0" /></a>
        </div>
    </div>
</div>


</body>
</html>
