package com.clarityenglish.bento.vo {
	
	[Bindable]
	public class ExerciseMark {
		
		public var correctCount:int = 0;
		
		public var incorrectCount:int = 0;
		
		public var missedCount:int = 0;
		
		/*public var correctPercent:int = 0;
		public var incorrectPercent:int = 0;
		public var missedPercent:int = 0;*/
		
		public var coverage:int = 0;
		
		public var duration:int = 0;
		
		// This is the UID in RM terms - built from productCode.courseID.unitID.exerciseID
		public var UID:String = "";
		
		public function ExerciseMark(correctCount:int = 0, incorrectCount:int = 0, missedCount:int = 0) {
			this.correctCount = correctCount;
			this.incorrectCount = incorrectCount;
			this.missedCount = missedCount;
		}
		
		/**
		 * A percentage calculated from the other figures. Very clumsy method. 
		 * 
		 */
		/*public function convertPercentages():void {
			if (totalQuestions <= 0) {
				// Historically we have always used -1 to indicate an unmarked exercise
				correctPercent = -1;
				incorrectPercent = 0;
				missedPercent = 0;
			} else {
				correctPercent = Math.round(100 * correctCount / totalQuestions);
				incorrectPercent = Math.round(100 * incorrectCount / totalQuestions);
				missedPercent = Math.round(100 * missedCount / totalQuestions);
			}
		}*/
		
		public function get correctPercent():int {
			// Historically we have always used -1 to indicate an unmarked exercise
			return (totalQuestions > 0) ? Math.round(100 * correctCount / totalQuestions) : -1;
		}
		
		public function get incorrectPercent():int {
			return (totalQuestions > 0) ? Math.round(100 * incorrectCount / totalQuestions) : 0;
		}
		
		public function get missedPercent():int {
			return (totalQuestions > 0) ? Math.round(100 * missedCount / totalQuestions) : 0;
		}
		
		/**
		 * A getter used in the marking window, again rather clumsy 
		 * 
		 * @return 
		 */
		public function get totalQuestions():int {
			return correctCount + incorrectCount + missedCount;			
		}
	}
	
}
