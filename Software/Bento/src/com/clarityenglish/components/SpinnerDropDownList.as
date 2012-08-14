package com.clarityenglish.components {
	import flash.events.Event;
	
	import spark.components.DropDownList;
	import spark.events.DropDownEvent;
	
	public class SpinnerDropDownList extends DropDownList {
		
		public function SpinnerDropDownList() {
			super();
			
			dropDownController = new SpinnerDropDownController();
			
			addEventListener(DropDownEvent.CLOSE, onClose, false, 0, true);
		}

		/**
		 * We need to throw a CHANGE event when the drop down is closed, otherwise Bento doesn't know a question has been answered.
		 */
		private function onClose(event:DropDownEvent):void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}
}
