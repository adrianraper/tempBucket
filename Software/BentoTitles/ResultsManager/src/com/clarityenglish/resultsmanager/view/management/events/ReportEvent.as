package com.clarityenglish.resultsmanager.view.management.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ReportEvent extends Event {
		
		public static const GENERATE:String = "generate";
		public static const SHOW_REPORT_WINDOW:String = "show_report_window";
		
		// These are possible values for attempts and should not be used as event types
		public static const ALL:String = "all";
		public static const FIRST:String = "first";
		public static const LAST:String = "last";
		
		public var forReportables:Array;
		public var onReportables:Array;
		
		public var fromDate:Date;
		public var toDate:Date;
		
		public var attempts:String;
		
		public var scoreMoreThan:Number = -1;
		public var scoreLessThan:Number = -1;
		public var durationMoreThan:Number = -1;
		public var durationLessThan:Number = -1;
		
		public var detailedReport:Boolean = true;
		public var template:String;
		
		//2012
		public var forClass:String;
		
		// v3.2 Add in optional student ID
		public var includeStudentID:Boolean = false;
		
		// gh#777
		public var includeInactiveUsers:Boolean = false;
		
		public function ReportEvent(type:String, forReportables:Array = null, onReportables:Array = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.forReportables = forReportables;
			this.onReportables = onReportables;
		}
		
		public override function clone():Event { 
			var event:ReportEvent = new ReportEvent(type, forReportables, onReportables, bubbles, cancelable);
			//gh#28
			event.forClass = forClass;
			
			event.fromDate = fromDate;
			event.toDate = toDate;
			event.attempts = attempts;
			event.scoreMoreThan = scoreMoreThan;
			event.scoreLessThan = scoreLessThan;
			event.durationMoreThan = durationMoreThan;
			event.durationLessThan = durationLessThan;
			event.detailedReport = detailedReport;
			event.template = template;
			// v3.2 Add in optional student ID
			event.includeStudentID = includeStudentID;
			// gh#777
			event.includeInactiveUsers = includeInactiveUsers;
			
			return event;
		} 
		
		public override function toString():String { 
			return formatToString("ReportEvent", "type", "forReportables", "onReportables", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}