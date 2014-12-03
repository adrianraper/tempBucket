package com.clarityenglish.activereading.view.event {
	import flash.events.Event;
	
	public class NodeSelectEvent extends Event {
		
		public static const NODE_SELECT:String = "nodeSelect"; 
		
		private var _node:XML;
		
		public function NodeSelectEvent(type:String, bubbles:Boolean, node:XML) {
			super(type, bubbles, cancelable);
			
			this._node = node;
		}
		
		public function get node():XML {
			return _node
		}
		
		public override function clone():Event {
			return new NodeSelectEvent(type, bubbles, node);
		}
	}
}