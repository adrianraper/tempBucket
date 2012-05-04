<?php
session_start();
include_once "variables.php";
$thistime = $_SERVER['REQUEST_TIME']*1000;

if (isset($_SESSION['loginID']))
	$loginID = $_SESSION['loginID'];

function redirect ($url) {
	header('Location: ' . $url);
	exit;
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  

<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">  
<head>
<title>British Council Road to IELTS - candidate registration</title>
<link rel="shortcut icon" href="<?php echo $commonDomain; ?>Software/R2IV2.ico" type="image/x-icon" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<link rel="stylesheet" href="css/general.css" type="text/css" /> 
<link type="text/css" href="<?php echo $commonDomain; ?>Software/Common/jQuery/development-bundle/themes/base/ui.all.css" rel="stylesheet" />
<link type="text/css" href="<?php echo $commonDomain; ?>Software/Common/jQuery/css/datepicker.css" rel="stylesheet" />

<script type="text/javascript" src="<?php echo $commonDomain; ?>Software/Common/jQuery/js/date.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain; ?>Software/Common/jQuery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain; ?>Software/Common/jQuery/js/jquery-ui-1.7.custom.min.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain; ?>Software/Common/jQuery/ui/ui.core.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain; ?>Software/Common/jQuery/js/jquery-ui-datePicker-2.1.2.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain; ?>Software/Common/jQuery/js/blockUI-2.js"></script>
<script type="text/javascript" src="validation.js"></script>
<script type="text/javascript" >
$(document).ready(function(){
	$('input#loginID').val("<?php echo $loginID?>");
	var actionFile;
	actionFile = "<?php echo $thisDomain.$startFolder ?>action.php";
	//console.log("actionfile=", actionFile);
});
</script>
</head>

<body>	

<div id="header"><div id="userAdminBar">
	Welcome to RoadToIELTS | <a href="mailto:support@roadtoielts.com">Contact us</a>
</div>
</div>

</div>
<div id="container_afterlogin">

        	
            
            <div id="loginbox">
            
            <div id="afterlogin_left"></div>
    	
        <div id="afterlogin_mid">

	
<div id="userDetails_form">
	<div class="addlearner_title">Type in your details.</div>
        <form id="RegisterForm" method="post" action="" >
	
        <fieldset>
		 <p class="complete_title">All fields must be completed.</p>
<!-- Login table Start -->
<ul>
    <li id="loginIDField">
        <p class="labelname">
          <label for="loginID" id="loginIDLbl">Login ID :</label></p>
        <p class="labeltitle">
        <input type="text" name="loginID" id="loginID" size="25" value="<?php echo $loginID; ?>" class="field" readonly="readonly" />
        </p>
        <p class="labeltitle"><label for="loginID" id="loginIDNote" class="note">Always use this ID to login.</label></p>
    </li>

<li id="learnerNameField">
    <p class="labelname"><label for="learnerName" id="nameLbl">Your name :</label></p>
    <p class="labeltitle">
		<input type="text" name="learnerName" id="learnerName" value="" tabindex="4" class="field" maxlength="64"/>
    </p>
    <p class="labeltitle"><label for="learnerName" id="learnerNameNote" class="note">For display only, not login.</label></p>
</li>

	<li id="passwordField">
	    <p class="labelname"><label for="password" id="nameLbl">Password :</label></p>
	    <p class="labeltitle">
		<input type="password" name="password" id="password" value="" tabindex="5" class="field" maxlength="32"/>
	    </p>
	    <p class="labeltitle"><label for="password" id="passwordNote" class="note">Your new password.</label></p>
	</li>
	<li id="password1Field">
	    <p class="labelname"><label for="password1" id="nameLbl">Confirm password :</label></p>
    <p class="labeltitle">
		<input type="password" name="password1" id="password1" value="" tabindex="6" class="field" maxlength="32"/>
    </p>
	    <p class="labeltitle"><label for="password11" id="password11Note" class="note"></label></p>
</li>

<li id="emailField">
    <p class="labelname"><label for="email" id="emailLbl" >Your email :</label></p>
    <p class="labeltitle">
		<input type="text" name="email" id="email" size="25"  value="" tabindex="7" class="field" maxlength="128"/>
    </p>
    <p class="labeltitle"><label for="email" id="emailNote" class="note">This email address will only be used to send you information about Road to IELTS.</label></p>
</li>

</ul>

<div class="button_area">

	<!-- this triggers the jQuery in validation.js -->
	<input type="hidden" id="productCode" name="productCode" value="<?php echo $productCode; ?>" />
	<input type="hidden" id="expiryDate" name="expiryDate" value="<?php echo $expiryDate; ?>" />
	<input id="RegisterSubmit" name="RegisterSubmit" type="submit" value="" tabindex="9" class="button_submit"/>
	<input id="clearFields" name="clearFields" type="submit" value="" tabindex="10" class="button_clear"/>
<div id="responseMessage" class="note"></div>
</div>

</fieldset>
</form>
</div>

<div id="modalDialogInputID" style="display:none; cursor:default"> 
        <h1>Please input the student's ID who you want to edit.</h1> 
	<p></p>
	<input type="text" id="editUserID" name="editUserUD" size=25 value="" class="field"/>
        <input type="button" id="mDIOK" value="OK" /> 
</div>
<div id="modalDialogDuplicate" style="display:none; cursor:default"> 
        <h1>A candidate with this ID has already been added.</h1> 
	<p>Please check the ID, or click to edit if the candidate might already be registered.</p>
	<p id="mDDname">Name: name</p>
	<p id="mDDid">ID: id</p>
        <input type="button" id="mDDOK" value="OK" /> 
</div>
<div id="modalDialogOther" style="display:none; cursor:default"> 
        <h1>This candidate could not be added to the system.</h1> 
	<p>Please check the details and try again.</p>
	<p id="mDOname">Name: name</p>
	<p id="mDOid">ID: id</p>
        <input type="button" id="mDOOK" value="OK" /> 
</div>
<div id="modalDialogSuccess" style="display:none; cursor:default"> 
        <h1>This candidate has been successfully added.</h1> 
	<p>An email has been sent with the following details:</p>
	<p id="mDSto">To: email</p>
	<p id="mDSname">Name: name</p>
	<p id="mDSid">ID: id</p>
	<p id="mDSpassword">Password: password</p>
	<p id="mDSexpiryDate">Expiry date: expiry</p>
	<p>This account at www.britishcouncil.org/learning-ielts.htm is now active.</p>
	<p>The candidate can change the password when they start the program.</p>
        <input type="button" id="mDSOK" value="OK" /> 
</div>
<div id="modalUpdateSuccess" style="display:none; cursor:default"> 
        <h1>This candidate has been successfully updated.</h1> 
	<p>An email has been sent with the following details:</p>
	<p id="mDUto">To: email</p>
	<p id="mDUname">Name: name</p>
	<p id="mDUid">ID: id</p>
	<p id="mDUpassword">Password: password</p>
	<p id="mDUexpiryDate">Expiry date: expiry</p>
	<p>This account at www.britishcouncil.org/learning-ielts.htm is now active.</p>
	<p>The candidate can change the password when they start the program.</p>
        <input type="button" id="mDUOK" value="OK" /> 
</div>
<div id="modalDialogEmailFailed" style="display:none; cursor:default"> 
        <h1>This candidate has been successfully added.</h1> 
	<p>But the email could not be sent:</p>
	<p id="mDEFto">To: email</p>
	<p id="mDEFname">Name: name</p>
	<p id="mDEFid">ID: id</p>
	<p id="mDEFpassword">Password: password</p>
	<p id="mDEFexpiryDate">Expiry date: expiry</p>
	<p>This account at www.britishcouncil.org/learning-ielts.htm is now active.</p>
	<p>The candidate can change the password when they start the program.</p>
	<h1>Please confirm the email address. If it is right please give the candidate these details yourself.</h1>
        <input type="button" id="mDEFOK" value="OK" /> 
</div>

</div>
<div id="afterlogin_right"></div>

<div class="clear"></div>



</div>

<div id="welcomeNotes">
<div class="addlearner_title">Notes for testing</div>
<p>Please try to use Road to IELTS as much as you can for a few days - or longer! When you have done as much as you want, please complete a survey. The survey can be run at <a href="http://www.clarityenglish.com/questionnaire/rtiv2feedback.php" target="_blank">http://www.clarityenglish.com/questionnaire/rtiv2feedback.php</a>. This URL is also on the Help page.</p>
<p>This will let us find out what you thought of Road to IELTS and any problems you had.</p>
<p>One of the questions we will ask is how long it took you to start Road to IELTS the first time. That will happen after you click 'Submit' on the left. Please try to note down how many seconds/minutes it takes.</p>
<p>If you have problems, please do email support@roadtoielts.com and we will help you.</p>
<div class="addlearner_title">Thank you very much!</div>
</div>





<!-- doesn't seem to be used -->
<div id="userLogin_div">
	<form id="userLogin_form" name="userLogin_form" action="action.php" method="post">
	<input type="hidden" id="lID" name="lID" value=""></input>
	<input type="hidden" id="lpwd" name="lpwd" value=""></input>
	<input type="hidden" id="method" name="method" value=""></input>
	</form>

</div>
    


</div>


</body>
</html>
