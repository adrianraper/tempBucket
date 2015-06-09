function checkForgetPwd() {
	//var email = $("input#IYJ_ForgetEmail").val();
	//var email = document.IYJ_forgetpwd.IYJ_ForgetEmail.val();
	var email = document.getElementById('IYJ_ForgetEmail');
	var outputMsg = document.getElementById('IYJ_ForgetEmailNote');
	var pattern=/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
	var AddEmailURL = 'Software/ResultsManager/web/amfphp/services/ResendEmailPassword.php';
	
	if (!pattern.test(email.value)) {
		seemsOK = false;
		//setLabelText("IYJreg_uEmailNote","Please input a valid email");
		//$("label#IYJreg_uEmailNote").show();
			//add message and change the class of the box and start fading
			//$(this).html('Please input a valid email').removeClass().addClass('field_msgRed').fadeTo(900,1);
			//$(this).html('Please input a valid email').fadeTo(900,1);
		outputMsg.innerHTML = 'Please input a valid email';
		email.focus();
	} else {
		//remove all the class add the messagebox classes and start fading
		//document.IYJ_forgetpwd.IYJ_ForgetEmailNote.removeClass().addClass('field_msgBlack').text('Checking...').fadeIn("slow");
		outputMsg.innerHTML = 'Checking...';
		//check the email exists or not from ajax
		$.post(AddEmailURL,{ IYJ_Email: email.value, IYJ_productCode:'1001' } ,function(data2) {
			var error = gup('error');
			var message = gup('message');
			var password = gup('password');
			switch (error) {
				case '0':
					outputMsg.innerHTML = 'Email sent! Your password is '+password;
					break;
				case '210':
					outputMsg.innerHTML = message;
					break;
				case '211':
					outputMsg.innerHTML = message;
					break;
				default:
					outputMsg.innerHTML = 'Unknown error. Please try again.';
			}
		});
	}
}

function gup(name){
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return results[1];
}