<?php

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
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
<title>Clarity Support Top Enquiry</title>
<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>               

<!--Jquery library-->
<script type="text/javascript" src="/script/jquery.js"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js"></script>




</head>

<body id="support">
<?php $currentSelection="support"; ?>
<?php $topenquiry="yes"; ?>



<div id="container_outter">
<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>

	<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
     <div id="container_support">
     
     
     
     	
        

        
        <div class="enquirybox">
        	<div class="top">
               <span class="title">Top Enquiries</span>
               <div id="qnaclose"></div>
               <div id="qnaopen"></div>             
        	</div>
          <div class="content">
          	<div class="topenquiry">
          
      				 <?php include ( 'common/topenquiry.php' ); ?>
             </div>
          
                    	          
            
          </div>
          <div class="btm"></div>
       </div>
     
	 <script type="text/javascript" src="/script/support_qna_customize.js"></script>
	 <script type="text/javascript">
		$( "#tq<?php echo $_REQUEST['tq']; ?>" ).trigger( "click" );
		$( "#tq<?php echo $_REQUEST['tq']; ?>" ).focus();
	 </script>
        
	<?php include 'common/searchbottom.php' ?>
    
    
     </div>
</div>




<?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>


</body>
</html>