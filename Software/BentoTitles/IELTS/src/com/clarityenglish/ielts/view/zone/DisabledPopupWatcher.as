package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.IToolTip;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.managers.ToolTipManager;
	
	import org.davekeen.util.PointUtil;
	import org.puremvc.as3.patterns.facade.Facade;
	
	import spark.components.DataGroup;
	import spark.components.IItemRenderer;
	import spark.components.List;
	
	// TODO: There is a chance this might cause a small memory leak, but since it is bound to the skin it shouldn't do so and anyway skins are recycled so it should
	// have an upper limit.
	public class DisabledPopupWatcher {
		
		private var target:UIComponent;
		
		private var dataGroup:DataGroup;
		
		private var lastItemRenderer:UIComponent;
		
		private var toolTipText:String;
		
		private var toolTip:IToolTip;
		
		public function DisabledPopupWatcher(target:UIComponent, productVersion:String = null, toolTipText:String = null) {
			this.target = target;
			
			// Determine the datagroup
			if (target is List) {
				this.dataGroup = (target as List).dataGroup;
			} else if (target is DataGroup) {
				this.dataGroup = target as DataGroup;
			}
			
			// Text depends on version
			if (toolTipText) {
				this.toolTipText = toolTipText;
			} else {
				switch (productVersion) {
					case IELTSApplication.FULL_VERSION:
						this.toolTipText = "Not currently available.";
						break;
					case IELTSApplication.LAST_MINUTE:
						this.toolTipText = "Only available in the Full Version. Click above to upgrade."
						break;
					case IELTSApplication.TEST_DRIVE:
						this.toolTipText = " Only available in the Last Minute version. Click above to upgrade."
						break;
					case IELTSApplication.DEMO:
						this.toolTipText = "Not available in this demo. Click above to find out prices."
						break;
					default:
						this.toolTipText = "Not available in the current version. Click above to upgrade."
				}
			}
			
			target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
		}
		
		private function onMouseMove(event:MouseEvent):void {
			var point:Point = PointUtil.convertPointCoordinateSpace(new Point(event.stageX, event.stageY), target.stage, target);
			
			// Loop through the item renderers trying to figure out if we are in one
			for (var n:int = 0; n < event.currentTarget.dataProvider.length; n++) {
				var itemRenderer:UIComponent = dataGroup.getElementAt(n) as UIComponent;
				
				// Figure out if the mouse is over this item renderer
				if (itemRenderer.getBounds(event.currentTarget as DisplayObject).containsPoint(point)) {
					if (itemRenderer !== lastItemRenderer) destroyToolTip();
					
					if (itemRenderer.enabled) {
						if (toolTip) ToolTipManager.destroyToolTip(toolTip);
					} else {
						if (!toolTip) {
							toolTip = ToolTipManager.createToolTip(toolTipText, event.stageX, event.stageY, null, target.stage as IUIComponent);
						}
					}
					
					lastItemRenderer = itemRenderer;
					break;
				}
			}
		}
		
		protected function onMouseOut(event:MouseEvent):void {
			destroyToolTip();
		}
		
		private function destroyToolTip():void {
			if (toolTip) {
				ToolTipManager.destroyToolTip(toolTip);
				toolTip = null;
			}
		}
		
	}
}
