<?php
session_start();
$current_subsite = "support"; 
	require_once('../db_login.php');

?>





<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />

<title>Clarity English language teaching online | Support | Troubleshooting</title>

<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>               

<!--Jquery Library-->
<script type="text/javascript" src="/script/jquery.js"></script>
<!--Select Menu easinng-->
<script type="text/javascript" src="/script/jquery.easing.min.js"></script>
<!-- Menu easinng: include Google's AJAX API loader -->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js"></script>
<!-- For tab: include the Tools -->
<script src="http://cdn.jquerytools.org/1.2.7/full/jquery.tools.min.js"></script>



<script type="text/javascript">
// What is $(document).ready ? See: http://flowplayer.org/tools/documentation/basics.html#document_ready
$(function() {

	$("ul#troublebutton").tabs("div.panes > .mytrouble", {
      /* tabs configuration goes here */
       // another property
      effect: 'fade',
	  initialIndex: null,
      // ... the rest of the configuration properties
	});

});





</script>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-873320-12']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</head>


<body id="support">
<?php $currentSelection="support"; ?>
<?php $supportSelection="troubleshoot"; ?>

<div id="container_outter">
<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>

	<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
     <div id="container_support">
     
     
            

                <div id="subpage_support_trouble">
     				
                    <div class="popularbox border">
                    	<div class="heading">My program is:</div>
           					<div class="inner">
                            	<div class="troubleprogram_box">
                                	<a href="/support/troubleshootingresults.php?search=Access Uk" target="_blank" id="auk" class="prog">Access UK</a>
                                    
                                 
                                
                                
                                        <a href="/support/troubleshootingresults.php?search=Business Writing" target="_blank"  id="bw" class="prog">Business Writing</a>
                                        
                                       
                                        
                                             
                                             <a href="/support/troubleshootingresults.php?search=Clarity Recorder" target="_blank"  id="recorder" class="prog">Clarity Recorder</a>
                                             
                                            
                                    
                                   
                                     
                                         <a href="/support/troubleshootingresults.php?search=It's Your Job" target="_blank"  id="iyj" class="prog">It's Your Job</a>
                                     
                                    
                                    
                                   
                                    
                                	<a href="/support/troubleshootingresults.php?search=Road to IELTS" target="_blank" id="rti" class="prog">Road to IELTS</a>
                                    
                                    	
                                       
                                        
                                  
                                    <a href="/support/troubleshootingresults.php?search=others" target="_blank" class="prog general">Other programs</a>
                               
                                   
                                   
                                </div>
                                <div class="troubleprogram_box">
                                	   <a href="/support/troubleshootingresults.php?search=Active Reading" target="_blank" id="ar" class="prog">Active Reading</a>
                                        <a href="/support/troubleshootingresults.php?search=Clarity Course Builder" target="_blank"  id="ccb" class="prog">Clarity Course Builder</a>
                                         <a href="/support/troubleshootingresults.php?search=Customer Service Communciation Skills" target="_blank"  class="prog" id="cscs">Customer Service Communciation Skills</a>
                                          <a href="/support/troubleshootingresults.php?search=Practical Placement Test" target="_blank" id="ppt" class="prog">Practical Placement Test</a>
                                          <a href="/support/troubleshootingresults.php?search=Study Skills Success" target="_blank" id="sss" class="prog">Study Skills Success</a>
                                        
                                	
                                    
                                
                               
                              </div>
                                <div class="troubleprogram_box right">
                                	<a href="/support/troubleshootingresults.php?search=Author Plus" target="_blank"  id="ap" class="prog">Author Plus</a>
                                	<a href="/support/troubleshootingresults.php?search=Clear Pronunciation" target="_blank"  id="cp" class="prog">Clear Pronunciation 1 / 2</a>
                                      <a href="/support/troubleshootingresults.php?search=English for Hotel Staff" target="_blank" id="efhs" class="prog">English for Hotel Staff</a>
                                       <a href="/support/troubleshootingresults.php?search=Results Manager" target="_blank"  id="rm" class="prog">Results Manager</a>
                                         <a href="/support/troubleshootingresults.php?search=Tense Buster" target="_blank" id="tb" class="prog">Tense Buster</a>
                                
                                    
                                
                              </div>
                                <div class="clear"></div>
                            	
                            
                            </div>
                        </div>
                   	</div>
                    
                    
                    <div class="popularbox">
                    	<div class="heading">I want to ask about...</div>
           					<div class="inner">
      							<ul id="troublebutton">
                    	<li class="button margin">
                        	<span class="name one">Installation guides</span>
                        	<span class="click install"><a></a></span>
                        </li>
                        <li class="button margin">
                        	<span class="name three">Standard or advanced (large) network</span>
                        	<span class="click network"><a></a></span>
                        </li>
                        <li class="button margin">
                        	<span class="name two">Permission & security</span>
                        	<span class="click permission"><a></a></span>
                        </li>
                        <li class="button margin">
                        	<span class="name two">Display & loading problems</span>
                        	<span class="click display"><a></a></span>
                        </li>
                        <li class="button margin">
                        	<span class="name two">Internet<br />connection</span>
                        	<span class="click internet"><a></a></span>
                        </li>
                        <li class="button">
                        	<span class="name one">Licence control</span>
                        	<span class="click licence"><a></a></span>
                        </li>
                    	
                    </ul>
                    <div class="clear"></div>
                    
                                <!-- tab "panes" -->
                                 <div class="panes">
                                          <div class="mytrouble">
                                              <div class="inner">
                                                    <span class="dot" id="install"></span>
                                     				
                                                       <div class="border">
													<div class="dlarea">
                                                          <a class="dl space" href="tech/pdf/network_installation_guide.pdf" target="_blank"><span>Download installation guide</span></a>
                                                         <a class="dl" href="tech/pdf/network_installation_sequence.pdf" target="_blank"><span>Download installation sequence</span></a>
                                                         <div class="clear"></div>
                                                    </div>
                                                    </div>
                                                                   <div class="border">
                                                        <div class="installbox">
                                                        <div id="install_left">
                                                        
                                                     	<h3>Installation sequence:</h3>
                                                        
                                                        
                                                         <span class="txt">All Clarity programs share a common architecture. To ensure that you have the latest version, you should install Clarity programs in the following order.</span>
                                                         
                                                         
                                                         
                                                         <div class="col">
                                                         	<div class="aline">1) It's Your Job (CD-138A)</div>
                                                            <div class="aline">2) Business Writing (CD-110A)</div>
                                                            <div class="aline">3) Author Plus (CD-101B)</div>
                                                            <div class="aline">4) Clear Pronunciation 1 (CD-139C)</div>
                                                            <div class="aline">5) Active Reading (CD-133A)</div>
                                                            <div class="aline">6) English For Hotel Staff (CD-140A)</div>
                                                         </div>
                                                         <div class="col">
                                                         	<div class="aline">7) Tense Buster V9 (CD-109D)</div>
                                                            <div class="aline">8) Study Skills Success V9 (CD-149A)</div>
                                                            <div class="aline">9) Clear Pronunciation 2 (CD-150A)</div>
                                                            <div class="aline">10) Clarity English Success (CD-137B)</div>
                                                            <div class="aline">11) Results Manager V3 (CD-102A)</div>
                                                            <div class="aline">12) Road To IELTS V2 (CD-152B)</div>
                                                         
                                                         </div>
                                                         
                                                         </div>
                                                         
                                                         <div id="install_right">
                                                         	<h3>Install in a different directory:</h3>
                                                             <span class="txt">Below programs are not compatible with the common components:</span>
                                                         
                                                  			 <ul>
                                                         		<li>My Canada (CD-120B)</li>
                                                           		<li>Peacekeeper (CD-134A)</li>
                                                        
                                                         		<li>CS Communciation Skills (CD-135A)</li>
                                                            	<li>Other Clarity programs, such as MindGame</li>
                                                            </ul>
                                                 
                                                         	
                                                         
                                                         </div>
                                                        
                                                            <div class="clear"></div>
                                                            </div>
                                                         
                                                </div>
                                                         <h3>Questions about installation:</h3>
                                               
                                                    
                                                    
                                                   <a href="troubleshootingresults.php?search=SPQ052" class="qna" target="_blank">For a network installation, how do I put shortcuts onto the learners' desktops?</a>
                                                    <a href="troubleshootingresults.php?search=SPQ098" class="qna" target="_blank">I cannot run the CD / DVD. It gives me a SecuROM error.</a>
                                                    <a href="troubleshootingresults.php?search=SPQ062" class="qna" target="_blank">I am using a Network licence. I have received a licence file (by email or CD) along with the main program. What should I do with it?</a>
                                                    <a href="troubleshootingresults.php?search=SPQ087" class="qna" target="_blank">In a network installation, how can I stop 'enterprising' learners from compromising the progress database?</a>
                                                    <a href="troubleshootingresults.php?search=SPQ115" class="qna" target="_blank">Can I download the programs?</a>
                                                    <a href="troubleshootingresults.php?search=SPQ029" class="qna" target="_blank">Can I install all the Clarity programs into one folder?</a>
                                                    <a href="troubleshootingresults.php?search=SPQ100" class="qna" target="_blank">I cannot start my program. It says "The database is badly damaged, Microsoft JET Database Engine cannot open the file .... It is already opened exclusively by another user, or you need permission to view its data".</a>
                                                    <a href="troubleshootingresults.php?search=SPQ102" class="qna" target="_blank">I cannot uninstall It's Your Job.</a>
                                                    <a href="troubleshootingresults.php?search=SPQ161" class="qna" target="_blank">What should I do after I have bought the program? How do I install it?</a>
                                                         	                                              
                                                 
                                                     
                                                     
											</div>
                                   </div>
                                            <div class="mytrouble">
                                                <div class="inner">
                                                    <span class="dot" id="network"></span>
                                               
                                                  <div class="border">
                                                    <h3>A standard (small) network means...</h3>
                                                    
                                                            <span class="txtwidth">a 20-user licence or less. This is most suitable for licences of 20 or less. It uses standard Windows programs to run.</span>
                                                            
                                                  <h3 style="margin:10px 0 0 0;">An advanced (large) network means...</h3>
                                                 
                                                    <span class="txtwidth">a licence larger than 20 computers. This will work with any number of licences. It uses a browser to run the programs.</span>
                                                  </div>
                                                      <h3>Related questions:</h3>
                                                    <a href="troubleshootingresults.php?search=SPQ043" class="qna" target="_blank">A handy troubleshooting guide for installing Clarity programs (large network version).</a>
                                                    <a href="troubleshootingresults.php?search=SPQ097" class="qna" target="_blank">I used an advanced network installation for one program, but my other program does not have this option. Can they work together?</a>
                                                    <a href="troubleshootingresults.php?search=SPQ050" class="qna" target="_blank">How do I install to an intranet?</a>
                                                    <a href="troubleshootingresults.php?search=SPQ058" class="qna" target="_blank">My licence is larger than 20. Can I still install my Clarity programs as a small network installation?</a>
                                                                                                      
                                               
                                                     
                                              </div>
                                   </div>
                                            <div class="mytrouble">
                                                <div class="inner">
                                                    <span class="dot" id="permission"></span>
                                                    
                                                  <h3>Permission & security</h3>
                                                  
                                                  <a href="troubleshootingresults.php?search=SPQ097" class="qna" target="_blank">For a network installation, what permissions do learners need?</a>
<a href="troubleshootingresults.php?search=SPQ051" class="qna" target="_blank">In a network installation, how can I stop 'enterprising' learners from compromising the progress database?</a>
<a href="troubleshootingresults.php?search=SPQ170" class="qna" target="_blank">I have accidentally deleted student data. How can I get it back?</a>
                                                 </div>
                                   </div>
                                   
                                   
                                   <div class="mytrouble">
                                                <div class="inner">
                                                    <span class="dot" id="display"></span>
                                                    
                                                  <h3>Display &amp; loading problem:</h3>
                                                  
                                                 <a href="troubleshootingresults.php?search=SPQ097" class="qna" target="_blank">I cannot hear anything in the listening exercises.</a>
<a href="troubleshootingresults.php?search=SPQ016" class="qna" target="_blank">I cannot see any video.</a>
<a href="troubleshootingresults.php?search=SPQ026" class="qna" target="_blank">When I start a Clarity program it seems all the buttons and boxes are displayed on top of each other, and I cannot do anything.</a>
<a href="troubleshootingresults.php?search=SPQ088" class="qna" target="_blank">I get a 'Library not registered' error when I start the program.</a>
<a href="troubleshootingresults.php?search=SPQ031" class="qna" target="_blank">When I am running a program, there is no text on the screen buttons.</a>
<a href="troubleshootingresults.php?search=SPQ090" class="qna" target="_blank">When I run the program the loading sticks at 0%.</a>
<a href="troubleshootingresults.php?search=SPQ106" class="qna" target="_blank">When I start my program it crashes and tells me there is a missing file that Office or MSN needs (msvcr).</a>
                                                 </div>
                                   </div>
                                   
                                   <div class="mytrouble">
                                                <div class="inner">
                                                    <span class="dot" id="internet"></span>
                                                    
                                                  <h3>Internet connection:</h3>
                                                  
                                                <a href="troubleshootingresults.php?search=SPQ017" class="qna" target="_blank">What speed internet connection do I need?</a>
<a href="troubleshootingresults.php?search=SPQ066" class="qna" target="_blank">What is the bandwidth needed for Clarity programs?</a>
<a href="troubleshootingresults.php?search=SPQ071" class="qna" target="_blank">The online Clarity programs are running slowly from computers inside my school. How can I get them to be faster?</a>
<a href="troubleshootingresults.php?search=SPQ209" class="qna" target="_blank">If my Internet connection crashes while I am using Clarity programs what should I do?</a>
<a href="troubleshootingresults.php?search=SPQ015" class="qna" target="_blank">My Internet connection is very slow and the listening exercise runs out of time before the audio has finished. What can I do?</a>
                                                 </div>
                                   </div>
                                   
                                   <div class="mytrouble">
                                                <div class="inner">
                                                    <span class="dot" id="licence"></span>
                                                 
                                                  <h3>Licence control:</h3>
                                                  
                                                <a href="troubleshootingresults.php?search=SPQ035" class="qna" target="_blank">Can I remove a learner and free up a licence?</a>
<a href="troubleshootingresults.php?search=SPQ060" class="qna" target="_blank">What happens if a learner simply closes their browser and does not properly close the Clarity program? Will their use of a licence last forever?</a>
<a href="troubleshootingresults.php?search=SPQ063" class="qna" target="_blank">When I start a Clarity program, it says my licence is full.</a>
                                                 </div>
                                   </div>
                                   
                                   
                                        </div>       
                        	</div>
                	</div>
                    
                    <div class="purebox">
                      <div class="dotbox_trouble large">
                            <div class="head">Error message I see:</div>
                            <div class="content">
                            	 <a href="troubleshootingresults.php?search=SPQ020" class="qna" target="_blank">Sorry, your account has not been activated yet.</a>
                                 <a href="troubleshootingresults.php?search=SPQ098" class="qna" target="_blank">Issues related to SecuROM</a>
                                 <a href="troubleshootingresults.php?search=SPQ111" class="qna" target="_blank">This content is not available to your group.</a>
                                 <a href="troubleshootingresults.php?search=SPQ063" class="qna" target="_blank">Sorry, the licence for this program is full.</a>
                                 <a href="troubleshootingresults.php?search=SPQ088" class="qna" target="_blank">Library not registered</a>
                                 <a href="troubleshootingresults.php?search=SPQ215" class="qna" target="_blank">Sorry, your account has not been started yet.</a>
                                 <a href="troubleshootingresults.php?search=SPQ216" class="qna" target="_blank">Your account has expired.</a>
                                 <a href="troubleshootingresults.php?search=SPQ100" class="qna" target="_blank">The database is badly damaged, Microsoft JET Database Engine cannot open the file ....</a>
                                 <a href="troubleshootingresults.php?search=SPQ106" class="qna" target="_blank">Couldn't find library MSVCR80.dll...</a>
                                 <a href="troubleshootingresults.php?search=SPQ110" class="qna" target="_blank">Your account does not have access to this title.</a>
                            
                            
                            </div>
                      </div>
                        <div class="dotbox_trouble small">
                            <div class="head">System requirements:</div>
                            <div class="content">
                            	<div class="dlblock">
                                    <div class="title">Program compatibilities</div>
                                    <div class="body">
                                        <a class="image programcomp" href="/support/programcompatibilities.php"  target="_blank"></a>
                                    </div>
                                  
                                </div>
                                  <div class="clear"></div>
                   		 </div>
                        </div>
                        
                        <div class="clear"></div>
                    </div>
                
                
                
                                  
                    
                </div>
                
         

        

     <?php include 'common/searchbottom.php' ?>
</div>
<?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>

</body>
</html>