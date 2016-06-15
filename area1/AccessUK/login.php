<?php 
	session_start(  );
	//check to make sure the session variable is registered
	if( (isset($_SESSION['UserName'])) OR ($_SESSION['UserType']==0) ){
		//session variable is not registered, go back to the main page
		header("location: index.php");
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Access UK: Living and learning in the UK</title>
<link rel="shortcut icon" href="/Software/AUK.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="css/home.css" />

<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="css/jquery.fancybox-1.3.1.css" />
<script type="text/javascript" src="script/jquery.V1.4.2.js"></script>

<!-- menu control -->
<script type="text/javascript" src="script/control.js"></script>

<!--Fancy Popup Box-->
<script type="text/javascript" src="script/jquery.fancybox-1.3.1.pack.js"></script>
<script type="text/javascript" src="script/jquery.fancybox.custom.js"></script>

<script language="javascript">
var popupWindow = null;
function centeredPopup(url,winName,w,h,scroll){
LeftPosition = (screen.width) ? (screen.width-w)/2 : 0;
TopPosition = (screen.height) ? (screen.height-h)/2 : 0;
settings =
'height='+h+',width='+w+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',resizable'
popupWindow = window.open(url,winName,settings)
}
</script>

<script type="text/javascript">
	function play() {
		document.getElementById("monFlash").SetVariable("player:jsPlay", "");
	}
	function pause() {
		document.getElementById("monFlash").SetVariable("player:jsPause", "");
	}
	function stop() {
		document.getElementById("monFlash").SetVariable("player:jsStop", "");
	}
	function volume(n) {
		document.getElementById("monFlash").SetVariable("player:jsVolume", n);
	}
</script>
</head>
<?php
	require_once('../../domainVariables.php');
	$startPage = $domain.'area1/AccessUK/Start.php?prefix='.$_SESSION['Prefix'];
?>
<body>
<div id="container">
  <div id="header"></div>
            
            <div id="site_content_container">
            <div id="site_content_container_border">
      <div id="menu">
            	<a class="menu_u1" id="U1" onclick="loadDIV(1)">
                    <span class="num">1</span>
                    <span class="title">Health</span>
                    <span class="clear"></span>
                </a>
                
                <a class="menu_u2" id="U2" onclick="loadDIV(2)">
                    <span class="num">2</span>
                    <span class="title">Accommodation</span>
                    <span class="clear"></span>
				</a>
                
                <a class="menu_u3" id="U3" onclick="loadDIV(3)">
                    <span class="num">3</span>
                    <span class="title">Support and Guidance</span>
                    <span class="clear"></span>
                </a>
                
                <a class="menu_u4" id="U4" onclick="loadDIV(4)">
                    <span class="num">4</span>
                    <span class="title">Casual Employment</span>
                    <span class="clear"></span>
                </a>
                
                <a class="menu_u5" id="U5" onclick="loadDIV(5)">
                    <span class="num">5</span>
                    <span class="title">Transport</span>
                    <span class="clear"></span>
                </a>
                
				<a class="menu_u6" id="U6" onclick="loadDIV(6)">
							<span class="num">6</span>
							<span class="title">A Day Out</span>
							<span class="clear"></span>
				</a>
						
				<a class="menu_u7" id="U7" onclick="loadDIV(7)">
							<span class="num">7</span>
							<span class="title">Communications</span>
							<span class="clear"></span>
				</a>
						
				<a class="menu_u8" id="U8" onclick="loadDIV(8)">
							<span class="num">8</span>
							<span class="title">An Evening Out</span>
							<span class="clear"></span>
				</a>
						
				
            
            </div>
            <div id="site_content_box">
           	  <div id="content_head">
              	Teachers' Site
                <a id="btn_welcome" class="welcome_iframe" href="welcome.htm">How to use Access UK</a>
                
				<?php if (isset($_SESSION['UserName'])) { ?>
				<input name="apdiv" type="button" class="btn_logout" value="Log out" onclick="window.location='db_logout.php'"/>
				<?php } ?>
             </div>
			 <div id="content_box"> <!-- innerHTML content -->
              <?php include ( 'content/u1.php' ); ?>
			  <script type="text/javascript">setActive(1);</script>
              </div>  
            
            
            
            </div>
            
            <div class="clear"></div>
            </div>
  </div>
            
            <div id="footer">
        	<div id="footer_line">
Data &copy; University of York, 2011. Software &copy; Clarity Language Consultants Ltd, 2011. All rights reserved.<br />
                <a href="contactus.htm" class="contact">Contact us</a> | <a href="http://www.clarityenglish.com/support/user/pdf/cs/CS_Terms_OfficialPDF.pdf" target="_blank">Terms and conditions</a>
            </div>
            <a href="http://www.york.ac.uk/" id="logo_york" target="_blank"></a>
            <a href="http://www.clarityenglish.com/" id="logo_clarity" target="_blank"></a>
        </div>
    
    
</div>

    

</body>
</html>
