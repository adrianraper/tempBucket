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
	$("ul#licencebutton").tabs("div.panes > .mylicence", {
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
<?php $supportSelection="licence"; ?>

<div id="container_outter">
<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>

	<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
     <div id="container_support">
     
     <div id="subpage_support_left">  				
        <div class="popularbox">
            <div class="heading">Which licence is appropriate for my institution?</div>
                <div class="inner">
            <p class="txt">There are licence types to suit almost every set up. For each type, the student sees the same interface and content, <br />but accesses the program in a different way. Click below to find out about the different licence types.</p>
     				<div id="licencetitle">
                            <div class="title" id="network"><span>Network version</span></div>
                            <div class="title" id="online"><span>Online version</span></div>
                            <div class="clear"></div>
       	 </div>
      				<ul id="licencebutton">
                    	<li class="button" id="CD">
                        	<a></a>
                        </li>
                        <li class="button" id="LTL">
                        	<a></a>
							
                        </li>
                        <li class="button" id="AA">
                        	<a></a>
                        </li>
                 
                    </ul>
                    
               
                    
                <!-- tab "panes" -->
                <div class="panes">
                  <div class="mylicence">
                   	  <div class="inner">
                            <span class="dot" id="CD"></span>
                            <a class="learnmore" href="/support/licenceresults.php?search=network">Learn more</a>
                            <span class="txt">The network version is installed on a standalone computer or network within your institution and can be accessed by students only within the centre. Purchase of the network versions is one-off: there are no recurring costs within the version.</span>                      </div>
                  </div>
                    <div class="mylicence">
                    	<div class="inner">
                            <span class="dot" id="LTL"></span>
                           <a class="learnmore" href="/support/licenceresults.php?search=Learner Tracking licence">Learn more</a>
                            <span class="txt">Online versions are accessible at any time on the Internet.</span>
                                        <span class="txt">With Learner Tracking licences, access is for named learners. Learners log in to the program, and all progress data is stored for teachers to view. Licences are not transferable. Online programs are charged on an annual basis
and all upgrades are included.</span>                         </div>
                  </div>
                    <div class="mylicence">
                        
                    	<div class="inner">
                            <span class="dot" id="AA"></span>
                            <a class="learnmore" href="/support/licenceresults.php?search=Anonymous Access licence">Learn more</a>
                            <span class="txt">Online versions are accessible at any time on the Internet.</span>
                            <span class="txt">With Anonymous Access licences, access is based on concurrent use. Learners log in anonymously and while no individual progress records are stored, overall usage levels are reported. Online programs are charged on an annual basis
and all upgrades are included.</span>
				</div>
                  </div>
						</div>
                        
                </div>
            </div>
              <div class="purebox">
                    <div class="dotbox">
                    	<div class="head">I want to ask about:</div>
                    <div id="tagsbox">
                    	<div class="col">
                        	<span class="name">Admin:</span>
                             <div class="tagbox">
                            	<a class="tag yellow" href="/support/licenceresults.php?search=order"><span>Order &amp; delivery</span></a>
                            </div>
                            <div class="tagbox">
                            	<a class="tag yellow" href="/support/licenceresults.php?search=upgrade"><span>Upgrade &amp; Extend licence</span></a>
                            </div>
						</div>
                        <div class="col">
                        	<span class="name">Product:</span>
                            <div class="tagbox">
                            	<a class="tag blue" href="/support/licenceresults.php?search=Clarity Course Builder"><span>Clarity Course Builder</span></a>
                    </div>
                            <div class="tagbox">
                            	<a class="tag blue" href="/support/licenceresults.php?search=Road to IELTS"><span>Road to IELTS</span></a>
                            </div>
                            <div class="tagbox">
                            	<a class="tag blue" href="/support/licenceresults.php?search=Tense Buster"><span>Tense Buster</span></a>
									
									
									
									
                        </div>
                   
             </div>
                        <div class="clear"></div>
                    </div>
             

                
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
                	<div id="techncial_support_pledge">
                    	<h2>Technical</h2>
                        <h2>support</h2>
                        <h2 class="more">pledge</h2>
                        <h3>Our aim is to ensure you have smooth, trouble-free use of any software you purchase from Clarity. <br />I therefore guarantee to find a fast and effective solution to any technical problems related to Clarity software, or provide a full refund.</h3>
                        <h4>
                        	Dr Adrian Raper,<br />
                            Technical Director
                        </h4>
                </div>
                
           </div>
                <div class="clear"></div>
     
     
     <?php include 'common/searchbottom.php' ?>
</div>
<?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>

</body>
</html>