package com.clarityenglish.ielts.view.menu {
	import com.clarityenglish.bento.view.base.BentoView;
	
	[SkinState("module")]
	[SkinState("progress")]
	public class MenuView extends BentoView {
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
		}
		
		protected override function getCurrentSkinState():String {
			return "module";
		}
		
	}
	
}