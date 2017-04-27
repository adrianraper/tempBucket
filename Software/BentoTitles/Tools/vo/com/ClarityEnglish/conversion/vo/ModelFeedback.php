<?php
/*
 * Used to hold feedback that will go into the model
 */
class ModelFeedback implements JsonSerializable {

    private $target = null;
    private $expr = null;

    function __construct() { }

    function addTarget($id) {
        $this->target = '#fb'.$id;
    }
    function getTarget() {
        return (isset($this->target)) ? $this->target : false;
    }
    function addExpr($expr) {
        $this->expr = $expr;
    }
    function getExpr() {
        return (isset($this->expr)) ? $this->expr : true;
    }
    public function jsonSerialize() {
        $rc = array();
        if (isset($this->target)) $rc['target'] = $this->target;
        if (isset($this->expr)) $rc['expr'] = $this->expr;
        return $rc;
    }
}
