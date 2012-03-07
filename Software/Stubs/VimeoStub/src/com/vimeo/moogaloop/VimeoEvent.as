package com.vimeo.moogaloop {
	import flash.events.Event;
	
	public class VimeoEvent extends Event {
		
		public static const FINISH : String         = 'finish';
		public static const LOAD_PROGRESS : String  = 'loadProgress';
		public static const PAUSE : String          = 'pause';
		public static const PLAY : String           = 'play';
		public static const PLAY_PROGRESS : String  = 'playProgress';
		public static const READY : String          = 'ready';
		public static const SEEK : String           = 'seek';
		
		private var _data:Object;
		
		public function VimeoEvent(type:String, data:Object = null, bubbles:Boolean = false) {
			super(type, bubbles);
			this._data = data;
		}

		public function get data():Object {
			return _data;
		}
		
		public override function clone():Event {
			return new VimeoEvent(type, _data, bubbles);
		}
		
		public override function toString():String {
			return formatToString("VimeoEvent", "data", "bubbles");
		}
		
	}
}