package com.clarityenglish.bento.vo.content.model.answer {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Model;
	
	public class NodeAnswer extends Answer {
		
		public function NodeAnswer(xml:XML) {
			super(xml);
		}
		
		public function get source():String {
			return xml.@source;
		}
		
		public function getSourceNodes(exercise:Exercise):Array {
			return Model.sourceToNodeArray(exercise, source);
		}
		
	}
	
}
