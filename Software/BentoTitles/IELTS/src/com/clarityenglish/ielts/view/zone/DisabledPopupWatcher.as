package com.clarityenglish.ielts.view.zone {
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.IToolTip;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.managers.ToolTipManager;
	
	import org.davekeen.util.PointUtil;
	
	import spark.components.IItemRenderer;
	
	public class DisabledPopupWatcher {
		
		private var target:UIComponent;
		
		private var lastItemRenderer:UIComponent;
		
		private var toolTipText:String;
		
		private var toolTip:IToolTip;
		
		public function DisabledPopupWatcher(target:UIComponent, toolTipText:String = "Not available in the current version") {
			this.target = target;
			this.toolTipText = toolTipText;
			
			target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(event:MouseEvent):void {
			var point:Point = PointUtil.convertPointCoordinateSpace(new Point(event.stageX, event.stageY), target.stage, target);
			
			// Loop through the item renderers trying to figure out if we are in one
			for (var n:int = 0; n < event.currentTarget.dataProvider.length; n++) {
				var itemRenderer:UIComponent = event.currentTarget.dataGroup.getElementAt(n);
				
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
		
		private function destroyToolTip():void {
			if (toolTip) {
				ToolTipManager.destroyToolTip(toolTip);
				toolTip = null;
			}
		}
		
	}
}
