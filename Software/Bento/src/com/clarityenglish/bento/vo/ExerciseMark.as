package com.clarityenglish.bento.vo {
	
	[Bindable]
	public class ExerciseMark {
		
		public var correctCount:int = 0;
		
		public var incorrectCount:int = 0;
		
		public var missedCount:int = 0;
		
		public function ExerciseMark(correctCount:int = 0, incorrectCount:int = 0, missedCount:int = 0) {
			this.correctCount = correctCount;
			this.incorrectCount = incorrectCount;
			this.missedCount = missedCount;
		}
		
	}
	
}
