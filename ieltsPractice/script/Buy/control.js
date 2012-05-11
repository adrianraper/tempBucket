// This script is copied from CLS control.js with many functions deleted. Refer back to that script if necessary.

// make a instance for the form
RTIBuy = new Object();
	RTIBuy.module=""; //52=Academic 53=General Training
	RTIBuy.subscriptionPeriod=""; //31=1month 92=3months
	RTIBuy.offerID=""; //59|60|61|62
    RTIBuy.name="";
    RTIBuy.password="";
    RTIBuy.email="";
    RTIBuy.ageGroup="";
    RTIBuy.phone="";
	RTIBuy.country="";
	RTIBuy.newsletter="";
	RTIBuy.paymentMethod="";
	RTIBuy.TotalAmount=0; //1month=USD49.99 3months=USD99.99
	RTIBuy.isReturn=false;

var seemsOK = false;
 
//Flow control Actions
function SaveAndGo(id){
	seemsOK = true;
	switch(id) {
		case '2':
			checkEmail();
			checkName();
			checkProduct();
			checkCountry();
			checkPassword();
			if (seemsOK) {
				// set the value
				RTIBuy.module=$("#R2IBuyForm input[name=R2ISelectModule]:checked").val();
				RTIBuy.subscriptionPeriod=$("#R2IBuyForm input[name=R2ISelectSubscription]:checked").val();
				if(RTIBuy.subscriptionPeriod=="31") RTIBuy.TotalAmount=49.99;
				else if (RTIBuy.subscriptionPeriod=="92") RTIBuy.TotalAmount=99.99;
				if (RTIBuy.module=="52" && RTIBuy.subscriptionPeriod=="31") RTIBuy.offerID='59';
				else if (RTIBuy.module=="52" && RTIBuy.subscriptionPeriod=="92") RTIBuy.offerID='60';
				else if (RTIBuy.module=="53" && RTIBuy.subscriptionPeriod=="31") RTIBuy.offerID='61';
				else if (RTIBuy.module=="53" && RTIBuy.subscriptionPeriod=="92") RTIBuy.offerID='62';
				RTIBuy.email=$("#RTIChooseEmail").val();
				RTIBuy.password=$("#RTIChoosePassword").val();
				RTIBuy.name=$("#RTIName").val();
				RTIBuy.country=$("#RTICountry").val();
				RTIBuy.ageGroup=$("#RTIAgeGroup").val();
				RTIBuy.phone=$("#RTIPhone").val();
				$('#RTINewsletter').is(':checked') ? RTIBuy.newsletter="yes" : RTIBuy.newsletter="no";
				// aSync for email checking
				setTimeout("nextStep('2')",1000);
				ListData('2');
			}
			break;
		case '3':
			checkPayment();
			checkAgreeTerms();
			if (seemsOK) {
				// set the value
				RTIBuy.paymentMethod = $("#R2IBuyForm input[name=R2ISelectPayment]:checked").val();
				nextStep('3');
				ListData('3');
			}
			break;
		default:
			break;
	}
}

function Backward(id){
	switch(id) {
		case "1":
			nextStep('1');
			ListData('1');
			break;
		case "2":
			nextStep('2');
			ListData('2');
			break;
		default:
			break;
	}
}

function nextStep(id){
	var xmlhttp=null;

	if (window.XMLHttpRequest){
		xmlhttp=new XMLHttpRequest();
	}else if (window.ActiveXObject){
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp!=null){
		var page = "buy_step" + id + ".php"
		xmlhttp.open("GET",page,false);
		xmlhttp.send(null);
		var place = document.getElementById('buy_innerHTML');
		place.innerHTML = xmlhttp.responseText;
		  var graph;
		  for(var i=1; i <=parseInt(id); i ++){
		   graph = document.getElementById('buy_step' + i);
		  }
		
		  for(var i=parseInt(id)+1; i<=4; i++){
		   graph = document.getElementById('buy_step' + i);
		  }
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
}

function ListData(id) {
	switch(id) {
		case "1":
			if (RTIBuy.module=="52") $("#R2ISelectModuleAC").attr('checked', true);
			else if (RTIBuy.module=="53") $("#R2ISelectModuleGT").attr('checked', true);
			if (RTIBuy.subscriptionPeriod=="31") $("#R2ISelectSubscription1m").attr('checked', true);
			else if (RTIBuy.subscriptionPeriod=="92") $("#R2ISelectSubscription3m").attr('checked', true);
			if (RTIBuy.name!="") $("#RTIName").val(RTIBuy.name);
			if (RTIBuy.email!="") $("#RTIChooseEmail").val(RTIBuy.email);
			if (RTIBuy.phone!="") $("#RTIPhone").val(RTIBuy.phone);
			$("#RTIAgeGroup").val(RTIBuy.ageGroup); 
			$("#RTICountry").val(RTIBuy.country);
			if (RTIBuy.newsletter=="yes") $("#RTINewsletter").attr('checked','checked')
			break;

		case "2":
			var pm = $('input:radio[name=R2ISelectPayment]');
			pm.filter('[value='+RTIBuy.paymentMethod+']').attr('checked', true);
			changePayment2();
			break;
		
		case "3":
			$("#R2IReviewModule").text(productCode2Text(RTIBuy.module));
			$("#R2IReviewSubscriptionPeriod").text(period2Text(RTIBuy.subscriptionPeriod));
			$("#R2IReviewAmount").text(RTIBuy.TotalAmount);
			$("#R2IReviewTotalAmount").text(RTIBuy.TotalAmount);
			$("#R2IReviewEmail").text(RTIBuy.email);
			$("#R2IReviewPassword").text(RTIBuy.password);
			$("#R2IReviewName").text(RTIBuy.name);
			$("#R2IReviewAgeGroup").text(RTIBuy.ageGroup);
			$("#R2IReviewPhone").text(RTIBuy.phone);
			$("#R2IReviewCountry").text(RTIBuy.country);
			$("#R2IReviewPaymentMethod").text(payment2Text(RTIBuy.paymentMethod));
			$("#R2IReviewExpiryDate").text(getExpiryDate(RTIBuy.subscriptionPeriod));
			changePayment3();
			break;

		case "4":
			break;
	}
}

// Step 1 Actions
function checkProduct() {
	if ( ($("#R2IBuyForm input[name=R2ISelectModule]:checked").val()==undefined) || ($("#R2IBuyForm input[name=R2ISelectSubscription]:checked").val()==undefined) ) {
		seemsOK = false;
		$("#RTIProductError").fadeTo(200,0.1,function() { 
			$(this).show().html(R2IBuyProductError).fadeTo(900,1);
		});
	} else { 
		//alert(RTIBuy.offerID);
		$("#RTIProductError").hide();
	}
}

function checkEmail() {
	var email = $("input#RTIChooseEmail").val();
	// use common email Pattern.
	if (!emailPattern.test(email)) {
		seemsOK = false;
		$("#RTIEmailError").fadeTo(200,0.1,function() { 
			$(this).html(R2IButEmailPatternIncorrect).fadeTo(900,1);
		});
		$("#RTIEmailValid").html('(This will be your login name)');
	} else {
		return sendMethodToAction();		
	}
}

// Call the action script
sendMethodToAction = function() {
	var formData = "method=checkUser&email=" + $("input#RTIChooseEmail").val();
	$("#RTIEmailValid").text('Checking...').fadeIn("slow");

	// call the database processing script
	new jQuery.ajax({ type: 'POST', 
					dataType: "xml",
					url: "action.php",
					data: formData,
					dataType: "json",
					success: onAjaxCheckEmailSuccess,
					error: onAjaxCheckEmailFail});
	return false;
};

onAjaxCheckEmailSuccess = function(data) {
	//alert('sucess, data='+data.success);
	if (data.success) {
		$("#RTIEmailError").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyEmailExists).fadeTo(900,1);
			seemsOK = false;
		});
	} else {
		$("#RTIEmailValid").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyEmailIsValid).fadeTo(900,1);
		});	
		$("#RTIEmailError").hide();
	}
};	

onAjaxCheckEmailFail = function(data, textStatus) {
	$("#RTIEmailError").fadeTo(200,0.1,function() { 
		$(this).html(R2IBuyEmailUnknwonError).fadeTo(900,1);
		seemsOK = false;
	});
};

function checkPassword() {
	var password = $("input#RTIChoosePassword").val();
	var password2 = $("input#RTIRetypePassword").val();
	//var passwordPattern = /^([a-zA-Z0-9_.-@#$%^&+=]){8,15}$/;
	if (!passwordPattern.test(password)) {
		seemsOK = false;
		$("#RTIPasswordError").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyPwdPatternIncorrect).fadeTo(900,1);
		});
	} else {
		$("#RTIPasswordError").hide();
	}
	if (password!=password2) {
		seemsOK = false;
		$("#RTIPassword2Error").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyPwdPatternIncorrect).fadeTo(900,1);
		});
	} else {
		$("#RTIPassword2Error").hide();
	}
}

function checkName() {
	var name = $("input#RTIName").val();
	if (name == "") {
		seemsOK = false;
		$("#RTINameError").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyNameMissing).fadeTo(900,1);
		});
	} else {
		$("#RTINameError").hide();
	}
}

function checkCountry() {
	var country = $("#RTICountry").val();
	if ( (country == "none") || (country == "") ){
		seemsOK = false;
		$("#RTICountryError").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyCountryNotChose).fadeTo(900,1);
		});
	} else {
		$("#RTICountryError").hide();
	}
}

// Step 2 Actions
function checkPayment() {
	if ($("#R2IBuyForm input[name=R2ISelectPayment]:checked").val()==undefined) {
		seemsOK = false;
		$("#R2IStep2Msg").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyPaymentNotSelected).fadeTo(900,1);
		});
	} else { 
		$("#R2IStep2Msg").hide();
	}
}
function checkAgreeTerms() {
	if (!$('#RTIAgreeTerms').is(':checked')) {
		seemsOK = false;
		$("#R2IStep2Msg").fadeTo(200,0.1,function() { 
			$(this).html(R2IBuyTnCNotChecked).fadeTo(900,1);
		});
	} else { 
		$("#R2IStep2Msg").hide();
	}
}
function changePayment2(){
	$("#buy_payment_user").show();
	if (RTIBuy.paymentMethod!="") var p=RTIBuy.paymentMethod
	else var p = $("#R2IBuyForm input[name=R2ISelectPayment]:checked").val();
	switch(p) {
		case "Visa":
		case "MC":
			$("#creditcard_user").fadeTo(900,1);
			$("#paypal_user").hide();
			$("#moneytransfer_user").hide();
			$("#directbank_user").hide();
			$("#buy_paydollar").fadeTo(900,1);
			$("#buy_paypal").hide();
			break;
		case "PP":
			$("#creditcard_user").hide();
			$("#paypal_user").fadeTo(900,1);
			$("#moneytransfer_user").hide();
			$("#directbank_user").hide();
			$("#buy_paydollar").hide();
			$("#buy_paypal").fadeTo(900,1);
			break;
		case "MT":
			$("#creditcard_user").hide();
			$("#paypal_user").hide();
			$("#moneytransfer_user").fadeTo(900,1);
			$("#directbank_user").hide();
			$("#buy_paydollar").hide();
			$("#buy_paypal").hide();
			break;
		case "DB":
			$("#creditcard_user").hide();
			$("#paypal_user").hide();
			$("#moneytransfer_user").hide();
			$("#directbank_user").fadeTo(900,1);
			$("#buy_paydollar").hide();
			$("#buy_paypal").hide();
			break;
	}
}

// Step 3 Actions
function changePayment3(){
	switch(RTIBuy.paymentMethod) {
		case "Visa":
		case "MC":
			$("#creditcard_user3").fadeTo(900,1);
			$("#paypal_user3").hide();
			$("#moneytransfer_user3").hide();
			$("#directbank_user3").hide();
			break;
		case "PP":
			$("#creditcard_user3").hide();
			$("#paypal_user3").fadeTo(900,1);
			$("#moneytransfer_user3").hide();
			$("#directbank_user3").hide();
			break;
		case "MT":
			$("#creditcard_user3").hide();
			$("#paypal_user3").hide();
			$("#moneytransfer_user3").fadeTo(900,1);
			$("#directbank_user3").hide();
			break;
		case "DB":
			$("#creditcard_user3").hide();
			$("#paypal_user3").hide();
			$("#moneytransfer_user3").hide();
			$("#directbank_user3").fadeTo(900,1);
			break;
	}
}

function processCheckOut(){
	var actionURL = 'processPayment.php';
	var formParam = {
		'paymentMethod': RTIBuy.paymentMethod,
		'name': RTIBuy.name,
		'email': RTIBuy.email,
		'password': RTIBuy.password,
		'country': RTIBuy.country,
		'offerID': RTIBuy.offerID,
		'amount': RTIBuy.TotalAmount,
		//'isReturn': isReturn,
		//below fields are just for emails and marketing use
		'ageGroup': RTIBuy.ageGroup,
		'phone': RTIBuy.phone,
		'newsletter': RTIBuy.newsletter
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

function period2Text(period) {
	switch (period) {
		case '31':
			return "1 month";
			break;
		case '92':
			return "3 months";
			break;
		case '183':
			return "6 months";
			break;
		case '365':
			return "1 year";
			break;
	}
}

function productCode2Text(pc) {
	switch (pc) {
		case '52':
			return "Academic Module";
			break;
		case '53':
			return "General Training";
			break;
	}
}

function payment2Text(method){ 
	switch(method) {
		case "Visa":
			return "Credit card: <strong>Visa</strong> (Credit Card verification with 3D Secure)";
			break;
		case "MC":
			return "Credit card: <strong>Master Card</strong> (Credit Card verification with 3D Secure)";
			break;
		case "PP":
			return "<strong>Paypal</strong>";
			break;
		case "MT":
			return "<strong>Money Transfer</strong>";
			break;
		case "DB":
			return "<strong>Direct Bank Deposit</strong>";
			break;
		default:
	}
}

function formatDate(d) {
var m_names = new Array("January", "February", "March", 
"April", "May", "June", "July", "August", "September", 
"October", "November", "December");
var curr_date = d.getDate();
var curr_month = d.getMonth();
var curr_year = d.getFullYear();
return m_names[curr_month] + " " + curr_date + ", " + curr_year
//document.write(curr_date + "-" + m_names[curr_month] + "-" + curr_year);
}

function getExpiryDate(d) {
	var startDate = new Date();
	var xd = new Date().setDate(startDate.getDate()+d); //d days from now
	//return formatDate(xd);
	return xd;
}