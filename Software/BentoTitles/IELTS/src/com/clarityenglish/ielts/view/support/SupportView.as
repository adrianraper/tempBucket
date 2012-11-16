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
	import spark.components.RichText;
	import spark.utils.TextFlowUtil;

	public class SupportView extends BentoView {

		[SkinPart]
		public var registerInfoButton:Button;
		
		[SkinPart]
		public var buyInfoButton:Button;
		
		[SkinPart]
		public var supportTextFlow1:TextFlow;
		
		[SkinPart]
		public var supportCaptionSpan1:SpanElement;
		
		[SkinPart]
		public var supportTextFlow2:TextFlow;
		
		[SkinPart]
		public var paragraphContentSpan1:SpanElement;
		
		[SkinPart]
		public var supportTextFlow3:TextFlow;
		
		[SkinPart]
		public var supportCaptionSpan2:SpanElement;
		
		[SkinPart]
		public var paragraphContentSpan2:SpanElement;
		
		[SkinPart]
		public var supportCaptionSpan3:SpanElement;
		
		[SkinPart]
		public var paragraphContentSpan3:SpanElement;
		
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
				case supportTextFlow1:
					if (config.languageCode == "ZH") {
						instance.columnCount = 1;
					} else {
						instance.columnCount = 2;
					}
					break;
				case supportCaptionSpan1:
					instance.text = copyProvider.getCopyForId("supportCaptionSpan1");
					break;
				case supportTextFlow2:
					if (config.languageCode == "ZH") {
						instance.columnCount = 1;
					} else {
						instance.columnCount = 2;
					}
					break;
				case paragraphContentSpan1:
					instance.text  = copyProvider.getCopyForId("paragraphContentSpan1");
					break;
				case supportTextFlow3:
					if (config.languageCode == "ZH") {
						instance.columnCount = 1;
					} else {
						instance.columnCount = 2;
					}
					break;
				case supportCaptionSpan2:
					instance.text = copyProvider.getCopyForId("supportCaptionSpan1");
					break;
				case paragraphContentSpan2:
					instance.text  = copyProvider.getCopyForId("paragraphContentSpan1");
					break;
				case supportCaptionSpan3:
					instance.text = copyProvider.getCopyForId("supportCaptionSpan1");
					break;
				case paragraphContentSpan3:
					instance.text  = copyProvider.getCopyForId("paragraphContentSpan1");
					break;
			}
		}

         //issue:#11 Language Code, read pictures from the folder base on the LanguageCode you set
		public function get assetFolder():String {
			trace ("the language code for the folder is "+ config.languageCode);
			return config.remoteDomain + '/Software/ResultsManager/web/resources/' + config.languageCode + '/assets/';
		}
		/*public function get assetFolder():String {
			return config.remoteDomain + '/Software/ResultsManager/web/resources/assets/';
		}*/
		
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