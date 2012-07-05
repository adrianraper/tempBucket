$(function() {

	// Form validation 
	$("input#RegisterSubmit").click(function() {
		seemsOK = true;
		// Check if the password and confirmed password are the same
		var password = $("input#password").val();
		var password1 = $("input#password1").val();
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
		var studentID = $("input#loginID").val();
		if (studentID == "") {
			seemsOK = false;
			$("label#loginIDNote").show();
			$("input#studentID").focus();
		}
		var email = $("input#email").val();
		if (email == "") {
			seemsOK = false;
			$("label#emailNote").show();
			$("input#emailValue").focus();
		}
		// If the expiry date is empty, we will just give a 3month subscription
		
		// If this simple processing seems fine, then send all the info to the server
		if (seemsOK) {
			return sendMethodToAction();
		} else {
			return false;
		}
	});
	$("input#clearFields").click(function() {
		clearAllFields();
	});

	clearAllFields = function() {
		$('.note').show();
		$("input#learnerName").val("");
		$("input#loginID").val("");
		$("input#email").val("");
		// $('#examDate').dpDisplay();
	};
	
	// Call the action script
	sendMethodToAction = function() {
		// block the button to avoid double clicking
		$("input#RegisterSubmit").hide();
		
		var formData = "method=addNewUser&" + $("form#RegisterForm").serialize();
		$("div#responseMessage").show();
		$("div#responseMessage").text("Please wait while your details are registered...");
		
		// call the database processing script
		new jQuery.ajax({ type: 'POST', 
						dataType: "xml",
						url: "action.php",
						success:  onAjaxSuccess,
						data: formData,
						dataType: "json",
						error: onAjaxError});

		return false;
	};

	onAjaxSuccess = function(data, textStatus) {
		$("input#RegisterSubmit").show();
		$("div#responseMessage").text("");
		$.unblockUI();
		
		// We might have an error
		if (data.error) {
			$(".button").show();
			
			$("div#responseMessage").show();
			$("div#responseMessage").text(data.message + ", error=" + data.error);
			switch (data.error) {
				case 201:
				case 202:
					var errorID = 'invalidIDorPassword';
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
				$("div#responseMessage").text("");
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
