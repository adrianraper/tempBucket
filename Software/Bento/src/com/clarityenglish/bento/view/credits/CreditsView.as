package com.clarityenglish.bento.view.credits {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.Label;
	import mx.controls.TextArea;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.TextArea;
	import spark.utils.TextFlowUtil;
	
	public class CreditsView extends BentoView {
		
		[SkinPart]
		public var creditsRichText:RichText;
		
		[SkinPart]
		public var thankYouLabel:spark.components.Label;
		
		[SkinPart]
		public var thankYouLabel2:spark.components.Label;
		
		[SkinPart]
		public var upgradeLabel:spark.components.Label;
		
		[SkinPart]
		public var fullVersionLabel:spark.components.Label;
		
		[SkinPart]
		public var moreButton:Button;
		
		[SkinPart]
		public var weWouldLabel:spark.components.Label;
		
		[SkinPart]
		public var creditCaptionLabel:RichText;
		
		[SkinPart]
		public var creditLabel:spark.components.Label;
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case creditsRichText:
					var creditsContentString:String = this.copyProvider.getCopyForId("creditsRichText");
					var creditFlow:TextFlow = TextFlowUtil.importFromString(creditsContentString);
					creditFlow.color = "#4E4E4E";
					creditFlow.fontSize = 14;
					creditFlow.lineHeight = 22;
					creditFlow.paragraphSpaceAfter = 12;
					creditsRichText.textFlow = creditFlow;
					break;
				case thankYouLabel:
				case thankYouLabel2:
					instance.text = copyProvider.getCopyForId("thankYouLabel");
					break;
				case weWouldLabel:
					instance.text = copyProvider.getCopyForId("weWouldLabel");
					break;
				case creditCaptionLabel:
					var creditsLabelString:String = this.copyProvider.getCopyForId("creditCaptionLabel");
					var creditsLabelFlow:TextFlow = TextFlowUtil.importFromString(creditsLabelString);
					instance.textFlow = creditsLabelFlow;
					break;
				case creditLabel:
					creditLabel.text = copyProvider.getCopyForId("creditLabel");
					break;
				case upgradeLabel:
					upgradeLabel.text = copyProvider.getCopyForId("upgradeLabel");
					break;
				case fullVersionLabel:
					fullVersionLabel.text = copyProvider.getCopyForId("fullVersionLabel");
					break;
				case moreButton:
					moreButton.label = copyProvider.getCopyForId("moreButton");
					break;
				
			}
		}
		
		protected override function getCurrentSkinState():String {
			trace("product version: "+super.getCurrentSkinState());
			switch (productVersion) {
				case "R2ITD":
					return "testDrive";
				case "R2ILM":
					return "lastMinute";
				default:
					return super.getCurrentSkinState();
			}
		}

	}
	
}