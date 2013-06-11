package com.clarityenglish.bento.view.xhtmlexercise.events
{
	import com.clarityenglish.textLayout.elements.AudioElement;
	
	import flash.events.Event;
	
	public class AudioStackEvent extends Event
	{
		public static const Audio_Stack_Ready:String = "audioStackReady";
		
		private var _audioStack:Vector.<AudioElement>= new Vector.<AudioElement>();
		
		public function AudioStackEvent(type:String, audioStack:Vector.<AudioElement>, bubbles:Boolean=false)
		{
			super(type, bubbles);
			
			this._audioStack = audioStack;
		}
		
		public function get audioStack():Vector.<AudioElement> {
			return _audioStack;
		}
	}
}