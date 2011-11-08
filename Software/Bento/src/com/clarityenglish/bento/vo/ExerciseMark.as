package com.clarityenglish.bento.vo {
	
	[Bindable]
	public class ExerciseMark {
		
		public var correctCount:uint = 0;
		
		public var incorrectCount:uint = 0;
		
		public var missedCount:uint = 0;
		
		public function ExerciseMark(correctCount:uint = 0, incorrectCount:uint = 0, missedCount:uint = 0) {
			this.correctCount = correctCount;
			this.incorrectCount = incorrectCount;
			this.missedCount = missedCount;
		}
		
	}
	
}
