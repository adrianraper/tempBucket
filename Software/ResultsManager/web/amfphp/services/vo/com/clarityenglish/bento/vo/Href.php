<?php
class Href {

	var $_explicitType = 'com.clarityenglish.bento.vo.Href';
	
	const XHTML = "xhtml";
	const MENU_XHTML = "menu_xhtml";
	const EXERCISE = "exercise";
	
	public $type;
	public $filename;
	public $currentDir;
	public $serverSide;
	public $transforms;
	public $options;
	
	/**
	 * Get the full url including the current dir and filename
	 */
	public function getUrl() {
		return (($this->currentDir) ? $this->currentDir."/" : "").$this->filename;
	}
	
}