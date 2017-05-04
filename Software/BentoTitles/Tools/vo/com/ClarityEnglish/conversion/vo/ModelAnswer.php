<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelAnswer implements JsonSerializable {

    private $source = null;
    private $correct = null;

    function __construct() { }

    function addSource($id, $prefix='a') {
        $this->source = '#'.$prefix.$id;
    }
    function addValue($text) {
        $this->source = $text;
    }
    function getSource() {
        return (isset($this->source)) ? $this->source : false;
    }
    function addCorrect($value) {
        $this->correct = $value;
    }
    function getBlock() {
        return (isset($this->correct)) ? $this->correct : false;
    }
    function addSourceNthChild($id, $idx, $selector='li') {
        $this->source = '#q'.$id.' '.$selector.':nth-child('.$idx.')';
    }
    public function jsonSerialize() {
        $rc = array();
        if (isset($this->source)) $rc['source'] = $this->source;
        if (isset($this->correct)) $rc['correct'] = $this->correct;
        return $rc;
    }
}
