package com.clarityenglish.clearpronunciation.view.home.event {
	import flash.events.Event;
	
	public class ListItemSelectedEvent extends Event {
		
		public static const SELECTED:String = "selected";
		
		private var _item:XML;
		
		public function ListItemSelectedEvent(type:String, bubbles:Boolean, item:XML) {
			super(type, bubbles, cancelable);
			
			this._item = item;
		}
		
		public function get item():XML {
			return _item;
		}
		
		public override function clone():Event {
			return new ListItemSelectedEvent(type, bubbles, item);
		}
	}
}