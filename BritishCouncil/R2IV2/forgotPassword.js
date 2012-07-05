// This script uses action.php to send a forgot password email based on the login ID.
$(function() {
	forgotPassword = function() {
		var studentID = $("input#loginID").val();
		if( studentID == "" ){
			$.blockUI({ message: $('#passwordForgetNoLoginID') });
		        $('input#mOK').click(function() { 
				$("div#responseMessage").text("");
				$.unblockUI();
				$("input#loginID").focus();
			}); 
			
			return false;
		}
		var formData = "method=forgotPassword&loginID=" + studentID;
		$("div#responseMessage").show();
		$("div#responseMessage").text("Please wait while we try to send you an email...");
		
		// call the database processing script
		new jQuery.ajax({
			type: 'POST', 
			dataType: "json",
			url: 'action.php',
			data: formData,
			success:  onForgotPasswordSuccess,
			error: onForgotPasswordError
		});
		
		return false;
	};

	onForgotPasswordSuccess = function(data, textStatus) {
		// Check the return code
		switch (data.error) {
			case 0:
				errorID = 'passwordForgetMailSent';
				break;
			case 1:
				var errorID = 'passwordForgetProblemLoginID';
				break;
			case 200:
				var errorID = 'passwordForgetNoSuchLoginID';
				break;
			case 202:
				var errorID = 'passwordForgetNoEmail';
				break;
			default:
				errorID = 'unexpected';
				break;
		}
			
		$("div#responseMessage").show();
		$.blockUI({ message: $('div#' + errorID).html() });
		$('input#mOK').click(function() { 
			$("div#responseMessage").text("");
			$.unblockUI();
		});
		
		return false;
		
	};

	onForgotPasswordError = function(XMLHttpRequest, textStatus, errorThrown) {
		var errorID = 'unexpected';
		$.blockUI({ message: $('div#' + errorID).html() });
		$('input#mOK').click(function() { 
			$("div#responseMessage").text("");
			$.unblockUI();
		});
		return false;
	};

});
  