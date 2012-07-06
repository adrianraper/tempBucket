<?php 
	session_start(  ); 
	//$prefix = $_SESSION['Prefix'] = 'clarity';
	//$rootID = $_SESSION['RootID'] = '163';
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

<!--Fancy Popup Box-->
<script type="text/javascript" src="script/jquery.fancybox-1.3.1.pack.js"></script>
<script type="text/javascript" src="script/jquery.fancybox.custom.js"></script>

<!--POP up script-->
<script type="text/javascript" src="../script/popup.js"></script>

</head>
<?php

require_once('../../domainVariables.php');
$startPage = $domain.'area1/AccessUK/Start.php?prefix='.$_SESSION['Prefix'];


$typedLoginName = $_POST['login_field']; 
$typedPassword = $_POST['password_field']; 


if ($_POST['process'] == "performValidation") {
	require_once('../../db_login.php');
	//$typedLoginName = $_POST['login_field1']; 
	//$typedPassword = $_POST['password_field1']; 
	$len_loginName = strlen($typedLoginName);
	//echo "hello $typedLoginName $typedPassword\n";
	if (($len_loginName > 0)){
		$resultset = $db->Execute("select * from T_User where F_UserName=? and F_Password=?",
			array($typedLoginName, $typedPassword));
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else {
			if ($resultset->RecordCount()==1) {
				$retrievedPassword = $resultset->fields['F_Password'];
				$retrievedUserType = $resultset->fields['F_UserType'];
				if( ($retrievedPassword==$typedPassword) AND ($retrievedUserType>0) ) {
					//echo "That is the correct password\n";
					// Create session variables based on the retrieved user information
					$retrievedUserName = $resultset->fields['F_UserName'];
					$retrievedUserID = $resultset->fields['F_UserID'];
					$retrievedStudentID = $resultset->fields['F_StudentID'];
					$retrievedEmail = $resultset->fields['F_Email'];
					$retrievedExpiryDate = $resultset->fields['F_ExpiryDate'];
					$_SESSION['UserName'] = $retrievedUserName;
					$_SESSION['Password'] = $typedPassword;
					$_SESSION['StudentID'] = $retrievedStudentID;
					$_SESSION['UserID'] = $retrievedUserID;
					$_SESSION['UserType'] = $retrievedUserType;
					$_SESSION['Email'] = $retrievedEmail;
					$_SESSION['UserExpiryDate'] = $retrievedExpiryDate;
					$resultset->Close();
					// and then go to the next page
						echo("<script language=\"javascript\">");
						echo ("top.location.href = \"login.php\";");
						echo("</script>");
				} else if ($retrievedUserType==0) {
						// 7 Oct This page is for teachers only. Show error message instead.
						$errorMsg = "This version is for teachers' use only. Please contact your administrator to use the self access version.";
						//echo ('ProgrampopUp("'.$startPage.'");');
				} else {
					$errorMsg = "Login name and/or password is not correct. The password is case sensitive.";
					//echo "<p>That is the wrong password.\n";
					//echo "Please try again.</p>\n";
				}
			} else { //Not found in userName, try LearnID
				$resultset->Close();
				$resultset = $db->Execute("select * from T_User where F_StudentID=? and F_Password=?",
					array($typedLoginName, $typedPassword));
				if (!$resultset) {
					$errorMsg = $db->ErrorMsg();
				} else {
					if ($resultset->RecordCount()==1) {
						$retrievedPassword = $resultset->fields['F_Password'];
						$retrievedUserType = $resultset->fields['F_UserType'];
						if( ($retrievedPassword==$typedPassword) AND ($retrievedUserType>0) ) {
							// Create session variables based on the retrieved user information
							$retrievedUserName = $resultset->fields['F_UserName'];
							$retrievedUserID = $resultset->fields['F_UserID'];
							$retrievedStudentID = $resultset->fields['F_StudentID'];
							$retrievedUserName = $resultset->fields['F_UserName'];
							$retrievedEmail = $resultset->fields['F_Email'];
							$retrievedExpiryDate = $resultset->fields['F_ExpiryDate'];
							$_SESSION['UserName'] = $retrievedUserName;
							$_SESSION['Password'] = $typedPassword;
							$_SESSION['StudentID'] = $retrievedStudentID;
							$_SESSION['UserID'] = $retrievedUserID;
							$_SESSION['UserType'] = $retrievedUserType;
							$_SESSION['Email'] = $retrievedEmail;
							$_SESSION['UserExpiryDate'] = $retrievedExpiryDate;
							$resultset->Close();
							// and then go to the next page
							echo("<script language=\"javascript\">");
							echo ("top.location.href = \"login.php\";");
							echo("</script>"); 
						} else if ($retrievedUserType==0) {
							// 7 Oct This page is for teachers only. Show error message instead.
							$errorMsg = "This version is for teachers' use only. Please contact your administrator to use the self access version.";
							//echo ('ProgrampopUp("'.$startPage.'");');
						} else {
							$errorMsg = "Login name and/or password is not correct. The password is case sensitive.";
							//echo "<p>That is the wrong password.\n";
							//echo "Please try again.</p>\n";
						}
					} elseif ($resultset->RecordCount()>1) {
						$errorMsg = "Another user is already logged in with this account";
						//echo "<p>More than one user with this learner ID.\n";
						//echo "Please try again.</p>\n";			
					} else {
						$errorMsg = "Login name and/or password is not correct. The password is case sensitive.";
					//echo "<p>No such account.\n";
					//echo "Please try again.</p>\n";	
					}
				}
			}
		}
		$resultset->Close();
		
		// First we need the root
		$resultset = $db->Execute("select * from T_Membership where F_UserID=?",array($retrievedUserID));
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else {
			if ($resultset->RecordCount()>0) {
				$retrievedRootID = $resultset->fields['F_RootID'];
				$_SESSION['RootID'] = $retrievedRootID;
				# GroupID is used for finding Hidden Content
				$retrievedGroupID = $resultset->fields['F_GroupID'];
				$_SESSION['GroupID'] = $retrievedGroupID;
			}
		}
		$resultset->Close();
		
		// School Details
		$resultset = $db->Execute("select F_Name, F_Prefix, F_Email, F_Logo, F_TermsConditions from T_AccountRoot where F_RootID=?",array($retrievedRootID));
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else {
			if ($resultset->RecordCount()==1) { // Should be only one Root
				$retrievedAccountName = $resultset->fields['F_Name'];
				$_SESSION['AccountName'] = $resultset->fields['F_Name'];
				$retrievedAccountPrefix = $resultset->fields['F_Prefix'];
				$_SESSION['Prefix'] = $resultset->fields['F_Prefix'];
				$retrievedAccountEmail = $resultset->fields['F_Email'];				
				$retrievedAccountLogo = $resultset->fields['F_Logo'];
				$retrievedTermsConditions = $resultset->fields['F_TermsConditions'];
				$_SESSION['TermsConditions'] = $retrievedTermsConditions;
				//die('only one Root!');
			} elseif ($resultset->RecordCount()==0) { // no details found
				die('Account detail not found!');
			} else { // go to error page, maybe?
				die('More than one details in one acccount!');
			}
		}
		$resultset->Close();		
		
		
		// NOTE can we also close the connection?
		$db->Close();	
	} else {
		$errorMsg = "You must type in your login name and password";
		//echo "<p>You must type in your name and password.\n";
		//echo "Please try again.</p>\n";
	}
}


?>
<body>
	<div id="container">
    	<div id="header"></div>
        <div id="login_head">
        	Welcome to Access UK: Living and learning in the UK
				<?php if(session_is_registered('UserName')) { ?>
				<input name="" type="button" class="btn_logout" value="Log out" onclick="window.location='db_logout.php'"/>
				<?php } ?>
        </div>
        
      <div id="content">
      
      	<div id="front_banner"></div>
		
		
		
		<?php if( (session_is_registered('UserName')==0) OR ($_SESSION['UserType']>0) ){ ?>
      <div class="login_box">
        	<div id="login_teacher_box">
                 
              <h1>The classroom version</h1>
                <?php if(session_is_registered('UserName')){ ?>
                <input name="" type="button" class="btn_after_login" value="Start Access UK" onclick="location.href='login.php'"/>
				<?php } else { ?>
                <div class="login_content_box">
                  <h2>Log in to use the classroom materials</h2>
                    <form id="form2" name="form" method="post" action="<?php $PHP_SELF ?>" class="loginarea_share" style="margin:0; padding:0;">
                    <div class="login_box_actual">
                      <div class="login_box_actual_field">
                            <div class="fieldname">Name</div>
                            <input name="login_field" type="text" class="fieldfield"/>
                            <div class="clear"></div>
                      </div>
                        
                        <div class="login_box_actual_field">
                            <div class="fieldname">Password</div>
                            <input name="password_field" type="password" class="fieldfield"/>
                            <div class="clear"></div>
                      </div>
                    <input type="hidden" name="process" value="performValidation" style="display:none"/>                    
                      <div class="login_box_effect_field">
                        <div class="login_box_forgot"><a href="forgotpassword.php" class="forgotpw_iframe">Forgot password?</a></div>
                        
                          <input name="input" type="submit" class="btn_loginstart" value="Start here" />
                        <div class="login_box_error"><?php echo $errorMsg; ?></div>
                        </div>
           
                    </div>
                    </form>
                </div>
				<?php } ?>
          </div>
        </div>
        <?php } ?>
		
        
        
        <div class="clear"></div>
        
        </div>
        
        <div id="footer">
        	<div id="footer_line">
            	Data &copy; University of York, 2011. Authors: Chris Copland and Huw Jones.<br />Software &copy; Clarity Language Consultants Ltd, 2011. All rights reserved.
            
   	      <br />
                <a href="contactus.htm" class="contact">Contact us</a> | <a href="http://www.clarityenglish.com/support/user/pdf/cs/CS_Terms_OfficialPDF.pdf" target="_blank">Terms and conditions</a>
            </div>
    <a href="http://www.york.ac.uk/" id="logo_york" target="_blank"></a>
            <a href="http://www.clarityenglish.com/" id="logo_clarity" target="_blank"></a>
        </div>
      
</div>
    


</body>
</html>
