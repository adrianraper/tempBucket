<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelDropdownQuestion extends ModelQuestion {

	function getType() {
        return ModelQuestion::QUESTION_TYPE_DROPDOWN;
	}

}
