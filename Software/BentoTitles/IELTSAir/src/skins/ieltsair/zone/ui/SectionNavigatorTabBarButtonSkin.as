package skins.ieltsair.zone.ui {
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
	import flash.display.GradientType;
	
	import mx.core.mx_internal;
	import mx.utils.ColorUtil;
	
	import spark.skins.mobile.TabbedViewNavigatorTabBarFirstTabSkin;
	
	use namespace mx_internal;
	
	public class SectionNavigatorTabBarButtonSkin extends TabbedViewNavigatorTabBarFirstTabSkin {
		
		protected override function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void {
			super.drawBackground(unscaledWidth, unscaledHeight);
			
			var chromeColor:uint = getStyle(fillColorStyleName);
			
			// In the down state, the fill shadow is defined in the FXG asset
			switch (currentState) {
				case "down":
					graphics.beginFill(chromeColor);
					break;
				case "upAndSelected":
				case "overAndSelected":
				case "downAndSelected":
					graphics.beginFill(getStyle(ZoneView.horribleHackCourseClass + "ColorDark"));
					break;
				default:
					graphics.beginFill(0x202020);
					break;
			}
			
			// inset chrome color by BORDER_SIZE
			// bottom line is a shadow
			graphics.drawRect(layoutBorderSize, layoutBorderSize, unscaledWidth - (layoutBorderSize * 2), unscaledHeight - (layoutBorderSize * 2));
			graphics.endFill();
		}
	
	}

}
