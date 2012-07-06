// JavaScript Document

function checkLogin() {
	var loginID = $("input#AccessUKLogin").val();
	var password = $("input#CLSPassword").val();
	document.getElementById("CLSLoginErrorArea").style.display = "block";
	//remove all the class add the messagebox classes and start fading
	$("#CLSLoginMsgTitle").text('').fadeIn("slow");
	$("#CLSLoginMsg").text(getCopyForId('BuyStep2Checking')).fadeIn("slow");
	// first check if the fields are empty
	if ((loginID=='')||(password=='')){ 
				$("#CLSLoginMsgTitle").fadeTo(200,0.1,function() {
					$(this).html(getCopyForId('LoginFailedSorry')).fadeTo(900,1);
				});
				$("#CLSLoginMsg").fadeTo(200,0.1,function() {
					$(this).html(getCopyForId('LoginFailedEmptyDetails')).removeClass().addClass('msg_error').fadeTo(900,1);
				});	
	} else {	
		//check the username exists or not from ajax
		$.post(commonPortal+"user_loginCheck.php",{ id:loginID, pwd:password } ,function(data, textStatus) {
			//alert(textStatus+': ' + data);
			var loginsuccess = '';
			loginSuccess = data.substring(0,3);
			//alert (loginSuccess);
			if(loginSuccess=='yes') { // login success
				window.location='mypackage.php';
			} else { //login failed
				$("#CLSLoginMsgTitle").fadeTo(200,0.1,function() { //start fading the messagebox
					//add message and change the class of the box and start fading
					$(this).html(getCopyForId('LoginFailedSorry')).removeClass().addClass('msg_error').fadeTo(900,1);
				});
				$("#CLSLoginMsg").fadeTo(200,0.1,function() { //start fading the messagebox
					//add message and change the class of the box and start fading
					$(this).html(getCopyForId('LoginFailedWrongDetails')+', '+data).removeClass().addClass('msg_error').fadeTo(900,1);
				});
			}
		});
	}
}

function updateAccount(userID, originalPassword) {
	var newPassword=$("input#newPassword").val();
	var confirmPassword=$("input#confirmPassword").val();
	document.getElementById("updateAccountMsg").style.display = "block";
	$("#updateAccountMsg").text(getCopyForId('BuyStep2Checking')).removeClass().addClass('msg').fadeIn("slow");
	// first do same simple check before database check.
	if ((newPassword=='')||(confirmPassword=='')){ 
				$("#updateAccountMsg").fadeTo(200,0.1,function() { //passwordUpdateMissingFields
					$(this).html(getCopyForId('MyPackageUpdateTwoPasswords')).removeClass().addClass('msg_error').fadeTo(900,1);
				});	
	} else if (newPassword!=confirmPassword){ 
				$("#updateAccountMsg").fadeTo(200,0.1,function() { //passwordUpdateDifferentPasswords
					$(this).html(getCopyForId('MyPackageSamePassword')).removeClass().addClass('msg_error').fadeTo(900,1);
				});	
	//RL: As the original password may change, the js value may be incorrect. Has to check in database.
	//} else if (newPassword==originalPassword){ 
	//			$("#updateAccountMsg").fadeTo(200,0.1,function() { //passwordUpdateNoChange
	//				$(this).html(getCopyForId('MyPackageCurrentPassword')).removeClass().addClass('msg_error').fadeTo(900,1);
	//			});	
	} else {
		// RL: we don't need the original password as it will be picked up in the php
		//$.post(domain + "Software/Common/Portal/"+"updateAccountDetails.php",{ userID:userID, originalPassword:originalPassword, newPassword:newPassword } ,function(data) {
		$.post(domain + "Software/Common/Portal/"+"updateAccountDetails.php",{ userID:userID, newPassword:newPassword } ,function(data) {
			switch (data) {
				case '1':
					$("#updateAccountMsg").fadeTo(200,0.1,function() { //passwordUpdateChangeSuccess
						$(this).html(getCopyForId('MyPackagePasswordChanged')).removeClass().addClass('msg_ok').fadeTo(900,1); 
					});
				break;
				case '-1':
					$("#updateAccountMsg").fadeTo(200,0.1,function() { //passwordUpdateDBRecordsNotMatched
						$(this).html(getCopyForId('MyPackagePasswordWrong')).removeClass().addClass('msg_OK').fadeTo(900,1);
					});
				break;				
				case '-2':
					$("#updateAccountMsg").fadeTo(200,0.1,function() { //passwordUpdateMultipleAccounts
						$(this).html(getCopyForId('MyPackageNoAccount')).removeClass().addClass('msg_OK').fadeTo(900,1);
					});
				break;
				default:
					$("#updateAccountMsg").fadeTo(200,0.1,function() { //passwordUpdateOtherErrors
						$(this).html(getCopyForId('BuyStep2UnknownError')).removeClass().addClass('msg_OK').fadeTo(900,1);
					});
				break;				
			}
		});	
	}
}

// Ask the expert
function AskTheExpert() {
	var name = $("input#AskForExpertUserName").val();
	var email = $("input#AskForExpertEmail").val();
	var country = $("input#AskForExpertCountry").val();
	var expiryDate = $("input#AskForExpertExpiryDate").val();
	var IELTSversion = $("input#IELTSversion").val();
	var question = $("textarea#AskForExpertContent").val();
	// first do same simple check.
	//alert(domain);
	$("#AskForExpertMsg").text('');
	if ((name=='')||(email=='')||(country=='')||(expiryDate=='')){ 
				$("#AskForExpertMsg").fadeTo(200,0.1,function() { //passwordUpdateMissingFields
					$(this).html(getCopyForId('MyPackageNoAccount')).removeClass().addClass('msg_error').fadeTo(900,1);
				});	
	} else if (question==''){ 
				$("#AskForExpertMsg").fadeTo(200,0.1,function() { //passwordUpdateDifferentPasswords
					$(this).html(getCopyForId('MyPackageTypeEnquiry')).removeClass().addClass('msg_error').fadeTo(900,1);
				});	
	} else { 
		$("#AskForExpertMsg").text(getCopyForId('BuyStep2Checking')).removeClass().addClass('msg').fadeIn("slow");
		// Call email to send.
		$.post(domain + "Software/Common/Portal/"+"EmailToExpert.php",{ name:name, email:email, country:country, expiryDate:expiryDate, IELTSversion:IELTSversion, question:question } ,function(data) {
//			switch (data) {
//				case '1': // success
					$("#AskForExpertMsg").fadeTo(200,0.1,function() { //passwordUpdateChangeSuccess
						$(this).html(getCopyForId('MyPackageEnquirySent')).removeClass().addClass('msg_ok').fadeTo(900,1); 
					});
//				break;
//				case '0': // unsuccess
//					$("#AskForExpertMsg").fadeTo(200,0.1,function() { //passwordUpdateDBRecordsNotMatched
//						$(this).html(getCopyForId('MyPackageEnquiryNotSent')).fadeTo(900,1);
//					});
//				break;							
//			}		
		});
	}
}

function programStartUp(link) {
$.post("generateArgList.php",{} ,function(data) {
		//alert(data);
		//ProgrampopUp(link+"?prefix=100153&userID=72020&password=clarity");
		ProgrampopUp(link+data);
});	
}