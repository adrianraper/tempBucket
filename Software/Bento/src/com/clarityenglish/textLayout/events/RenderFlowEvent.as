package com.clarityenglish.textLayout.events {
	import flash.events.Event;
	
	import flashx.textLayout.elements.TextFlow;
	
	public class RenderFlowEvent extends Event {
		
		public static const TEXT_FLOW_CLEARED:String = "textFlowCleared";
		
		private var _textFlow:TextFlow;
		
		public function RenderFlowEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, textFlow:TextFlow = null) {
			super(type, bubbles, bubbles);
			
			this._textFlow = textFlow;
		}
		
		public  function get textFlow():TextFlow {
			return _textFlow;
		}
		
		public override function clone():Event {
			return new RenderFlowEvent(type, bubbles, cancelable, textFlow);
		}
		
		public override function toString():String {
			return formatToString("RenderFlowEvent");
		}
		
	}
}