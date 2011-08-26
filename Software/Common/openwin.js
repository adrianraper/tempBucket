/*
<a href="javascript:openWindow( 'http://scriptasylum.com', 200, 200 ,0 ,0 ,0 ,0 ,0 ,1 ,10 ,10 )">Link text here</a> 
Usage: openWindow( url , w , h , tb , stb , L , mb , sb , rs , x , y ) 

url - The URL of the page to open. Example: "http://scriptasylum.com". 
w - The width of the window in pixels. 
h - The height of the window in pixels (doesn't include menubars). 
tb - Toolbar visible? 1 = yes, 0 = no. 
stb - Status bar visible? 1 = yes, 0 = no. 
L - Linkbar visible? 1 = yes, 0 = no. 
mb - Menubar visible? 1 = yes, 0 = no. 
sb - Scrollbars visible? 1 = yes, 0 = no. 
rs - Resizable window? 1 = yes, 0 = no. 
x - The horizontal position of the window from the left of the screen. 
y - The vertical position of the window from the top of the screen. 
*/

function openWindow(url,w,h,tb,stb,l,mb,sb,rs,x,y){
var t=(document.layers)? ',screenX='+x+',screenY='+y: ',left='+x+',top='+y; //A LITTLE CROSS-BROWSER CODE FOR WINDOW POSITIONING
tb=(tb)?'yes':'no'; stb=(stb)?'yes':'no'; l=(l)?'yes':'no'; mb=(mb)?'yes':'no'; sb=(sb)?'yes':'no'; rs=(rs)?'yes':'no';
var xx=window.open(url, 'newWin'+new Date().getTime(), 'scrollbars='+sb+',width='+w+',height='+h+',toolbar='+tb+',status='+stb+',menubar='+mb+',links='+l+',resizable='+rs+t);
xx.focus();
}

function onCloseForm() {
	if (navigator.appName.indexOf ("Microsoft") !=-1) {
		window.closeFormHandler.SetVariable("arg","onCloseForm");
	} else {
		document.closeFormHandler.SetVariable("arg","onCloseForm");
	}
}

function openWindowForNNW(url,n,w,h,tb,stb,l,mb,sb,rs,x,y){
x=(screen.width-w)/2; y=(screen.height-h)/2;	// v0.16.1, DL: make the popup at center of screen
var t=(document.layers)? ',screenX='+x+',screenY='+y: ',left='+x+',top='+y; //A LITTLE CROSS-BROWSER CODE FOR WINDOW POSITIONING
tb=(tb)?'yes':'no'; stb=(stb)?'yes':'no'; l=(l)?'yes':'no'; mb=(mb)?'yes':'no'; sb=(sb)?'yes':'no'; rs=(rs)?'yes':'no';
var xx=window.open(url, n, 'scrollbars='+sb+',width='+w+',height='+h+',toolbar='+tb+',status='+stb+',menubar='+mb+',links='+l+',resizable='+rs+t);
xx.focus();
}

function openRecorderBadger(moviePath) {
	openWindow(moviePath + '../../Recorder/ClarityRecorderBadger.html', 258, 251 ,0 ,0 ,0 ,0 ,0 ,1 ,200 ,200);
};
function openRecorderLocalBadger(moviePath) {
	openWindow(moviePath + '../../Recorder/ClarityRecorderLocalBadger.html', 258, 251 ,0 ,0 ,0 ,0 ,0 ,1 ,200 ,200);
};