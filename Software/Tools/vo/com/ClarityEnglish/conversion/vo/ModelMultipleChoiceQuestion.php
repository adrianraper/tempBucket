<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelMultipleChoiceQuestion extends ModelQuestion {

    private $draggables = null;
    
	function getType() {
        return ModelQuestion::QUESTION_TYPE_MULTIPLECHOICE;
	}

}
