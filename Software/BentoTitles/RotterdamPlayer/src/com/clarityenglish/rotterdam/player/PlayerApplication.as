package com.clarityenglish.rotterdam.player {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.interfaces.IBentoApplication;
	
	import mx.events.FlexEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	import org.davekeen.util.StateUtil;
	
	[SkinState("loading")]
	[SkinState("login")]
	[SkinState("title")]
	public class PlayerApplication extends BentoApplication implements IBentoApplication {
		
		public var browserManager:IBrowserManager;
		
		public function PlayerApplication() {
			super();
			
			StateUtil.addStates(this, [ "loading", "login", "title" ], true);
			
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
		}
		
		protected function creationComplete(event:FlexEvent):void {
			// Initialise the browser manager to help with capturing events that might take us away from the application
			// and also let us parse the URL
			browserManager = BrowserManager.getInstance(); 
			browserManager.init("", "Rotterdam player");
			
			facade.sendNotification(BBNotifications.STARTUP, this);
		}
		
	}
}
