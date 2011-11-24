package com.clarityenglish.bento.vo {
	
	[Bindable]
	public class ExerciseMark {
		
		public var correctCount:int = 0;
		
		public var incorrectCount:int = 0;
		
		public var missedCount:int = 0;
		
		public var percent:int = 0;
		
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
		 * A percentage calculated from the other figures 
		 * 
		 */
		public function setPercent():void {
			var totalQ:uint =  correctCount + incorrectCount + missedCount;
			if (totalQ <= 0) {
				// Historically we have always used -1 to indicate an unmarked exercise
				percent = -1;
			} else {
				percent = Math.round(100 * correctCount / totalQ);
			}
		}
		
	}
	
}
