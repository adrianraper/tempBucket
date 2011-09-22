<?php
//
// Common for all sections in an exercise
//
class Content{
	
	var $paragraphs = Array();
	var $mediaNodes = Array();
	var $fields = Array();
	
	protected $parent;
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		//echo "set parent for ";
		$this->parent = $object;
	}
	function __construct($xmlObj=null, $parent=null) {
		if ($parent) 
			$this->setParent($parent);
			
		if ($xmlObj) {
			//echo 'create new content for '.$this->getSection();
			// Dig out the paragraphs from this xml object and create them
			$groupPara = null;
			foreach ($xmlObj->children() as $child) {
				//echo $child->getName();
				if (strtolower($child->getName())=='paragraph') {
					// Where is the best place to be smart about combining paragraphs?
					// If there is an empty paragraph, that clearly separates two.
					// Likewise if a paragraph has y=+x, then it is probably separating two.
					// And if the paragraph attributes are different (except for indentation fudges)
					// Or if the text begins 1. - in which case it becomes a list.
					// So, read first paragraph and hold all of it.
					// Then read next in a loop until you hit one that is the beginning of a new group. Hold that in nextGroup.
					// For each one that is read, just grab the pure text and add it to the first para pure text.
					if (!$groupPara) {
						// Turn this first para xml into an object
						$groupPara = New Paragraph($child, $this);
					} else {
						// What can we tell about how this paragraph fits into a group?
						$thisPara = New Paragraph($child, $this);
						$thisParaType = $this->getParaGrouping($thisPara);
						if ($thisParaType) {
							//echo "para=$thisParaType ".substr($thisPara->getPureText(),0,64)."\n";
							// At this stage I am just merging, but worth noting paragraph types
							$thisPara->setTagType($thisParaType);
							//echo $thisParaType."\n";
							// Yes it does. So save it in next, and write out the previous group
							// $nextGroupPara = $thisPara;
							// First just save the previous merged paragraph
							$this->addParagraph($groupPara);
							// Then get ready for the next round by setting the new para as the first of the next group
							// How you do this depends on the type of group it is starting
							if ($thisParaType=='empty') {
								// I really want to just drop an empty paragraph
								$groupPara = null;
							} else {
								$groupPara = $thisPara;
							}
						} else {
							// This paragraph's text should be merged to the previous one then.
							// Grab the plain text and merge it
							$pureText = $thisPara->getPureText();
							//echo 'merge='.$pureText."\n";			
							$groupPara->mergeText($pureText); 
						}
					// Confirm that this gives the full set
					//} else {
					//	$buildText.=$firstGroupPara->getText();
					//	$firstGroupPara = $thisPara;
					}
				}
				if ($child->getName()=='media') {
					$this->addMediaNode($child);
				}
				if ($child->getName()=='field') {
					$this->addField($child);
				}
			}
			// Write out the final group
			$this->addParagraph($groupPara);
		}
	}

	function addField($xmlObj) {
		$this->fields[] = new Field($xmlObj, $this);
	}
	function getFields() {
		return $this->fields;
	}
	function addMediaNode($xmlObj) {
		$this->mediaNodes[] = new MediaNode($xmlObj, $this);
	}
	function getMediaNodes() {
		return $this->mediaNodes;
	}
	// If you have a paragraph as xml, this will add it to the content
	function addParagraphFromXML($xmlObj) {
		$this->paragraphs[] = new Paragraph($xmlObj, $this);
	}
	// If you have a paragraph as an object, this will add it to the content
	function addParagraph($para) {
		$this->paragraphs[] = $para;
	}
	function getParagraphs() {
		return $this->paragraphs;
	}
	//function getSection() {
		// This must always be overwritten in the specific section
	//}
	// Used in output of the converted XML
	function output() {
		
		// First see if this exercise outputs content in a special way 
		if (($this->getParent()->getExerciseType()==Exercise::EXERCISE_TYPE_DRAGANDDROP) &&
			$this->getSection()==Exercise::EXERCISE_SECTION_BODY) {
			// Output for drag and drop body
			$buildText = $this->bodyOutput(Exercise::EXERCISE_TYPE_DRAGANDDROP);
			
		} else {
			$buildText='';
			$lastTagType = null;
			foreach ($this->getParagraphs() as $paragraph) {
				// Keep track of any paragraph that is a different tag type than the previous one
				$thisTagType = $paragraph->getTagType();
				$buildText.=$paragraph->output($lastTagType,$thisTagType);
				$lastTagType = $thisTagType;
			}		
			foreach ($this->getMediaNodes() as $mediaNode) {
				$buildText.=$mediaNode->output();
			}
		}
		// Whatever happens there are some characters I want to replace
		// non-breaking space special characters
		$buildText = preg_replace('/\xc2\xa0/', '&#160;', $buildText);
		
		return $buildText;
	}
	// Special output functions
	// Should this be somewhere else?
	function bodyOutput($exerciseType) {
		$builder='';
		if ($exerciseType==Exercise::EXERCISE_TYPE_DRAGANDDROP) {
			// You need to output all the paragraphs. 
			$lastTagType = null;
			foreach ($this->getParagraphs() as $paragraph) {
				// Keep track of any paragraph that is a different tag type than the previous one
				$thisTagType = $paragraph->getTagType();
				$builder.=$paragraph->output($lastTagType,$thisTagType);
				$lastTagType = $thisTagType;
			}		
			//echo $builder;
			
			// As you do it, you want to find any drops and replace them with an input field
			// You will also write out a question node in the script node
			$pattern = '/([^\[]*)[\[]([\d]+)[\]]([^\[]*)/is';
			$buildText='';
			if (preg_match_all($pattern, $builder, $matches, PREG_SET_ORDER)) {
				foreach ($matches as $m) {
					// read the fields to find the matching answer
					$answer='';
					foreach ($this->getFields() as $field) {
						if ($field->getID()==$m[2]) {
							$fieldType = $field->getType();
							$answers = $field->getAnswers();
							$answer = $answers[0]->getAnswer();
							continue;
							// TODO: What if we didn't find this field id?
						}
					}
					if ($fieldType==Field::FIELD_TYPE_DROP) {
						$buildText.=$m[1].'<input id="'.$m[2].'" type="droptarget" />'.$m[3];
					}
					// And then the final bit after the last match...
					
					// We have already written the questions to the model
				}
			}
			
			foreach ($this->getMediaNodes() as $mediaNode) {
				$buildText.=$mediaNode->output();
			}
		}
		return $buildText;
	}
	// Check each paragraph to see if it can be merged into the previous one
	function getParaGrouping($thisPara) {
		// Check various conditions to see if this para should merge with the previous one(s)
		// 1. Has extra space been added before this paragraph?
		if ($thisPara->y > 0) {
			//echo "new because y>0 \n";
			return 'spaceBefore';
		}
		// Does it look like the start of a list?
		// TODO. Add a variation for bulleted lists
		$pureText = $thisPara->getPureText($thisPara->getText());
		$pattern = '/^[\d]\./';
		if (preg_match($pattern, $pureText)) {
			return 'ol';
		}
		// Is it empty?
		$pattern = '/^[\s\xc2\xa0]*$/';
		if (preg_match($pattern, $pureText)>0) {
			return 'empty';
		}
		return null;
	}
	// A utility function to describe the object
	function toString() {
		global $newline;
		$build=$newline.'<'.$this->getSection().'>';
		
		foreach ($this->getParagraphs() as $para) {
			if ($para)
	  			$build.=$para->toString();
		}
		foreach ($this->getFields() as $field) {
	  		$build.=$field->toString();
		}
		foreach ($this->getMediaNodes() as $mediaNode) {
	  		$build.=$mediaNode->toString();
		}
		
		$build.=$newline.'</'.$this->getSection().'>';	
		return $build;
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

		// Whatever happens there are some characters I want to replace
		// non-breaking space special characters
		$buildText = preg_replace('/\xc2\xa0/', '&#160;', $buildText);
*/
?>
