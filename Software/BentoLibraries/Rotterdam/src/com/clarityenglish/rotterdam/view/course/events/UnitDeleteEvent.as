package com.clarityenglish.rotterdam.view.course.events {
	import flash.events.Event;
	
	public class UnitDeleteEvent extends Event {
		
		public static const UNIT_DELETE:String = "unitDelete";
		
		private var _unit:XML;
		
		public function UnitDeleteEvent(type:String, unit:XML, bubbles:Boolean = false) {
			super(type, bubbles, false);
			
			_unit = unit;
		}
		
		public function get unit():XML {
			return _unit;
		}
		
		public override function clone():Event {
			return new UnitDeleteEvent(type, unit, bubbles);
		}
		
		public override function toString():String {
			return formatToString("UnitDeleteEvent", "unit", "bubbles");
		}
		
	}
}
