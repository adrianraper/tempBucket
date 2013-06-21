package com.clarityenglish.bento.view.xhtmlexercise.events
{
	import com.clarityenglish.textLayout.elements.AudioElement;
	
	import flash.events.Event;
	
	public class MarkingButtonEvent extends Event
	{
		public static const MARK_BUTTON_CLICKED:String = "markButtonClicked";
		
		private var _isMarked:Boolean;
		 
		public function MarkingButtonEvent(type:String, isMarked:Boolean, bubbles:Boolean=false)
		{
			super(type, bubbles);
			
			this._isMarked = isMarked;
		}
		
		public function get isMarked():Boolean {
			return _isMarked;
		}
	}
}