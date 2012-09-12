package com.clarityenglish.rotterdam.builder.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	
	public class TitleView extends BentoView {
		
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}

	}
}