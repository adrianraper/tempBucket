<?php
require_once(dirname(__FILE__)."/../Reportable.php");

class Bookmark {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.content.Bookmark';

	var $title;
	var $course;
	var $unit;
	var $exercise;
	
	function Bookmark($uid = null) {
		if ($uid) {
			// parse the uid
			$uidParts = explode('.', $uid);
			if (isset($uidParts[0]))
				$this->title = $uidParts[0];
			if (isset($uidParts[1]))
				$this->course = $uidParts[1];
			if (isset($uidParts[2]))
				$this->unit = $uidParts[2];
			if (isset($uidParts[3]))
				$this->exercise = $uidParts[3];
		}
	}
	
	public function createFromIdObject($idObject) {
		if (isset($idObject['Title'])) $this->title = $idObject['Title'];
		if (isset($idObject['Course'])) $this->course = $idObject['Course'];
		if (isset($idObject['Unit'])) $this->unit = $idObject['Unit'];
		if (isset($idObject['Exercise'])) $this->exercise = $idObject['Exercise'];
	}

	public function setTitle($value) {
		$this->title = value;
	}
	public function setCourse($value) {
		$this->course = value;
	}
	public function setUnit($value) {
		$this->unit = value;
	}
	public function setExercise($value) {
		$this->exercise = value;
	}
	public function setFinished() {
		$this->title = null;
	}
	public function isFinished() {
		return !isset($this->title);
	}
	
	public function uid() {
		$uid = '';
		if ($this->isFinished()) return null;
		if (isset($this->title)) $uid = $this->title;
		if (isset($this->course)) $uid .= '.'.$this->course;
		if (isset($this->unit)) $uid .= '.'.$this->unit;
		if (isset($this->exercise)) $uid .= '.'.$this->exercise;
		return $uid;		
	}
}
