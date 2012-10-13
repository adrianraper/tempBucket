package com.clarityenglish.ielts {
	import caurina.transitions.properties.CurveModifiers;
	import caurina.transitions.properties.DisplayShortcuts;
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.interfaces.IBentoApplication;
	import com.clarityenglish.common.vo.config.BentoError;
	
	import flash.display.StageQuality;
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	import org.davekeen.util.StateUtil;
	
	[SkinState("loading")]
	[SkinState("nonetwork")]
	[SkinState("login")]
	[SkinState("title")]
	[SkinState("credits")]
	public class IELTSApplication extends BentoApplication implements IBentoApplication {
		
		[Bindable]
		public var versionNumber:String = "(unknown)";
		
		public var browserManager:IBrowserManager;
		
		public static const FULL_VERSION:String = "R2IFV";
		public static const LAST_MINUTE:String = "R2ILM";
		public static const TEST_DRIVE:String = "R2ITD";
		public static const HOME_USER:String = "R2IHU";
		public static const DEMO:String = "R2ID";
		
		public static const ACADEMIC_MODULE:uint = 52;
		public static const GENERAL_TRAINING_MODULE:uint = 53;
		
		public function IELTSApplication() {
			super();
			
			StateUtil.addStates(this, [ "loading", "login", "title", "credits", "nonetwork" ], true);
			
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function creationComplete(event:FlexEvent):void {
			// Initialize some Tweener plugins
			DisplayShortcuts.init();
			CurveModifiers.init();
			
			// Initialise the browser manager to help with capturing events that might take us away from the application
			// and also let us parse the URL
			browserManager = BrowserManager.getInstance(); 
			browserManager.init("", "Road to IELTS V2");
			
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
