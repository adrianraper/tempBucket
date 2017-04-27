<?php
class ConversionOps {
	
	var $exercise;
	var $outfile;
	
	public function __construct($exercise) {
		$this->exercise = $exercise;	
	}
	function setOutputFile($filename) {
		$this->outfile = $filename;
	}
	// Main function to control the conversion and writing
	function createOutput() {
		$fh = fopen($this->outfile, 'wb');
		// Check that you can create this file
		$fh = fopen($this->outfile, 'wb');
		if (!$fh) {
			throw new Exception("Can't write to the file ".$this->outfile);
		} else {
			// build the contents of the string we will write out
			//echo $this->outfile;
			$head = $this->formatHtmlHead();
			$rubric = $this->formatHtmlRubric();
			$sections = $this->formatHtmlSections();
            $feedback = $this->formatHtmlFeedback();
			$contents = $this->formatFullHtml($head, $rubric, $sections, $feedback);
			fwrite($fh, $contents);
			fclose($fh);
		}	
	}
	function formatHtmlRubric() {
		$rubricText = $this->exercise->getRubric();
		$build =<<< EOD
\n<header class="rubric">
	$rubricText
</header>
EOD;
		return $build;
	}
	function formatHtmlSections() {
		$build = '';
		// Better to write out the sections in a specific order
		// Mind you we build them in a specific order so should be fine
		foreach ($this->exercise->getSections() as $section) {
			$sectionText = $section->output();
			$sectionType = $section->getSection();
			//echo "output section ".$sectionType."=".$sectionText.$newline;
			$sectionBuild =<<< EOD
\n<!-- section is $sectionType-->
	$sectionText
EOD;
			// It might be nice to format the sectionText - not sure. Or leave Dreamweaver to do this?
			// BUG. There is something that stops some readingTexts from getting formatted, 
			// they just disappear after going through the following.
			//$build .= $sectionBuild; 
			$dom = new DOMDocument('1.0');
			$dom->preserveWhiteSpace = false;
			$dom->formatOutput = true;
			$rc = $dom->loadXML($sectionBuild);
			if ($rc) {
				$build .= str_replace('<?xml version="1.0"?'.'>','',$dom->saveXML());
			} else {
				// If the XML didn't load for some reason, just output it raw
				$build .= $sectionBuild; 
			} 
			//echo "output section ".$sectionType."=".$build.$newline;
		}
		return $build;
	}
    function formatHtmlFeedback() {
        $build = '';
        // Better to write out the sections in a specific order
        // Mind you we build them in a specific order so should be fine
        foreach ($this->exercise->getFeedback() as $section) {
            $sectionText = $section->output();
            $sectionType = $section->getSection();
            //echo "output section ".$sectionType."=".$sectionText.$newline;
            $sectionBuild =<<< EOD
\n<!-- section is $sectionType-->
	$sectionText
EOD;
            // It might be nice to format the sectionText - not sure. Or leave Dreamweaver to do this?
            // BUG. There is something that stops some readingTexts from getting formatted, 
            // they just disappear after going through the following.
            //$build .= $sectionBuild; 
            $dom = new DOMDocument('1.0');
            $dom->preserveWhiteSpace = false;
            $dom->formatOutput = true;
            $rc = $dom->loadXML($sectionBuild);
            if ($rc) {
                $build .= str_replace('<?xml version="1.0"?'.'>','',$dom->saveXML());
            } else {
                // If the XML didn't load for some reason, just output it raw
                $build .= $sectionBuild;
            }
            //echo "output section ".$sectionType."=".$build.$newline;
        }
        return $build;
    }
	function formatHtmlHead() {
		// Components that go in the head
		$exerciseType = strtolower($this->exercise->getType());
		
		// TODO. Settings. Need to move into the model at some point.
		$settings = strtolower($this->exercise->getSettings());
		
		// Model (questions and answers)
		//$model = $this->exercise->model->toString();
		$model = $this->exercise->model->output();
		
		$now =date('Y-m-d');
		$build =<<< EOD
    <head>
        <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width">
            <link rel="stylesheet" href="../css/styles.less" />
	$model
    </head>
EOD;
		return $build;
	}
	function formatFullHtml($head, $rubric, $sections, $feedback) {
		// Switch from practically xhtml to xml with html characteristics
		//	<!DOCTYPE html>
		//	<html xmlns="http://www.w3.org/1999/xhtml">
		// TODO. Note that trac has an issue raised regarding this xmlns as it stops xpath working.
		$build =<<< EOD
<!DOCTYPE html>
<html>
$head
<body>
	$rubric
	$sections
</body>
$feedback
</html>
EOD;
		return $build;
	}
}
?>