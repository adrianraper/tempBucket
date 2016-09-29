package com.clarityenglish.ielts {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.interfaces.IBentoApplication;
	
	import mx.events.FlexEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	import org.davekeen.util.StateUtil;
	
	[SkinState("loading")]
	[SkinState("nonetwork")]
	[SkinState("login")]
	[SkinState("title")]
	[SkinState("ending")]
	public class IELTSApplication extends BentoApplication implements IBentoApplication {
		
		public var browserManager:IBrowserManager;
		
		public static const FULL_VERSION:String = "R2IFV";
		public static const LAST_MINUTE:String = "R2ILM";
		public static const TEST_DRIVE:String = "R2ITD";
		public static const HOME_USER:String = "R2IHU";
		
		// gh#39
		public static const ACADEMIC_MODULE:String = '52';
		public static const GENERAL_TRAINING_MODULE:String = '53';
		
		public function IELTSApplication() {
			super();
			
			StateUtil.addStates(this, [ "loading", "login", "title", "ending", "nonetwork" ], true);
			
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
		}
		
		protected function creationComplete(event:FlexEvent):void {
			// Initialise the browser manager to help with capturing events that might take us away from the application
			// and also let us parse the URL
			browserManager = BrowserManager.getInstance(); 
			browserManager.init("", "Road to IELTS V2");
			
			facade.sendNotification(BBNotifications.STARTUP, this);
		}
		
	}
}
