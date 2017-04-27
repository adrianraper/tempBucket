<?php
/*
 * Used to hold questions that will go into the model
 */
class ModelAnswer {

    private $source = null;
    private $correct = null;

    function __construct() { }

    function addSource($id) {
        $this->source = '#a'.$id;
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
    function outputForCouloir() {
        return json_encode($this);
    }
}
