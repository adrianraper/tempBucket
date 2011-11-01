package com.clarityenglish.bento.vo.content.model.answer {
	
	public class Feedback {
		
		private var xml:XML;
		
		public function Feedback(xml:XML = null) {
			this.xml = xml;
		}
		
		public function get source():String {
			return xml.@source;
		}
		
		public function get title():String {
			return xml.@title || "Feedback";
		}
		
	}
	
}
