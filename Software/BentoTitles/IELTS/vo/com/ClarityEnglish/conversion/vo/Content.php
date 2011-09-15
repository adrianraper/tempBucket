<?php
//
// Common for all sections in an exercise
//
class Content{
	
	var $paragraphs = Array();
	var $mediaNodes = Array();
	
	function addMediaNode($xmlObj) {
		$this->mediaNodes[] = new MediaNode($xmlObj, $this);
	}
	function getMediaNodes() {
		return $this->mediaNodes;
	}
	function addParagraph($xmlObj) {
		$this->paragraphs[] = new Paragraph($xmlObj, $this);
	}
	function getParagraphs() {
		return $this->paragraphs;
	}
	//function getClass() {
		// This must always be overwritten in the specific section
	//}
	// Used in output
	function getText() {
		
		$buildText='';
		// Where is the best place to be smart about combining paragraphs?
		// If there is an empty paragraph, that clearly separates two.
		// Likewise if a paragraph has y=+x, then it is probably separating two.
		// And if the paragraph attributes are different (except for indentation fudges)
		// Or if the text begins 1. - in which case it becomes a list.
		// So, read first paragraph and hold all of it.
		// Then read next in a loop until you hit one that is the beginning of a new group. Hold that in nextGroup.
		// For each one that is read, just grab the pure text and add it to the first para pure text.
		$allParagraphs = $this->getParagraphs();
		$firstGroupPara = null;
		// $nextGroupPara = null;
		for ($i=0, $size = sizeof($allParagraphs); $i<$size; ++$i) {
			$thisPara = $allParagraphs[$i];
			if (!$firstGroupPara) {
				// Make a copy of the paragraph that you can alter on a temporary basis
				$firstGroupPara = clone $thisPara;
			
			} else {
				// Does this new para look like the first in the next group?
				if ($this->isParaFirstInGroup($thisPara)) {
					// Yes it does. So save it in next, and write out the previous group
					// $nextGroupPara = $thisPara;
					// First just write out merged paragraph
					$buildText.=$firstGroupPara->getText()."\n";
					// Then get ready for the next round by setting the new para as the first of the next group
					$firstGroupPara = $thisPara;
				} else {
					// This paragraph text should be merged to the first one then.
					// First, drop the <p></p> so you can add text without it.
					$pattern = '/<p [^>]+>('.Paragraph::characters_to_keep.'+)<\/p>/is';
					$replacement = '\1';
					$htmlString = preg_replace($pattern, $replacement, $thisPara->getText());
					//echo 'merge='.$htmlString."\n";			
					$firstGroupPara->mergeText($htmlString); 
				}
			// Confirm that this gives the full set
			//} else {
			//	$buildText.=$firstGroupPara->getText();
			//	$firstGroupPara = $thisPara;
			}
		}
		// Write out the final group
		$buildText.=$firstGroupPara->getText()."\n";
		
		//foreach ($this->getParagraphs() as $paragraph) {
		//	$buildText.=$paragraph->getText();
		//}
		foreach ($this->getMediaNodes() as $mediaNode) {
			$buildText.=$mediaNode->toString();
		}
		return $buildText;
	}
	function isParaFirstInGroup($thisPara) {
		// Check various conditions to see if this para should merge with the previous one(s)
		// 1. Has extra space been added before this paragraph?
		if ($thisPara->y > 0) {
			//echo "new because y>0 \n";
			return true;
		}
		// Does it look like the start of a list?
		$pureText = $thisPara->getPureText($thisPara->getText());
		$pattern = '/^[\d]+\./';
		if (preg_match($pattern, $pureText)) {
			//echo "new list \n";
			return true;
		}
		return false;
	}
}
?>
