package com.clarityenglish.bento.view.xhtmlexercise.events {
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
	
	import flash.events.Event;
	
	public class FeedbackEvent extends Event {
		
		public static const FEEDBACK_SHOW:String = "feedbackShow";
		
		private var _feedback:Feedback;
		
		public function FeedbackEvent(type:String, feedback:Feedback, bubbles:Boolean = false) {
			super(type, bubbles);
			
			this._feedback = feedback;
		}
		
		public function get feedback():Feedback {
			return _feedback;
		}
		
		public override function clone():Event {
			return new FeedbackEvent(type, feedback, bubbles);
		}
		
		public override function toString():String {
			return formatToString("FeedbackEvent", "feedback", "bubbles");
		}
		
	}
}