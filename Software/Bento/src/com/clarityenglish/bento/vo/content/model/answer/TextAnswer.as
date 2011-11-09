package com.clarityenglish.bento.vo.content.model.answer {
	import com.clarityenglish.bento.vo.content.Exercise;
	
	public class TextAnswer extends Answer {
		
		public function TextAnswer(xml:XML) {
			super(xml);
		}
		
		public function get value():String {
			return xml.@value;
		}
		
		public override function toReadableString(exercise:Exercise):String {
			return value;
		}
		
	}
	
}
