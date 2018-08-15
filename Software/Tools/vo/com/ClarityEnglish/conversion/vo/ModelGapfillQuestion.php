<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelGapfillQuestion extends ModelQuestion {

	function getType() {
        return ModelQuestion::QUESTION_TYPE_GAPFILL;
	}

}
