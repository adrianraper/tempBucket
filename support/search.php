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
<title>Clarity English language teaching online | Support | Search</title>
<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>               
<!--Jquery library-->
<script type="text/javascript" src="/script/jquery.js"></script>





<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js"></script>

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
<?php $supportSelection="search"; ?>
<?php $topenquiry="yes"; ?>



<div id="container_outter">
<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>

	<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
     <div id="container_support">
     
     	<div id="searchbig_container">
     		<div class="borderbox">
                <span class="top"></span>
                <div class="content_search">
                    <div id="tip_a">
                    	Please use keywords for the search, such as 
                    <div class="tagline">
                      <a class="tag yellow" href="results.php?search=System Compatibility" onClick="_gaq.push(['_trackEvent', 'Support', 'Search', 'tag_system',, true]);"><span>System compatibility</span></a>
                      <a class="tag blue" href="results.php?search=Road to IELTS" onClick="_gaq.push(['_trackEvent', 'Support', 'Search', 'tag_RTI',, true]);"><span>Road to IELTS</span></a>
                      <a class="tag purple" href="results.php?search=SCORM" onClick="_gaq.push(['_trackEvent', 'Support', 'Search', 'tag_scorm',, true]);"><span>SCORM-compliant</span></a>
                          <div class="clear"></div>
                      </div>
                    
                    
                    
                  and you may enter multiple keywords to refine a specific seach below.</div>
                  <div id="tip_a_line"></div>
                  <div id="tip_b">You can just press enter to search immediately.</div>
                  <div id="tip_b_line"></div>
                
                
                  <div id="search_bar">
                    <form id="form1" method="post" class="searchform" action="results.php">
                       <input type='text' value="<?php if(isset($search)) echo($search);?>"  name="search" id="search_field" autofocus/>
                       <input name="" type="button" id="search_clear" value="" onclick="document.getElementById('search_field').value = '';" />
                       <input type="submit" value="Search" style="display:none;" />
                      
                    </form>
                  </div>
                   
                    <div class="clear"></div>
                  <script type="text/javascript">
                        var input = document.getElementById("search_field");
                        if ( !("autofocus" in input) ) {
                            input.focus();
                        }
                    </script>
                    
                
                  
            
                </div>
                <span class="btm"></span>
          </div>
     	</div>
        

        
        <div class="enquirybox">
        	<div class="top">
               <span class="title">Top enquiries</span>
               <div id="qnaclose"></div>
               <div id="qnaopen"></div>             
        	</div>
          <div class="content">
          
       
          
                    	<?php include ( 'common/topenquiry.php' ); ?>          
            
          </div>
          <div class="btm"></div>
       </div>
       <script type="text/javascript" src="/script/support_qna_customize.js"></script>
       
       <?php include 'common/searchbottom.php' ?>
        
        

    
    
     </div>
</div>




<?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>


</body>
</html>