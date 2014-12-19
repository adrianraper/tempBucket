package com.clarityenglish.activereading.view.credits {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import mx.core.FlexGlobals;
	
	import spark.components.Label;
	
	public class CreditsView extends BentoView {
		
		[SkinPart]
		public var versionLabel:Label;
		
		[SkinPart]
		public var copyrightLabel:Label;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch(instance) {
				case versionLabel:
					versionLabel.text = "v" + FlexGlobals.topLevelApplication.versionNumber + "  " + copyProvider.getCopyForId("versionLabel");
					break;
				case copyrightLabel:
					copyrightLabel.text = copyProvider.getCopyForId("footerLabel");
					break;
			}
		}
	}
}