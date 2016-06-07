<?php 
session_start();
$current_subsite = ""; 
 ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
<title>Clarity English language teaching online | Home</title>
<meta name="classification" content="Education">
<meta name="robots" content="ALL">
<meta name="Description" content="Clarity publishes and distributes effective, easy-to-use, enjoyable ICT for English. Titles are available online or for networks, and cover grammar, vocabulary, listening, speaking, IELTS preparation, Business English, and authoring. Includes extensive support for teachers.">
<meta name="Keywords" content="online english, english teaching, Clarity English, ICT for English, IELTS preparation, authoring, ELT,  EFL, ESL, ESOL, CALL, ELT software, ELT program">

<link rel="stylesheet" type="text/css" href="css/global.css?v=20150724"/>            
<link rel="stylesheet" type="text/css" href="css/home.css?v=20150724"/>
<link rel="stylesheet" type="text/css" href="css/iview.css"/>
<link rel="stylesheet" type="text/css" href="css/colorbox.css"/>
<link href='https://fonts.googleapis.com/css?family=Roboto+Condensed:400,700,300' rel='stylesheet' type='text/css'>

<!--Jquery library-->
<script type="text/javascript" src="script/jquery-1.8.2.min.js"></script>
<!--Colobox-->
<script type="text/javascript" src="script/jquery.colorbox-min.js"></script>
<!--iView script-->
<script type="text/javascript" src="script/raphael-min.js"></script>
<script type="text/javascript" src="script/jquery.easing.min.js"></script>
<script type="text/javascript" src="script/iview.pack.js"></script>

<script>
$(function() {
    $(".iframebox_video").colorbox({
		 iframe:true,
		 width:"687px", 
		 height:"466px", 
	
		 scrolling:false 
	});
	
	
	
  });

$(document).bind('cbox_complete', function(){
       if($("#cboxTitle").html() == ""){ 
        $("#cboxTitle").hide(); 
    } 
});

</script>



<!-- Menu easinng: include Google's AJAX API loader -->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js"></script>
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

<body id="home">
<a name="top"></a>
<?php $currentSelection="home"; ?>



     <div id="container_outter">
     <?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>
    <div id="container">
    	
            <div id="container_inner" style="padding-top:0;">
            
             <a class="slider_banner" href="http://www.clarityenglish.com/PracticalWriting" target="_blank" onClick="_gaq.push(['_trackEvent', 'PW Launch 2015', 'Oct', 'CE-Home-Banner',, true]);">
             
             <h2>Do your students need help with their writing?</h2>
             <h1 id="tag-line">Try <span>Practical Writing</span>! Click <span><u>here</u></span>.</h1>                                   
                                            
                                    

             </a>
             
             <div id="home-box">
                   
             
             
                   <div class="box_space" id="rti">
                   	<div class="link_left"><a href="program/roadtoielts2.php" onClick="_gaq.push(['_trackEvent', 'Home', 'Panel', 'link_RTI_teachers',, true]);">Teachers click here</a></div>
                    <div class="link_right"><a href="http://www.ieltspractice.com" onClick="_gaq.push(['_trackEvent', 'Home', 'Panel', 'link_RTI_candidates',, true]);">Candidates click here</a></div>
                   
                   </div>
                   
                   <div class="box_space"  id="ccb">
                 	
                    
                     <a class="iframebox_video" href="video/ccb/video-popup.php" id="play" onClick="_gaq.push(['_trackEvent', 'Home', 'Panel', 'link_CCB_video',, true]);"></a>
                    
                    <a href="program/claritycoursebuilder.php" class="link" onClick="_gaq.push(['_trackEvent', 'Home', 'Panel', 'link_CCB',, true]);">Find out more about the Clarity Course Builder</a>
                  </div>
                   
                   
                      
                   
                    <div class="box" id="auk"> <a href="program/accessuk.php" class="link" onClick="_gaq.push(['_trackEvent', 'Home', 'Panel', 'link_AUK',, true]);" target="_blank">Click here to see why</a></div>
           
                  
                   
                 <div class="clear"></div>
             </div>
            
            
            <div class="clear"></div>
     

      </div>
            </div>
</div>
  
  

    
    <?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/footer_general.php') ; ?>



</body>
</html>
