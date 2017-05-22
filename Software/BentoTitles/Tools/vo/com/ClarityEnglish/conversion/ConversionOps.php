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
    	    $readingText = $this->formatHtmlReadingText();
			$sections = $this->formatHtmlSections();
            $feedback = $this->formatHtmlFeedback();
			$contents = $this->formatFullHtml($head, $rubric, $readingText, $sections, $feedback);
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
<header class="rubric">
  $rubricText
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
	function formatHtmlSections() {
        // TODO Making the assumption that we only have one 'block' per exercise for anything grouping...
        $build = '<div class="sections" id="b1">';

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
	function formatHtmlHead() {
		// Components that go in the head
		//$exerciseType = strtolower($this->exercise->getType());
        //$now =date('Y-m-d');

		$model = $this->exercise->model->output();
        $extrabuild = ($this->exercise->getReadingText()) ? '<link rel="stylesheet" href="../css/unscrollable.less" />' : '';

		$build =<<< EOD
  <head>
    <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width">
    <link rel="stylesheet" href="../css/styles.less" />
    $extrabuild
    $model
  </head>
EOD;
		return $build;
	}
	function formatFullHtml($head, $rubric, $readingText, $sections, $feedback) {
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
$rubric
$sections
EOD;
        }
        $build .= <<< EOD
</body>
$feedback
</html>
EOD;
		return $build;
	}
	function formatSplitScreen($rubric, $text, $questions) {
        $build = <<< EOD
  <div class="page-split">
    <div class="page-split-one">
      <div class="content mod-split-one" id="g1-text">
        $rubric
        $text
      </div>
      <div class="page-split-sidebar mod-page-one">
        <span class="page-split-sidebar-text mod-page-one">Questions</span>
      </div>
    </div>
    <div class="page-split-two">
      <div class="page-split-sidebar mod-page-two">
        <span class="page-split-sidebar-text mod-page-two">Text</span>
      </div>        
      <div class="content mod-split-two">
        $questions
      </div>
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