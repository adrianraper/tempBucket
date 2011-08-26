package  
{
	import flash.external.ExternalInterface;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.net.LocalConnection;
	import flash.events.StatusEvent;
	//import com.clarityenglish.utils.TraceUtils;
	/**
	 * ...
	 * @author Adrian Raper
	 *
	 * This assumes that you are NOT online, but that you are running from a webserver.
	 *
	 * This has to do tricky things as you can't use the air.swf on a non-connected computer to detect the application version (or presence).
	 * And we can't install AIR from here, so all you can do is install the AIR app or launch it, but without knowing if it is there.
	 * So lets first try to launch it and see if we can pick up any LocalConnection activity. If there is, then goodbye.
	 * If there isn't, then we can offer up the install button. In the worst case, the install will simply tell you Recorder is already installed.
	 */
	public class MyLocalBadger  extends MovieClip
	{
		
		public function MyLocalBadger() 
		{
			
			var sendConn:LocalConnection = new LocalConnection();
			function myTrace(message:String):void {
				sendConn.send("_trace", "myTrace", message, 0);
			}

			var airSWF:Object; // This is the reference to the main class of air.swf 
			var airSWFLoader:Loader = new Loader(); // Used to load the SWF 
			var loaderContext:LoaderContext = new LoaderContext();  
			var checkInstallationTimer:Timer;
			var airStatus:String;

			// Used to set the application domain
			loaderContext.applicationDomain = ApplicationDomain.currentDomain; 
			// Where you will go once adobe has worked out your situation
			airSWFLoader.contentLoaderInfo.addEventListener(Event.INIT, onInit); 

			//var loader:Loader = new Loader();
			//var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
			var fullPath:String = this.loaderInfo.loaderURL;
			var domainPath:String = fullPath.substring(0, fullPath.indexOf("MyLocalBadger.swf",0));
			myTrace("badger is running from: " + domainPath);
			var pathToCommon:String = domainPath + "../Common/";
			var pathToInstall:String = domainPath + "../../Install/";
			//myTrace("path to common: " + pathToCommon);
			//myTrace("path to install: " + pathToInstall);			
			
			try {
				// Does it make any difference to getApplicationVersion if you use a full URL? No.
				// Do I need a crossdomain file on my server? I would have thought it has to be on Adobe's.
				//airSWFLoader.load(new URLRequest("http://airdownload.adobe.com/air/browserapi/air.swf"),  
				//airSWFLoader.load(new URLRequest("http://dock.fixbench/Software/Common/air.swf"),  
				airSWFLoader.load(new URLRequest(pathToCommon + "air.swf"),  
				//airSWFLoader.load(new URLRequest("../../Software/Common/air.swf"),  
								loaderContext);
			} catch (e:Error) {
				msgTxt.text = e.message;
			} 
			// Style for the main button
			var myTF:TextFormat = new TextFormat();
			myTF.font = "Arial,Helvetica";
			myTF.size = 14;
			myTF.bold = true;
			//myTF.color = 0xFFFFFF;
			cmdLaunch.setStyle("textFormat", myTF);
			// Change the alpha in any way sets it to totally opaque
			cmdLaunch.alpha = 100;
			
			// Style for the message
			var msgTF:TextFormat = new TextFormat();
			msgTF.font = "Arial,Helvetica";
			msgTF.size = 11;
			msgTF.align = "center";
			//msgTxt.setStyle("textFormat", msgTF);
			
			// for help link
			var moreHelp:String = "<u><a href='http://www.ClarityEnglish.com/Support/support_recorder.php' target='_blank'>More info...</a></u>";
			var newline:String = "<br/>";
				
			var creationCompleteTimer:Timer = new Timer(100, 1);
			creationCompleteTimer.addEventListener(TimerEvent.TIMER, creationComplete);
			creationCompleteTimer.start();

			// v4.0.1.4 use local connection to detect if recorder starts
			var receiveConn:LocalConnection;			
			receiveConn = new LocalConnection();
			receiveConn.allowDomain('*');
			
			var lcReceiver = new Object();
			receiveConn.client = lcReceiver;
			receiveConn.addEventListener(StatusEvent.STATUS, rcStatusChanged);
			try {
				// Set yourself up with a connection string that other people must use
				receiveConn.connect("_clarityBadger");
			} catch (error:ArgumentError) {
				//TraceUtils.myTrace("localConnection setup failure, " + error.message);
				receiveConn = undefined;
			}
			function rcStatusChanged(event:StatusEvent):void {
				myTrace("badger rcStatusChanged: " + event); 
			}
			// This is the only way in which we can know that we have the Recorder running.
			// Once that has happened, we will certainly want to try and close this window if we can.
			lcReceiver.onClarityRecorderLoaded = function():void {
				myTrace("Clarity Recorder is now loaded");
				// So now we can exit since our job is done
				checkInstallationTimer.stop();
				closeWindow();
			}
			
			function creationComplete():void {
			}
			
			function onInit(e:Event):void { 
				airSWF = e.target.content; 
				// Is AIR installed?
				airStatus = airSWF.getStatus();
				myTrace("AIR status=" + airStatus);
				
				// If AIR is installed, then see if the application is installed.
				// The status refers to AIR
				if (airStatus=="installed") {
					// You can't detect any more. So now try to launch the application and listen for success.
					var appID:String = "com.ClarityEnglish.ClarityRecorder";
					var pubID:String = "";
					//airSWF.getApplicationVersion(appID, pubID, versionDetectCallback);
					versionDetectCallback("4.0.1.2");
				// This means that you don't have AIR, but your system can support it.
				// If you are not online there is nothing you can do from here.
				} else if (airStatus=="available") {
					cmdLaunch.visible = false;
					//msgTxt.htmlText = "You need to install Adobe's AIR. " + newline + moreHelp;
					msgTxt.htmlText = "You need to install Adobe's AIR. " + newline + "You can get this by running a Clarity client installation on this computer. Please ask your support staff.";

				// Your computer can't run AIR
				} else {
					cmdLaunch.label = "Sorry, your computer can't run this program.";
				}
				
			}

			// This is called after a pause to see if the attempted launch worked.
			function didRecorderStart(e:TimerEvent):void {
				// If you are here, it means that the timer wasn't stopped because the Recorder hasn't told us it started.
				// So we'll need to install the app.
				myTrace("did recorder start? er er, not yet");
				versionDetectCallback(null);
			}
			
			// This function is only called manually because air.swf doesn't support it locally.
			function versionDetectCallback(version:String):void {
				myTrace("versionDetectCallback=" + version);
				if (version == null) {
					//MonsterDebugger.trace(this, "Application not installed.");
					cmdLaunch.removeEventListener(MouseEvent.CLICK, launchApp);
					cmdLaunch.addEventListener(MouseEvent.CLICK, installApp);
					cmdLaunch.label = "Install";
					msgTxt.htmlText = "Click to install the Clarity Recorder. " + moreHelp;
				} else {
					cmdLaunch.addEventListener(MouseEvent.CLICK, launchApp);
					cmdLaunch.label = "Run";
					msgTxt.htmlText = "Click to run the Clarity Recorder. " + newline + moreHelp;
				}
			}

			function installApp(myEvent:MouseEvent):void {
				//var url:String = "http://dock/Fixbench/Software/Recorder/ClarityRecorder.air";
				// Sadly this must be an absolute URL, not relative. And can't refer to a file.
				//var url:String = "/Software/Recorder/air/ClarityRecorder.air";
				msgTxt.text = "Please choose Open rather than Save when you are asked.";
				//var url:String = "http://dock.fixbench/Install/ClarityRecorder/ClarityRecorder.air";
				var url:String = pathToInstall + "ClarityRecorder/ClarityRecorder.air";
				//var url:String = "file:///D:/Fixbench/Install/ClarityRecorder/ClarityRecorder.air";
				//var url:String = "../../Install/ClarityRecorder/ClarityRecorder.air";
				//var runtimeVersion:String = "2.0beta2";
				var runtimeVersion:String = "2.0";
				var arguments:Array = ["launchFromBrowser"]; // Optional
				airSWF.installApplication(url, runtimeVersion, arguments);
			}
			
			function launchApp(myEvent:MouseEvent):void {
				myTrace("Trying to launch Clarity Recorder");
				var appID:String = "com.ClarityEnglish.ClarityRecorder";
				var pubID:String = "";
				var arguments:Array = ["launchFromBrowser"]; // Optional
				airSWF.launchApplication(appID, pubID, arguments);
				// Now we don't know if this will succeed, so wait for x seconds to see if we get any communication on localConnection
				// from the launched recorder. If we don't then we should assume that we need to install.
					checkInstallationTimer = new Timer(5000, 1); // Try once after 5 seconds
					checkInstallationTimer.addEventListener(TimerEvent.TIMER_COMPLETE, didRecorderStart);
					checkInstallationTimer.start();
				// This might or might not succeed so we will wait for a few seconds
				cmdLaunch.label = "...";
				msgTxt.htmlText = "Trying to start the Clarity Recorder. If this fails in a few seconds you can install it. " + newline + moreHelp;
			}
			
			function closeWindow():void {
				// Bug 17. July 17 2010. AR
				// Try to close this window now that you have, hopefully, run the application.
				// I could use LC to actually test if it has worked I suppose.
				// This is not clever because sometimes AIR loads from within this badger, so closing stops the installation
				// So you should only close when you know that a) the recorder is running or b) that you have started the AIR download
				//msgTxt.text = "Closing window";
				ExternalInterface.call("closeWindow");
				// If you can't close this window, lets make it clear that we are done
				cmdLaunch.visible = false;
				msgTxt.htmlText = "The Clarity Recorder is now running. " + newline + moreHelp;
				cmdLaunch.removeEventListener(MouseEvent.CLICK, launchApp);
				cmdLaunch.removeEventListener(MouseEvent.CLICK, installApp);
			}
			// Utility stuff for version numbers
			function needUpgrade(myVersion, latestVersion):Boolean {
				var myVersionArray:Array = myVersion.split(".");
				for (var i=0; i<4;i++) {
					if (isNaN(parseInt(myVersionArray[i]))) myVersionArray[i]=0;
				}
				var myVersionObj:Object = new Object();
				myVersionObj.major = parseInt(myVersionArray[0]);
				myVersionObj.minor = parseInt(myVersionArray[1]);
				myVersionObj.build = parseInt(myVersionArray[2]);
				myVersionObj.patch = parseInt(myVersionArray[3]);
				
				var latestVersionArray:Array = latestVersion.split(".");
				for (i=0; i<4;i++) {
					if (isNaN(parseInt(latestVersionArray[i]))) latestVersionArray[i]=0;
				}
				var latestVersionObj:Object = new Object();
				latestVersionObj.major = parseInt(latestVersionArray[0]);
				latestVersionObj.minor = parseInt(latestVersionArray[1]);
				latestVersionObj.build = parseInt(latestVersionArray[2]);
				latestVersionObj.patch = parseInt(latestVersionArray[3]);
				
				if (latestVersionObj.major < myVersionObj.major) return false;
				if (latestVersionObj.major > myVersionObj.major) return true;
				if (latestVersionObj.minor < myVersionObj.minor) return false;
				if (latestVersionObj.minor > myVersionObj.minor) return true;
				if (latestVersionObj.build < myVersionObj.build) return false;
				if (latestVersionObj.build > myVersionObj.build) return true;
				if (latestVersionObj.patch > myVersionObj.patch) return true;
				return false;
			}
		}
		
	}

}