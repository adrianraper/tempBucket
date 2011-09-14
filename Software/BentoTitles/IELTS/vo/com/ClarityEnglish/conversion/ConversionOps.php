<?php
class ConversionOps {
	
	var $exercise;
	var $outfile;
	
	function ConversionOps($exercise) {
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
			throw new Exception("Can't write to the file $filename");
		} else {
			// build the contents of the string we will write out
			$head = $this->formatHtmlHead();
			$rubric = $this->formatHtmlRubric();
			$sections = $this->formatHtmlSections();
			$contents = $this->formatFullHtml($head, $rubric, $sections);
			fwrite($fh, $contents);
			fclose($fh);
		}	
	}
	function formatHtmlRubric() {
		$rubricText = $this->exercise->getRubric();
		$build =<<< EOD
		<header>
			$rubricText
		</header>
EOD;
		return $build;
	}
	function formatHtmlSections() {
		$build = '';
		foreach ($this->exercise->getSections() as $section) {
			$sectionText = $section->getText();
			$sectionType = $section->getClass();
			$build .=<<< EOD
			<section id="$sectionType">
				$sectionText
			</section>
EOD;
		}
		return $build;
	}
	function formatHtmlHead() {
		// Components that go in the head
		$exerciseType = strtolower($this->exercise->getType());
		
		// Settings
		$settings = strtolower($this->exercise->getSettings());
		
		// Model (questions and answers)
		
		$build =<<< EOD
		<head>
			<link rel="stylesheet" href="exercises/css/exercises.css" type="text/css" />
			<link rel="stylesheet" href="exercises/css/$exerciseType.css" type="text/css" />
			<style type="text/css">
			<![CDATA[			
				list {
					list-style-type: decimal;
					margin-left: 0; 
					padding-left: 20px; 
					padding-bottom: 12px; 
				}
				p {
					padding-bottom: 12px; 
				}
				.no-padding {
					padding-bottom: 0px; 
				}
				.h1 {
					font-size: 12px;
					font-weight: bold;
					color: #3A00FF;	
				}
			]]>
			</style>
			<script id="settings" type="application/xml">
				$settings
			</script>
			<script id="model" type="application/xml">
			</script>
		</head>
EOD;

		return $build;
	}
	function formatFullHtml($head, $rubric, $sections) {
		$build =<<< EOD
			<!DOCTYPE html>
			$head
			<body>
				$rubric
				$sections
			</body>
EOD;
		return $build;
	}
}
?>