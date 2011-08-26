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
	/**
	 * ...
	 * @author Adrian Raper
	 */
	public class MyBadger  extends MovieClip
	{
		
		public function MyBadger() 
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
			 
			try {
				airSWFLoader.load(new URLRequest("http://airdownload.adobe.com/air/browserapi/air.swf"),  
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
			
			// Style for the upgrade button
			myTF = new TextFormat();
			myTF.font = "Arial,Helvetica";
			myTF.size = 11;
			//myTF.bold = true;
			//myTF.color = 0xFFFFFF;
			cmdUpgrade.setStyle("textFormat", myTF);
			cmdUpgrade.alpha = 100;
			// Hide the upgrade button unless you need it
			cmdUpgrade.visible = false; // Doesn't work here
			cmdUpgrade.label = "Upgrade";
			
			// Style for the survey button
			myTF = new TextFormat();
			myTF.font = "Arial,Helvetica";
			myTF.size = 12;
			myTF.bold = true;
			//myTF.color = 0xFFFFFF;
			cmdSurveyOK.setStyle("textFormat", myTF);
			cmdSurveyOK.alpha = 100;
			
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
				//myTrace("badger rcStatusChanged: " + event); 
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
				cmdUpgrade.visible = false;
				cmdSurveyEmail.visible=false;
				cmdSurveyOK.visible=false;
				surveyTxt1.visible = false;
				surveyTxt2.visible = false;
				surveyTxt1.y+=200;
				surveyTxt2.y+=200;
				cmdSurveyEmail.y+=200;
				cmdSurveyOK.y+=200;
			}
			
			function onInit(e:Event):void { 
				airSWF = e.target.content; 
				// Is AIR installed?
				airStatus = airSWF.getStatus();
				//MonsterDebugger.trace(this, "AIR status=" + status);
				
				// If AIR is installed, then see if the application is installed.
				// The status refers to AIR
				if (airStatus=="installed") {
					var appID:String = "com.ClarityEnglish.ClarityRecorder";
					var pubID:String = "";
					airSWF.getApplicationVersion(appID, pubID, versionDetectCallback);
				// This means that you don't have AIR, but your system can support it.
				// v1.1 It seems that if just download the .air app, it will seamlessly do AIR too.
				// Yes. You get an adobe popup window over the badger which does the AIR installation first.
				} else if (airStatus=="available") {
					//cmdLaunch.addEventListener(MouseEvent.CLICK, getAIR);
					//cmdLaunch.label = "Get AIR";		
					//msgTxt.text = "Download Adobe's AIR";
					// v1.1 Before you simply install it, how about asking if they mind giving us their email address so we can follow up?
					// Comment out this line if you don't want to do this, and one more later
					//betaSoftwareSurvey();
					cmdLaunch.addEventListener(MouseEvent.CLICK, installApp);
					cmdLaunch.label = "Install";
					msgTxt.htmlText = "Click to download and open the Clarity Recorder installer. Adobe's AIR will also be installed. " + newline + moreHelp;

				// Your computer can't run AIR
				} else {
					cmdLaunch.label = "Can't run!";
				}
				
				// And what happens if you are not online, yet simply want to launch the AIR app that you already have?
				// It is possible to include the air.swf in our packaging?
				
			}
			// v1.1 Ask if they mind telling us their email address before installing
			function betaSoftwareSurvey():void {
				cmdLaunch.visible = false;
				msgTxt.visible = false;
				surveyTxt1.htmlText = "Please type your email address.";
				surveyTxt2.htmlText = "We would like to send you an email to see if the Recorder is working OK after download.";
				cmdSurveyOK.visible=true;
				surveyTxt1.visible = true;
				surveyTxt2.visible = true;
				cmdSurveyOK.addEventListener(MouseEvent.CLICK, installAfterSurvey);
				cmdSurveyEmail.visible=true;
			}
			// Take us back on track
			function installAfterSurvey(e:Event):void {
				//myTrace("after survey, their email address is " + cmdSurveyEmail.text);
				// Send ourselves a note with their email address (if given) and a simple count that someone has tried to download the Recorder.
				var surveyResult:XML = <query method="downloadRecorder" productCode="4" />;
				if (cmdSurveyEmail.text!="") {
					surveyResult.@email = cmdSurveyEmail.text;
				}
				//if (this.referrer && this.referrer!="") {
				//	surveyResult.@referrer = this.referrer;
				//}
				var request:URLRequest = new URLRequest("http://www.ClarityEnglish.com/Software/Common/Source/SQLServer/runProgressQuery.php");
				var loader:URLLoader = new URLLoader();
				//loader.addEventListener(Event.COMPLETE, completeHandler);

				request.data = surveyResult.toXMLString();
				request.method = URLRequestMethod.POST;
				try {
					loader.load(request);
				}
				catch (error:SecurityError) {
					//trace("A SecurityError has occurred.");
				}
				
				surveyTxt1.visible = false;
				surveyTxt2.visible = false;
				cmdSurveyEmail.visible=false;
				cmdSurveyOK.visible=false;
				cmdSurveyOK.removeEventListener(MouseEvent.CLICK, installAfterSurvey);
				cmdLaunch.visible = true;
				msgTxt.visible = true;
				
			}
			function completeHandler(event:Event):void {
				//var loader:URLLoader = URLLoader(event.target);
				//msgTxt.htmlText = "completeHandler: " + loader.data;
			}

			// This is called occasionally if you are trying to work out how the installation is going.
			function checkAIRStatus(e:TimerEvent):void {
				// Is AIR installed?
				airStatus = airSWF.getStatus();
				msgTxt.htmlText = "Checking AIR installation... " + moreHelp;
				
				// If AIR is installed we will close the window. Sure this is safe?
				// Lets check. Yes, AIR isn't fully installed until you have left this window.
				if (airStatus=="installed") {
					msgTxt.htmlText = "AIR now installed. " + moreHelp;
					checkInstallationTimer.stop();
					closeWindow();
				}
			}
			function versionDetectCallback(version:String):void {
				if (version == null) {
					//MonsterDebugger.trace(this, "Application not installed.");
					// v1.1 Before you simply install it, how about asking if they mind giving us their email address so we can follow up?
					// Comment out this line if you don't want to do this and one more earlier
					//betaSoftwareSurvey();
					cmdLaunch.removeEventListener(MouseEvent.CLICK, getAIR);
					cmdLaunch.addEventListener(MouseEvent.CLICK, installApp);
					cmdLaunch.label = "Install";
					msgTxt.htmlText = "Click to install the Clarity Recorder. " + moreHelp;
				} else {
					cmdLaunch.removeEventListener(MouseEvent.CLICK, getAIR);
					cmdLaunch.removeEventListener(MouseEvent.CLICK, installApp);
					cmdLaunch.addEventListener(MouseEvent.CLICK, launchApp);
					cmdLaunch.label = "Run";
					//msgTxt.htmlText = "Click to start the Clarity Recorder. ";
					// What about testing the version to see if we need an upgrade?
					// I could read application.xml in this folder and pick up the version number from that to compare it.
					// For now hardcode.
					var latestVersion = "4.0.1.5";
					if (needUpgrade(version, latestVersion)) {
						cmdUpgrade.visible = true;
						cmdUpgrade.addEventListener(MouseEvent.CLICK, installApp);
						cmdUpgrade.label = "Upgrade";
						msgTxt.htmlText = "Click to run the Clarity Recorder, or click to upgrade to the latest version (" + latestVersion + ") of the Recorder. "  + moreHelp;
					} else {
						msgTxt.htmlText = "Click to run the Clarity Recorder. " + newline + moreHelp;
					}
				}
			}

			function installApp(myEvent:MouseEvent):void {
				//var url:String = "http://dock/Fixbench/Software/Recorder/ClarityRecorder.air";
				// Sadly this must be an absolute URL, not relative
				//var url:String = "/Software/Recorder/air/ClarityRecorder.air";
				msgTxt.text = "Please choose Open rather than Save if you are asked.";
				var url:String = "http://www.ClarityEnglish.com/Software/Recorder/air/ClarityRecorder.air";
				//var url:String = "http://claritymain/Software/Recorder/air/ClarityRecorder.air";
				//var runtimeVersion:String = "2.0beta2";
				var runtimeVersion:String = "2.0";
				var arguments:Array = ["launchFromBrowser"]; // Optional
				airSWF.installApplication(url, runtimeVersion, arguments);
				// You should only allow the close if you know that AIR is installed. If it isn't the start checking.
				if (airStatus=="installed") {
					closeWindow();
				} else {
					checkInstallationTimer = new Timer(5000, 0); // Try every 5 seconds
					checkInstallationTimer.addEventListener(TimerEvent.TIMER, checkAIRStatus);
					checkInstallationTimer.start();
				}
			}
			function launchApp(myEvent:MouseEvent):void {
				//MonsterDebugger.trace(this, "Try to launch");
				var appID:String = "com.ClarityEnglish.ClarityRecorder";
				var pubID:String = "";
				var arguments:Array = ["launchFromBrowser"]; // Optional
				airSWF.launchApplication(appID, pubID, arguments);
				closeWindow();
			}
			// Function deprecated as AIR installed by badger directly
			function getAIR(myEvent:MouseEvent):void {
				// If you have to do this, then every so often check to see if the AIR installation is complete
				// In which case we can change our label to Install.
				checkInstallationTimer = new Timer(10000, 0);
				checkInstallationTimer.addEventListener(TimerEvent.TIMER, checkAIRStatus);
				checkInstallationTimer.start();
				msgTxt.htmlText = "Download Adobe's AIR. " + moreHelp;
					
				//var url:String = "http://labs.adobe.com/technologies/air2/";
				var url:String = "http://get.adobe.com/air/";
				var request:URLRequest = new URLRequest(url);
				try {
					//navigateToURL(request, '_blank'); // second argument is target
				} catch (e:Error) {
					trace("Can't link to AIR download site");
				}
			}
			function closeWindow():void {
				// Bug 17. July 17 2010. AR
				// Try to close this window now that you have, hopefully, run the application.
				// I could use LC to actually test if it has worked I suppose.
				// This is not clever because sometimes AIR loads from within this badger, so closing stops the installation
				// So you should only close when you know that a) the recorder is running or b) that you have started the AIR download
				//msgTxt.text = "Closing window";
				ExternalInterface.call("closeWindow");	
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