// This program is to simply load an html page into a mdm wrapper

// You may be sent some parameters which include the path and whether or not you are online
// Pick them up and break down into name/value pairs
cmd_value = mdm.Application.getCMDParams(1);
cmd_array = new Array();
if (cmd_value.indexOf("/")==0) {
	cmd_value=cmd_value.substr(1);
}
if (cmd_value != undefined) {
	cmd_pairs = cmd_value.split("&");
	for (var i in cmd_pairs) {
		var cmd_pair = cmd_pairs[i].split("=");
		myTrace("cmd: " + cmd_pair[0] + "=" + cmd_pair[1]);
		cmd_array.push({parameter:cmd_pair[0], value:cmd_pair[1]});
	}
} else {
	myTrace("empty command line");
}
// Check what we have
for (var i in cmd_array) {
	if (cmd_array[i].parameter == "path") {
		var moviePath:String = cmd_array[i].value
		myTrace("moviePath=" + _global.ORCHID.commandLine.username);
	} else if (cmd_array[i].parameter == "online") {
		//myOnline = (cmd_array[i].value=="true");
		var myOnline:String = cmd_array[i].value;
		myTrace("myOnline=" + myOnline);
	}
}

var appPath:String = mdm.Application.path;
var fullURL=appPath + "ClarityRecorderMDMBadger.html?online=" + myOnline;
myTrace("launching " + fullURL);
//mdm.browser_load("0", 100, 100, 280, 260, appPath + "ClarityRecorderMDMLocalBadger.html", true);
var myBrowser = new mdm.Browser(0, 0, 800, 350, fullURL, false);
//if (myOnline) {
//} else {
//	var myBrowser = new mdm.Browser(0, 0, 280, 280, appPath + "ClarityRecorderMDMBadger.html?online=false", false);
//}
