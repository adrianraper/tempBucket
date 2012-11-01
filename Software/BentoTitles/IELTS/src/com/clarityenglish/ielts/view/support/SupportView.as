package com.clarityenglish.ielts.view.support {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.utils.TextFlowUtil;

	public class SupportView extends BentoView {

		[SkinPart]
		public var registerInfoButton:Button;
		
		[SkinPart]
		public var buyInfoButton:Button;
		
		[SkinPart]
		public var supportCaption1:SpanElement;
		
		[SkinPart]
		public var paragraphContent1:SpanElement;
		
		[SkinPart]
		public var supportCaption2:SpanElement;
		
		[SkinPart]
		public var paragraphContent2:SpanElement;
		
		[SkinPart]
		public var supportCaption3:SpanElement;
		
		[SkinPart]
		public var paragraphContent3:SpanElement;
		
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
				case supportCaption1:
					instance.text = copyProvider.getCopyForId("supportCaption1");
					break;
				case paragraphContent1:
					instance.text  = copyProvider.getCopyForId("paragraphContent1");
					break;
				case supportCaption2:
					instance.text = copyProvider.getCopyForId("supportCaption1");
					break;
				case paragraphContent2:
					instance.text  = copyProvider.getCopyForId("paragraphContent1");
					break;
				case supportCaption3:
					instance.text = copyProvider.getCopyForId("supportCaption1");
					break;
				case paragraphContent3:
					instance.text  = copyProvider.getCopyForId("paragraphContent1");
					break;
			}
		}

                //issue:#11 Language Code
		/*public function get assetFolder():String {
			return config.remoteDomain + '/Software/ResultsManager/web/resources/' + config.languageCode + '/assets/';
		}*/
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