<?php session_start(  ) ?>
<?php
require_once('../db_login.php');

if ($_POST['process'] == "") {
	$prefix = $_GET['prefix'];
	
	if (isset($prefix)) { # confirm get the prefix value from the URL
		$resultset = $db->Execute("select * from T_AccountRoot where F_Prefix =?", array($prefix));
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else { # found the record!
			$retrievedLoginOption = $resultset->fields['F_LoginOption'];
			if (intval($retrievedLoginOption)&128) {
				$retrievedRootID = $resultset->fields['F_RootID'];
				$retrievedSchoolName = $resultset->fields['F_Name'];
				$retrievedSchoolLogo = $resultset->fields['F_Logo'];
				$_SESSION['AccountName'] = $retrievedSchoolName;
				$_SESSION['RootID'] = $retrievedRootID;
				$_SESSION['Shared'] = true;
				$_SESSION['accountPrefix'] = $prefix;
			} else { # not a shared Account, go to main login page
				//echo "This is not a shared account.";
				header("location: ../index.php");
			}
		}
		$resultset->Close();
	} else {
		#get prefix failed.
		echo "No such account.";
	}
}

if ($_POST['process'] == "performValidation") {
	//$typedLoginName = $_POST['loginName']; 
	$typedPassword = $_POST['password'];
	$rootID = $_POST['rootID'];
	$len_Password = strlen($typedPassword);
	//echo "hello $typedLoginName $typedPassword\n";
	//if (($len_loginName > 0)){
	If ($len_Password > 0) {
		$sql = "select * from T_User as u inner join T_Membership as m on u.F_UserID = m.F_UserID"
				." where F_RootID =? and F_Password=?";
		$resultset = $db->Execute($sql,	array($rootID, $typedPassword));
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else {
			if ($resultset->RecordCount()==1) {
				//$retrievedPassword = $resultset->fields['F_Password'];
				//if($retrievedPassword==$typedPassword) {
					//echo "That is the correct password\n";
					// Create session variables based on the retrieved user information
					$retrievedUserName = $resultset->fields['F_UserName'];
					$retrievedUserID = $resultset->fields['F_UserID'];
					$retrievedUserType = $resultset->fields['F_UserType'];
					$retrievedEmail = $resultset->fields['F_Email'];
					$retrievedExpiryDate = $resultset->fields['F_ExpiryDate'];
					$_SESSION['UserName'] = $retrievedUserName;
					$_SESSION['Password'] = $typedPassword;
					$_SESSION['UserID'] = $retrievedUserID;
					$_SESSION['UserType'] = $retrievedUserType;
					$_SESSION['Email'] = $retrievedEmail;
					$_SESSION['F_ExpiryDate'] = $retrievedExpiryDate;
					$resultset->Close();
					// and then go to the next page
					header("location: ../englishonline/index.php");
				//} else {
					//$errorMsg = "Incorrect password.";
					//echo "<p>That is the wrong password.\n";
					//echo "Please try again.</p>\n";
				//}
			}  elseif ($resultset->RecordCount()>1) {
				
				$errorMsg = "Multiple accounts found. Please contact your administrator.";
				//echo "<p>More than one user with this learner ID.\n";
				//echo "Please try again.</p>\n";			
			}  else {
				$errorMsg = "Password is not correct";
				//echo "<p>No such account.\n";
				//echo "Please try again.</p>\n";	
			}
		}
		$resultset->Close();
		// NOTE can we also close the connection?
		$db->Close();
	} else {
		$errorMsg = "You must type in your password";
		//exit;
	}
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Clarity English language teaching software | <?php echo $retrievedSchoolName ?> Home</title>

<!---CSS Global-->
<link rel="stylesheet" type="text/css" href="../css/global.css" />
<link rel="stylesheet" type="text/css" href="../css/home.css" />
<link rel="stylesheet" type="text/css" href="../css/englishonline.css" />

<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="../css/fancybox.css" />

<!--Jquery Library-->
<script type="text/javascript" src="../script/jquery.js"></script>

<!--Fancy Popup Box-->
<script type="text/javascript" src="../script/fancybox.js"></script>
<script type="text/javascript" src="../script/fancybox_custom.js"></script>

</head>

<body id="home_page">
<div id="container">
<?php 
// Is this a new entry to the page?
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
	//echo "Please type your details:\n";
	$typedLoginName="";
	#$errorMsg="Please login.";
} else {
	// Now done at the top of the page so you can redirect if successful
}
?>

  <!--header area-->
<?php include ( 'header.php' ); ?>
<!--End of header area-->
  
  <!--middle box-->
  <div id="middlebox">
  <!--middle box left-->
   <div id="middleboxleft"> 
   

      		<?php include ( '../index_left.php' ); ?>

    
   </div>
  
  <!--middle box right-->
    <div id="middleboxright">
      <div id="loginpanel_share">
        <h2><?php echo $_SESSION['AccountName'] ?> Online</h2>
		<?php if(session_is_registered('UserName') == 0) { ?>       
		<form id="form1" name="form1" method="post" action="<?php $PHP_SELF ?>" class="loginarea_share">
        <?php if ($retrievedSchoolLogo <> "") { ?>
        <img src="schoollogo/<?php echo $retrievedSchoolLogo?>" />
		<?php } ?>
          <p>Password:</p>
          <input type="password" name="password" id="password" class="loginfield" accesskey="p" tabindex="2"/>
        
        <div id="loginaction">
          <div id="loginlink_box"><a href="mailto: support@clarityenglish.com?subject=Anonymous Access licence login enquiry">Need help?</a></div>
          <div id="loginbutton">
            <!--<a href="englishonline/index.htm"><input name="Signin" type="button" value="Sign in" id="loginbutton"/></a>-->
			<input type="submit" name="Signin" id="loginbutton" value="" accesskey="g" tabindex="3" class="redbtn_small_login"/>
			<input type="hidden" name="process" value="performValidation" style="display:none"/>
			<input type="hidden" name="rootID" value="<?php echo $_SESSION['RootID']?>" style="display:none"/>
          </div>
        </div>
		</form>
		<?php } else { ?>
  <div class="login_after_msg_share">
        
        	<p>Welcome <?php echo $_SESSION['UserName'];?> (<?php echo $_SESSION['UserTypeName'];?>)</p>
            <p><?php echo $_SESSION['schoolName'];?></p>
        </div>
            <div class="loginbottom_after_msg_share">
				<?php if(session_is_registered('UserName') == 1) { ?><a href="../db_logout.php">Logout</a><?php } ?>
			</div>
            
	    <?php } ?>
        <div class="loginbottom_share"><?php echo $errorMsg; ?></div>
      </div>
      
      
           

    	<div class="logo_right_button">
                <a href="mailto:info@clarityenglish.com">
                	<p class="customer_right_button_header"></p>
                </a>
                </div>
              
        
	  </div>


  

  <!--footer css-->
  <div id="footer">
    <?php include ( '../footer.php' ); ?>
    </div>
</div>
</div>
</body>
</html>