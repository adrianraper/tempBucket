package com.clarityenglish.bento.view.credits {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.Label;
	import mx.controls.TextArea;
	
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
		public var weWouldLabel:spark.components.Label;
		
		[SkinPart]
		public var creditCaptionLabel:RichText;
		
		[SkinPart]
		public var creditLabel:spark.components.Label;
		
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
				
			}
		}

	}
	
}