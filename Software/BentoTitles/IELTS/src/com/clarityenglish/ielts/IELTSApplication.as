package com.clarityenglish.ielts {
	import caurina.transitions.properties.CurveModifiers;
	import caurina.transitions.properties.DisplayShortcuts;
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.interfaces.IBentoApplication;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.events.FlexEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	import org.davekeen.util.StateUtil;
	
	[SkinState("loading")]
	[SkinState("login")]
	[SkinState("title")]
	[SkinState("credits")]
	public class IELTSApplication extends BentoApplication implements IBentoApplication {
		
		[Bindable]
		public var versionNumber:String = "(unknown)";
		
		public var browserManager:IBrowserManager;
		
		public var checkNetworkAvailabilityUrl:String;
		
		public static const FULL_VERSION:String = "R2IFV";
		public static const LAST_MINUTE:String = "R2ILM";
		public static const TEST_DRIVE:String = "R2ITD";
		public static const HOME_USER:String = "R2IHU";
		public static const DEMO:String = "R2ID";
		
		public static const ACADEMIC_MODULE:uint = 52;
		public static const GENERAL_TRAINING_MODULE:uint = 53;
		
		public function IELTSApplication() {
			super();
			
			StateUtil.addStates(this, [ "loading", "login", "title", "credits" ], true);
			
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.ACTIVATE, onActivate);
		}
		
		protected function creationComplete(event:FlexEvent):void {
			// Initialize some Tweener libraries
			DisplayShortcuts.init();
			CurveModifiers.init();
			
			// Allows BandScoreCalculator-200.swf to load (in the browser)
			//Security.allowDomain("*");
			
			// Initialise the browser manager to help with capturing events that might take us away from the application
			// and also let us parse the URL
			browserManager = BrowserManager.getInstance(); 
			//browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, parseURL); 
			browserManager.init("", "Road to IELTS V2");
			//var url:String = browserManager.url;
			//var fragment:String = browserManager.fragment;
			
			// Hardcode/override some parameters that you expect to come from flashvars
			//FlexGlobals.topLevelApplication.parameters.rootID=163;
			//FlexGlobals.topLevelApplication.parameters.prefix = "BCHK";
			
			// #474 - network availability test
			checkNetworkAvailability(startBento, onNetworkError);
		}
		
		// #474 - network availability test when returning to the app after suspending it
		protected function onActivate(event:Event):void {
			checkNetworkAvailability(null, onNetworkError);
		}
		
		private function checkNetworkAvailability(onSuccess:Function, onFailure:Function):void {
			if (checkNetworkAvailabilityUrl) {
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void {
					if (e.status == 200)
						if (onSuccess) onSuccess();
				});
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onFailure, false, 0, true);
				urlLoader.addEventListener(IOErrorEvent.NETWORK_ERROR, onFailure, false, 0, true);
				urlLoader.load(new URLRequest(checkNetworkAvailabilityUrl));
			}
		}
		
		private function onNetworkError(event:IOErrorEvent):void {
			var bentoError:BentoError = new BentoError();
			bentoError.errorContext = "Road to IELTS is unable to connect to the network.  Please check your connection and try again.";
			bentoError.isFatal = true;
			facade.sendNotification(CommonNotifications.BENTO_ERROR, bentoError);
		}
		
		private function startBento():void {
			facade.sendNotification(BBNotifications.STARTUP, this);
		}
		
		protected function onAddedToStage(event:Event):void {
			stage.quality = StageQuality.BEST;
		}
		
		public function showErrorMessage(error:BentoError):void {
			// This is no longer used and is taken care of using notifications and commands instead
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}
