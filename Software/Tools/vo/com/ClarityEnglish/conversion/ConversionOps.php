<?php
class ConversionOps {
	
	var $exercise;
	var $outfile;
    var $newline = "\n";
	
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
			$sections = $this->formatHtmlSections($rubric); //rubric will be printed inside section
    	    $readingText = $this->formatHtmlReadingText();
            $feedback = $this->formatHtmlFeedback();
			$hint = $this->formatHtmlHint();
			$contents = $this->formatFullHtml($head, $rubric, $readingText, $sections, $feedback, $hint);
            $prettyPrinter = new Gajus\Dindent\Indenter();
            $prettyContents = $prettyPrinter->indent($contents);
			fwrite($fh, $prettyContents);
			fclose($fh);
		}	
	}
	
	function formatHtmlRubric() {
		$rubricText = $this->exercise->getRubric();
		// sss##2
		$build =<<< EOD
<header class="bvr-rubric">
  <p>$rubricText</p>
</header>
EOD;
		return $this->prettyprintHtml($build);
	}
    function formatHtmlReadingText() {
	    $build = '';
        // Better to write out the sections in a specific order
        // Mind you we build them in a specific order so should be fine
        foreach ($this->exercise->getReadingText() as $section) {
            $sectionText = $section->output();
            $build .= $this->prettyprint($sectionText);
        }
        return $build;
    }
	function formatHtmlSections($rubric) {
        // TODO Making the assumption that we only have one 'block' per exercise for anything grouping...
        //$build = '<div class="section" id="b1">';
		$build = '';
		if ($this->exercise->getReadingText()) {
			switch ($this->exercise->getType()) {
				case 'draganddrop':
					$build .= '<div class="section-content page-split-two mod-top-fix mod-drag" id="b1">';
					break;
				case 'gapfill':
				case 'presentation':
				case 'dropdown':
				case 'multiplechoice':
				case 'quiz':
				case 'targetspotting':
				case 'proofreading':
					$build .= '<div class="section-content page-split-two mod-top-fix" id="b1">';
			}			
		}	
		else {
			switch ($this->exercise->getType()) {
				case 'draganddrop':
					$build .= '<div class="section-content mod-top-fix mod-drag">';
					break;
				case 'gapfill':
				case 'presentation':
				case 'dropdown':
				case 'multiplechoice':
				case 'quiz':
				case 'targetspotting':
				case 'proofreading':
					$build .= '<div class="section-content mod-top-fix">';
			}
		}
		$build .= $rubric;
        foreach ($this->exercise->getSections() as $section) {
			$sectionText = $section->output();
            $build .= $this->prettyprint($sectionText);
		}

		$build .= '</div>';
		return $build;
	}
    function formatHtmlFeedback() {
        $build = '';
        // Better to write out the sections in a specific order
        // Mind you we build them in a specific order so should be fine
        foreach ($this->exercise->getFeedback() as $section) {
            $sectionText = $section->output();
            $build .= $this->prettyprint($sectionText);
        }
        return $build;
    }
    function formatHtmlHint() {
        $build = '';
        // Better to write out the sections in a specific order
        // Mind you we build them in a specific order so should be fine
        foreach ($this->exercise->getHint() as $section) {
            $sectionText = $section->output();
            $build .= $this->prettyprint($sectionText);
        }
        return $build;
    }
	function formatHtmlHead() {
		// Components that go in the head
		//$exerciseType = strtolower($this->exercise->getType());
        //$now =date('Y-m-d');

		$model = $this->exercise->model->output();
        //$extrabuild = ($this->exercise->getReadingText()) ? '<link rel="stylesheet" href="../css/unscrollable.less" />' : '';

		$build =<<< EOD
  <head>
    <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width">
    <link rel="stylesheet" href="../css/styles.less" />
    $model
  </head>
EOD;
		return $build;
	}
	function formatFullHtml($head, $rubric, $readingText, $sections, $feedback, $hint) {
        //if ($rubric) $rubric = $this->prettyprintHtml($rubric);
        //if ($readingText) $readingText = $this->prettyprintHtml($readingText);
        //if ($feedback) $feedback = $this->prettyprint($feedback);
        //if ($sections) $sections = $this->prettyprintHtml($sections);
        $build = <<< EOD
<!DOCTYPE html>
<html>
$head
<body>
EOD;
        if ($this->exercise->getReadingText()) {
            $build .= $this->formatSplitScreen($rubric, $readingText, $sections);
        } else {
            $build .= <<< EOD
<div class="section" id="b1">
$sections
EOD;
        }
        $build .= <<< EOD
</body>
$feedback
$hint
</html>
EOD;
		return $build;
	}
	function formatSplitScreen($rubric, $text, $questions) {
        $build = <<< EOD
  <div class="section bvr-page-split mod-split">
    <div class="section-content page-split-one">
      <div class="section-content-body" id="g1-text">
        $text
      </div>
    </div>
        $questions
    </div>
  </div>
EOD;
        return $build;
    }

    // There are some bits of html that get wrecked if you do prettyprintHtml, so do the xml version for them
    function prettyprint($text) {
	    return $text;
	    // Do all pretty print in the regex beautifier now
        $dom = new DOMDocument('1.0');
        $dom->preserveWhiteSpace = false;
        $dom->formatOutput = true;
        $rc = $dom->loadXML($text);
        if ($rc) {
            $build = str_replace('<?xml version="1.0"?' . '>', '', $dom->saveXML());
        } else {
            // If the XML didn't load for some reason, just output it raw
            $build = $text;
        }
        return $build;
    }
    function prettyprintHtml($text) {
        return $text;
        // Do all pretty print in the regex beautifier now
        $dom = new DOMDocument('1.0');
        $dom->preserveWhiteSpace = false;
        $dom->formatOutput = true;
        $rc = $dom->loadHTML($text, LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD);
        if ($rc) {
            $build = $dom->saveHTML();
        } else {
            // If the html didn't load for some reason, just output it raw
            $build = $text;
        }
        return $build;
    }
    // Not able to make this work yet
    /*
    function formatHtml($html) {
        // Load HTML that already has doctype and stuff
        $formatter = new \HtmlFormatter\HtmlFormatter($html);

        // Add rules to remove some stuff
        //$formatter->remove( 'img' );
        //$formatter->remove( [ '.some_css_class', '#some_id', 'div.some_other_class' ] );
        // Only the above syntax is supported, not full CSS/jQuery selectors

        // These tags get replaced with their inner HTML,
        // e.g. <tag>foo</tag> --> foo
        // Only tag names are supported here
        //$formatter->flatten( 'span' );
        //$formatter->flatten( [ 'code', 'pre' ] );

        // Actually perform the removals
        //$formatter->filterContent();

        // Direct DomDocument manipulations are possible
        //$formatter->getDoc()->createElement( 'p', 'Appended paragraph' );

        // Get resulting HTML
        return $formatter->getText();
    }
    */
}