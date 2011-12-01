package com.clarityenglish.textLayout.events {
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.TextFlow;
	
	public class RenderFlowMouseEvent extends Event {
		
		public static const RENDER_FLOW_CLICK:String = "renderFlowClick";
		
		private var _textFlow:TextFlow;
		
		private var _mouseEvent:MouseEvent;
		
		public function RenderFlowMouseEvent(type:String, textFlow:TextFlow, mouseEvent:MouseEvent) {
			super(type, true);
			
			this._textFlow = textFlow;
			this._mouseEvent = mouseEvent;
		}
		
		public function get textFlow():TextFlow {
			return _textFlow;
		}
		
		public function get mouseEvent():MouseEvent {
			return _mouseEvent;
		}
		
		public override function clone():Event {
			return new RenderFlowMouseEvent(type, textFlow, mouseEvent);
		}
		
		public override function toString():String {
			return formatToString("RenderFlowMouseEvent");
		}
		
	}
}