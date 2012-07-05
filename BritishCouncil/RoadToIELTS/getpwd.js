$(function() {
	getEmailFromServer = function() {
		// block the screen
		//$(".button").hide();
		var studentID = $("input#studentID").val();
		if( studentID == "" ){
			// Replace with jqModal to avoid conflict with other UIBlock? No,doesn't help.
			$.blockUI({ message: $('#specialIDNote') });
			/*
			$('#modalDialogDuplicate').jqmShow(); 
			*/
		        $('input#mOK').click(function() { 
				$("div#responseMessage").text("");
				$.unblockUI();
				clearAllFields();
				$("input#studentID").focus();
			}); 
			
			return false;
		}
		 var tstudentID = studentID.substr( 6, 8);
		 var inputID = studentID;
		studentID = tstudentID.substr(0, 3) + tstudentID.substr(4, 4);
		var formData = "method=getUserDetail&studentID=" + studentID + "&inputID=" + inputID;
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
		
		$("div#responseMessage").text("Please wait while your e-mail sending...");
		return false;
	}

	onGetSuccess = function(data, textStatus) {
		//$(".button").show();
		$("div#responseMessage").show();
		// Parse the returned XML node to see if we successfully registered the candidate or not
		rcActionErr = 0;
		rcEmailErr = 0;
		$("db",data).each(function() {
			$("action",this).each(function() {
					rcActionErr = $(this).attr("errorCode");
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
			$("div#responseMessage").text("This id is not in database");

			// Replace with jqModal to avoid conflict with other UIBlock? No,doesn't help.
			$.blockUI({ message: $('#modalDialogEmailFailed') });
			/*
			$('#modalDialogDuplicate').jqmShow(); 
			*/
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
		$("div#responseMessage").text("This id is not in database");
		// Replace with jqModal to avoid conflict with other UIBlock? No,doesn't help.
		$.blockUI({ message: $('#modalDialogEmailFailed') });
		/*
		$('#modalDialogDuplicate').jqmShow(); 
		*/
	        $('input#mDEFOK').click(function() { 
			$("div#responseMessage").text("");
			$.unblockUI();
			clearAllFields();
		}); 
		return false;
	}

	clearAllFields = function() {
		$("input#studentID").val("");
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
  