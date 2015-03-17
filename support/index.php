<?php 
session_start();
$current_subsite = "support"; 

	require_once('../db_login.php');

	for ($i=5; $i<10; $i++){	
		$sql = "SELECT * FROM T_QuestionAnswer WHERE F_Categories like '%?%'";
		$resultset = $db->Execute($sql,$i);
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else {
			if ($resultset->RecordCount()>0) {
				$qid[$i] = $resultset->fields['F_QID'];
				$score[$i] = $value;
				$question[$i] = $resultset->fields['F_Question'];
				$answer[$i] = $resultset->fields['F_Answer'];
				$url[$i] = $resultset->fields['F_URL'];
				$priority[$i] = $resultset->fields['F_Priority'];
				$category[$i] = $resultset->fields['F_Categories'];
			}
		}
		$resultset->Close();
	}


?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
<title>Clarity English language teaching online | Support </title>
<meta name="classification" content="Education">
<meta name="robots" content="ALL">
<meta name="Description" content="Clarity runs several projects to support learning communities worldwide.">
<meta name="Keywords" content="online english, english teaching, Clarity English, ICT for English, IELTS preparation, authoring, ELT,  EFL, ESL, ESOL, CALL, ELT software, ELT program">

<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>               

<!--Jquery library-->
<script type="text/javascript" src="/script/jquery.js"></script>

<!--Select Menu easinng-->
<script type="text/javascript" src="/script/jquery.easing.min.js"></script>
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

<body id="support">
<?php $currentSelection="support"; ?>

<div id="container_outter">

<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>
    

     
    <div id="container">
    	<div id="menu_program">

     </div>
            <div id="container_inner">
            
            	<div id="support_home_top">
                	<div class="box" id="licence">
                    	<a href="./licence.php" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_txt_licence',, true]);" class="txtbox">
                        	<span class="title">Licence and delivery</span>
                            <span class="txt">Learn about Clarity's licensing and  other <br />
                            options.</span>
                        </a>
                    	 <a href="./licence.php" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_licence',, true]);" class="click"></a>
                    </div>
                    <div class="box" id="troubleshoot">
                  	<a href="./troubleshooting.php" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_txt_troubleshoot',, true]);" class="txtbox">
                         <span class="title">Troubleshooting</span>
                         <span class="txt">Find the solutions and <br />tips that we have <br />collected.</span>                    </a>
           		    <a href="./troubleshooting.php" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_troubleshoot',, true]);"  class="click"></a>
                    </div>
					<div class="box" id="tutorial">
                  <a href="./tutorials.php" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_txt_tutorials',, true]);" class="txtbox">
                            <span class="title">Tutorials</span>
                            <span class="txt">Download the installation guide and user manual for your product.</span>
                        </a>
                    <a href="./tutorials.php" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_tutorials',, true]);"  class="click"> </a>
                    </div>
                    <div class="box" id="search">
                  	<a href="./search.php"  onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_txt_search',, true]);" class="txtbox">
                        	<span class="title">Search Support</span>
                            <span class="txt">Use our search engine to <br />find the solution you <br />need.</span>                       	</a>
                    	<a href="./search.php"  onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_search',, true]);" class="click"></a>
                    
                    </div>
                    <div class="box" id="contact">
                 		 <a href="./contact.php"  onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_txt_contact',, true]);" class="txtbox">
                        	<span class="title">Contact Clarity Support</span>
                            <span class="txt">Get in touch with the Clarity Support Team.</span>
                         </a>
                    	<a href="./contact.php"  onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'Btn_contact',, true]);" class="click"></a>                  </div>
                    
             
                
                
                </div>
                
                <div id="support_home_btm">
                
                	<div id="box_enquiry">
                    	<div id="content">
							<h2>Top Enquiries</h2>
                            
                            <ul class="list_dot">
                            	<li><a href="topenquiry.php?tq=1&#tq1" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'top_q1',, true]);"><?php echo $question[5]; ?></a></li>
                            	
                               
                                <li><a href="topenquiry.php?tq=2&#tq2" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'top_q2',, true]);"><?php echo $question[6]; ?></a></li>
                                <li><a href="topenquiry.php?tq=3&#tq3" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'top_q3',, true]);"><?php echo $question[7]; ?></a></li>
                                <li><a href="topenquiry.php?tq=4&#tq4" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'top_q4',, true]);"><?php echo $question[8]; ?></a></li>
                                <li><a href="topenquiry.php?tq=5&#tq5" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'top_q5',, true]);"><?php echo $question[9]; ?></a></li>
                            </ul>                        	
                        </div>
                    	
                    
                    </div>
                    <div id="box_teachers">
                    	<div id="content">
                    	<h2>Support for teachers</h2>
							<p class="txt">Check the Clarity support materials to boost program usage! We have designed materials such as flyers and posters to help you get the best value from your current Clarity subscription.</p>
                     
                            <p class="txt">Most of these materials are FREE! They have been devised in collaboration with a range of institutions to ensure that both teachers and learners are aware of Clarity resources.</p>
                         
                         <div id="btnmore">
                         <a class="btn_blue" href="../resources/index.php" onClick="_gaq.push(['_trackEvent', 'Support', 'Home', 'link_resources',, true]);"><span>Click to find out more</span></a>
                         </div>
                   
                            <p class="clear"></p>
                            
						</div>
                    </div>
                	
                
                
                </div>
	 		
            
            
            
         
         
          </div>
          
        
         
         
         
        
        
        

        
        	
            
            
           
         
      
        
    </div>
​



</div>


  <?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_general.php' ); ?>
  




</body>
</html>
