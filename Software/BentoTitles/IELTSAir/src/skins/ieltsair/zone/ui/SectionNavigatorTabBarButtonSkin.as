package skins.ieltsair.zone.ui {
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
	import flash.display.GradientType;
	import flash.events.Event;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.core.mx_internal;
	import mx.utils.ColorUtil;
	
	import spark.skins.mobile.TabbedViewNavigatorTabBarFirstTabSkin;
	
	use namespace mx_internal;
	
	public class SectionNavigatorTabBarButtonSkin extends TabbedViewNavigatorTabBarFirstTabSkin {
		
		private var changeWatcher:ChangeWatcher;
		
		public function SectionNavigatorTabBarButtonSkin() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		/**
		 * #392 Do some binding on zoneView.courseClass (via AS instead of MXML) so that the background colour changes when the course changes
		 */
		protected function onAddedToStage(event:Event):void {
			var zoneView:ZoneView = parentDocument["hostComponent"];
			changeWatcher = ChangeWatcher.watch(zoneView, "courseClass", onCourseClassChanged, false, true);
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			changeWatcher.unwatch();
			changeWatcher = null;
		}
		
		private function onCourseClassChanged(e:Event):void {
			invalidateDisplayList();
		}
		
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
					var zoneView:ZoneView = parentDocument["hostComponent"];
					graphics.beginFill(getStyle(zoneView.courseClass + "ColorDark"));
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
