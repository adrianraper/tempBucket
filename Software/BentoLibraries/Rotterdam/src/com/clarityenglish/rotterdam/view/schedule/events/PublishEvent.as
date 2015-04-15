package com.clarityenglish.rotterdam.view.schedule.events {
	import com.clarityenglish.resultsmanager.vo.manageable.Group;
	
	import flash.events.Event;
	
	public class PublishEvent extends Event {
		
		public static const CALENDER_SETTINGS_DELETE:String = "calenderSettingsDelete";
		
		private var _group:Group;
		
		public function PublishEvent(type:String, group:Group, bubbles:Boolean) {
			super(type, bubbles, false);
			
			this._group = group;
		}
		
		public function get group():Group {
			return _group;
		}
		
		public override function clone():Event {
			return new PublishEvent(type, group, bubbles);
		}
		
		public override function toString():String {
			return formatToString("PublishEvent", "group", "bubbles");
		}
		
	}
}
