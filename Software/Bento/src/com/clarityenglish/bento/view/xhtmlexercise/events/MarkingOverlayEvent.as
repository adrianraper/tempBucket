package com.clarityenglish.bento.view.xhtmlexercise.events {
	import flash.events.Event;
	
	import flashx.textLayout.elements.FlowElement;
	
	public class MarkingOverlayEvent extends Event {
		
		public static const FLOW_ELEMENT_MARKED:String = "flowElementMarked";
		public static const FLOW_ELEMENT_UNMARKED:String = "flowElementUnmarked";
		
		private var _flowElement:FlowElement;
		private var _markingClass:String;
		
		public function MarkingOverlayEvent(type:String, flowElement:FlowElement, markingClass:String = null) {
			super(type, true);
			
			this._flowElement = flowElement;
			this._markingClass = markingClass;
		}
		
		public function get flowElement():FlowElement {
			return _flowElement;
		}
		
		public function get markingClass():String {
			return _markingClass;
		}
		
		public override function clone():Event {
			return new MarkingOverlayEvent(type, flowElement, markingClass);
		}
		
		public override function toString():String {
			return formatToString("MarkingEvent", "flowElement", "markingClass");
		}
		
	}
}