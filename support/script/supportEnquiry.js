//Fail  message
var msgFailSending = 'Please try again.';
var msgMissingFields = 'Please fill in all the fields.';
var msgInvliadEmail = 'Invalid email address.';
var msgUnselectSector = 'Please select a role.';

var seemsOK;

function verifySupportEnquiryForm() {

	var licenceType = "";
	$('input#btnSend').attr('disabled',true);
	if ($("#network").is(':checked')){	licenceType ="Network CD licence" ;}
	if ($("#online").is(':checked')){	licenceType ="Online licence" ;}
	if ($("#notsure").is(':checked')){	licenceType ="Not sure" ;}


	var name = $('input#F_Name').val();
	var email = $('input#F_Email').val();
	var institution = $('input#F_Institution').val();
	var userType = $('select#F_UserType').val();
	var os = $('select#F_OS').val();
	var programs = $('select#F_Program').val();
	var serialNo = "";
	if (licenceType != "Online licence"){
		serialNo = $('input#F_SerialNo').val();
	}
	var invoiceNo = $('input#F_InvoiceNo').val();
	var message = $('textarea#F_Message').val();
	
	seemsOK = true;
	if (licenceType == null || licenceType == "") {
		seemsOK = false;
		$('#ErrMsgLicenceType').show();
	}else{
		$('#ErrMsgLicenceType').hide();
	}
	
	if (name == null || name == "") {
		seemsOK = false;
		$('#ErrMsgName').show();
	}else{
		$('#ErrMsgName').hide();
	}
	
	if (email == null || email == "") {
		seemsOK = false;
		$('#ErrMsgEmail').show();
	}else{
		// check email valid
		var pattern=/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
		if (!pattern.test(email)) {
			seemsOK = false;
			$('#ErrMsgEmail').show();
		}else{
			$('#ErrMsgEmail').hide();
		}
	}
	
	if (institution == null || institution == "") {
		seemsOK = false;
		$('#ErrMsgInstitution').show();
	}else{
		$('#ErrMsgInstitution').hide();
	}
	
	if (userType == null || userType == "") {
		seemsOK = false;
		$('#ErrMsgUserType').show();
	}else{
		$('#ErrMsgUserType').hide();
	}
	
	/*if (os == null || os == "") {
		seemsOK = false;
		$('#ErrMsgOS').show();
	}else{
		$('#ErrMsgOS').hide();
	}*/
	
	if (programs == null || programs == "") {
		seemsOK = false;
		$('#ErrMsgPrograms').show();
	}else{
		programs = programs.toString().toUpperCase();
		$('#ErrMsgPrograms').hide();
	}
	
	if (message == null || message == "") {
		seemsOK = false;
		$('#ErrMsgMessage').show();
	}else{
		$('#ErrMsgMessage').hide();
	}

		//$('input#btnSend').attr('disabled',false);
	//show waiting and hide all others
	//$("#form_waiting").show();
	//$("#form_ok").hide();
	//$("#form_oops").hide();
	//$("#form_submit").hide();

	//submit if OK
	if (seemsOK) {
		//$('#MsgSendbox').hide();
		$('#MsgError').hide();
		$('#MsgLoading').show("slide");
		//$('#MsgSendbox').show("slide");
		var subject = licenceType;
		var postXML = "requestID=21&name="+name+"&email="+email+"&institution="+institution;
		postXML += "&userType="+userType+"&subject="+subject+"&message="+message+"&os="+os;
		postXML += "&programs="+programs+"&serialNo="+serialNo+"&invoiceNo="+invoiceNo;

		submitForm(postXML, userType);
	} else { //show back the button
		$('input#btnSend').attr('disabled',false);
		//alert(1111);
		//$('#MsgSendbox').hide();
	}
}

function submitForm(postXML, userType) {
	//alert(postXML);
	//alert(domain + "sendEnquiry.php");
	var domain = "http://www.clarityenglish.com/";
	//return;
	// Now send the XML to php to process
	$.post(domain + "sendEnquiry.php",{ postXML:postXML } ,function(data) {	
		if (data) {
				$("#form_waiting").hide();				
				//$("#form_ok").show();
				if (userType == "Student"){
					window.location = "/thanks_student.php";
				}else if (userType == "Candidate"){
					window.location = "/thanks_candidate.php";
				}else{
					window.location = "/thanks_support.php";
				}
			} else {				
				//$('#MsgSendbox').hide();
				$('#MsgLoading').hide();
				$('#MsgError').show();
				//$('#MsgSendbox').show("slide");
				$('input#btnSend').attr('disabled',false);
			}
		});
		
		
		
}

