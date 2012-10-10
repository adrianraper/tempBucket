package com.clarityenglish.rotterdam.player {
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
	[SkinState("login")]
	[SkinState("title")]
	public class PlayerApplication extends BentoApplication implements IBentoApplication {
		
		[Bindable]
		public var versionNumber:String = "(unknown)";
		
		public var browserManager:IBrowserManager;
		
		public function PlayerApplication() {
			super();
			
			StateUtil.addStates(this, [ "loading", "login", "courseselector" ], true);
			
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
			browserManager.init("", "Rotterdam player");
			
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
