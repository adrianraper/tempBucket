package skins.ieltsair.title {
	import spark.layouts.HorizontalLayout;
	import spark.skins.mobile.ActionBarSkin;
	
	public class PaddableActionBarSkin extends ActionBarSkin {
		
		protected override function createChildren():void {
			super.createChildren();
			
			// #484
			if (getStyle("buttonSpacing")) (navigationGroup.layout as HorizontalLayout).gap = getStyle("buttonSpacing");
			if (getStyle("buttonSpacing")) (actionGroup.layout as HorizontalLayout).gap = getStyle("buttonSpacing");
		}
		
	}
}
