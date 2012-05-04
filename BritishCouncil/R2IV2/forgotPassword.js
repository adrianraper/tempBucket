// This script uses action.php to read the user's details based on the login ID.
// Once we have the email address we send a forgot email to it.
$(function() {
	getEmailFromServer = function() {
		var loginID = $("input#loginID").val();
		if( loginID == "" ){
			$.blockUI({ message: $('#specialIDNote') });
		        $('input#mOK').click(function() { 
				$("div#responseMessage").text("");
				$.unblockUI();
				clearAllFields();
				$("input#loginID").focus();
			}); 
			
			return false;
		}
		// TODO. It makes sense to use the whole loginID as the studentID doesn't it?
		var studentID = loginID.substr(6, 8);
		studentID = studentID.substr(0, 3) + studentID.substr(4, 4);
		var formData = "method=forgotPassword&studentID=" + studentID + "&loginID=" + loginID;
		$("div#responseMessage").show();
		
		// call the database processing script
		new jQuery.ajax({
			type: 'POST', 
			dataType: "xml",
			url: 'action.php',
			success:  onGetSuccess,
			data: formData,
			error: onGetError
		});
		
		$("div#responseMessage").text("Please wait while we try to send you an email...");
		return false;
	}

	onGetSuccess = function(data, textStatus) {
		$("div#responseMessage").show();
		// Parse the returned XML node to see if we successfully found the candidate's email or not
		rcActionErr = 0;
		rcEmailErr = 0;
		$("db",data).each(function() {
			// AR but return from getUserDetail has a USER node, not an action node, and an ERR node not a mail one
			// Hmm, except that action.php overwrites the return from the runProgressQuery call.
			$("action",this).each(function() {
				rcUserID = $(this).attr("userID");
				rcName = $(this).attr("name");
				rcStudentID = $(this).attr("studentID");
				rcEmail = $(this).attr("email");
			});
			$("mail",this).each(function() {
					rcEmailErr = $(this).attr("errorCode");
				});
			});
		if (rcEmailErr > 0) {
			// Fire up the thickbox modal window showing the email that we tried to send and ask them to send it directly?
			// It seems we use the message text from the login.php file instead
			if (rcEmailErr==101) {
				$("div#responseMessage").text("You didn't type an email address when you registered. Please contact support.");
			} else {
				$("div#responseMessage").text("This login id has not been registered, " + rcEmailErr + ".");
			}

			$.blockUI({ message: $('#modalDialogEmailFailed') });
		        $('input#mDEFOK').click(function() { 
				$("div#responseMessage").text("");
				$.unblockUI();
				clearAllFields();
			}); 
			
		} else {	
			$.blockUI({ message: $('#mailSendSuccess') });
			$('input#mDSOK').click(function() { 
				$("div#responseMessage").text("");
				$.unblockUI(); 
				clearAllFields();
			});
		}
		return false;
	}

	onGetError = function(XMLHttpRequest, textStatus, errorThrown) {
		// Fire up the thickbox modal window showing the email that we tried to send and ask them to send it directly?
		// It seems we use the message text from the login.php file instead.
		// But you would only come here if there was a system error, rather than an id not found error?
		$("div#responseMessage").text("This login id has not been registered.");
		$.blockUI({ message: $('#modalDialogEmailFailed') });
	        $('input#mDEFOK').click(function() { 
			$("div#responseMessage").text("");
			$.unblockUI();
			clearAllFields();
		}); 
		return false;
	}

	clearAllFields = function() {
		// I think we should keep the ID, but drop the password
		$("input#userPassword").val("");
	}
	$.blockUI.defaults.timeout = 30000; 
	$.blockUI.defaults.css = { 
		width:	'450px', 
		top:		'20%', 
		left:		'30%', 
		padding:	'20px', 
		cursor:	'wait' ,
		textAlign:	'left', 
		padding:	'15px', 
		border:	'none', 
		color:	'#fff',
		backgroundColor:		'#000000',
		'-webkit-border-radius':	'10px', 
		'-moz-border-radius':	'10px'
	};
});
  