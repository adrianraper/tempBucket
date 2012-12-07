package com.clarityenglish.ielts.view.support {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
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
		
		[SkinPart]
		public var helpLabel:RichText;
		
		[SkinPart]
		public var keyScreenSpan:SpanElement;
		
		[SkinPart]
		public var homeScreenIntroSpan:SpanElement;
		
		[SkinPart]
		public var skillScreenIntroSpan:SpanElement;
		
		[SkinPart]
		public var exerciseSreenIntroSpan:SpanElement;
		
		[SkinPart]
		public var techProRichText:RichText;
		
		[SkinPart]
		public var contentProRichText:RichText;
		
		[SkinPart]
		public var clarityRichText:RichText;
		
		[SkinPart]
		public var upGradeRichText:RichText;
		
		[SkinPart]
		public var upGradeTestRichText:RichText;
		
		[SkinPart]
		public var userManualLabel:Label;
		
		[SkinPart]
		public var testDriveSpan:SpanElement;
		
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
					instance.label = copyProvider.getCopyForId("registerInfoButton");
					break;
				case buyInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onBuyInfoClick);
					instance.label = copyProvider.getCopyForId("buyInfoButton");
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
				case helpLabel:
					instance.text  = copyProvider.getCopyForId("help");
					break;
				case keyScreenSpan:
					instance.text  = copyProvider.getCopyForId("keyScreenSpan");
					break;
				case homeScreenIntroSpan:
					instance.text  = copyProvider.getCopyForId("homeScreenIntroSpan");
					break;
				case skillScreenIntroSpan:
					instance.text  = copyProvider.getCopyForId("skillScreenIntroSpan");
					break;
				case exerciseSreenIntroSpan:
					instance.text  = copyProvider.getCopyForId("exerciseSreenIntroSpan");
					break;
				case techProRichText:
					var contactUsContentString1:String = this.copyProvider.getCopyForId("contactUsContent1");
					var contactUsFlow1:TextFlow = TextFlowUtil.importFromString(contactUsContentString1);
					instance.textFlow = contactUsFlow1;
					break;
				case contentProRichText:
					var contactUsContentString2:String = this.copyProvider.getCopyForId("contactUsContent2");
					var contactUsFlow2:TextFlow = TextFlowUtil.importFromString(contactUsContentString2);
					instance.textFlow = contactUsFlow2;
					break;
				case clarityRichText:
					var clarityString:String = this.copyProvider.getCopyForId("clarityRichText");
					var clarityFlow:TextFlow = TextFlowUtil.importFromString(clarityString);
					instance.textFlow = clarityFlow;
					break;
				case upGradeRichText:
					var upGradeString:String = this.copyProvider.getCopyForId("upGradeRichText");
					var upGradeFlow:TextFlow = TextFlowUtil.importFromString(upGradeString);
					instance.textFlow = upGradeFlow;
					break;
				case upGradeTestRichText:
					var upGradeTestString:String = this.copyProvider.getCopyForId("upGradeRichText");
					var upGradeTestFlow:TextFlow = TextFlowUtil.importFromString(upGradeTestString);
					instance.textFlow = upGradeTestFlow;
					break;
				case userManualLabel:
					instance.text  = copyProvider.getCopyForId("userManualLabel");
					break;
				case testDriveSpan:
					instance.text  = copyProvider.getCopyForId("testDriveSpan");
					break;
			}
		}

         // gh#11 Language Code, read pictures from the folder base on the LanguageCode you set
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
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