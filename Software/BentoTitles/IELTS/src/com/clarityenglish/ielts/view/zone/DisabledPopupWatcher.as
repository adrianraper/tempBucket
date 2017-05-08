package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
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
		
		//gh#11
		public function DisabledPopupWatcher(target:UIComponent, copyProvider:CopyProvider, productVersion:String = null, toolTipText:String = null) {
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
						this.toolTipText = copyProvider.getCopyForId("notCurAvailable");
						break;
					case IELTSApplication.LAST_MINUTE:
						this.toolTipText = copyProvider.getCopyForId("onlyAvailableFV");
						break;
					case IELTSApplication.TEST_DRIVE:
						this.toolTipText = copyProvider.getCopyForId("notAvailableTD");
						break;
					case BentoApplication.DEMO:
						this.toolTipText = copyProvider.getCopyForId("notAvailbleDemo");
						break;
					default:
						this.toolTipText = copyProvider.getCopyForId("notAvailble");
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
				if (itemRenderer && itemRenderer.getBounds(event.currentTarget as DisplayObject).containsPoint(point)) {
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
