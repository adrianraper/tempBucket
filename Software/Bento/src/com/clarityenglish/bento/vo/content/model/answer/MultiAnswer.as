package com.clarityenglish.bento.vo.content.model.answer {
	import flash.utils.Dictionary;
	
	import org.davekeen.collections.VectorMap;
	
	/**
	 * @author Dave
	 */
	public class MultiAnswer extends Answer {
		
		private var answerMap:VectorMap;
		
		public function MultiAnswer(xml:XML = null) {
			if (xml)
				throw new Error("MultiAnswers should not take an xml parameter");
			
			answerMap = new VectorMap();
		}
		
		public function putAnswer(key:Object, answer:Answer):void {
			answerMap.put(key, answer);
		}
		
		public function getAnswer(key:Object):Answer {
			return answerMap.fetch(key) as Answer;
		}
		
		/**
		 * The score for a composite answer is the sum of all its answers.
		 * 
		 * @return 
		 */
		public override function get score():int {
			var totalScore:int = 0;
			
			for each (var answer:Answer in answerMap.getValues())
				totalScore += answer.score;	
			
			return totalScore;
		}
		
	}
	
}
