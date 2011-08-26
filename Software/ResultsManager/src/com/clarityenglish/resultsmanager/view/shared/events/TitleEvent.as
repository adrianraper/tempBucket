package com.clarityenglish.resultsmanager.view.shared.events {
	import com.clarityenglish.common.vo.content.Title;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class TitleEvent extends Event {
		
		public static const TITLE_CHANGE:String = "title_change";
		
		public var title:Title;
		public var fromDate:Date;
		public var toDate:Date;
		
		public function TitleEvent(type:String, title:Title, fromDate:Date = null, toDate:Date = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.title = title;
			this.fromDate = fromDate;
			this.toDate = toDate;
		} 
		
		public override function clone():Event { 
			return new TitleEvent(type, title, fromDate, toDate, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("TitleEvent", "type", "title", "fromDate", "toDate", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}