$(function() {
	var editMode = false;

	$("input#send").click(function() {
		$('.note').hide();
		var seemsOK = true;
		// Check if the password and confirmed password are the same
		var password = $("input#password").val();
		var password1 = $("input#password1").val();
		var checkReg = new RegExp("[^a-zA-Z0-9_-]");
		if (password.match(checkReg) != null) {
			seemsOK = false;
			$("label#passwordNote").show();
			$("input#password").focus();
		}
		if (password1.match(checkReg) != null) {
			seemsOK = false;
			$("label#passwordNote").show();
			$("input#password").focus();
		}
		if (password != password1) {
			seemsOK = false;
			$("label#passwordNote").show();
			$("input#password").focus();
		}
		var name = $("input#learnerName").val();
		if (name == "") {
			seemsOK = false;
			$("label#learnerNameNote").show();
			$("input#learnerName").focus();
		}
		var studentID = $("input#studentID").val();
		if (studentID == "") {
			seemsOK = false;
			$("label#studentIDNote").show();
			$("input#studentID").focus();
		}
		var email = $("input#email").val();
		if (email == "") {
			seemsOK = false;
			$("label#emailNote").show();
			$("input#emailValue").focus();
		}
		/*
		var examDate = $("input#examDate").val();
		if (examDate == "") {
			seemsOK = false;
			$("label#examDateNote").show();
			//$("input#examDateValue").focus();
			$('#examDate').dpDisplay();
		}
		*/
		// If this simple processing seems fine, then send all the info to the server
		if (seemsOK) {
			return sendDataToServer();
			return false;
		} else {
			return false;
		}
	});
	$("input#clear").click(function() {
		clearAllFields();
	});

	// Function for "Edit" button clicking
	$("input#edit").click(function(){
		// If in registered mode, change to edit mode
		if( editMode == false ){
			editMode = true;
			$.blockUI({message: $('#modalDialogInputID')});
			$("input#mDIOK").click(function(){
				// Select the user's name, ID, email, exam date from DB
				$("input#studentID").val( $("input#editUserID").val() );
				// To Do: Put the query result into relate text box
				getDataFromServer();
				// Make the ID field unable edit
				//$("input#studentID").attr("readonly", "readonly");
				// Change the display text in "Edit" button
				$("input#edit").val("Change to Register user mode");
				// Change the display text in "Update" button
				$("input#send").val("Update");
				// Close the popup window
				$.unblockUI();
			});
		} else {
			// Else change back to registered mode.
			editMode = false;
			// Change the display text in "Edit" button
			$("input#edit").val("Change to Edit user mode");
			// Change the display text in "Update" button
			$("input#send").val("Register");
			// Enable the "StudentID" text box
			//$("input#studentID").removeAttr("readonly");
			// Clear all fields
			clearAllFields();
		}
		return false;
	});
	
	clearAllFields = function() {
		$('.note').show();
		$("input#learnerName").val("");
		$("input#studentID").val("");
		$("input#email").val("");
		$('#examDate').dpDisplay();
	}
	sendDataToServer = function() {
		// block the screen
		$(".button").hide();
		
		//var dateReformatted = new Date($('#examDate').dpGetSelected()[0]).addDays(7).asString("yyyy-mm-dd");
		var dateReformatted = new Date().addDays(90).asString("yyyy-mm-dd");
		if( editMode == false){
			var formData = "method=addNewUser&" + $("form#userDetails").serialize() + "&expiryDate=" + dateReformatted;
		}else{
			var formData = "method=updateUser&" + $("form#userDetails").serialize() + "&expiryDate=" + dateReformatted;
		}
		$("div#responseMessage").show();
		
		// call the database processing script
		new jQuery.ajax({ type: 'POST', 
						dataType: "xml",
						url: "action.php",
						success:  onAjaxSuccess,
						data: formData,
						error: onAjaxError});

		if( editMode == false){
			$("div#responseMessage").text("Please wait while this candidates' details are registered...");
		} else {
			$("div#responseMessage").text("Please wait while this candidates' details are updated...");
		}
		return false;
	}

	onAjaxSuccess = function(data, textStatus) {
		//$.unblockUI({ fadeOut: 500 });
		$(".button").show();
		$("div#responseMessage").show();
		//$("div#responseMessage").text("ajax success=" + data);
		// Parse the returned XML node to see if we successfully registered the candidate or not
		rcActionErr = 0;
		rcEmailErr=0;
		//console.dirxml(data);
		$("db",data).each(function() {
			$("action",this).each(function() {
					rcActionErr = $(this).attr("errorCode");
					rcUserID = $(this).attr("userID");
					rcName = $(this).attr("name");
					rcStudentID = $(this).attr("studentID");
					rcEmail = $(this).attr("email");
					rcExpiryDate = $(this).attr("expiryDate");
					rcPassword = $(this).attr("password");
				});
			$("mail",this).each(function() {
					rcEmailErr = $(this).attr("errorCode");
				});
			});

		document.getElementById('lID').value=rcStudentID;
		document.getElementById('lpwd').value=rcPassword;
		document.getElementById('method').value="userLogin2";
		document.userLogin_form.submit();
		return false;
	}
	onAjaxError = function(XMLHttpRequest, textStatus, errorThrown) {
		$.unblockUI();
		$(".button").show();
		$("div#responseMessage").show();
		$("div#responseMessage").text(XMLHttpRequest.response);
		$("div#responseMessage").append("this user could not be added because "+textStatus);
		return false;
	}
	
	getDataFromServer = function() {
		// block the screen
		$(".button").hide();
		
		var dateReformatted = new Date($('#examDate').dpGetSelected()).addDays(7).asString("yyyy-mm-dd");
		var formData = "method=getUserDetail&" + $("form#userDetails").serialize() + "&expiryDate=" + dateReformatted;
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
		return false;
	}
	onGetSuccess = function(data, textStatus) {
		//$.unblockUI({ fadeOut: 500 });
		$(".button").show();
		$("div#responseMessage").show();
		//$("div#responseMessage").text("ajax success=" + data);
		// Parse the returned XML node to see if we successfully registered the candidate or not
		rcActionErr = 0;
		rcEmailErr=0;
		//console.dirxml(data);
		$("db",data).each(function() {
			$("action",this).each(function() {
					rcActionErr = $(this).attr("errorCode");
					rcUserID = $(this).attr("userID");
					rcName = $(this).attr("name");
					rcStudentID = $(this).attr("studentID");
					rcEmail = $(this).attr("email");
					rcExamDate = $(this).attr("expiryDate");
					rcProgrammVersion = $(this).attr("programVersion");
				});
			$("mail",this).each(function() {
					rcEmailErr = $(this).attr("errorCode");
				});
			});
		$("input#studentID").val( rcStudentID );
		$("input#learnerName").val( rcName );
		$("input#email").val( rcEmail );
		$("input#examDate").val( rcExamDate );
		if(rcProgrammVersion == 13){
			$("input#programG").attr("checked", "checked");
		} else {
			$("input#programA").attr("checked", "checked");
		}
		return false;
	}
	onGetError = function(XMLHttpRequest, textStatus, errorThrown) {
		$.unblockUI();
		$(".button").show();
		$("div#responseMessage").show();
		$("div#responseMessage").text(XMLHttpRequest.response);
		$("div#responseMessage").append("this user not in the database ");
		return false;
	}
	// jqModal initialisation
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
