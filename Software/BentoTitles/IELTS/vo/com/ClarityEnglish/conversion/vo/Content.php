<?php
//
// Common for all sections in an exercise
//
class Content{
	
	var $paragraphs = Array();
	var $mediaNodes = Array();
	
	function __construct($xmlObj=null) {
		if ($xmlObj) {
			// Dig out the paragraphs from this xml object and create them
			foreach ($xmlObj->children() as $child) {
				if ($child->getName()=='paragraph') {
					$this->addParagraph($child);
				}
				if ($child->getName()=='media') {
					$this->addMediaNode($child);
				}
			}
		}
	}

	
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
				$startTag = null;
			
			} else {
				// Does this new para look like the first in the next group?
				$thisParaType = $this->isParaFirstInGroup($thisPara);
				//echo "para=$thisParaType ".substr($thisPara->getPureText(),0,64)."\n";
				if ($thisParaType) {
					//echo $thisParaType."\n";
					// Yes it does. So save it in next, and write out the previous group
					// $nextGroupPara = $thisPara;
					// First just write out the previous merged paragraph
					$buildText.=$firstGroupPara->getText();
					// Then get ready for the next round by setting the new para as the first of the next group
					// How you do this depends on the type of group it is starting
					if ($thisParaType=='empty') {
						// I really want to just drop an empty paragraph
						$firstGroupPara = null;
					} else {
						$firstGroupPara = clone $thisPara;
					}
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
		$buildText.=$firstGroupPara->getText();
		
		// Next step is to see if any of the paragraphs should be changed to lists.
		// Note that I am now working with a string, not an array of paragraph types. This doesn't seem smart.
		// But in R2I, lists only seem to happen in presentations, so are simple.
		// Oh, and of course a mulitple choice is a list. But then you have <question> tags to help.
		// Let's see
		
		// Whatever happens there are some characters I want to replace
		// non-breaking space special characters
		$buildText = preg_replace('/\xc2\xa0/', '&#160;', $buildText);
		
		//foreach ($this->getParagraphs() as $paragraph) {
		//	$buildText.=$paragraph->getText();
		//}
		foreach ($this->getMediaNodes() as $mediaNode) {
			$buildText.=$mediaNode->toString();
		}
		return $buildText;
	}
	// Check each paragraph to see if it the start of something special
	function isParaFirstInGroup($thisPara) {
		// Check various conditions to see if this para should merge with the previous one(s)
		// 1. Has extra space been added before this paragraph?
		if ($thisPara->y > 0) {
			//echo "new because y>0 \n";
			return 'spaceBefore';
		}
		// Does it look like the start of a list?
		$pureText = $thisPara->getPureText($thisPara->getText());
		$pattern = '/^1\./';
		if (preg_match($pattern, $pureText)) {
			return 'ol';
		}
		// or other items in the list?
		$pureText = $thisPara->getPureText($thisPara->getText());
		$pattern = '/^[\d]+\./';
		if (preg_match($pattern, $pureText)) {
			return 'list';
		}
		// Is it empty?
		$pattern = '/^[\s\xc2\xa0]*$/';
		if (preg_match($pattern, $pureText)>0) {
			return 'empty';
		}
		return null;
	}
}
/*
 					} elseif ($thisParaType=='ol') {
						// At the start of the list I want to add <ol></ol> surrounds
						$firstGroupPara = clone $thisPara;
						$firstGroupPara->setText('<ol><li>'.$thisPara->getPureText());
						$startTag = 'ol,li';
					} elseif ($thisParaType=='list') {
						// For a continuing list I want to change <p> to <li>
						$firstGroupPara = clone $thisPara;
						$firstGroupPara->setText('<li>'.$thisPara->getPureText());
						$startTag .= 'li';
*/
?>
