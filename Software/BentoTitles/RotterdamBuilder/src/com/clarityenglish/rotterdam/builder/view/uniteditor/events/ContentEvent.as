package com.clarityenglish.rotterdam.builder.view.uniteditor.events {
	import flash.events.Event;
	
	public class ContentEvent extends Event {
		
		public static const CONTENT_SELECT:String = "contentSelect";
		//gh #212 
		public static const CONTENT_CANCEL:String = "contentCancel";		
		
		private var _uid:String;
		private var _caption:String;
		//gh #181
		private var _program:String;
		private var _isSingleFolder:Boolean;
		
		public function ContentEvent(type:String, uid:String, caption:String, program:String, isSingleFolder:Boolean, bubbles:Boolean) {
			super(type, bubbles, false);
			
			this._uid = uid;
			this._caption = caption;
			//#181
			this._program = program;
			this._isSingleFolder = isSingleFolder;
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
		
		public function get isSingleFolder():Boolean {
			return _isSingleFolder;
		}
		
		public override function clone():Event {
			return new ContentEvent(type, uid, caption, program, isSingleFolder, bubbles);
		}
		
		public override function toString():String {
			return formatToString("ContentEvent", "uid", "caption", "program", "isSingleFolder", "bubbles");
		}
	}
}
