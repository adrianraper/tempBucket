// make a instance for the form
joinUsFormObject = new Object();
    joinUsFormObject.name = "";
    joinUsFormObject.email = "";
	joinUsFormObject.country = "";
	joinUsFormObject.deliveryFrequency = "";
	joinUsFormObject.contactMethod = "";
	joinUsFormObject.language = "";
	joinUsFormObject.startDate = "";
	joinUsFormObject.expiryDate = "";

var seemsOK = false;

function checkEmail() {
	var email = document.getElementById("IYJreg_uEmail").value;
	var pattern=/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
	if (!pattern.test(email)) {
		seemsOK = false;
		alert('Please input a valid email');
	} else {
	/*
		$.post("ce_user_availability.php",{ IYJreg_uEmail:email } ,function(data) {
			if(data=='no') { //if username not avaiable
				alert('This email already exists');
				seemsOK = false;
			}
		});
	*/
	}
}

function checkCountry() {
	var country = document.getElementById("IYJreg_uCountry").value;
	if ( (country == "none") || (country == "") ){
		seemsOK = false;
		alert('Please select your country');

	}
}

function checkName() {
	var name = document.getElementById("IYJreg_uFullName").value;
	if (name == "") {
		seemsOK = false;
		alert('Please input your name');
	}
}

function checkDate() {
	joinUsFormObject.startDate = document.getElementById("startdate");
	joinUsFormObject.expiryDate = document.getElementById("enddate");
	if (joinUsFormObject.startDate="") {
		var sDate = new Date();
		joinUsFormObject.startDate = dateFormat(sDate, 'mmmm d, yyyy'); 
	}
	if (joinUsFormObject.expiryDate="") {
		var xDate = new Date().setDate(joinUsFormObject.startDate.getDate()+31);
		joinUsFormObject.expiryDate = dateFormat(xDate, 'mmmm d, yyyy'); 
	}
}

function checkRegData() {
			seemsOK = true;
			checkEmail();
			checkName();
			checkCountry();
			checkDate();
			joinUsFormObject.deliveryFrequency = checkOptionValue(document.IYJdmsForm.IYJreg_dFreq);
			joinUsFormObject.contactMethod = ListCheckedItem(document.IYJdmsForm.IYJreg_contact);
			if (joinUsFormObject.contactMethod=="") {
				joinUsFormObject.contactMethod="Not at all";
			}
			joinUsFormObject.language = checkOptionValue(document.IYJdmsForm.IYJreg_language);
			setTimeout("AsynCheck()",1000);
}

function AsynCheck() {
	if (seemsOK) {
		//alert('all fields OK');
		joinUsFormObject.name = document.getElementById("IYJreg_uFullName").value;
		joinUsFormObject.email = document.getElementById("IYJreg_uEmail").value;
		joinUsFormObject.country = document.getElementById("IYJreg_uCountry").value;
		//alert(joinUsFormObject.country);
		submitJoinUs();
	} else {
		alert("You have incompleted fields.");
		//return false;
	}
}

function submitJoinUs(){
	var actionURL = 'http://clarityMain/Software/ResultsManager/web/amfphp/services/AddAccountFromScript.php';
	
	var formParam = {
		'name': joinUsFormObject.name,
		'email': joinUsFormObject.email,
		'country': joinUsFormObject.country,
		'deliveryFrequency': joinUsFormObject.deliveryFrequency,
		'contactMethod': joinUsFormObject.contactMethod,
		'language': joinUsFormObject.language,
		'productCode': '1001',
		'startDate': joinUsFormObject.startDate,
		'expiryDate': joinUsFormObject.expiryDate,
		'checkSum': '123123',
	};
	
	post_to_url(actionURL, formParam);
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