<?php
	if (isset($_GET['session']))
		session_id($_GET['session']);
	session_start();
	$currentSessionID = session_id();
	
	require_once('../../db_login.php');

	$server = $_SERVER['HTTP_HOST'];
	// v6.5.6 Add support for HTTP_X_FORWARDED_FOR
	if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
		// This might show a list of IPs. Assume/hope that EZProxy puts itself at the head of the list.
		// Not always it doesn't. So need to send the whole list to the licence checking algorithm. Better send as a list than an array.
		//$ipList = explode(',',$_SERVER['HTTP_X_FORWARDED_FOR']);
		//$ip = $ipList[0];
		$ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
	} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
		$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
	} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
		$ip = $_SERVER["HTTP_CLIENT_IP"];
	} else {
		$ip = $_SERVER["REMOTE_ADDR"];
	}
	
	//added by sky
	$ip = str_replace(" ", "", $ip);
	
	if (isset($_GET['prefix'])){
		$prefix = $_GET['prefix'];
	}else{
		header('Location: no-prefix.html');
	}
	
	$authentication = false;
	$registerLink = "start.php?prefix=".strtoupper($_GET["prefix"]);
	
	//$authentication?":
	
	$resultset = $db->Execute("SELECT F_RootID as rootID FROM T_AccountRoot where F_Prefix = ?",array($prefix));
	if (!$resultset) {
		$errorMsg = $db->ErrorMsg();
	} else {
		if ($resultset->RecordCount()==1) {
				$rootID = $resultset->fields['rootID'];
		}else{
			header('Location: no-prefix.html');
		}
	} 
	$resultset->Close();

	$resultset = $db->Execute("SELECT * FROM T_LicenceAttributes where F_RootID = ? and F_Key in ('IPrange','RUrange') and (F_ProductCode is null or F_ProductCode = '' or F_ProductCode in (55,59))",array($rootID));
	if (!$resultset) {
		$errorMsg = $db->ErrorMsg();
	} else {
		if ($resultset->RecordCount() == 0) {
			$authentication = true;
		}
	} 
	$resultset->Close();
	
	if (!$authentication){
		$resultset = $db->Execute("SELECT * FROM T_LicenceAttributes where F_RootID = ? and F_Key = 'IPrange' and (F_ProductCode is null or F_ProductCode = '' or F_ProductCode in (55,59))",array($rootID));
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else {
			if ($resultset->RecordCount()==1) {
					$IPrange = $resultset->fields['F_Value'];
					
					if (isIPInRange($ip, $IPrange)) $authentication  = true;
			}
		} 
		$resultset->Close();	
		
		// it is dangerous to send the whole referrer as you might get confused with parameters (specifically content)
		if (isset($_SERVER['HTTP_REFERER'])) {
			if (strpos($_SERVER['HTTP_REFERER'],'?')) {
				$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
			} else {
				$referrer = $_SERVER['HTTP_REFERER'];
			}
		} else if (isset($_SESSION['Referer'])) {
			$referrer = $_SESSION['Referer'];
		}

		if (isset($referrer)){
			$resultset = $db->Execute("SELECT * FROM rack80829.T_LicenceAttributes where F_RootID = ? and F_Key = 'RUrange' and (F_ProductCode is null or F_ProductCode = '' or F_ProductCode in (55,59))",array($rootID));
			if (!$resultset) {
				$errorMsg = $db->ErrorMsg();
			} else {
				if ($resultset->RecordCount()==1) {
						$RUrange = $resultset->fields['F_Value'];
						
						$RUranges = explode(',', $RUrange);
						$RUMatched = false;
						foreach($RUranges as $value){
							if (strpos($referrer, $value) !== FALSE) $RUMatched = true;
						}
						if ($RUMatched) $authentication  = true;
				}
			} 
			$resultset->Close();
		}
	}

if (!$authentication){	
	$resultset = $db->Execute("SELECT * FROM T_LicenceAttributes where F_RootID = ? and F_Key = 'barcode' and (F_ProductCode is null or F_ProductCode = '' or F_ProductCode in (55,59))",array($rootID));
	if (!$resultset) {
		$errorMsg = $db->ErrorMsg();
	} else {
		if ($resultset->RecordCount() == 1) {
			$registerLink = "/library/".strtoupper($_GET["prefix"])."/index.php?pc=59&startPage=start.php";
		}else{
			$registerLink = 'no-prefix.html';
		}
	} 
	$resultset->Close();
}
	
	$db->Close();

function isIPInRange($ip, $ipRangeList) {
	$ipRangeArray = explode(',', $ipRangeList);
	foreach ($ipRangeArray as $ipRange) {
		$ipRange = trim($ipRange);
		
		// loop through the ip addresses you are running from
		$myIpArray = explode(',', $ip);
		foreach ($myIpArray as $myIp) {
			$myIp = trim($myIp);

			// first, is there an exact match?
			if ($myIp == $ipRange)
				return true;
			
			// or does it fall in the range? 
			// assume nnn.nnn.nnn.x-y or nnn.nnn.x-y
			$targetBlocks = explode('.',$ipRange);
			$thisBlocks = explode(".",$myIp);
			// how far down do they specify?
			for ($i=0; $i<count($targetBlocks); $i++) {
				// echo "match ".$thisBlocks[$i]." against ".$targetBlocks[$i]."<br/>";
				if ($targetBlocks[$i] == $thisBlocks[$i]) {
				} else if (strpos($targetBlocks[$i], '-') !== FALSE) {
					$targetArray = explode('-',$targetBlocks[$i]);
					$targetStart = (int) $targetArray[0];
					$targetEnd = (int) $targetArray[1];
					$thisDetail = (int) $thisBlocks[$i];
					if ($targetStart <= $thisDetail && $thisDetail <= $targetEnd) {
						//myTrace("range match " + thisDetail + " between " + targetStart + " and " + targetEnd);
						return true;
					}
				} else {
					//myTrace("no match between " + targetBlocks[i] + " and " + thisBlocks[i]);
					break;
				}
			}
		}
	}
	return false;
}


?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Home | Improve your grammar in 6 weeks</title>
    <link rel="icon" type="image/png" href="images/favicon.png" />
    <link rel="stylesheet" type="text/css" href="css/home.css"/>
    <link rel="stylesheet" type="text/css" href="css/colorbox.css"/>
    <link href='https://fonts.googleapis.com/css?family=Shadows+Into+Light' rel='stylesheet' type='text/css'>

    <script src="https://code.jquery.com/jquery-1.9.1.min.js"></script>
    <!--include jQuery Validation Plugin-->
    <script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.12.0/jquery.validate.min.js"></script>
    <script src="script/jquery.colorbox-min.js"></script>
    <script src="script/login.js"></script>
	<script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
    
      ga('create', 'UA-873320-17', 'auto');
      ga('send', 'pageview');
    
    </script>

</head>

<body>

<div id="holder-index">

    <div id="header-box">
        <div id="header">
            <img src="images/banner-TB.jpg" alt="Improve your grammar in 6 weeks!" width="638" height="191" border="0"/>

      <div id="menu-box">
                <div class="menu select level-test">
                    <div class="arrow on"></div>
                    <div class="num">1</div>
                    <div class="step select">
                        <div class="icon"></div>
                        Level Test
                    </div>
                </div>

                <div class="menu select register">
                    <div class="arrow on"></div>
                    <div class="num">2</div>
                    <div class="step select">
                        <div class="icon"></div>
                        Register
                    </div>
                </div>

                <div class="menu select results">
                    <div class="arrow on"></div>
                    <div class="num">3</div>
                    <div class="step select">
                        <div class="icon"></div>
                        Result
                    </div>
                </div>
            </div>
        </div>
  </div>

    <div id="container-index">
        <div id="content">
            <div class="box border">
                <div class="innerbox get-your-level">
                    <div id="new-user" class="title-rotate">New user</div>
                    <h1>Get your level</h1>

                    <div class="but-area">
                        <a href="<?php echo($registerLink);?>" class="animsition-link button home">Register</a></div>
                </div>
            </div>

            <div class="box">
                <div class="innerbox">
                    <div id="return-user" class="title-rotate">Registered already?<br/>
                        Sign-in here!
                    </div>
                    <form id="loginForm">
                        <div class="box-details">
                            <div class="col top" >
                                <label for="userEmail" class="name home">Email</label><label for="userEmail" class="error home"></label><br />
                                <input class="field" id="userEmail" name="userEmail" type="text" value="<?php echo $_GET['email']; ?>" />
                            </div>
                            <div class="col bottom">
                                <label for="password" class="name home">Password</label><label for="password" class="error home"></label><br />
                                <input class="field" id="password" name="password" type="password"/>
                            </div>

                        </div>

                        <div class="but-area">
                          <input id="signIn" class="button signin" value="Sign in" type="submit" style="margin:0 auto;" />
                      		<input id="loadingMsg" class="button loading" value="Please wait" type="submit" style="margin:0 auto; display:none;"  />
                                
                        <div class="button-below-msg-box"  style="padding-top:8px;">
                        	<div class="error home" id="errorMessage"></div>
                               
                       </div>
                        
                      </div>
                      <a class="forgot home" href="https://www.clarityenglish.com/support/forgotPassword.php" target="_blank">Forgot your password?</a>
                        
                        
                        
                        
                      <div class="clear"></div>
                    </form>
                    <div id="links-function">|&nbsp;<a id="changeLevel">Change my level</a>&nbsp;|&nbsp;<a id="unsubscribe">Unsubscribe</a>&nbsp;|
                    </div>
                </div>
            <div class="clear"></div>
        </div>
        
        	<div class="clear"></div>
    </div>
</div>
</div>

<div id="footer-box">

    <div id="footer">

        <div id="box-position">
            <img src="images/ipad-tensebuster.png" alt="Tense Buster on iPad" id="ipad" width="425" height="115"/>

            <div id="bubble">
                <div id="txtbox"><strong>Now on<Br/><span>Tablet</span></strong></div>
            </div>
            <div id="topic">Download the <strong>Tense Buster app</strong> and study on the go!</div>

               <a href="https://itunes.apple.com/ae/app/tense-buster/id696619890?mt=8" target="_blank"><img src="images/apple-app.png" id="apple"/></a>
               <a href="https://play.google.com/store/apps/details?id=air.com.clarityenglish.tensebuster.app&hl=en" target="_blank"><img src="images/google-play.png" id="googleplay"/></a>
               <a href="https://www.clarityenglish.com/downloads/apk/TenseBuster.php?utm_campaign=APP-APK&utm_source=TB-6wk&utm_medium=TB-6wk-home" target="_blank"><img src="images/android-app.png" id="apk"/></a>             </div>
        </div>
        
        
        <div id="footerline" class="bg-grey">
    <div class="box">
        <a href="https://www.ClarityEnglish.com" target="_blank" id="website">www.ClarityEnglish.com</a>
        <a href="https://www.ClarityEnglish.com" target="_blank"><img src="images/clarityenglish.jpg" border="0"/></a>
        <div class="clear"></div>
    </div>
</div>
        
    </div>
    




</body>
</html>
