package com.clarityenglish.rotterdam.builder.view.uniteditor.events {
	import flash.events.Event;
	
	public class GapEvent extends Event {
		
		public static const GAP_CREATED:String = "gapCreated";
		public static const GAP_REMOVED:String = "gapRemoved";
		public static const GAP_SELECTED:String = "gapSelected";
		public static const GAP_DESELECTED:String = "gapDeselected";
		public static const GAP_DELETED:String = "gapDeleted";
		
		private var _gapId:String;
		private var _gapText:String;
		
		public function GapEvent(type:String, gapId:String, gapText:String = null) {
			super(type, false, false);
			
			this._gapId = gapId;
			this._gapText = gapText;
		}
		
		public function get gapId():String {
			return _gapId;
		}
		
		public function get gapText():String {
			return _gapText;
		}
		
		public override function clone():Event {
			return new GapEvent(type, gapId, gapText);
		}
		
		public override function toString():String {
			return formatToString("GapEvent", "gapId", "gapText");
		}
		
	}
}
