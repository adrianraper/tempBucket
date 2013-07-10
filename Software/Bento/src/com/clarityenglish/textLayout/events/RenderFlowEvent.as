package com.clarityenglish.textLayout.events {
	import flash.events.Event;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.TextFlow;
	
	public class RenderFlowEvent extends Event {
		
		public static const TEXT_FLOW_CLEARED:String = "textFlowCleared";
		public static const RENDER_FLOW_UPDATE_COMPLETE:String = "renderFlowUpdateComplete";
		
		private var _textFlow:TextFlow;
		
		private var _controller:ContainerController;
		
		public function RenderFlowEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, textFlow:TextFlow = null, controller:ContainerController = null) {
			super(type, bubbles, cancelable);
			
			this._textFlow = textFlow;
			this._controller = controller;
		}
		
		public function get textFlow():TextFlow {
			return _textFlow;
		}
		
		public function get controller():ContainerController {
			return _controller;
		}
		
		public override function clone():Event {
			return new RenderFlowEvent(type, bubbles, cancelable, textFlow, controller);
		}
		
		public override function toString():String {
			return formatToString("RenderFlowEvent");
		}
		
	}
}