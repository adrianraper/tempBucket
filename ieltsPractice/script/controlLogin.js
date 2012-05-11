$(document).ready(function(){

	$("#choose_login").click(function(){
		$("#login_panel").slideToggle("slow");
		$(this).toggleClass("btn_login_active"); return false;
	});
	
	 
});

function checkLogin() {
	var email = $("input#RTILogin").val();
	var password = $("input#RTIPassword").val();
	$("#RTILoginMsg").hide();
	// use common email pattern.
	if (!emailPattern.test(email)) {
		seemsOK = false;
		$("#RTILoginMsg").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyEmailPatternIncorrect).fadeTo(900,1);
		});
	} else {
		return sendLoginAction();		
	}
}

// Call the action script
sendLoginAction = function() {
	var formData = "method=login&loginID=" + $("input#RTILogin").val() + "&userPassword=" + $("input#RTIPassword").val();
	$("#RTILoginMsg").text('Checking...').fadeIn("slow");

	console.log(formData);

	// call the database processing script
	new jQuery.ajax({ type: 'POST', 
					url: "action.php",
					data: formData,
					dataType: "json",
					success: onAjaxLoginEmailSuccess,
					error: onAjaxLoginEmailFail});
	return false;
};

onAjaxLoginEmailSuccess = function(data, textStatus) {
	//alert('sucess, data='+data.success);
	
	// Did the gateway send back an error:
	if (data.error) {
		$("#RTILoginMsg").fadeTo(200,0.1,function() { 
			$(this).html(R2ILoginIncorrect).fadeTo(900,1);
			seemsOK = false;
		});
		// To help check on errors, write to the browser's console
		console.log(data.error + ': ' + data.message);
		
	} else if (data.user) {
		$("#RTILoginMsg").fadeTo(200,0.1,function() { 
			$(this).html(R2ILoginSuccess).fadeTo(900,1);
			
			// Load the My Account page
			window.location='myaccount.php';
			
		});
		
	} else {
		$("#RTILoginMsg").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyEmailUnknownError).fadeTo(900,1);
			seemsOK = false;
		});	
	}
};	

onAjaxLoginEmailFail = function(data, textStatus) {
	$("#RTILoginMsg").fadeTo(200,0.1,function() { 
		$(this).html(R2IBuyEmailUnknownError).fadeTo(900,1);
		seemsOK = false;
	});
};