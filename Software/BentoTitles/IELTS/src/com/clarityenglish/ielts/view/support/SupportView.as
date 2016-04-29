package com.clarityenglish.ielts.view.support {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

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
		public var manual:Signal = new Signal();

		public function SupportView() {
			super();
		}

		// gh#93
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (registerInfoButton) registerInfoButton.label = copyProvider.getCopyForId("registerInfoButton");
			if (buyInfoButton) buyInfoButton.label = copyProvider.getCopyForId("buyInfoButton");
			if (supportTextFlow1) {
				if (config.languageCode == "ZH") {
					supportTextFlow1.columnCount = 1;
				} else {
					supportTextFlow1.columnCount = 2;
				}
			}
			if (supportTextFlow2) {
				if (config.languageCode == "ZH") {
					supportTextFlow2.columnCount = 1;
				} else {
					supportTextFlow2.columnCount = 2;
				}
			}
			if (supportTextFlow3) {
				if (config.languageCode == "ZH") {
					supportTextFlow3.columnCount = 1;
				} else {
					supportTextFlow3.columnCount = 2;
				}
			}
			if (supportCaptionSpan1) supportCaptionSpan1.text = copyProvider.getCopyForId("supportCaptionSpan1");
			if (supportCaptionSpan2) supportCaptionSpan2.text = copyProvider.getCopyForId("supportCaptionSpan1");
			if (supportCaptionSpan3) supportCaptionSpan3.text = copyProvider.getCopyForId("supportCaptionSpan1");
			if (paragraphContentSpan1) paragraphContentSpan1.text = copyProvider.getCopyForId("paragraphContentSpan1");
			if (paragraphContentSpan2) paragraphContentSpan2.text = copyProvider.getCopyForId("paragraphContentSpan1");
			if (paragraphContentSpan3) paragraphContentSpan3.text = copyProvider.getCopyForId("paragraphContentSpan1");
			if (helpLabel) helpLabel.text = copyProvider.getCopyForId("Help");
			if (keyScreenSpan) keyScreenSpan.text = copyProvider.getCopyForId("keyScreenSpan");
			if (homeScreenIntroSpan) homeScreenIntroSpan.text = copyProvider.getCopyForId("homeScreenIntroSpan");
			if (skillScreenIntroSpan) skillScreenIntroSpan.text = copyProvider.getCopyForId("skillScreenIntroSpan");
			if (exerciseSreenIntroSpan) exerciseSreenIntroSpan.text = copyProvider.getCopyForId("exerciseSreenIntroSpan");
			if (techProRichText) {
				switch (productVersion) {
					case IELTSApplication.TEST_DRIVE:
					case IELTSApplication.LAST_MINUTE:
						var supportEmail:String = this.copyProvider.getCopyForId("supportEmailR2I");
						break;
					case IELTSApplication.HOME_USER:
						supportEmail = this.copyProvider.getCopyForId("supportEmailIP");
						break;
					case BentoApplication.DEMO:
					case IELTSApplication.FULL_VERSION:
					default:
						supportEmail = this.copyProvider.getCopyForId("supportEmailCE");
						break;
				}
				var replaceObj:Object = new Object();
				replaceObj.supportEmail = supportEmail;
				var contactUsContentString1:String = this.copyProvider.getCopyForId("contactUsContent1", replaceObj);
				var contactUsFlow1:TextFlow = TextFlowUtil.importFromString(contactUsContentString1);
				techProRichText.textFlow = contactUsFlow1;
			}
			if (contentProRichText) {
				var contactUsContentString2:String = this.copyProvider.getCopyForId("contactUsContent2");
				var contactUsFlow2:TextFlow = TextFlowUtil.importFromString(contactUsContentString2);
				contentProRichText.textFlow = contactUsFlow2;
			}
			if (clarityRichText) {
				var clarityString:String = this.copyProvider.getCopyForId("clarityRichText");
				var clarityFlow:TextFlow = TextFlowUtil.importFromString(clarityString);
				clarityRichText.textFlow = clarityFlow;
			}
			if (upGradeRichText) {
				var upGradeString:String = this.copyProvider.getCopyForId("upGradeRichText");
				var upGradeFlow:TextFlow = TextFlowUtil.importFromString(upGradeString);
				upGradeRichText.textFlow = upGradeFlow;
			}
			if (upGradeTestRichText) {
				var upGradeTestString:String = this.copyProvider.getCopyForId("upGradeRichText");
				var upGradeTestFlow:TextFlow = TextFlowUtil.importFromString(upGradeTestString);
				upGradeTestRichText.textFlow = upGradeTestFlow;
			}
			if (userManualLabel) userManualLabel.text = copyProvider.getCopyForId("userManualLabel");
			if (testDriveSpan) testDriveSpan.text = copyProvider.getCopyForId("testDriveSpan");
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			// gh#93
			switch (instance) {
				case registerInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onRegisterInfoClick);
					break;
				case buyInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onBuyInfoClick);
					break;
				case userManualLabel:
					instance.addEventListener(MouseEvent.CLICK, onUserManualClick);
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
				case BentoApplication.DEMO:
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
			//buy.dispatch();
			var url:String = copyProvider.getCopyForId("TDHelpBlueBannerLink");
			navigateToURL(new URLRequest(url), "_blank");
		}
		
		private function onUserManualClick(event:MouseEvent):void {
			manual.dispatch();
		}
		
	}
	
}