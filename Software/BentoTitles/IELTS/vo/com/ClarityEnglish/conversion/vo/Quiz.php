<?php
class Quiz extends Exercise {
	
	// Anything special for a drag and drop?
	function getExerciseType() {
		return Exercise::EXERCISE_TYPE_QUIZ;
	}
	
}
?>