package com.clarityenglish.bento.view.xhtmlexercise.events
{
	import com.clarityenglish.bento.vo.content.model.Question;
	
	import flash.events.Event;
	
	public class HintEvent extends Event
	{
		public static const HINT_SHOW:String = "hintShow";
		
		private var _question:Question;
		
		public function HintEvent(type:String, question:Question = null, bubbles:Boolean=false)
		{
			super(type, bubbles);
			
			this._question = question;
		}
		
		public function get question():Question {
			return _question;
		}
		
		public override function clone():Event {
			return new SectionEvent(type, question, bubbles);
		}
		
		public override function toString():String {
			return formatToString("HintEvent", "question", "bubbles");
		}
	}
}