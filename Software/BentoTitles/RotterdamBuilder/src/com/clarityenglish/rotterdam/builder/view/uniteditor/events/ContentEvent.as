package com.clarityenglish.rotterdam.builder.view.uniteditor.events {
	import flash.events.Event;
	
	public class ContentEvent extends Event {
		
		public static const CONTENT_SELECT:String = "contentSelect";
		
		private var _uid:String;
		private var _caption:String;
		//gh #181
		private var _program:String;
		
		public function ContentEvent(type:String, uid:String, caption:String, program:String, bubbles:Boolean) {
			super(type, bubbles, false);
			
			this._uid = uid;
			this._caption = caption;
			//#181
			this._program = program;
		}
		
		public function get uid():String {
			return _uid;
		}
		
		public function get caption():String {
			return _caption;
		}
		
		//gh #181
		public function get program():String {
			return _program;
		}
		
		public override function clone():Event {
			return new ContentEvent(type, uid, caption, program, bubbles);
		}
		
		public override function toString():String {
			return formatToString("ContentEvent", "uid", "caption", "program", "bubbles");
		}
	}
}
