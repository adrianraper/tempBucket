package com.clarityenglish.bento.vo.content.model.answer {
	
	public class MultiAnswer extends Answer {
		
		private var answers:Vector.<Answer>;
		
		public function MultiAnswer(xml:XML) {
			super(xml);
		}
		
		public function addAnswer(answer:Answer):void {
			answers.push(answer);
		}
		
		public function getAnswerAt(idx:int):Answer {
			if (idx < 0 || idx >= length)
				throw new RangeError("Illegal index " + idx);
			
			return answers[idx];
		}
		
		public function get length():int {
			return answers.length
		}
		
		/**
		 * The score for a composite answer is the sum of all its answers.
		 * 
		 * @return 
		 */
		public override function get score():int {
			var totalScore:int = 0;
			
			for each (var answer:Answer in answers)
				totalScore += answer.score;	
			
			return totalScore;
		}
		
	}
	
}
