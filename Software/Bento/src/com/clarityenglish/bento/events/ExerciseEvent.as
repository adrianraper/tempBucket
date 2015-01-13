package com.clarityenglish.bento.events {
	import flash.events.Event;
	
	public class ExerciseEvent extends Event {
		
		public static const EXERCISE_SELECTED:String = "exerciseSelected";
		
		private var _hrefFilename:String;
		private var _node:XML;
		private var _attribute:String;
		
		public function ExerciseEvent(type:String, hrefFilename:String, node:XML = null, attribute:String = null) {
			super(type, true, false);
			
			this._hrefFilename = hrefFilename;
			this._node = node;
			this._attribute = attribute;
		}
		
		public function get hrefFilename():String {
			return _hrefFilename;
		}
		
		public function get node():XML {
			return _node;
		}
		
		public function get attribute():String {
			return _attribute;
		}

		public override function clone():Event {
			return new ExerciseEvent(type, _hrefFilename, _node);
		}
		
		public override function toString():String {
			return formatToString("ExerciseEvent", "hrefFilename", "node");
		}
		
	}
}
