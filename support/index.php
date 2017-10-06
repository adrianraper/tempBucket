<?php

//$current_subsite = "support"; 
	/*
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
	*/

?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>ClarityEnglish: Online English since 1992 | Support</title>
    <link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
    <meta name="robots" content="ALL">
    <meta name="Description" content="Find answers to questions about installation, compatibility, licencing and technical issues relating to ClarityEnglish programs.">
    <meta name="keywords" content="Technical support from ClarityEnglish, installation, compatibility, licencing, technical issues, ask support">

    <!-- Bootstrap -->
    <link href="/bootstrap/css/bootstrap.min.css?v=170824" rel="stylesheet">
    <link href="/bootstrap/css/mobile-max767.css?v=170824" rel="stylesheet">
	<link href="/bootstrap/css/support-mobile.css?v=170824" rel="stylesheet">
    <link href="/bootstrap/css/tablet-768-1199.css?v=170824" rel="stylesheet">

    <!---Font style--->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i,800,800i" rel="stylesheet">
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    
    <!---Google Analytics Tracking--->
	<script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
    
      ga('create', 'UA-873320-20', 'auto');
      ga('send', 'pageview');
    
    </script>
    
  </head>
  <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/bootstrap/js/bootstrap.min.js"></script>
	<script src="/bootstrap/js/support.js"></script>
	<script src="/bootstrap/js/supportEnquiry.js"></script>
  <script>

  </script>
  <body>  

    <?php include $_SERVER['DOCUMENT_ROOT'].'/inc_nav.php'; ?>  
    <div class="jumbotron support-jumbotron">
    	<div class="banner-txt-box Trans-W-bg text-center">
    		<h1 id="general-banner-txt">Support</h1>
        </div>
    </div>
	

	<div class="container-fluid support-search-overview">
        
        
        <h2 class="general-tag text-center">Search</h2>   
        
              
        <form id="form1" method="post" class="searchform text-center" action="result.php" target="_blank">
				<div class="support-border container">
				<input type='text' autofocus value="<?php if(isset($search)) echo($search);?>"  class="general-subtag  support-search" name="search" id="search_field"/>
                <!--<input name="" type="button" id="search_clear" value="" onclick="document.getElementById('search_field').value = '';" />-->
                <input type="submit" class="support-search-btn" style="display:inline;"/>
				</div>
		</form>
		<p class="general-text">Please use keywords to search for the support you need, such as "SCORM", "bandwidth", "network". Or, if you prefer, use the form below to simply ask us your question.</p>
		
    </div>
	
	
	
	<?php include 'support-ticket.php'; ?>
	
    <?php include 'support-materials.php'; ?>
     
	<?php include $_SERVER['DOCUMENT_ROOT'].'/inc_footer.php'; ?>


  </body>
</html>