$(function(){
	// For single input, Enter means click submit. But this seems to truncate the learnerName!
	// Ah, because I was clicking Enter to select a pretyped word from the list.
	//$("input#learnerName").keydown (function(event){
	//	if(event.keyCode == '13'){
	//		$("input#send").click();
	//	}
	//});

	// Do some validation on the fields the user has typed. In this case, just check that something has been typed.
	$("input#send").click (function(){
		$('.note').hide();
		var seemsOK = true;
		var name = $("input#learnerName").val();
		if (name == ""){
			var seemsOK = false;
			$("label#learnerNameNote").show();
			$("input#learnerName").focus();
		}
		// Japan doesn't use an email
		/*
		var email = $("input#learnerEmail").val();
		if (email == ""){
			var seemsOK = false;
			$("label#learnerEmailNote").show();
			$("input#learnerEmail").focus();
		}
		*/
		// If this simple processing seems fine, then send all the info to the server
		if (seemsOK){
			return sendDataToServer();
		} else	{
			return false;
		}
	});
	$("input#clear").click (function(){
		clearAllFields();
	});

	clearAllFields = function(){
		$('.note').hide();
		$("input#learnerName").val("");
		// Japan doesn't use an email
		//$("input#learnerEmail").val("");
	}
	sendDataToServer = function(){
		// block the screen
		$(".button").hide();
		
		// The method is sent from here rather than from the form
		var formData = "method=registerUser&" + $("form#userDetails").serialize();
		$("div#responseMessage").show();
		// Debug. This first stage just checks the form names.
		// alert(formData); return false;
		// call the database processing script
		new jQuery.ajax({ type: 'POST', 
						dataType: "xml",
						url: 'action.eninjp.php',
						success:  onAjaxSuccess,
						data: formData,
						error: onAjaxError});

		$("div#responseMessage").text("Please wait while your details are registered...");
		return false;
	}
	onAjaxSuccess = function(data, textStatus){
		$(".button").show();
		$("div#responseMessage").show();
		// Parse the returned XML node to see if we successfully registered the learner or not
		rcActionErr = 0;
		rcEmailErr = 0;
		//console.dirxml(data);
		// Debug. Charles should show the response from action.php well.
		// Japan doesn't use an email
		$("db", data).each(function(){
			$("action", this).each(function(){
				rcActionErr = $(this).attr("errorCode");
				rcName = $(this).attr("name");
				//rcEmail = $(this).attr("email");
				rcUserID = $(this).attr("userID");
			});
		});
		// Debug. See what error code came back without taking any more action.
		//$("div#responseMessage").text("ajax success, errCode=" + rcActionErr); return false;
		// Check that the user has been registered correctly. We can expect to get errors from duplicate email
		if (rcActionErr>0) {
			switch (rcActionErr) {
			case '220':
				// Warn that this is a duplicate email address
				$("div#responseMessage").text("Sorry, this phrase has already been used. Please try another."); 
				break;
			case '206':
				// Warn that this is a duplicate email address
				$("div#responseMessage").text("Sorry, this phrase has already been used. Please try another.");
				break;
			default:
			}
		} else {
			$("div#responseMessage").text("You have been registered, the program will now start...");
			// TODO. Can't I go direct to action.php from here? Or even the redirect?
			// Drawback is in building the POST data to pass to Start. I can do it with queryString, but not so neat
			// How can I pick up the domain?
			// $domain + $startFolder
			//var rcURL = "http://dock.fixbench/area1/ILATest/Start.php?prefix=regPrefix"
			//window.location = rcURL;
			// Go back to the original page, and use a hidden form to do an immediate resubmit to a separate section in action.php
			$("input#regUserID").val(rcUserID);
			$("input#regMethod").val("startUser");
			$('#userStart_form').submit();
		}
		return false;
	}
	onAjaxError = function(XMLHttpRequest, textStatus, errorThrown){
		$.unblockUI();
		$(".button").show();
		$("div#responseMessage").show();
		//$("div#responseMessage").text(XMLHttpRequest.response);
		$("div#responseMessage").text("Sorry, your details can't be added right now: " + textStatus);
		return false;
	}
	// jqModal initialisation
	$.blockUI.defaults.timeout = 30000;
	$.blockUI.defaults.css = {
		width : '450px',
		top : '20%',
		left : '30%',
		padding : '20px',
		cursor : 'wait' ,
		textAlign : 'left',
		padding : '15px',
		border : 'none',
		color : '#fff',
		backgroundColor : '#000000',
		'-webkit-border-radius' : '10px',
		'-moz-border-radius' : '10px'
	};
});
