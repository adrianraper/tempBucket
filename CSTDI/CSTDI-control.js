$(function(){

	// Do some validation on the fields the user has typed. In this case, just check that something has been typed in mandatory fields
	$("input#submit").click (function(){
		$('.note').hide();
		var seemsOK = true;
		var userID = $("input#UserID").val();
		if (userID == ""){
			var seemsOK = false;
			$("label#UserIDNote").text("You must fill in a UserID").show();
			$("input#UserID").focus();
		}
		var firstName = $("input#FirstName").val();
		if (firstName == ""){
			var seemsOK = false;
			$("label#FirstNameNote").text("You must fill in a FirstName").show();
			$("input#FirstName").focus();
		}
		var lastName = $("input#LastName").val();
		if (lastName == ""){
			var seemsOK = false;
			$("label#LastNameNote").text("You must fill in a LastName").show();
			$("input#LastName").focus();
		}
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
		$("input#FirstName").val("");
		$("input#LastName").val("");
		$("input#UserID").val("");
		// The following fields will probably stay the same, so don't clear them
		//$("input#SalCat").val("");
		//$("input#DeptCode").val("");
	}
	sendDataToServer = function(){
		// block the screen
		$(".button").hide();
		
		// The method is sent from here rather than from the form
		$("div#responseMessage").show();
		
		// Send the Clarity program in the URL
		var targetURL = 'transparentSignOn.php?dest=' + $("select#ProductCode").val();
		$('form').attr("action",targetURL);
		$('form').submit();
		
	}
});
