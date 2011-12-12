function openWindow(url,w,h,tb,stb,l,mb,sb,rs,x,y){
var t=(document.layers)? ',screenX='+x+',screenY='+y: ',left='+x+',top='+y; //A LITTLE CROSS-BROWSER CODE FOR WINDOW POSITIONING
tb=(tb)?'yes':'no'; stb=(stb)?'yes':'no'; l=(l)?'yes':'no'; mb=(mb)?'yes':'no'; sb=(sb)?'yes':'no'; rs=(rs)?'yes':'no';
var xx=window.open(url, 'newWin'+new Date().getTime(), 'scrollbars='+sb+',width='+w+',height='+h+',toolbar='+tb+',status='+stb+',menubar='+mb+',links='+l+',resizable='+rs+t);
xx.focus();
}
function onCloseForm() {
	if (navigator.appName.indexOf ("Microsoft") !=-1) {window.closeFormHandler.SetVariable("arg","onCloseForm");} else {document.closeFormHandler.SetVariable("arg","onCloseForm");}
}
function openWindowForNNW(url,n,w,h,tb,stb,l,mb,sb,rs,x,y){
x=(screen.width-w)/2; y=(screen.height-h)/2;	// v0.16.1, DL: make the popup at center of screen
var t=(document.layers)? ',screenX='+x+',screenY='+y: ',left='+x+',top='+y; //A LITTLE CROSS-BROWSER CODE FOR WINDOW POSITIONING
tb=(tb)?'yes':'no'; stb=(stb)?'yes':'no'; l=(l)?'yes':'no'; mb=(mb)?'yes':'no'; sb=(sb)?'yes':'no'; rs=(rs)?'yes':'no';
var xx=window.open(url, n, 'scrollbars='+sb+',width='+w+',height='+h+',toolbar='+tb+',status='+stb+',menubar='+mb+',links='+l+',resizable='+rs+t);
xx.focus();
}
function openKeyFactsVideoPlayer(page) {
var url = "/Content/RoadToIELTS2/" + page;	
var w = 400; var h = 233; 
var lp = (screen.width) ? (screen.width-w)/2 : 0;var tp = (screen.height) ? (screen.height-h)/2 : 0;var t = ',top='+tp+',left='+lp;var ow = this.window.open(url, "KeyFactsVideo", "toolbar=no,menubar=no,location=no,status=no,scrollbars=no,resizable=no,width="+w+",height="+h+t);
ow.focus();
} 
function openRecorderBadger(moviePath) {
	openWindow(moviePath + '../../Recorder/ClarityRecorderBadger.html', 258, 251 ,0 ,0 ,0 ,0 ,0 ,1 ,200 ,200);
};
function openRecorderLocalBadger(moviePath) {
	openWindow(moviePath + '../../Recorder/ClarityRecorderLocalBadger.html', 258, 251 ,0 ,0 ,0 ,0 ,0 ,1 ,200 ,200);
};