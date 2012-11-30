package com.clarityenglish.rotterdam.builder.view.uniteditor.events {
	import flash.events.Event;
	
	public class ContentEvent extends Event {
		
		public static const CONTENT_SELECT:String = "contentSelect";
		
		private var _uid:String;
		private var _caption:String;
		
		public function ContentEvent(type:String, uid:String, caption:String, bubbles:Boolean) {
			super(type, bubbles, false);
			
			this._uid = uid;
			this._caption = caption;
		}
		
		public function get uid():String {
			return _uid;
		}
		
		public function get caption():String {
			return _caption;
		}
		
		public override function clone():Event {
			return new ContentEvent(type, uid, caption, bubbles);
		}
		
		public override function toString():String {
			return formatToString("ContentEvent", "uid", "caption", "bubbles");
		}
	}
}
