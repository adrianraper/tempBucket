package com.clarityenglish.ielts.view.credits {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.TextArea;
	
	import spark.components.RichText;
	import spark.components.TextArea;
	import spark.utils.TextFlowUtil;
	
	public class CreditsView extends BentoView {
		
		[SkinPart]
		public var creditsContent:RichText;
		
		//issue:#11 language Code
		/*public override function setCopyProvider(copyProvider:CopyProvider):void {
			this.copyProvider = copyProvider;	
		}*/
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case creditsContent:
					var creditsContentString:String = this.copyProvider.getCopyForId("creditsContent");
					var creditFlow:TextFlow = TextFlowUtil.importFromString(creditsContentString);
					creditFlow.color = "#4E4E4E";
					creditFlow.fontSize = 14;
					creditFlow.lineHeight = 22;
					creditFlow.paragraphSpaceAfter = 12;
					creditsContent.textFlow = creditFlow;
					break;
			}
		}

	}
	
}