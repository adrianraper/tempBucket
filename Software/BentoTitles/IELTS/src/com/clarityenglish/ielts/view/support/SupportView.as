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
		
		private var _productVersion:String;
		private var _productCode:uint;
		private var _licenceType:uint;
		
		public var register:Signal = new Signal();
		public var buy:Signal = new Signal();

		public function SupportView() {
			super();
		}
		
		public function get productVersion():String {
			return _productVersion;
		}
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
			}
		}
		public function get productCode():uint {
			return _productCode;
		}
		public function set productCode(value:uint):void {
			if (_productCode != value) {
				_productCode = value;
			}
		}
		public function get licenceType():uint {
			return _licenceType;
		}
		
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
			}
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			//trace("partAdded in HomeView for " + partName);
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
					break;
				case IELTSApplication.TEST_DRIVE:
					return "testDrive";
					break;
				case IELTSApplication.FULL_VERSION:
					var currentState:String = "fullVersion";
					return currentState;
					break;
				case IELTSApplication.LAST_MINUTE:
					return "lastMinute";
					break;
				case IELTSApplication.HOME_USER:
					return "homeUser";
					break;
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