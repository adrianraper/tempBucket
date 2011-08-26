// This program is to simply load an html page into a mdm wrapper

var appPath:String = mdm.Application.path;
var fullURL=appPath + "ClarityRecorderMDM.html";
myTrace("launching " + fullURL);
// The browser window needs to be wider to accomodate a vertical scroll bar even if you don't need it.
// You can then make the Flash window smaller so that it is cropped.
var myBrowser = new mdm.Browser(0, 0, 870, 350, fullURL, false);
