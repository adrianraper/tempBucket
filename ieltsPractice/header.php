<?php 

// BUG: I think this is called in every page that uses header.php
//session_start(  );
//date_default_timezone_set('UTC');

function showDate($ts) {
	return date("j M Y",strtotime($ts));
}
?>
<link rel="stylesheet" type="text/css" href="css/home.css" />

				<?php if(!isset($_SESSION['CLS_userID'])) { ?>
                <div id="login_panel">
                
                
                    <div id="login_panel_area">
                        
                      <div id="login_panel_area_left">
                            <h1>Welcome to IELTSpractice.com</h1>
                          <p>Please log in to prepare for your IELTS
                test. If you have not subscribed, click on <a href="buy.php">Buy now</a>.</p>
                        
                      </div>
                
                        <div id="login_panel_area_right">
                  
                                <div class="login_area">
                                <h1>Member login</h1>
                                
                                <div class="login_field_line_outter">
                                                
                                    <div class="login_field_line">
                                        <div class="title">Email:</div>
                                        <input name="RTILogin" id="RTILogin" type="text" class="field" />
                                     </div>
                                    <div class="login_field_line">
                                        <div class="title">Password:</div>
                                        <input name="RTIPassword" id="RTIPassword" type="password" class="field" />
                                    
                                    </div>
                                
                                </div>
                                
                                <div class="login_field_button_outter">
                                    <input name="" type="button" class="login_btn_inner" value="" onclick="javascript:checkLogin();"/> 
                                </div>
                                
                                <div class="login_msg"><a class="forgot_msg" href="/members/forgotpassword.php">Forgot password?</a></div>
                            
                            </div>
                            
                            <div class="error_area">
                                <h1 name="CLSLoginMsgTitle" id="CLSLoginMsgTitle">Status...</h1>
                                <div class="error_msg"><label id="RTILoginMsg"></label></div>
                            </div>
                        </div>
                   
                        <div style="clear:both"></div>
                        
                    </div>
                
                    
                    <!-- you can put content here -->
                </div>
				<?php } else {?>

                <div id="logout_panel">
                    <div id="logout_panel_area">
                             <p class="welcome">Welcome <?php echo $_SESSION['CLS_name'] ?></p>
                             <p class="logout"><a href="db_logout.php">Log out</a></p>
                             <div class="clear"></div>
                     </div>
                </div>
				<?php }?>
                
                
                <div id="header">

                    <div id="button_area">
                        <div class="btn_yellow" id="choose_buy"><a href="buy.php">Buy now</a></div>
						<?php if(!isset($_SESSION['CLS_userID'])) { ?>
                        <a class="btn_grey" id="choose_login" href="#" target="_blank"><span>Log in</span></a>
						<?php } else { ?>
						<a class="btn_grey" id="choose_login" href="myaccount.php"><span>My Account</span></a>
						<?php } ?>
                        <a class="btn_grey" id="choose_contact" href="contactus.htm" target="_blank"><span>Contact us</span></a>
                        <a class="btn_grey" id="choose_about" href="aboutus.php"><span>About us</span></a>
                        <a class="btn_grey" id="choose_why"  href="whychoose.php"><span>Why Road to IELTS?</span></a>
                        <a class="btn_grey" id="choose_home" href="index.php"><span>Home</span></a>
                        
                        <div class="clear"></div>
                   
                    </div>
                
                    <div id="logo_area">     
                        <div class="logo_clarity"><a href="http://www.clarityenglish.com" target="_blank"></a></div>
                        <div class="logo_bc"><a href="http://www.britishcouncil.org/hongkong.htm" target="_blank"></a></div>
                        <div class="clear"></div>
                    </div>
                </div>
                
      
