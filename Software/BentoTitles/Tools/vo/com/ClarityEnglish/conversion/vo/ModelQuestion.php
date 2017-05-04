<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelQuestion implements JsonSerializable {

    const QUESTION_TYPE_DRAG = 'DragQuestion';
    const QUESTION_TYPE_MULTIPLECHOICE = 'MultipleChoiceQuestion';
    const QUESTION_TYPE_GAPFILL = 'GapfillQuestion';
    const QUESTION_TYPE_DROPDOWN = 'DropdownQuestion';
    const QUESTION_TYPE_ERRORCORRECTION = 'ErrorCorrectionQuestion';
    const QUESTION_TYPE_TARGETSPOTTING = 'TargetSpottingQuestion';

    private $id = null;
    private $source = null;
    private $block = null;
    private $feedback = null;
    private $tags = null;
    private $answers = array();
    private $draggables = null;

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
    // This will generate a unique ID for a question
    // "id": "1256650a-eb2b-4cac-9a2c-062db5354496"
    function generateId() {
        return UUID::v4();
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
        return (isset($this->id)) ? $this->id : $this->generateId();
    }
    function addSource($id) {
        $this->source = '#q'.$id;
    }
    function getSource() {
        return (isset($this->source)) ? $this->source : false;
    }
    function addBlock($id, $prefix='b') {
        $this->block = '#'.$prefix.$id;
    }
    function getBlock() {
        return (isset($this->block)) ? $this->block : false;
    }
    function addFeedback($id) {
        $this->feedback = '#fb'.$id;
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
    function addDraggables($selector) {
        $this->draggables = $selector;
    }
    public function jsonSerialize() {
        $rc = array();
        $rc['questionType'] = $this->getType();
        $rc['id'] = $this->getId();
        if (isset($this->feedback)) $rc['feedback'] = $this->feedback;
        if (isset($this->source)) $rc['source'] = $this->source;
        if (isset($this->block)) $rc['block'] = $this->block;
        if (isset($this->draggables)) $rc['draggables'] = $this->draggables;
        if (isset($this->tags)) $rc['tags'] = $this->tags;
        if (count($this->answers) > 0) $rc['answers'] = $this->answers;
        return $rc;
    }
}
