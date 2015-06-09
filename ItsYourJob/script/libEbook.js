var g_Date = new Date();
var g_starttime = g_Date.getTime();
function onFlip(pageNumber, totalPages){
	var realTotalPages = Math.round( parseInt(totalPages, 10) / 2);
	var correct = Math.round( parseInt(pageNumber, 10) / 2);
	var wrong = 0;
	var skipped = realTotalPages - correct;
	var g_Now = new Date();
	var duration = Math.round((g_Now.getTime() - g_starttime)/1000);
	var score = Math.round(100 * ( correct / realTotalPages ));

    var ebookID = location.search.match(new RegExp("[\?\&]e=([^\&]*)(\&?)","i"));
    ebookID = ebookID ? ebookID[1] : ebookID;
    var ebookitemID = location.search.match(new RegExp("[\?\&]i=([^\&]*)(\&?)","i"));
    ebookitemID = ebookitemID ? ebookitemID[1] : ebookitemID;
    var courseID = location.search.match(new RegExp("[\?\&]o=([^\&]*)(\&?)","i"));
    courseID = courseID ? courseID[1] : courseID;
    writeScore(courseID, ebookID, ebookitemID, score, correct, wrong, skipped, duration);
}

function writeScore(courseID, unitID, itemID, score, correct, wrong, skipped, duration){
	var svrlet = "/ItsYourJob/writeScore.php";
	svrlet += "?o=" + courseID;
	svrlet += "&u=" + unitID;
	svrlet += "&i=" + itemID;
	svrlet += "&s=" + score;
	svrlet += "&c=" + correct;
	svrlet += "&w=" + wrong;
	svrlet += "&m=" + skipped;
	svrlet += "&d=" + duration;
	cmdRequest(svrlet, "GET", null, true);
}

function cmdRequest(svrlet, method, handle, syn){
	xmlhttp = null;
	if (window.XMLHttpRequest){// code for Firefox, Opera, IE7, etc.
		xmlhttp = new XMLHttpRequest();
	}else if (window.ActiveXObject){// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp != null){
		xmlhttp.onreadystatechange = handle;
		xmlhttp.open(method, svrlet, syn);
		xmlhttp.send(null);
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
}