package com.clarityenglish.bento.view.nonetwork {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import spark.components.Label;
	
	public class NoNetworkView extends BentoView {
		
		[SkinPart]
		public var noNetWorkLabel:Label;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case noNetWorkLabel:
					noNetWorkLabel.text = copyProvider.getCopyForId("noNetWorkLabel");
					break;
			}
		}
		
	}
}