<?php
session_start();
include_once "Variables.php";
$thistime = $_SERVER['REQUEST_TIME']*1000;
$rootID = $_SESSION['rootID'];
$groupID = $_SESSION['groupID'];
$userEmail = $_SESSION['userEmail'];
$userName = $_SESSION['userName'];
$studentID = $_SESSION[ 'studentID' ];
$loginID = $_SESSION['loginID'];
$programVersion = $_SESSION[ 'programVersion' ];
if ($groupID > 0) {
	// good - we can keep going
} else {
	redirect($domain.$startFolder."login.php");
}

function redirect ($url) {
	header('Location: ' . $url);
	exit;
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  

<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">  
<head>
<title>British Council Road to IELTS - candidate registration</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<link rel="stylesheet" href="css/general.css" type="text/css" /> 
<link type="text/css" href="<? echo $domain ?>/Software/Common/jQuery/development-bundle/themes/base/ui.all.css" rel="stylesheet" />
<link type="text/css" href="<? echo $domain ?>/Software/Common/jQuery/css/datepicker.css" rel="stylesheet" />

<!-- <link type="text/css" href="../Software/Common/jQuery/css/thickbox.css" rel="stylesheet" /> -->
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/date.js"></script>
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/jquery-ui-1.7.custom.min.js"></script>
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/ui/ui.core.js"></script>
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/jquery-ui-datePicker-2.1.2.js"></script>
<!-- <script type="text/javascript" src="../Software/Common/jQuery/js/thickBox-3.1.js"></script> -->
<script type="text/javascript" src="<? echo $domain ?>/Software/Common/jQuery/js/blockUI-2.js"></script>
<script type="text/javascript" src="validation.js"></script>
<script type="text/javascript" >
$(document).ready(function(){
	/*
	Date.firstDayOfWeek = 1;
	Date.format = 'dd mmmm, yyyy';
	$("#examDate").datePicker({
		startDate: (new Date(<? echo $thistime ?>)).asString(),
		endDate: (new Date(<? echo $thistime ?>).addMonths(3)).asString()
	});
	$('#examDate').dpDisplay();
	*/
	$('input#studentID').val("<? echo $studentID?>");
	var program = "<?echo $programVersion?>";
	if( program == "A"){
		$("input#programA").attr("checked", "checked");
	} else {
		$("input#programG").attr("checked", "checked");
	}
	var actionFile;
	actionFile = "<? echo $domain.$startFolder ?>action.php";
	//console.log("actionfile=", actionFile);
});
</script>
</head>

<body>	
<div id="container_afterlogin">
     
<div id="userAdminBar">
	Welcome to RoadToIELTS | <a href="logout.php">Logout</a> | <a href="mailto:support@clarityenglish.com">Contact us</a>
</div>
        
<div id="userDetails_form">
		<div id="addlearner_title">Type the candidate's details.</div>
        <form id="userDetails" name="userDetails" method="post" action="" >
        <fieldset>
		 <p class="complete_title">All fields must be completed. Please use the English alphabet.</p>
<!-- Login table Start -->
<ul>
    <li id="loginIDField">
        <p class="labelname">
          <label for="loginID" id="loginIDLbl">Login ID :</label></p>
        <p class="labeltitle">
        <input type="text" name="loginID" id="loginID" size="25" value="<?php echo $_SESSION['loginID']; ?>" class="field" readonly/>
        </p>
        <p class="labeltitle"><label for="loginID" id="loginIDNote" class="note">Always use this ID to login.</label></p>
    </li>
	<li id="studentIDField" style="display:none">
	    <p class="labelname">
	      <label for="studentID" id="studentIDLbl">Candidate's ID :</label></p>
	    <p class="labeltitle">
		<input type="text" name="studentID" id="studentID" size="25" value="" tabindex="1" class="field" readonly/>
	    </p>
	    <p class="labeltitle"><label for="studentID" id="studentIDNote" class="note">A unique ID that will be used to login to the account.</label></p>
	</li>
	<li id="programField" style="display:none">
    <p class="labelname"><label for="programGroup" id="programLbl">Program :</label></p>
    <p class="labeltitle">
		<input type="radio" id="programA" name="programGroup" value="12" checked="checked" tabindex="2">
	<span style="font-size:11px;"><label for="programA" id="programALbl" >Academic</label></span><br />
		<input type="radio" id="programG" name="programGroup" value="13" tabindex="3">
	<span style="font-size:11px;"><label for="programG" id="programLbl">General Training</label></span>
    </p>
    <p class="labeltitle"><label for="programGroup" id="programNote" class="note">Which exam is the candidate sitting?</label></p>
</li>

<li id="learnerNameField">
    <p class="labelname"><label for="learnerName" id="nameLbl">Candidate's name :</label></p>
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
	    <p class="labeltitle"><label for="password" id="passwordNote" class="note">The candidate's password. (Please use "a-z A-Z 0-9 _ -" charactor)</label></p>
	</li>
	<li id="password1Field">
	    <p class="labelname"><label for="password1" id="nameLbl">Confirm Password :</label></p>
    <p class="labeltitle">
		<input type="password" name="password1" id="password1" value="" tabindex="6" class="field" maxlength="32"/>
    </p>
	    <p class="labeltitle"><label for="password11" id="password11Note" class="note">The two passwords must be the same.</label></p>
</li>

<li id="emailField">
    <p class="labelname"><label for="email" id="emailLbl" >Email :</label></p>
    <p class="labeltitle">
		<input type="text" name="email" id="email" size="25"  value="" tabindex="7" class="field" maxlength="128"/>
    </p>
    <p class="labeltitle"><label for="email" id="emailNote" class="note">This email address is used to send the candidate account information.</label></p>
</li>

<!-- note that examDate field doesn't have a name attribute so that jquery.serialize doesn't pick it up, we do it manually
<li>

    <p class="labelname"><label for="examDate" id="examDateLbl" >Exam date :</label></p>

    <p class="labeltitle">
		<input type="text" id="examDate" readonly tabindex="8" class="field_date"/>
    </p>
    <p class="labeltitle"><label for="examDate" id="examDateNote" class="note">Click the calendar to select your exam date. 3 months from now is the limit.</label>
    </p>   
</li>
-->
</ul>

<div class="button_area">

	<input id="send" name="send" type="submit" value="Submit" tabindex="9" class="button_long"/>
	<input id="clearFields" name="clearFields" type="submit" value="Clear fields" tabindex="10" class="button_long"/>
	<!--
	<input id="edit" name="edit" type="submit" value="Change to Edit user mode" tabindex="9" class="button_long"/>
	-->
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
<div id="userLogin_div">
	<form id="userLogin_form" name="userLogin_form" action="action.php" method="post">
	<input type="hidden" id="lID" name="lID" value=""></input>
	<input type="hidden" id="lpwd" name="lpwd" value=""></input>
	<input type="hidden" id="method" name="method" value=""></input>
	</form>
</div>
</body>
</html>
