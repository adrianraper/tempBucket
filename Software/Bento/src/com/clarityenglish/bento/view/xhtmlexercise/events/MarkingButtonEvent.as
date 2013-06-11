package com.clarityenglish.bento.view.xhtmlexercise.events
{
	import com.clarityenglish.textLayout.elements.AudioElement;
	
	import flash.events.Event;
	
	public class MarkingButtonEvent extends Event
	{
		public static const MARK_BUTTON_CLICKED:String = "markButtonClicked";
		
		private var _delayAudioElement:AudioElement;
		 
		public function MarkingButtonEvent(type:String, delayAudioElement:AudioElement, bubbles:Boolean=false)
		{
			super(type, bubbles);
			
			this._delayAudioElement = delayAudioElement;
		}
		
		public function get delayAudioElement():AudioElement {
			return _delayAudioElement;
		}
	}
}