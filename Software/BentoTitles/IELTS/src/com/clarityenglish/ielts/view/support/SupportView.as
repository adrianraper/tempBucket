package com.clarityenglish.ielts.view.support {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;

	public class SupportView extends BentoView {

		[SkinPart]
		public var registerInfoButton:Button;
		
		[SkinPart]
		public var buyInfoButton:Button;
		
		public var register:Signal = new Signal();
		public var buy:Signal = new Signal();

		public function SupportView() {
			super();
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case registerInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onRegisterInfoClick);
					break;
				case buyInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onBuyInfoClick);
					break;
			}
		}

		public function get assetFolder():String {
			return config.remoteDomain + '/Software/ResultsManager/web/resources/assets/';
		}
		
		protected override function getCurrentSkinState():String {
			switch (productVersion) {
				case IELTSApplication.DEMO:
					return "demo";
				case IELTSApplication.TEST_DRIVE:
					return "testDrive";
				case IELTSApplication.FULL_VERSION:
					return "fullVersion";
				case IELTSApplication.LAST_MINUTE:
					return "lastMinute";
				case IELTSApplication.HOME_USER:
					return "homeUser";
				default:
					return super.getCurrentSkinState();
			}
		}

		private function onRegisterInfoClick(event:MouseEvent):void {
			register.dispatch();
		}
		
		private function onBuyInfoClick(event:MouseEvent):void {
			buy.dispatch();
		}
		
	}
	
}