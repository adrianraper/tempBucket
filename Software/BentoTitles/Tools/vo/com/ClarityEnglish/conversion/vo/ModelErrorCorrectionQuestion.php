<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelErrorCorrectionQuestion extends ModelQuestion {

	function getType() {
        return ModelQuestion::QUESTION_TYPE_ERRORCORRECTION;
	}

}
