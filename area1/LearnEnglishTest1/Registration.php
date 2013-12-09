<?php
session_start();
//$domain = $_SERVER['HTTP_HOST'];
unset($_SESSION);
if( isset($_GET['code']) ) {
	$errorCode = $_GET['code'];
} else {
	$errorCode="";
}
$errorMessage = "";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>British Council LearnEnglish Level Test - registration</title>
<link rel="shortcut icon" href="favicon.ico" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="css/common.css" type="text/css" />

<link type="text/css" href="/Software/Common/jQuery/development-bundle/themes/base/ui.all.css" rel="stylesheet" />
<script type="text/javascript" src="/Software/Common/jQuery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="/Software/Common/jQuery/js/jquery-ui-1.7.custom.min.js"></script>
<script type="text/javascript" src="/Software/Common/jQuery/ui/ui.core.js"></script>
<script type="text/javascript" src="/Software/Common/jQuery/js/blockUI-2.js"></script>
<script type="text/javascript" src="validation.js"></script>
</head>

<body>
    <div id="container_afterlogin">
      <div id="userAdminBar"><!--Welcome to British Council | <a href="logout.php">Logout</a> | <a href="mailto:support@clarityenglish.com">Contact us</a>--></div>
        <div id="userDetails_form">
        <div id="table_top"></div>
        
            <div id="addlearner_title">
                <p>Dear Educator</p>
                <p>You have been nominated to participate in a pilot program between Microsoft and British Council that will allow educators to assess their English skills. We invite you to follow the link below to take an assessment test, which will result in a level score.</p>
                <p>To best take advantage of the upcoming Microsoft events, your score should be a minimum of level B1 (intermediate) Common European Framwork of Reference for Languages. If you score below this level, we will provide you with a link to additional training in English Language skills.</p>
                <p>Good luck!</p>
                <p>Sincerely<br/>
                Microsoft Partners in Learning/ British Council</p>
            </div>
            <form id="userDetails" name="userDetails" onSubmit="return false;">
        
                <!-- Login table Start -->
                <ul>
                    <li id="learnerNameField">
                        <p class="labelname"><label for="learnerName" id="nameLbl">Your name:</label></p>
                        <p class="labeltitle"><input type="text" name="learnerName" id="learnerName" value="" tabindex="1" class="field" /></p>
                        <p class="labelnameNote"><label for="learnerName" id="learnerNameNote" style="display:none;">This name will be shown on your result.</label></p>
                        <p class="clear"></p>
                    </li>
                    <li id="learnerEmailField">
                        <p class="labelname"><label for="learnerEmail" id="emailLbl">Your email:</label></p>
                        <p class="labeltitle"><input type="text" name="learnerEmail" id="learnerEmail" value="" tabindex="2" class="field" /></p>
                        <p class="labelemailNote"><label for="learnerEmail" id="learnerEmailNote" style="display:none;">Your email is used to find your result later.</label></p>
                    </li>
                </ul>
                <div class="button_area">
                    <input id="send" name="send" type="submit" value="Enter" tabindex="2" class="button_short" />
                    <input id="clear" name="clear" type="submit" value="Clear" tabindex="3" class="button_short" />
                    <div id="responseMessage" class="note"></div>
                </div>
            </form>
            
            <div id="userLogin_div">
                <!-- Hidden fields for use in activating login after registration. TODO. work this from validation.js  -->
                <form id="userStart_form" action="action.php" method="post" style="margin:0; padding:0;">
                    <input type="hidden" id="regMethod" name="method" value="startUser"  />
                    <input type="hidden" id="regUserID" name="regUserID" value=""></input>
                </form>
            </div>
            
            <a id="link_clarity_logo" href="http://www.clarityenglish.com" target="_blank"></a>
            <a id="link_clarity_txt" href="http://www.clarityenglish.com" target="_blank">www.clarityenglish.com</a>            </div>
    
    
    
    </div>




</body>
</html>