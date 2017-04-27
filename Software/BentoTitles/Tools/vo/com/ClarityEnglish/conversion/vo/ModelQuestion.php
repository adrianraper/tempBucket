<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelQuestion {

    const QUESTION_TYPE_DRAG = 'question_type_drag';
    const QUESTION_TYPE_MULTIPLECHOICE = 'question_type_multiplechoice';
    const QUESTION_TYPE_GAPFILL = 'question_type_gapfill';
    const QUESTION_TYPE_DROPDOWN = 'question_type_dropdown';
    const QUESTION_TYPE_ERRORCORRECTION = 'question_type_errorcorrection';
    const QUESTION_TYPE_TARGETSPOTTING = 'question_type_targetspotting';

    private $id = null;
    //private $questionType = null;
    private $source = null;
    private $block = null;
    private $feedback = null;
    private $answers = array();

    protected $parent;

    function __construct($parent=null) {
        if ($parent)
            $this->setParent($parent);
    }

    // TODO Not sure if I will need to refer to the parent = model
    function getParent() {
        return $this->parent;
    }
    function setParent($object) {
        $this->parent = $object;
    }

    // Expect this to be overridden by specific question types
	function getType() {
        throw new Exception("getType must be overridden by child classes");
	}

	// Builder functions, can be overridden if necessary
    function addId($id) {
        $this->id = $id;
    }
    function getId() {
        return (isset($this->id)) ? $this->id : generateId();
    }
    function addSource($id) {
        $this->source = '#q'.$id;
    }
    function getSource() {
        return (isset($this->source)) ? $this->source : false;
    }
    function addBlock($id) {
        $this->block = '#b'.$id;
    }
    function getBlock() {
        return (isset($this->block)) ? $this->block : false;
    }
    function addFeedback($id) {
        $this->feedback = '#'.$id;
    }
    function getFeedback() {
        return (isset($this->feedback)) ? $this->feedback : false;
    }
    function addAnswer($answer) {
        $this->answers[] = $answer;
    }
    function getAnswers() {
        return $this->answers;
    }
    function outputForCouloir() {
        return json_encode($this);
    }
}
