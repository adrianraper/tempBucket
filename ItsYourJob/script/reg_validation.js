// make a instance for the form
joinUsFormObject = new Object();
    joinUsFormObject.name = "";
    joinUsFormObject.email = "";
	joinUsFormObject.country = "";
	joinUsFormObject.deliveryFrequency = "";
	joinUsFormObject.contactMethod = "";
	joinUsFormObject.language = "";

var seemsOK = false;
var startDate = new Date();
var expiryDate = new Date().setDate(startDate.getDate()+31); //31 days from now
startDate = dateFormat(startDate, 'mmmm d, yyyy'); 
expiryDate = dateFormat(expiryDate, 'mmmm d, yyyy');

//startDate = startDate.format("longDate");
//expiryDate = expiryDate.format("longDate");

function nextStep(id){
	xmlhttp=null;
	if (window.XMLHttpRequest){
		xmlhttp=new XMLHttpRequest();
	}else if (window.ActiveXObject){
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp!=null){
		var page = "joinus_step" + id + ".htm"
		xmlhttp.open("GET",page,false);
		xmlhttp.send(null);
		var place = document.getElementById('join_box_page');
		place.innerHTML = xmlhttp.responseText;
		  var graph;
		  for(var i=1; i <=parseInt(id); i ++){
		   graph = document.getElementById('join_box_step' + i);
		   graph.className = "graph_on";
		  }
		
		  for(var i=parseInt(id)+1; i<=4; i++){
		   graph = document.getElementById('join_box_step' + i);
		   graph.className = "graph_off";
		  }
		  // Progress display frame 
		$("a.pop_success_iframe").fancybox({ 
			'centerOnScroll':false,
			'frameWidth':565,
			'frameHeight':360
		});
		
		/* Join Us - Course setting learn more screen */ 
		$("a.join_learnmore_iframe").fancybox({ 
			'centerOnScroll':false,
			'frameWidth':568,
			'frameHeight':478
		});
		
		/* Join Us Step 4 - Important notes */ 
		$("a.join_imnotes_iframe").fancybox({ 
			'centerOnScroll':false,
			'frameWidth':680,
			'frameHeight':480
		});

		//$(function(){
		//snip
		//Text tag demo
		//$("#IYJreg_uFullName").fieldtag();
		//$("#IYJreg_uEmail").fieldtag();
	//});
		
		
	
		
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
}

//$("#IYJreg_uEmail").blur(function() {
function checkEmail() {
	var email = $("input#IYJreg_uEmail").val();
	var pattern=/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
	if (!pattern.test(email)) {
		seemsOK = false;
		//setLabelText("IYJreg_uEmailNote","Please input a valid email");
		//$("label#IYJreg_uEmailNote").show();
		$("#IYJreg_uEmailNote").fadeTo(200,0.1,function() { //start fading the messagebox
			//add message and change the class of the box and start fading
			$(this).html('Please input a valid email').removeClass().addClass('field_msgRed').fadeTo(900,1);
		});
		//$("input#IYJreg_uEmail").focus();
	} else {
		//remove all the class add the messagebox classes and start fading
		$("#IYJreg_uEmailNote").removeClass().addClass('field_msgBlack').text('Checking...').fadeIn("slow");
		//check the username exists or not from ajax
		$.post("user_availability.php",{ IYJreg_uEmail:$("input#IYJreg_uEmail").val() } ,function(data) {
			if(data=='no') { //if username not avaiable
				$("#IYJreg_uEmailNote").fadeTo(200,0.1,function() { //start fading the messagebox
					//add message and change the class of the box and start fading
					$(this).html('This email already exists').removeClass().addClass('field_msgRed').fadeTo(900,1);
					seemsOK = false;
					//$("input#IYJreg_uEmail").focus();
				});
			} else {
				$("#IYJreg_uEmailNote").fadeTo(200,0.1,function() { //start fading the messagebox
					//add message and change the class of the box and start fading
					$(this).html('Email is valid').removeClass().addClass('field_msgGreen').fadeTo(900,1);
					// If this simple processing seems fine, then save all the info to the object
				});
			}
		});
	}
}

function checkCountry() {
	var country = document.getElementById("IYJreg_uCountry").value;
	if ( (country == "none") || (country == "") ){
		seemsOK = false;
		//setLabelText("IYJreg_uCountryNote","Please select your country");
		//$("label#IYJreg_uCountryNote").show();
		$("#IYJreg_uCountryNote").fadeTo(200,0.1,function() { //start fading the messagebox
			//add message and change the class of the box and start fading
			$(this).html('Please select your country').fadeTo(900,1);
		});
		//$("input#IYJreg_uCountry").focus();
	} else {
		$("#IYJreg_uCountryNote").html('').removeClass();
	}
}

function checkName() {
	var name = $("input#IYJreg_uFullName").val();
	if (name == "") {
		seemsOK = false;
		//setLabelText("IYJreg_uFullNameNote","Please input your name");
		//$("label#IYJreg_uFullNameNote").show();
		$("#IYJreg_uFullNameNote").fadeTo(200,0.1,function() { //start fading the messagebox
			//add message and change the class of the box and start fading
			$(this).html('Please input your name').fadeTo(900,1);
		});
		//$("input#IYJreg_uFullName").focus();
	} else {
		$("#IYJreg_uFullNameNote").html('').removeClass();
	}
}


/*function watermarkName() {
	//var name = $("input#IYJreg_uFullName");
	var name = document.joinUsForm.IYJreg_uFullName;
	if (name.value=='This is what we will call you') {
		name.value='';
		name.style.color='black';
	} else if(name.value.replace(/\s/g,'')==''){
		name.style.color='gray';
		name.value='This is what we will call you';
	}
}*/


/*function watermarkName() {
	//var name = $("input#IYJreg_uFullName");
	var name = document.joinUsForm.IYJreg_uFullName;
	if (name.style.backgroundImage.src == "../images/join_fullname_water.jpg") {

		alert("changeBackground..."); 
		name.style.backgroundImage.src = "";

	} else if(name.value==''){
		name.style.color='gray';
		name.style.backgroundImage.src = "../images/join_fullname_water.jpg"; 
	}
}

function watermarkEmail() {
	//var name = $("input#IYJreg_uFullName");
	var email = document.joinUsForm.IYJreg_uEmail;
	if (email.value=='This will be your login name') {
		email.value='';
		email.style.color='black';
	} else if(email.value.replace(/\s/g,'')==''){
		email.style.color='gray';
		email.value='This will be your login name';
	}
}
*/

function checkRegData(id){
	switch(id) {
		case "3":
			seemsOK = true;
			//$("label#IYJreg_uFullNameNote").hide();
			//$("label#IYJreg_uEmailNote").hide();
			//$("label#IYJreg_uCountryNote").hide();
			$("#IYJreg_uFullNameNote").text('');
			$("#IYJreg_uEmailNote").text('');
			$("#IYJreg_uCountryNote").text('');
			checkEmail();
			checkName();
			checkCountry();
			setTimeout("AsynCheck()",1000);
			nextStep('3');
			break;
		
		case "4":
				joinUsFormObject.deliveryFrequency = checkOptionValue(document.joinUsForm.IYJreg_dFreq);
				joinUsFormObject.contactMethod = ListCheckedItem(document.joinUsForm.IYJreg_contact);
				if (joinUsFormObject.contactMethod=="") {
					joinUsFormObject.contactMethod="Not at all";
				}
				joinUsFormObject.language = checkOptionValue(document.joinUsForm.IYJreg_language);
				displayRegData('4');
			break;
		
		default:
			break;
	}
}

function AsynCheck() {
	if (seemsOK) {
		//alert('all fields OK');
		joinUsFormObject.name = $("input#IYJreg_uFullName").val();
		joinUsFormObject.email = $("input#IYJreg_uEmail").val();
		joinUsFormObject.country = document.getElementById("IYJreg_uCountry").value;
		//alert(joinUsFormObject.country);
	} else {
		//alert("You have incompleted fields.");
		//return false;
	}
}

function displayRegData(id){
	switch(id) {
		case "2":
			nextStep('2');
			document.getElementById("IYJreg_uFullName").value = joinUsFormObject.name;
			document.getElementById("IYJreg_uEmail").value = joinUsFormObject.email; 
			if (joinUsFormObject.country=="")
				document.getElementById("IYJreg_uCountry").value = "none"; 
			else
				document.getElementById("IYJreg_uCountry").value = joinUsFormObject.country; 
			setLabelText("IYJreg_startDate",startDate);
			setLabelText("IYJreg_expiryDate",expiryDate);
			//setLabelText("IYJreg_uFullName",joinUsFormObject.name);
			//setLabelText("IYJreg_uEmail",joinUsFormObject.email);
			//setLabelText("IYJreg_uCountry",joinUsFormObject.country);
			break;
		
		case "3":
			nextStep('3');
			setCheckedValue(document.joinUsForm.IYJreg_dFreq,joinUsFormObject.deliveryFrequency);
			setLabelText("IYJreg_contact",joinUsFormObject.contactMethod);
			setCheckedValue(document.joinUsForm.IYJreg_language,joinUsFormObject.language);
			break;
		
		case "4":
			nextStep('4');
			var deliveryFrequency = '';
			var language = '';
			switch(joinUsFormObject.deliveryFrequency) {
				case '1':
					deliveryFrequency = 'One unit every day';
					break;
				case '3':
					deliveryFrequency = 'One unit every three days';
					break;
				default :
					deliveryFrequency = 'All at once';
					break;
			}
			switch(joinUsFormObject.language) {
				case 'NAMEN':
					language = 'North American English';
					break;
				case 'INDEN':
					language = 'Indian English';
					break;
				default :
					language = 'International English';
					break;
			}
			setLabelText("IYJreg_uFullName_review",joinUsFormObject.name);
			setLabelText("IYJreg_uEmail_review",joinUsFormObject.email);
			setLabelText("IYJreg_uCountry_review",joinUsFormObject.country);
			//setLabelText("IYJreg_dFreq_review",joinUsFormObject.deliveryFrequency);
			setLabelText("IYJreg_dFreq_review",deliveryFrequency);
			setLabelText("IYJreg_contact_review",joinUsFormObject.contactMethod);
			//setLabelText("IYJreg_language_review",joinUsFormObject.language);
			setLabelText("IYJreg_language_review",language);
			setLabelText("IYJreg_startDate",startDate);
			setLabelText("IYJreg_expiryDate",expiryDate);
			break;
		
		default:
			break;
	}
}

function submitJoinUs(){
	var actionURL = 'joinus_action.php';

	/*
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1;//January is 0!
	var yyyy = today.getFullYear();
	if(dd<10){dd='0'+dd}
	if(mm<10){mm='0'+mm}
	// Need to use server time for starting
	//var startDate = yyyy+'-'+mm+'-'+dd;
	
	var e = new Date();
	e.setDate(e.getDate()+31); //10 weeks from startDate
	dd = e.getDate();
	mm = e.getMonth()+1;//January is 0!
	yyyy = e.getFullYear();
	var expiryDate = yyyy+'-'+mm+'-'+dd;
	*/
	
	var formParam = {
		'name': joinUsFormObject.name,
		'email': joinUsFormObject.email,
		'country': joinUsFormObject.country,
		'deliveryFrequency': joinUsFormObject.deliveryFrequency,
		'contactMethod': joinUsFormObject.contactMethod,
		'language': joinUsFormObject.language,
		'productCode': '1001',
		//'startDate': startDate,
		'expiryDate': expiryDate,
		'checkSum': '123123',
		// Testing ID
		'merchantId': '88100983',
		//Real ID
		//'merchantId': '88060532',
		'amount': '24.95',
		//'orderRef': '00000001',
		'currCode': '840',
		//'successUrl': 'http://www.ClarityEnglish.com/Software/ResultsManager/web/amfphp/services/AddAccountFromScript.php',
		'successUrl': 'http://clarityMain/itsyourjob/joinus_afterAction.php',
		'failUrl': 'http://clarityMain/itsyourjob/joinus_failure.php?error=PaymentFailure',
		'errorUrl': 'http://clarityMain/itsyourjob/joinus_failure.php?error=PaymentError',
		'payType': 'N',
		'lang':'E'
	};
	
	post_to_url(actionURL, formParam);
}

function setLabelText(id, txt){
	var elem;
	if( document.getElementById && (elem=document.getElementById(id)) ){
		if( !elem.firstChild )
			elem.appendChild( document.createTextNode( txt ) );
		else 
			elem.firstChild.data = txt;
	}
	return false; 
}

function checkOptionValue(inputObj){
	var objLength = inputObj.length;
	if(objLength == undefined){
		if(inputObj.checked)
			return inputObj.value;
		else
			return "";
		}else{
			for(var i = 0; i < objLength; i++) {
				if(inputObj[i].checked) {
					return inputObj[i].value;
				}
			}
		}
	return "";
}

// set the radio button with the given value as being checked
// do nothing if there are no radio buttons
// if the given value does not exist, all the radio buttons
// are reset to unchecked
function setCheckedValue(radioObj, newValue) {
	if(!radioObj)
		return;
	var radioLength = radioObj.length;
	if(radioLength == undefined) {
		radioObj.checked = (radioObj.value == newValue.toString());
		return;
	}
	for(var i = 0; i < radioLength; i++) {
		radioObj[i].checked = false;
		if(radioObj[i].value == newValue.toString()) {
			radioObj[i].checked = true;
		}
	}
}


function post_to_url(url, params){
	var form = document.createElement("form");
	form.setAttribute("method", 'post');
	form.setAttribute("action", url);

	for(var key in params) {
		var hiddenField = document.createElement("input");
		hiddenField.setAttribute("type", "hidden");
		hiddenField.setAttribute("name", key);
		hiddenField.setAttribute("value", params[key]);
		
		form.appendChild(hiddenField);
	}

	document.body.appendChild(form);
	form.submit();
}

function ClearAllChecked(chk){
	for (i = 0; i < chk.length-1; i++)
		chk[i].checked = false ;
}

function ClearSingleChecked(chk, i){
	
		chk[i].checked = false ;
}

function ListCheckedItem(chk) {
	var t = "";
	for (i = 0; i < chk.length; i++) {
		if (chk[i].checked == true) {
			t += ", " + chk[i].value;
		}
	}
	t = t.substring(2);
	return t;
}
/*
$(function() {
	var editMode = false;
	
	$("input#send").click(function() {
		$('.note').hide();
		var seemsOK = true;
		// Check if the password and confirmed password are the same
		var password = $("input#password").val();
		var password1 = $("input#password1").val();
		if( password != password1){
			var seemsOK = false;
			$("label#passwordNote").show();
			$("input#password").focus();
		}
		var name = $("input#learnerName").val();
		if (name == "") {
			var seemsOK = false;
			$("label#learnerNameNote").show();
			$("input#learnerName").focus();
		}

		var email = $("input#email").val();
		if (email == "") {
			var seemsOK = false;
			$("label#emailNote").show();
			$("input#emailValue").focus();
		}

		
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
				//$("input#studentID").val( $("input#editUserID").val() );
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
		//$("input#studentID").val("");
		$("input#email").val("");
		//$('#examDate').dpDisplay();
	}


sendDataToServer = function() {
	// block the screen
	$(".button").hide();
	
	//var formData = "method=updateUser&" + $("form#userDetails").serialize();
	//var formData = "method=updateUser&" + $("form#userDetails").serialize();
	var formData = "name=" + joinUsFormObject.name + "&email=" + joinUsFormObject.email + "&country=" + joinUsFormObject.country + "&deliveryFrequency=" + joinUsFormObject.deliveryFrequency + "&contactMethod=" + joinUsFormObject.contactMethod + "&language=" + joinUsFormObject.language + "&productCode=1001&verificationCode=123&expiryDate=2009-10-31&startDate=2009-10-06&checkSum=123123";
	formData += "&orderRef=456&amount=49&currCode=840&lang=E&merchantId=12100184";
	formData += "&successUrl=http://www.google.com";
	formData += "&failUrl=http://www.yahoo.com";
	formData += "&errorUrl=http://www.microsoft.com";
	alert(formData);
	
	$("div#responseMessage").show();
	
	// call the database processing script
	new jQuery.ajax({ type: 'POST', 
					dataType: "xml",
					url: 'action.php',
					//url: actionFile,
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
					//rcStudentID = $(this).attr("studentID");
					rcEmail = $(this).attr("email");
					//rcExpiryDate = $(this).attr("expiryDate");
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
		
		//var dateReformatted = new Date($('#examDate').dpGetSelected()).addDays(7).asString("yyyy-mm-dd");
		//var formData = "method=getUserDetail&" + $("form#userDetails").serialize() + "&expiryDate=" + dateReformatted;
		var formData = "method=getUserDetail&" + $("form#userDetails").serialize();
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
					//rcStudentID = $(this).attr("studentID");
					rcEmail = $(this).attr("email");
					//rcExamDate = $(this).attr("expiryDate");
					//rcProgrammVersion = $(this).attr("programVersion");
				});
			$("mail",this).each(function() {
					rcEmailErr = $(this).attr("errorCode");
				});
			});
		//$("input#studentID").val( rcStudentID );
		$("input#learnerName").val( rcName );
		$("input#email").val( rcEmail );
		//$("input#examDate").val( rcExamDate );

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
*/