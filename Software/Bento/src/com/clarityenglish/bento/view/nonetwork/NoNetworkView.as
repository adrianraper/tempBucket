package com.clarityenglish.bento.view.nonetwork {
	import com.clarityenglish.bento.view.base.BentoView;

import mx.core.FlexGlobals;

import spark.components.Label;

	public class NoNetworkView extends BentoView {

		[SkinPart]
		public var nonetworkCaptionLabel:Label;

		[SkinPart]
		public var nonetworkContentLabel:Label;

		[SkinPart]
		public var versionLabel:Label;

		[SkinPart]
		public var copyrightLabel:Label;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case nonetworkCaptionLabel:
					nonetworkCaptionLabel.text = copyProvider.getCopyForId("nonetworkCaptionLabel");
					break;
				case nonetworkContentLabel:
					nonetworkContentLabel.text = copyProvider.getCopyForId("nonetworkContentLabel");
					break;
				case versionLabel:
					versionLabel.text = copyProvider.getCopyForId("versionLabel", {versionNumber: FlexGlobals.topLevelApplication.versionNumber});
					break;
				case copyrightLabel:
					copyrightLabel.text = copyProvider.getCopyForId("copyright");
					break;
			}
		}
		
	}
}