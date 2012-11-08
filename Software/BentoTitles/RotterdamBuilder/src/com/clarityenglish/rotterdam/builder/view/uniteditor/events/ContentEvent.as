package com.clarityenglish.rotterdam.builder.view.uniteditor.events {
	import flash.events.Event;
	
	public class ContentEvent extends Event {
		
		public static const CONTENT_SELECT:String = "contentSelect";
		
		private var _uid:String;
		
		public function ContentEvent(type:String, uid:String, bubbles:Boolean) {
			super(type, bubbles, false);
			
			this._uid = uid;
		}
		
		public function get uid():String {
			return _uid;
		}
		
		public override function clone():Event {
			return new ContentEvent(type, uid, bubbles);
		}
		
		public override function toString():String {
			return formatToString("ContentEvent", "uid", "bubbles");
		}
	}
}
