function openWindowForNNW(url,n,w,h,tb,stb,l,mb,sb,rs,x,y){
	x=(screen.width-w)/2; y=(screen.height-h)/2;	// v0.16.1, DL: make the popup at center of screen
	var t=(document.layers)? ',screenX='+x+',screenY='+y: ',left='+x+',top='+y; //A LITTLE CROSS-BROWSER CODE FOR WINDOW POSITIONING
	tb=(tb)?'yes':'no'; stb=(stb)?'yes':'no'; l=(l)?'yes':'no'; mb=(mb)?'yes':'no'; sb=(sb)?'yes':'no'; rs=(rs)?'yes':'no';
	var xx=window.open(url, n, 'scrollbars='+sb+',width='+w+',height='+h+',toolbar='+tb+',status='+stb+',menubar='+mb+',links='+l+',resizable='+rs+t);
	xx.focus();
}
function openWindow(url,w,h,tb,stb,l,mb,sb,rs,x,y){
	openWindowForNNW(url, 'newWin'+new Date().getTime(), w,h,tb,stb,l,mb,sb,rs); 
}
function onCloseForm() {
	if (navigator.appName.indexOf ("Microsoft") !=-1) {window.closeFormHandler.SetVariable("arg","onCloseForm");} else {document.closeFormHandler.SetVariable("arg","onCloseForm");}
}
function openKeyFactsVideoPlayer(page) {
	var url = "/Content/RoadToIELTS2/" + page;	
	var w = 431; var h = 249; 
	openWindowForNNW(page, 'video', w, h, 0, 0, 0, 0, 0, 0); 
} 
function openRecorderBadger(moviePath) {
	openWindow(moviePath + '../../Recorder/ClarityRecorderBadger.html', 258, 251, 0, 0, 0, 0, 0, 1);
};
function openRecorderLocalBadger(moviePath) {
	openWindow(moviePath + '../../Recorder/ClarityRecorderLocalBadger.html', 258, 251, 0, 0, 0, 0, 0, 1);
};
function videopopup(page) { 
	openWindowForNNW(page, 'video', 660, 380, 0, 0, 0, 0, 0, 0); 
} 