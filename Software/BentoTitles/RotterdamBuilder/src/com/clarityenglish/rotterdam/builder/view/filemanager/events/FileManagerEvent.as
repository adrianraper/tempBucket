package com.clarityenglish.rotterdam.builder.view.filemanager.events {
	import flash.events.Event;
	
	public class FileManagerEvent extends Event {
		
		public static const FILE_SELECT:String = "fileSelect";
		//gh #212
		public static const FILE_CANCEL:String = "fileCancle";
		
		private var _mediaNode:XML;
		
		public function FileManagerEvent(type:String, mediaNode:XML, bubbles:Boolean) {
			super(type, bubbles, false);
			
			this._mediaNode = mediaNode;
		}
		
		public function get mediaNode():XML {
			return _mediaNode;
		}
		
		public override function clone():Event {
			return new FileManagerEvent(type, mediaNode, bubbles);
		}
		
		public override function toString():String {
			return formatToString("FileManagerEvent", "mediaNode", "bubbles");
		}
	}
}
