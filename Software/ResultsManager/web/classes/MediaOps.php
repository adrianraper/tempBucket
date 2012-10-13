<?php

class MediaOps {
	
	var $accountFolder;
	
	function MediaOps($accountFolder = null) {
		$this->accountFolder = $accountFolder;
		$this->mediaFolder = $this->accountFolder."/media";
		$this->mediaFilename = $this->accountFolder."/media/media.xml";
	}
	
}