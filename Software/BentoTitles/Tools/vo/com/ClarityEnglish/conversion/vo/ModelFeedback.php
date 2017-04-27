<?php
/*
 * Used to hold feedback that will go into the model
 */
class ModelFeedback {

    private $target = null;
    private $expr = null;

    function __construct() { }

    function addTarget($id) {
        $this->source = '#fb'.$id;
    }
    function getTarget() {
        return (isset($this->source)) ? $this->source : false;
    }
    function addExpr($expr) {
        $this->expr = $expr;
    }
    function getExpr() {
        return (isset($this->expr)) ? $this->expr : true;
    }
    function outputForCouloir() {
        return json_encode($this);
    }
}
