package com.clarityenglish.bento.view.xhtmlexercise.events
{
	import com.clarityenglish.textLayout.elements.AudioElement;
	
	import flash.events.Event;
	
	public class MarkingButtonEvent extends Event
	{
		public static const MARK_BUTTON_CLICKED:String = "markButtonClicked";
		
		private var _audioElement:AudioElement;
		 
		public function MarkingButtonEvent(type:String, audioElement:AudioElement, bubbles:Boolean=false)
		{
			super(type, bubbles);
			
			this._audioElement = audioElement;
		}
		
		public function get audioELement():AudioElement {
			return _audioElement;
		}
	}
}