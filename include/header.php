<?php
// 2013 Mar 5 Vivying added for catching the undefine variable in header.php
// Updated AR 6 June 2016
 if (!isset($miniSelection)) $miniSelection = "";
 if (!isset($currentSelection)) $currentSelection = "";
 if (!isset($current_subsite)) $current_subsite = "";
 if (!isset($userTypeName)) $userTypeName = "";
?>   
<link href='http://fonts.googleapis.com/css?family=Roboto:400,300,500,700' rel='stylesheet' type='text/css'>
<script src="/script/modernizr.custom.63321.js"></script>
<script>
$(function(){
	$("#menu_program .button").hover(function(){
   	 $(this).parent().find('.select').removeClass("other-hover").addClass("other-hover"); 
	 
    });
	
	$("#menu_program #box").mouseleave(function(e)
    {
    $(this).find('.select').removeClass("select other-hover").addClass("select");
    });
});

$(function(){
  $('#lava li').hover(function(){
    $(this).find('div[id^="container-"]').stop().show();
	$(this).addClass("selected");
  },
  function(){
    $(this).find('div[id^="container-"]').stop().hide();
	$(this).removeClass("selected");
  });
});
</script>
<div id="header_login_box">
  <div id="menu_main_blue">
  
       <!--- no log in yet ---> 
            <?php if (!isset($_SESSION['UserName'])) { ?>   
     		<div class="width-auto" id="header_top">
            
            
<div class="top_button">
                        <div class="link right"><a href="/englishonline/login.php" <?php if ($miniSelection =="login"){echo 'class="selected"'; }?>>Sign in</a></div>
                        <div class="link"><a href="/contactus.php" <?php if ($miniSelection =="contact"){echo 'class="selected"'; }?>>Contact us</a></div>
                        <div class="link"><a href="/program/demo.php" <?php if ($miniSelection =="demo"){echo 'class="selected"'; }?>>Try a FREE demo</a></div>
                         <div class="link"><a href="/catalogue.php" target="_blank">Download catalogue</a></div>
                        
              </div>
    	

                <div id="logo-clarityenglish"><a href="/"><img src="/images/logo-clarityenglish.jpg" /></a><span id="since">Since 1992</span></div>
                <a href="/prices.php<?php echo $referralurl;?>" target="_blank" id="price-enquiry">Price enquiry</a>
                
                        <div class="clear"></div>
              
    </div>

      
           
  <div id="menu_btm">
  	
       	<div class="width-full">
    
         
                <div class="width-auto">
                 
                <div class="sub_cat"><a href="/"  class="select">Education</a></div>
                  <div class="sub_cat"><a href="/lib/program/">Library</a></div>
              
            </div>
     </div>
 </div>
<!--- after log in  ---> 			
			<?php }			
			else{ ?>                    
				<!--- in the programs session  ---> 
				<?php   if($current_subsite == "englishonline") { ?> 
    <div class="width-auto" id="header_top_login">
    	
		  <div class="top_button">
    
          <div class="link space right"><a href="/db_logout.php">Log out</a></div>
      	  <div class="link space"><a href="/contactus.php">Contact us</a></div>
           <?php if ($userTypeName <> "Student"){ ?><div class="link space"><a href="/resources/">FREE teacher resources</a></div><?php } ?>
      </div>
                <div id="logo-clarityenglish"><a href="/"><img src="/images/logo-clarityenglish.jpg" /></a><span id="since">Since 1992</span></div>
                <div id="mini-login-button-area">
                    	<div class="welcome_bar"><div id="<?php echo $_SESSION['UserIcon'] ; ?>">Welcome <?php if (!isset($_SESSION['Shared'])) {echo " " . $_SESSION['UserName'] . " (" . $_SESSION['UserTypeName'] . ")";} else {echo  $_SESSION['AccountName'];} ?>.</div></div>
                        <div id="ceonline-buttons-box">
                       	 	<div id="get-the-catalogue-now-mini"><a href="/catalogue.php"><img src="/images/get-the-catalogue-now-mini.jpg" /></a></div>
                         	<div id="ceonline-buttons">
                            	<a href="/englishonline/" class="button <?php if ($eoSelection =="programs"){echo 'select'; }?>">My programs</a>
                                <a href="/englishonline/settings.php" class="button <?php if ($eoSelection =="settings"){echo 'select'; }?>">My settings</a>
                                <a href="/support/" class="button <?php if ($eoSelection =="support"){echo 'select'; }?>">Support</a>                            </div>
                            <div class="clear"></div>
                         </div>
                    </div>
  
    </div>
    
            <div class="clear"></div>
		
    
        	
							
			  <?php }			
				else{ ?> 				
			<!--- logged in but outside the program session, do not print the 'how to buy' and request price buttons and the menu_btm_box  ---> 			
				 
                  <div class="width-auto" id="header_top">
    				
                    <div class="top_button">
    
          <div class="link space right"><a href="/db_logout.php">Log out</a></div>
      	  <div class="link space"><a href="/contactus.php">Contact us</a></div>

           
           <?php if ($userTypeName <> "Student"){ ?><div class="link space"><a href="/program/demo.php">Try a FREE demo</a></div><?php } ?>
      </div>
                   <div id="logo-clarityenglish"><a href="/"><img src="/images/logo-clarityenglish.jpg" /></a><span id="since">Since 1992</span></div>
             
             		<div id="mini-login-button-area">
                    	<div class="welcome_bar"><div id="<?php echo $_SESSION['UserIcon'] ; ?>">Welcome <?php if (!isset($_SESSION['Shared'])) {echo " " . $_SESSION['UserName'] . " (" . $_SESSION['UserTypeName'] . ")";} else {echo  $_SESSION['AccountName'];} ?>.</div></div>
                        <div id="ceonline-buttons-box">
                       	 	<div id="get-the-catalogue-now-mini"><a href="/catalogue.php"><img src="/images/get-the-catalogue-now-mini.jpg" /></a></div>
                         	<div id="ceonline-buttons">
                            	<a href="/englishonline/" class="button <?php if ($eoSelection =="programs"){echo 'select'; }?>">My programs</a>
                                <a href="/englishonline/settings.php" class="button  <?php if ($eoSelection =="settings"){echo 'select'; }?>">My settings</a>
                                <a href="/support/" class="button <?php if ($eoSelection =="support"){echo 'select'; }?>">Support</a>                            </div>
                            <div class="clear"></div>
                         </div>
                    </div>
                   
    </div>
                         <div class="clear"></div>
                            
                          <div class="width-full">
          <div id="menu_btm">
            <div class="width-auto">
            <div class="sub_cat"><a href="/"  class="select">Education</a></div>
              <div class="sub_cat"><a href="/lib/program/">Library</a></div>
              </div>
    		</div>
    </div>

			
			
        	<?php } ?>
		<?php } ?> 
 
	            
         
  </div>
    
<div class="clear"></div>
	
    <div class="width-full">
        <div id="menu_btm_box">        
            
         <div class="width-auto">
                 <div id="lava">
            
                
                    <ul id="academic">
                        <li <?php if ($currentSelection =="programs"){echo 'class="current"'; }?>><a href="/program/" class="menu-link">Programs</a>
                    
                            <div id="container-1">
                               	<table border="0" cellspacing="0" cellpadding="0">
                                      <tr valign="top" align="left">
                                        <td class="col border">
                                            	<div class="title">Clarity Suite</div>
                                            <div class="subtitle">General English</div>
                                            <a class="m-link" href="/program/tensebuster.php">Tense Buster</a>
                                            <a class="m-link" href="/program/activereading.php">Active Reading</a>
                                            <a class="m-link" href="/program/practicalwriting.php">Practical Writing</a>
                                            <a class="m-link" href="/program/clarityenglishsuccess.php">Clarity English Success</a>
                                                
                                            <div class="subtitle">EAP / Exam practice</div>
                                            <a class="m-link" href="/program/roadtoielts.php">Road to IELTS</a>
                                            <a class="m-link" href="/program/studyskills.php">Study Skills Success V9</a>
                                            <a class="m-link" href="/program/accessuk.php">Access UK</a>
                                                
                                            <div class="subtitle">Pronunciation</div>
                                            <a class="m-link" href="/program/clearpronunciation1.php">Clear Pronunciation 1 (Sounds)</a>
                                            <a class="m-link" href="/program/clearpronunciation2.php">Clear Pronunciation 2 (Speech)</a>
                                                
                                            <div class="subtitle">Business / Career</div>
                                            <a class="m-link" href="/program/englishforhotelstaff.php">English for Hotel Staff</a>
                                           
                                            <a class="m-link" href="/program/businesswriting.php">Business Writing</a>
                                            <a class="m-link" href="/program/itsyourjob.php">It's Your Job</a>
                                                
                                            <div class="subtitle">Teacher's tools</div>
                                            <a class="m-link" href="/program/authorplus.php">Author Plus</a>
                                            <a class="m-link" href="/program/claritycoursebuilder.php">Clarity Course Builder</a>
                                            <a class="m-link" href="/program/resultsmanager.php">Results Manager</a>
                                          	<a class="link-button" href="/program/" style="margin-top:10px;">+ Show all Clarity programs</a>
                                         </td>
                                         <td class="col dark">
                                       	   <div class="title" style="margin-bottom:10px;">Other programs</div>
                                            <a class="m-link" href="/program/others.php#ConnectedSpeech" id="link-CS">Connected Speech</a>
                                            <a class="m-link" href="/program/others.php#IssuesinEnglish2" id="link-Issues2">Issues in English 2</a>
                                            
                                           
                                            <a class="m-link" href="/program/others.php#SpellingFusion" id="link-Spelling">Spelling Fusion</a>
                                            <a class="m-link" href="/program/others.php#TalkNow" id="link-TalkNow">Talk Now</a>
                                           
                                            <a class="link-button" href="/program/others.php" style="margin-top:10px;">+ Show all other programs</a>
                                            <hr class="dotted" />
                                            
                                            <a class="link-guide" href="/catalogue.php">
                                           	<span class="get">Get</span>
                                            <span class="the">the</span>
                                            <span class="catalogue">Catalogue</span>
                                            <span class="now">now!</span>                                            </a>
                                           <hr class="dotted" />
                                           <a class="level-scale" href="/program/cef.php">English level scale
                                           <span>IELTS overall band scores, TOEFL IBT score & CEF level scale that correspond with the Clarity programs.</span>                                               </a>
                                           <hr class="dotted" />
                                           <a class="pro-action free-demo" href="/program/demo.php">Try the<Br />FREE<br />Demo</a>
                                           <a class="pro-action free-trial"  href="mailto:sales@clarityenglish.com?subject=Request FREE Trial">Request<br />FREE<br />Trial</a>
                                           <a class="pro-action price" href="/prices.php">Price<br />
                                           Enquiry</a>
                                          </td>
                                      </tr>
                               </table>

                                
                                    
                                  
                               
                             </div>
                             
                        </li>
                      
                        
                        <li <?php if ($currentSelection =="resources"){echo 'class="current"'; }?>><a href="/resources/" class="menu-link">Free teacher resources</a>
                        
                        <div id="container-2">
                        		
                                	
                                    <table border="0" cellspacing="0" cellpadding="0">
                                      <tr valign="top" align="left">
                                        <td class="col  border"  style="width:260px;">
                                        
                                        <div class="title margin">Support materials <a class="link-button learn-more" href="/resources/">Learn more</a></div>
                                        	
                                	<a class="m-link"  href="/resources/?program=ActiveReading">Active Reading</a>
                                    <a class="m-link"  href="/resources/?program=BusinessWriting">Business Writing</a>
                                    <a class="m-link"  href="/resources/?program=ClarityCourseBuilder">Clarity Course Builder</a>
                                    <a class="m-link"  href="/resources/?program=ClearPronunciation">Clear Pronunciation 1 &amp; 2</a>
                                
                                    <a class="m-link"  href="/resources/?program=EnglishforHotelStaff">English for Hotel Staff</a>
                                    <a class="m-link"  href="/resources/?program=ItsYourJob">It's Your Job</a>
                                    <a class="m-link"  href="/resources/?program=PracticalWriting">Practical Writing</a>
                                    <a class="m-link"  href="/resources/?program=RoadtoIELTS">Road to IELTS</a>
                                    <a class="m-link"  href="/resources/?program=StudySkillsSuccess">Study Skills Success</a>
                                    <a class="m-link"  href="/resources/?program=TenseBuster">Tense Buster</a>
                                    
                                        
                                        </td>
                                        
                                         <td class="col  dark"  style="width:260px;">
                                      
                                         <div class="title margin">Clarity Recorder <a class="link-button learn-more" href="/resources/recorder.php">Learn more</a></div>
                                         
                                            <img src="/images/menu-recorder-logo.png" style="margin:0;" />
                                         
                                        <p class="txt">The Clarity Recorder integrates with other Clarity programs (Tense Buster, Clear Pronunciation, Author Plus and so on) to enable you to record, play and save from within their interfaces.</p>
                                        
                                       <div id="recorder-box">
                                        <a href="/resources/recorder.php#desktop" class="recorder network" id="recorder-desktop">Desktop version</a>
                                        
                                         <a href="/resources/recorder.php#online" class="recorder online" id="recorder-online">Online version</a>
                                     	</div>
                                        </td>
                                        
                                       </tr>
                               		 </table>
                            
                                
                                
  
                           
                 
                     
                        
                        </div>
                        </li>
                        
                        		
                        <li <?php if ($currentSelection =="support"){echo 'class="current"'; }?>><a href="/support/" class="menu-link">Support</a>
                        
                        	<div id="container-3">
                            	<table border="0" cellspacing="0" cellpadding="0">
                                      <tr valign="top" align="left">
                                        <td class="col narrow border"  style="width:400px;">
                                        	<div class="box border">
                                            <div class="title margin">Licence and delivery <a class="link-button learn-more" href="/support/licence.php">Learn more</a></div>
                                            <a class="m-link"  href="/support/licence.php#appropriate-licence">Which licence is appropriate for my institution?</a>	
                                            <a class="m-link"  href="/support/licenceresults.php?search=order">How to place an order?</a>
                                            <a class="m-link"  href="/support/licenceresults.php?search=upgrade">How to upgrade and extend licence?</a>
                                            </div>
                                            
                                            <div class="box">
                                            <div class="title margin">Troubleshooting <a class="link-button learn-more" href="/support/troubleshooting.php">Learn more</a></div>
                                          
                                            
                                            <div id="support-trouble-box">
                                            
                                            <div id="support-trouble-left">
                                            	<div class="subtitle no-margin">My program is...</div>
                                            	<a class="m-link"  href="/support/troubleshootingresults.php?search=Access%20Uk">Access UK</a>
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Active%20Reading">Active Reading</a>
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Author%20Plus">Author Plus</a>		
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Business%20Writing">Business Writing</a>		
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Clarity%20Course%20Builder">Clarity Course Builder</a>		
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Clear%20Pronunciation">Clear Pronunciation</a>		
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Clarity%20Recorder">Clarity Recorder</a>		
                                                <a class="m-link cscs"  href="/support/troubleshootingresults.php?search=Customer%20Service%20Communciation%20Skills">Customer Service Communciation Skills</a>		
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=English%20for%20Hotel%20Staff">English for Hotel Staff</a>		
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=It%27s%20Your%20Job">It's Your Job</a>			
												<a class="m-link"  href="/support/troubleshootingresults.php?search=Practical%20Placement%20Test">Practical Placement Test</a>
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Results%20Manager">Results Manager</a>
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Road%20to%20IELTS">Road to IELTS</a>
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Study%20Skills%20Success">Study Skills Success</a>	
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=Tense%20Buster">Tense Buster</a>	
                                                <a class="m-link"  href="/support/troubleshootingresults.php?search=others">Others</a>	
                                                 
                                            
                                            </div>
                                            <div id="support-trouble-right">
                                            	<div class="subtitle no-margin">I want to know about</div>
                                                <div class="icon-support-box">
                                                    <a class="icon-support" id="install" href="/support/troubleshooting.php#Installation"><span>Installation</span></a> 
                                                    <a class="icon-support" id="standadv" href="/support/troubleshooting.php#Network"><span>Standard or advanced</span></a>
                                                    <a class="icon-support" id="permission" href="/support/troubleshooting.php#Permission"><span>Permission &amp; security</span></a>
                                                    <a class="icon-support" id="display" href="/support/troubleshooting.php#Display"><span>Display &amp; loading problems</span></a>
                                                    <a class="icon-support" id="internet" href="/support/troubleshooting.php#Internet"><span>Internet connection</span></a>
                                                    <a class="icon-support" id="licence" href="/support/troubleshooting.php#Licence"><span>Licence control</span></a>
                                                    <div class="clear"></div>
                                                </div>
                                                                                             
                                                
                                            
                                            
                                            </div>
                                            <div class="clear"></div>
                                            </div>
                                           <div class="subtitle">Error message I see... <a class="link-button learn-more" href="/support/troubleshooting.php#error-msg">Learn more</a></div>
                                          	  </div>
                                          
                              
                                    
                                        	
                                        </td>
                                        
                                        <td class="col narrow dark"  style="width:320px;">
                                        	<div class="box light">
                                        		<div class="title single">Latest release <a class="link-button learn-more" href="/support/tutorials.php#latest-release" id="latest-release">Learn more</a></div>
                                            </div>
                                            
                                            <div class="box english-level">
                                        		<div class="title single">English level scale <a class="link-button learn-more" href="/program/cef.php">Learn more</a></div>
                                                 <p class="txt">IELTS overall band scores, TOEFL iBT scores & CEF (Common European Framework) levels that correspond with
the Clarity programs.</p>
                                            </div>
                                            
                                            <div class="box light">
                                        		<div class="title single">Program compatibilities <a class="link-button learn-more" href="/support/programcompatibilities.php">Learn more</a></div>
                                                
                                                 <p class="txt">The system requirements (what sort of computers do you need) are listed for each network and online program.
                                                
                                            </div>
                                            
                                             <div class="box">
                                        		<div class="title margin">Tutorials <a class="link-button learn-more" href="/support/tutorials.php">Learn more</a></div>
                                                
                                                <a class="m-link"  href="/support/tutorials.php#installation-guides" id="installation-guides">Installation guides</a>
                                                <a class="m-link"  href="/support/tutorials.php#about-the-products" id="about-the-products">About the products</a>
                                            </div>
                                            
                                             <div class="box light">
                                        		<div class="title margin">Search Support <a class="link-button learn-more" href="/support/search.php">Learn more</a></div>
                                                <div class="box-search">
                                              
                                                	<form id="form1" method="post" class="search-form" action="/support/results.php">
                                                          <input type='text' value="<?php if(isset($search)) echo($search);?>"  name="search" id="menu-search" class="field" placeholder="Press enter to search "/>
                                                          <input name="" type="button" onclick="document.getElementById('menu-search').value = '';" class="clear"/>
                                                           <input type="submit" value="Search" style="display:none;" />
                                                        </form>
                                                
                                                
                                                </div>
                                                
                                            </div>
                                            
                                            <div class="box">
                                       		  <div class="title margin">Contact Clarity Support <a class="link-button learn-more" href="/support/contact.php">Learn more</a></div>
                                                <div class="phone">
                                                	<span>+44 (0) 845 130 5627 (United Kingdom)<br />
                                               	  +852 2791 1787 (Hong Kong)</span>  
                                              </div>
                                              <div class="email">
                                                 	<span>support@clarityenglish.com<br />
                                                    we will get back to you within one working day.</span>
                                              </div> 
                                                
                                                <a class="link-button" href="/support/contact.php#submit-a-support-ticket">Submit a support ticket</a>
                                            </div>
                                        
                                        	
                                        </td>
                                        </tr>
                                        </table>
                            
                            
                          
                               
                            </div>
                        </li>
                        
                        	
                        <li <?php if ($currentSelection =="story"){echo 'class="current"'; }?>><a href="/story/" class="menu-link right">About ClarityEnglish</a>
                        
                        		<div id="container-4">
                            		<div class="col">
                                    		<a class="m-link"  href="/story/">Our journey</a>
                                           
                                            <a class="m-link"  href="/story/clients.php">Worldwide projects &amp; clients</a>
                                         
                                            <a class="m-link"  href="/press/news/">Media relations</a>
                                    
                                    </div>
                               		
                                
                                </div>
                        </li>
                  </ul>
                </div>
       	  </div>
        
        
        </div>
    </div>
  </div>
  
<div class="clear"></div>
     
     
     
     
     
