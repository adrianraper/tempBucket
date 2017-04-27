<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelDragQuestion extends ModelQuestion {

    private $draggables = null;
    
	function getType() {
        return ModelQuestion::QUESTION_TYPE_DRAG;
	}

    function addDraggables($selector) {
        $this->draggables = $selector;
    }
}
