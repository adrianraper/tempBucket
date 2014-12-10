// This script uses action.php to read the user's details based on the login ID.
$(function() {

	// Form validation 
	$("input#LoginSubmit").click(function() {
		seemsOK = true;
		// Do any validation of the form first
		if ($("input#learnerName").length) {
			var studentName = $("input#learnerName").val();
			if (studentName == "") {
				seemsOK = false;
				$("input#learnerName").focus();
			}
		}
		if ($("input#learnerEmail").length) {
			var studentEmail = $("input#learnerEmail").val();
			if (studentEmail == "") {
				seemsOK = false;
				$("input#learnerEmail").focus();
			}
		}
		if ($("input#learnerID").length) {
			var studentID = $("input#learnerID").val();
			if (studentID == "") {
				seemsOK = false;
				$("input#learnerID").focus();
			}
		}
		if (seemsOK) {
			return sendMethodToAction();
			//return false;
		} else {
			return false;
		}
	});

	// Call the action script
	sendMethodToAction = function() {
		// block the button to avoid double clicking
		$("input#LoginSubmit").hide();
		
		var formData = "method=addNewUser&" + $("form#loginForm").serialize();
		$("div#responseMessage").show();
		$("div#responseMessage").text("Please wait while your details are checked...");
		// alert(formData); return false;
		// call the database processing script
		new jQuery.ajax({ type: 'POST', 
						url: "action.php",
						data: formData,
						dataType: "json",
						success:  onAjaxSuccess,
						error: onAjaxError});

		return false;
	};

	onAjaxSuccess = function(data, textStatus) {

		$("input#LoginSubmit").show();
		$("div#responseMessage").text("");
		$.unblockUI();
		
		// We might have an error
		if (data.error) {
			$(".button").show();
			
			$("div#responseMessage").show();
			switch (data.error) {
				case 201:
				case 202:
				case 204:
				case 209:
					var errorID = 'invalidIDorPassword';
					break;
				case 206:
				case 220:
					errorID = 'duplicateEmail';
					break;
				default:
					errorID = 'unexpected';
					break;
			}
			// ODD: If you just do { }message: $('div#' + errorID) } it will work once, but second time doesn't pick up any text.
			$.blockUI({ message: $('div#' + errorID).html() });
			$('input#mOK').click(function() { 
				$("div#responseMessage").text("");
				$.unblockUI();
				clearAllFields();
			}); 			
		
		// Or a redirect
		} else if (data.redirect) {
			window.location = data.redirect;
			
		// Anything else is unexpected
		} else {
			errorID = 'unexpected';
			$.blockUI({ message: $('div#' + errorID).html() });
			$('input#mOK').click(function() { 
				$("div#responseMessage").text(data.message + ", error=" + data.error);
				$.unblockUI();
				clearAllFields();
			}); 			
		}
		return false;
	};
	onAjaxError = function(XMLHttpRequest, textStatus, errorThrown) {
		$.unblockUI();
		$(".button").show();
		$("div#responseMessage").show();
		$("div#responseMessage").text("textStatus="+textStatus + " errorThrown=" + errorThrown);
		return false;
	};

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
  