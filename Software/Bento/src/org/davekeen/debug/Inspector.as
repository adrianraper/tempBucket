package org.davekeen.debug {
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	
	import org.davekeen.util.ClassUtil;
	
	public class Inspector extends Sprite {
		
		private var inspectedObject:DisplayObject;
		
		public function Inspector() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			mouseChildren = mouseEnabled = false;
		}
		
		protected function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, true);
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		protected function onMouseOver(event:MouseEvent):void {
			inspectedObject = event.target as DisplayObject;
			
			var rect:Rectangle = inspectedObject.getBounds(stage);
			
			graphics.clear();
			graphics.lineStyle(2, 0xFF0000);
			graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			graphics.endFill();
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			var doNothing:Object = null;
			
			if (inspectedObject is TextLine) {
				var textFlowLine:TextFlowLine = (inspectedObject as TextLine).userData as TextFlowLine;
				if (textFlowLine) {
					trace(TLFUtil.dumpTextFlow(textFlowLine.paragraph.getTextFlow()));
				}
			} else {
				trace(ClassUtil.getClass(inspectedObject));
			}
		}
	}
}