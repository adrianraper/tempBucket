// common code for each AP module
#include "D:/Projectbench/myTrace.as"

var progressNS			= new Object();
progressNS.moduleName 	= "progressModule";
progressNS.depth		= 1; 
// v6.5.4.3 To allow you to know if this is a full or dummy module
progressNS.harness = false;

_parent.controlNS.remoteOnData(progressNS.moduleName, true);

// global variables
_global.myTrace= myTrace;
_global.myParent= _parent;
//_global.myInterface= _parent.interface;

// my program start here
import AP_Progress.ProgressApp;
var app:ProgressApp;
app= new AP_Progress.ProgressApp();

// v6.5.5.8 In order to make sure that amcharts doesn't show the licence message if the loading sequence isn't good, try to preload it here.
// This will throw up a missing file for amPie_data.xml and amColumn_data.xml (which it expects in the area1 folder)
// More worringly it is is looking in area1/CP for the licence files.
// Surely it should look in the path folder? Yes, but it doesn't. Screws it all up for later too. So how about just loading the licence so at least that is in cache?
// Doesn't have any fantastic impact. If throttling is on, even though I already have the licences I still end up looking in area1 folder.
// I think the solution is to avoid loading progress again when you want to display it.
/*this.createEmptyMovieClip("amchartsPlaceHolderPie",-100);
amchartsPlaceHolderPie._y = -250;
this.createEmptyMovieClip("amchartsPlaceHolderColumn",-101);
amchartsPlaceHolderColumn._y = -200;

amPieListener= new Object(); 
amPieListener.onLoadComplete = function(target_mc:MovieClip):Void {
	myTrace("loadComplete for ampie");
	target_mc.path = _global.ORCHID.paths.movie + "ampie/";
	//target_mc.chart_settings = new XML("<settings><data><chart><series><value xid='1'>1</value></series></chart></data></settings>")
}
amPieLoader= new MovieClipLoader();
amPieLoader.addListener(amPieListener);
//amPieLoader.loadClip(_global.ORCHID.paths.movie + "ampie/ampie.swf?ver=3", amchartsPlaceHolderPie);
//amchartsPlaceHolderColumn.loadMovie(_global.ORCHID.paths.movie + "amcolumn/amcolumn.swf");
*/
// Even with this code, we can still get cases where the licence isn't found when ampie.swf gets loaded. That doesn't look good.
var amPieVars = new LoadVars();
amPieVars.load(_global.ORCHID.paths.movie + "ampie/amcharts_key.txt");
var amPieColumn = new LoadVars();
amPieColumn.load(_global.ORCHID.paths.movie + "amcolumn/amcharts_key.txt");
amPieColumn.onLoad = function(success) {
	//myTrace("amcolumn licence loaded"); // + this.getBytesLoaded());
}
amPieVars.onLoad = function(success) {
	//myTrace("ampie licence loaded"); // + this.getBytesLoaded());
}

this._parent.progressLoadedEvent();
stop();

// v6.5.5.6 Only used for debugging why the stage was resizing on loading amcolumn.
/*
this.stageListener = new Object();
this.stageListener.onResize = function() {
	myTrace("stage resized, scaleMode=" + Stage.scaleMode + " width=" + Stage.width);
}
Stage.addListener(this.stageListener);
*/

// v6.5.5.6 Where oh where is this called from? I want to find out what width and height are sent to it.
// Ah. view.as.cmdProgress. They are set to fit in the content section of teh pop up progress window.
function InitApp(myXmlRec:XML, everyoneXmlRec:XML, nAppWidth:Number, nAppHeight:Number):Void{
	//myTrace("1codeInProgress nAppWidth=" + nAppWidth + " stage.scaleMode=" + Stage.scaleMode);
	app.InitApp(this, nAppWidth, nAppHeight, this._parent.getNextHighestDepth(), myXmlRec, everyoneXmlRec);
}

function printPage(strHeader:String):Void{
	app.printPage(strHeader);
}
// v6.5.6.4 New SSS
function displayScores():Void {
	app.displayScores();
}
function displayCompare():Void {
	app.displayCompare();
}
function displayAnalysis():Void {
	app.displayAnalysis();
}