package com.clarityenglish.bento.vo.content.model.answer {
	
	public class TextAnswer extends Answer {
		
		public function TextAnswer(xml:XML) {
			super(xml);
		}
		
		public function get value():String {
			return xml.@value;
		}
		
	}
	
}
