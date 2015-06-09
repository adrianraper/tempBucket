// make a instance for the form
joinUsFormObject = new Object();
	joinUsFormObject.email = "";
    joinUsFormObject.email = "";
    joinUsFormObject.password = "";
	joinUsFormObject.country = "";
	joinUsFormObject.deliveryFrequency = "";
	joinUsFormObject.contactMethod = "";
	joinUsFormObject.language = "";

var seemsOK = false;
var startDate = new Date();
var expiryDate = new Date().setDate(startDate.getDate()+31); //31 days from now
startDate = dateFormat(startDate, 'mmmm d, yyyy'); 
expiryDate = dateFormat(expiryDate, 'mmmm d, yyyy');

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
		//do nothing
	}
}


function checkPassword() {
	var email = $("input#IYJreg_uEmail").val();
	var password = $("input#IYJreg_uPassword").val();
	var pattern=/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
	if (password == "") {
		seemsOK = false;
		$("#IYJreg_uPasswordNote").fadeTo(200,0.1,function() { //start fading the messagebox
			//add message and change the class of the box and start fading
			$(this).html('Please input your Password').removeClass().addClass('field_msgRed').fadeTo(900,1);
		});
	} else {
		//remove all the class add the messagebox classes and start fading
		$("#IYJreg_uPasswordNote").removeClass().addClass('field_msgBlack').text('Checking...').fadeIn("slow");
		//check the username exists or not from ajax
		$.post("user_exist.php",{ IYJreg_uEmail:email,IYJreg_uPassword:password } ,function(data) {
			if(data=='no') { //if username not avaiable
				$("#IYJreg_uPasswordNote").fadeTo(200,0.1,function() { //start fading the messagebox
					//add message and change the class of the box and start fading
					$(this).html('This users does not exist.').removeClass().addClass('field_msgRed').fadeTo(900,1);
					seemsOK = false;
				});
			} else {
				$("#IYJreg_uPasswordNote").fadeTo(200,0.1,function() { //start fading the messagebox
					//add message and change the class of the box and start fading
					$(this).html('Confirmed').removeClass().addClass('field_msgGreen').fadeTo(900,1);
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
		$("#IYJreg_uCountryNote").fadeTo(200,0.1,function() { //start fading the messagebox
			//add message and change the class of the box and start fading
			$(this).html('Please select your country').fadeTo(900,1);
		});
	} else {
		$("#IYJreg_uCountryNote").html('').removeClass();
	}
}



function checkRegData(){
			seemsOK = true;
			$("#IYJreg_uEmailNote").text('');
			$("#IYJreg_uPasswordNote").text('');
			$("#IYJreg_uCountryNote").text('');
			checkEmail();
			checkPassword();
			checkCountry();
			setTimeout("AsynCheck()",1000);
			joinUsFormObject.deliveryFrequency = checkOptionValue(document.joinUsForm.IYJreg_dFreq);
			joinUsFormObject.contactMethod = ListCheckedItem(document.joinUsForm.IYJreg_contact);
			if (joinUsFormObject.contactMethod=="") {
				joinUsFormObject.contactMethod="Not at all";
			}
			joinUsFormObject.language = checkOptionValue(document.joinUsForm.IYJreg_language);
}

function AsynCheck() {
	if (seemsOK) {
		//alert('all fields OK');
		joinUsFormObject.email = $("input#IYJreg_uEmail").val();
		joinUsFormObject.password = $("input#IYJreg_uPassword").val();
		joinUsFormObject.country = document.getElementById("IYJreg_uCountry").value;
		//alert(joinUsFormObject.country);
	} else {
		//alert("You have incompleted fields.");
		//return false;
	}
}

function submitJoinUs(){
	var actionURL = 'joinus_action.php';
	
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
		'amount': '14.95',
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