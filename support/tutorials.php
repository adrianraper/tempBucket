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

<title>Clarity English language teaching online | Support | Licence and delivery</title>

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

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-873320-12']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>



<script type="text/javascript">
// What is $(document).ready ? See: http://flowplayer.org/tools/documentation/basics.html#document_ready
$(function() {

	$("ul#tutorialsbutton").tabs("div.panes > .mylicence", {
      /* tabs configuration goes here */
       // another property
      effect: 'fade',
	  initialIndex: null,
      // ... the rest of the configuration properties
	});


	   

   
});





</script>

</head>


<body id="support">
<?php $currentSelection="support"; ?>
<?php $supportSelection="tutorials"; ?>

<div id="container_outter">
<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>

	<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
     <div id="container_support">
     
     
            

                <div id="subpage_support_left">
     				
                    <div class="popularbox">
                    	<div class="heading">What's popular?</div>
           					<div class="inner">
      							<ul id="tutorialsbutton">
                    	<li class="button margin">
                        	<span class="name">Installation guides</span>
                        	<span class="click guides"><a></a></span>
                        </li>
                        <li class="button margin">
                        	<span class="name">About the products</span>
                        	<span class="click articles"><a></a></span>
                        </li>
                        <li class="button">
                        	<span class="name">Latest releases</span>
                        	<span class="click release"><a></a></span>
                        </li>
                    	
                    </ul>
                    
                                <!-- tab "panes" -->
                                 <div class="panes">
                                          <div class="mylicence">
                                              <div class="inner">
                                                    <span class="dot" id="guide"></span>
<div class="border">
													<div class="dlarea">
                                                          <a class="dl space" href="tech/pdf/network_installation_guide.pdf" target="_blank"><span>Download installation guide</span></a>
                                                         <a class="dl" href="tech/pdf/network_installation_sequence.pdf" target="_blank"><span>Download installation sequence</span></a>
                                                         <div class="clear"></div>
														</div>
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
                                                         <div class="clear"></div>
                                                         
                                                        
                                        
                                                         
                                                         </div>
                                                         
                                                         <h3>Install in a different directory:</h3>
                                                         
                                                         <div class="col">
                                                         	<div class="aline">&bull; My Canada (CD-120B)</a></div>
                                                            <div class="aline">&bull; Peacekeeper (CD-134A)</a></div>
                                                         </div>
                                                         
                                                          <div class="col">
                                                         	<div class="aline">&bull; CS Communciation Skills (CD-135A)</a></div>
                                                            <div class="aline">&bull; Other Clarity programs, such as MindGame</a></div>
                                                         </div>
                                                         <div class="clear"></div>
                                                         
                                                         	                                              
                                                 
                                                     
                                                     
												</div>
                                   </div>
                                            <div class="mylicence">
                                                <div class="inner">
                                                    <span class="dot" id="articles"></span>
                                                  <div class="border">
                                                    <h3>General questions</h3>
                                                    <a href="/support/tutorialsresults.php?search=print" class="qna" target="_blank">Can I print out all the content of a Clarity program?</a>
                                                    <a href="/support/tutorialsresults.php?search=resize" class="qna" target="_blank">Can I resize the screen of Clarity programs?</a>
                                                    </div>
                                                    
                                                     <h3>Product-related question</h3>
                                                     <div class="col">
                                                     	<div class="aline"><a href="/support/tutorialsresults.php?search=Author Plus" target="_blank" class="prog" id="ap">Author Plus</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Clarity Course Builder" target="_blank" class="prog" id="ccb">Clarity Course Builder</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Customer Service Communication Skills" target="_blank" class="prog" id="cscs">Customer Service Communication Skills</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=MindGame" target="_blank" class="prog" id="mg">MindGame</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Road to IELTS" target="_blank" class="prog" id="rti">Road to IELTS</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Active Reading" target="_blank" class="prog" id="ar">Active Reading</a></div>
                                                        
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Clarity Recorder" target="_blank" class="prog" id="recorder">Clarity Recorder</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=English for Hotel Staff" target="_blank" class="prog" id="efhs">English for Hotel Staff</a></div>
                                                     
                                                     </div>
                                                     <div class="col">
                                                     	<div class="aline"><a href="/support/tutorialsresults.php?search=Practical Placement Test" target="_blank" class="prog" id="ppt">Practical Placement Test</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Study Skills Success" target="_blank" class="prog" id="sss">Study Skills Success</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Business Writing" target="_blank" class="prog" id="bw">Business Writing</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Clear Pronunciation 1" target="_blank" class="prog" id="cp1">Clear Pronunciation 1</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Clear Pronunciation 2" target="_blank" class="prog" id="cp2">Clear Pronunciation 2</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=It's Your Job" target="_blank" class="prog" id="iyj">It's Your Job</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Results Manager" target="_blank" class="prog" id="rm">Results Manager</a></div>
                                                        <div class="aline"><a href="/support/tutorialsresults.php?search=Tense Buster" target="_blank" class="prog" id="tb">Tense Buster</a></div>
                                                     
                                                     </div>
                                                     <div class="clear"></div>
                                                     
                                                     </div>
                                   </div>
                                            <div class="mylicence">
                                                <div class="inner">
                                                    <span class="dot" id="release"></span>
                                                    
                                                     <h3>General questions</h3>
                                                    <a href="/support/tutorialsresults.php?search=SPQ082" class="qna" target="_blank">What are the latest releases of all Clarity titles?</a>
                                                    <a href="/support/tutorialsresults.php?search=SPQ081" class="qna" target="_blank">How do I know what version of a Clarity title I am running?</a>
                                                      <a href="/support/tutorialsresults.php?search=SPQ083" class="qna" target="_blank">How can I get the latest versions?</a>
                                                    
                                                    
                                                    
                                                                                            </div>
                                   </div>
                                        </div>       
                        	</div>
                	</div>
                    
                    <div class="purebox">
                        <div class="dotbox_col left">
                            <div class="head">Device-related questions</div>
                            <div class="inner">
                                 
                                <div class="tagbox">
                                    <a class="tag yellow" href="/support/tutorialsresults.php?search=Online" target="_blank"><span>Online versions</span></a>                                    
                                </div>
                                <div class="tagbox">
                                    <a href="/support/tutorialsresults.php?search=Tablet" target="_blank" class="tag yellow"><span>iPad / Android tablet version</span></a>                                </div>
                                    <div class="tagbox">
                                    <a class="tag yellow" href="/support/tutorialsresults.php?search=Network" target="_blank"><span>Network (CD) version</span></a>                                    
                                </div>
                                    
                          </div>
                        </div>
                        
                         <div class="dotbox_col">
                            <div class="head">You may be interested to know...</div>
                            <div class="inner"><p class="txt">If you want your students to work on a particular unit or exercise, click <a href="tech/pdf/DirectAccess.pdf" target="_blank">here</a> to find out about direct access links.</p>
                           </div>
                        </div>
                        
                        <div class="clear"></div>
                    </div>
                
                <div class="purebox">
               	<div class="dotbox">

                	<div class="dlblock left">
                    	<div class="title">Program compatibilities</div>
                        <div class="body">
                        	<a class="image programcomp" href="/support/programcompatibilities.php"  target="_blank"></a>
                        </div>
                    </div>
                    
                     <div class="dlblock left">
                    	<div class="title">English level scale chart</div>
                        <div class="body">
                        	<a class="image cef" href="/program/cef.php"  target="_blank"></a>
                        </div>
                    </div>
                    <div class="dlblock">
                    	<div class="title">ISBNs for Clarity programs</div>
                        <div class="body">
                        	<a class="image isbns" href="/support/user/pdf/cs/CS_Clarity_ISBNs.pdf" target="_blank"></a>
                        </div>
                    </div>
                   
                    
  <div class="clear"></div>
              
                </div>
                </div>
                
                                  
                    
                </div>
                <div id="subpage_support_right">
                	<div id="scormbanner">
                		<div id="icon"></div>
                    	
                    	<a href="tutorialsresults.php?search=SCORM" target="_blank">
                        <h1>SCORM<br />compliant</h1>
                        <h2>Click to see how <br />Clarity programs work <br />with your Learning  <br />Management System <br />(LMS / VLE).</h2>
                        </a>                  </div>
       </div>
                <div class="clear"></div>

        

     <?php include 'common/searchbottom.php' ?>
</div>
<?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>

</body>
</html>