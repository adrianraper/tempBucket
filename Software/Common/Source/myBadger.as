// v6.4.3 Since any movies published for different Flash players will not share the same
//_global space, I need to pass this object through to them.
if (_global.ORCHID == undefined) {
	_global.ORCHID = this._parent.sharedGlobal;
} 

this.depth=0;
this.margin=0;

myTrace("I am in badger " + this);

var airSWFLoader:MovieClipLoader = new MovieClipLoader();
var loadListener = new Object();
airSWFLoader.addListener(loadListener); 
var airSWF = this.createEmptyMovieClip("airSWF", this.depth++);
airSWFLoader.loadClip("http://airdownload.adobe.com/air/browserapi/air.swf?cache=" + new Date().getTime(), airSWF);

loadListener.onLoadInit = function(targetMC) { 
	myTrace("content has been loaded into "+targetMC); 
	// So lets see if AIR is loaded. AH, but I can't talk to the air.swf. I suppose because it is AS3?
	var AIRstatus:String = targetMC.getStatus();
	myTrace("and AIR is "+AIRstatus); 
} 
loadListener.onLoadComplete = function(targetMC) { 
        var loadProgress = airSWFLoader.getProgress(targetMC);
        myTrace("Bytes loaded at end=" + loadProgress.bytesLoaded);
        myTrace("Total bytes loaded at end=" + loadProgress.bytesTotal);
} 
loadListener.onLoadError = function(mc, errorCode) {
	myTrace("loading error "+errorCode); 
}
loadListener.onLoadStart = function (targetMC) {
        var loadProgress = airSWFLoader.getProgress(targetMC);
        myTrace ("The movieclip " + targetMC + " has started loading");
        myTrace("Bytes loaded at start=" + loadProgress.bytesLoaded);
        myTrace("Total bytes loaded at start=" + loadProgress.bytesTotal);
}
/*
//import nl.demonsters.debugger.MonsterDebugger;
//var debugger:MonsterDebugger = new MonsterDebugger(this);
//MonsterDebugger.trace(this, "AIR checker");
			
var airSWF:Object; // This is the reference to the main class of air.swf 
var airSWFLoader:Loader = new Loader(); // Used to load the SWF 
var loaderContext:LoaderContext = new LoaderContext();  

// Used to set the application domain
loaderContext.applicationDomain = ApplicationDomain.currentDomain; 
 
airSWFLoader.contentLoaderInfo.addEventListener(Event.INIT, onInit); 
airSWFLoader.load(new URLRequest("http://airdownload.adobe.com/air/browserapi/air.swf"),  
                    loaderContext); 
 
function onInit(e:Event):void  
{ 
    airSWF = e.target.content; 
	// Is AIR installed?
	var status:String = airSWF.getStatus();
	//MonsterDebugger.trace(this, "AIR status=" + status);
	
	// If AIR is installed, then see if the application is installed.
	if (status=="installed") {
		var appID:String = "com.ClarityEnglish.ClarityRecorder";
		var pubID:String = "";
		airSWF.getApplicationVersion(appID, pubID, versionDetectCallback);
	}
}
function versionDetectCallback(version:String):void
{
    if (version == null) {
        //MonsterDebugger.trace(this, "Application not installed.");
		cmdLaunch.addEventListener(MouseEvent.CLICK, installApp);
		cmdLaunch.label = "Install me";
    } else {
        //MonsterDebugger.trace(this, "Application installed just fine.");
		cmdLaunch.addEventListener(MouseEvent.CLICK, launchApp);
		cmdLaunch.label = "Launch me";
    }
}

function installApp(myEvent:MouseEvent):void {
	var url:String = "http://dock/Fixbench/Recorder/ClarityRecorder/air/ClarityRecorder.air";
	var runtimeVersion:String = "2.0beta2";
	var arguments:Array = ["launchFromBrowser"]; // Optional
	airSWF.installApplication(url, runtimeVersion, arguments);
}
function launchApp(myEvent:MouseEvent):void {
    //MonsterDebugger.trace(this, "Try to launch");
	var appID:String = "com.ClarityEnglish.ClarityRecorder";
	var pubID:String = "";
	var arguments:Array = ["launchFromBrowser"]; // Optional
	airSWF.launchApplication(appID, pubID, arguments);
}
*/
stop();