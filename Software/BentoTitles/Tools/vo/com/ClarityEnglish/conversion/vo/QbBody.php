<?php

class QbBody {
	// This is a question based body.
	// It just holds each question, which we treat as a Content object
	// It also needs to hold its own mediaNodes

	private $questions = Array();
	private $mediaNodes = Array();
	
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
			// Go through the object picking out question nodes and making a Question (::Content) object for each
            $groupPara = null;
			foreach ($xmlObj->children() as $child) {
				switch (strtolower($child->getName())) {
				    case 'question':
					    $this->addQuestion($child);
				        break;

	    			// And there might be paragraphs outside the questions (assume they have no fields or media in them)
                    case 'paragraph':
                            // Copied from content
                            if (!$groupPara) {
                                // Turn this first para xml into an object
                                $groupPara = New Paragraph($child, $this);
                            } else {
                                // What can we tell about how this paragraph fits into a group?
                                $thisPara = New Paragraph($child, $this);
                                $thisParaType = $thisPara->getParaGrouping();
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
                            }
                            $this->addParagraph($groupPara);
                        break;

                    // For field nodes, add them to the relevant Question
                    // Note that this will only work if the question has already been created
                        case 'field':
					// Which question does this field relate to?
					    $qID = $child['group'];
					    $this->addField($qID, $child);
					    break;

    				// Also go through the mediaNodes, those that are question based should be added to the relevant Question
                    case 'media':
                        // Which question does this field relate to?
                        $qbMedia = substr($child['type'],0,1)=='q' ? true : false;
                        if ($qbMedia) {
                            $qID = $child['id'];
                            $this->addQbMediaNode($qID, $child);
                        } else {
                            // Those that are common to the exercise can stay in here.
                            $this->addMediaNode($child);
                        }
                        break;
				}
			}
		}
	}
	function addQuestion($xmlObj) {
		// We need to let the question know which number it is as we add it
		// We link the Content to the Exercise rather than to the question (I think!)
		$this->questions[] = new Question(count($this->questions)+1,$xmlObj, $this->getParent());
	}
	function getQuestions() {
		return $this->questions;
	}
	function addField($qID, $xmlObj) {
		foreach($this->questions as $question) {
			if ($question->getID()==$qID) {
				$question->addField($xmlObj);
			}
		}
	}
	function getFields($qID) {
		foreach($this->questions as $question) {
			if ($question->getID()==$qID) {
				return $question->getFields();
			}
		}
	}
	function addQbMediaNode($qID, $xmlObj) {
		foreach($this->questions as $question) {
			if ($question->getID()==$qID) {
				$question->addMediaNode($xmlObj);
			}
		}
	}
	function addMediaNode($xmlObj) {
		$this->mediaNodes[] = new MediaNode($xmlObj, $this);
	}
    function addParagraph($para) {
        $this->paragraphs[] = $para;
    }
    function getParagraphs() {
        return $this->paragraphs;
    }
	// QbBody has to implement the same interface as Body
	function getSection() {
		return Exercise::EXERCISE_SECTION_BODY;
	}
	function output() {
		global $newline;
		//echo "output qbBody";
		$buildText = '';
		// Also output the common mediaNodes. These are likely to be first.
		foreach($this->mediaNodes as $mediaNode) {
			$buildText.=$mediaNode->output();
		}
		// Here we output the common stuff
        // TODO Making the assumption that we only have one 'block' per exercise for anything grouping...
		$buildText .= $newline.'<div class="container-questions"><ol class="questions" id="b1">';
		// Then for each question
		foreach($this->getQuestions() as $question) {
			$buildText.= $question->output();
		}
		$buildText .= '</ol></div>';
        $lastTagType = null;
        foreach ($this->getParagraphs() as $paragraph) {
            if ($paragraph) {
                // Keep track of any paragraph that is a different tag type than the previous one
                $thisTagType = $paragraph->getTagType();
                $buildText.=$paragraph->output($lastTagType,$thisTagType);
                $lastTagType = $thisTagType;

            }
        }

		return $buildText;
	}
	function toString() {
		$buildText = '';
		foreach($this->questions as $question) {
			$buildText.= $question->toString();
		}
		// Also write the common mediaNodes
		foreach($this->mediaNodes as $mediaNode) {
			$buildText.=$mediaNode->toString();
		}
		return $buildText;
	}
}
?>
