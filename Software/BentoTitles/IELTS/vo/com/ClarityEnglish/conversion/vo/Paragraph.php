<?php
class Paragraph {
	
	// A paragraph has settings and a block of html text
	var $text = '';
	// x and y will go towards padding and margin
	var $x;
	var $y;
	// width and height might be used as is unless this ruins floats
	var $width;
	var $height;
	// for reference
	var $id;

	const characters_to_keep = '[\s\w\d<>#=&;,\'"\/\? \.\t\h\xc2\xa0]';
	
	protected $parent;
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		$this->parent = $object;
	}
	
	function Paragraph($xmlObj=null, $parent=null) {
		// Keep a reference back to the section we are part of
		$this->setParent($parent);
		
		//echo $xmlObj;
		if ($xmlObj) {
			// Dig out the text and settings from this xml
			$attr = $xmlObj->attributes();
			if (count($attr)>0) {
				foreach($attr as $a => $b) {
					switch ($a) {
						case 'id':
							$this->$a = $b;
							break;
						case 'x':
						case 'y':
						case 'width':
						case 'height':
							$this->$a = intval($b);
							break;
						default:
					}
				}
			}
			$this->text = $this->stripAPFormatting($xmlObj);
			//echo "id=".$this->id;
		}
	}
	
	// The content of the paragraph is html with Flash flavours. We want to turn this into the html
	// flavours that we can use in Bento.
	function stripAPFormatting($fullParagraphHtml) {
		// First of all, assuming that this is pure Author Plus, just strip away standard bits
		// It might be useful to know what section this paragraph is in...
		// And, if we are in a rubric - I think I should simply get rid of ALL html tags to leave pure text.
		$section = $this->getParent();
		//echo "section=".$section->getClass()."\n";
		// General pattern use
		//$charactersToKeep = '[\s\w\d<>#=&;,\'"\/\? \.\t\h\xc2\xa0]';
		// Whatever happens there are some characters I want to replace
		// non-breaking space special characters
		$fullParagraphHtml = preg_replace('/\xc2\xa0/', '&#160;', $fullParagraphHtml);
		
		if ($section->getClass()==Exercise::EXERCISE_SECTION_RUBRIC) {
			// This is what a standard rubric paragraph looks like
			//<paragraph x="12" y="+4" width="605" height="0" style="headline" tabs="0" indent="0" id="1">
			//	<![CDATA[<B><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="Verdana" SIZE="12" COLOR="#000000" LETTERSPACING="0" KERNING="0"><B>Read the text below.</B></FONT></P></TEXTFORMAT></B>]]>
			//</paragraph>
			// Get rid of as many outside tags as you can.
			$builtHtml = $this->getPureText($fullParagraphHtml);
						
		} else {

			// In this function we will use regex to figure out which html tags we should keep and which
			// are no longer required.
			// First, see if there is a standard textformat tag to remove
			// Stuff that looks the same doesn't match the same...
			// Need to cope with extra characters, including tabs and non-breaking spaces. \h?
			$pattern = '/<TEXTFORMAT [^>]+>('.Paragraph::characters_to_keep.'+)<\/TEXTFORMAT>/is';
			$replacement = '\1';
			$builtHtml = preg_replace($pattern, $replacement, $fullParagraphHtml);
			// In terms of conversion - it is a question of what I want to keep 
			// FONT - I don't care about any changes in face or size. I want to keep color changes. Ignore everything else.
			$pattern = '/<FONT [^>]+ COLOR="([#a-fA-F0-9x]+)" [^>]+>('.Paragraph::characters_to_keep.'+)<\/FONT>/is';
			$replacement = '<font color="\1">\2</font>';
			$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
			
			// For good xhtml keep all tags lowercase. It may be quicker to just do a strreplace for these!
			/*
			$pattern = '/<P ([^>]+)>('.$charactersToKeep.'+)<\/P>/is';
			$replacement = '<p \1>\2</p>';
			$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
			$pattern = '/<B>('.$charactersToKeep.'+)<\/B>/is';
			$replacement = '<b>\1</b>';
			$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
			*/
			// Not quite, it leaves ALIGN=\"LEFT\", which xhtml doesn't like. So add stripslashes.
			//$builtHtml = stripslashes(preg_replace("/(<\/?)(\w+)([^>]*>)/e","'\\1'.strtolower('\\2').'\\3'",$builtHtml));
			// Or maybe I should even change everything in a tag - all attribute keys and values.
			$builtHtml = stripslashes(preg_replace("/(<\/?)([^>]+)(>)/e","'\\1'.strtolower('\\2').'\\3'",$builtHtml));
			
			//echo $fullParagraphHtml."\n";	
			//echo $builtHtml."\n";	
			// P - Just keep.
		}		
		// send back our formatted output
		return $builtHtml;
	}
	// For an html string, get rid of as many outside tags as are likely
	function getPureText($htmlString) {
		// get rid of b
		// <B> Author Plus mistakenly puts <B> outside textformat - so drop that along with the textformat
		$pattern = '/<B>('.Paragraph::characters_to_keep.'+)<\/B>/is';
		$replacement = '\1';
		$builtHtml = preg_replace($pattern, $replacement, $htmlString);
		// then textformat
		$pattern = '/<TEXTFORMAT [^>]+>('.Paragraph::characters_to_keep.'+)<\/TEXTFORMAT>/is';
		$replacement = '\1';
		$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
		// then p
		$pattern = '/<P [^>]+>('.Paragraph::characters_to_keep.'+)<\/P>/is';
		$replacement = '\1';
		$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
		// then font
		$pattern = '/<FONT [^>]+>('.Paragraph::characters_to_keep.'+)<\/FONT>/is';
		$replacement = '\1';
		$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
		// then any other b
		$pattern = '/<B>('.Paragraph::characters_to_keep.'+)<\/B>/is';
		$replacement = '\1';
		$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
		
		return $builtHtml;
	}
	function getText(){
		return $this->text;
	}
	function setText($text){
		$this->text = $text;
	}
	
	// This function adds some html text to this paragraph 
	function mergeText($htmlString) {
		//$this->text.=$htmlString;
		//$charactersToKeep = '[\s\w\d<>#=&;,\'"\/\? \.\t\h\xc2\xa0]';
		$pattern = '/(<p [^>]+>)('.Paragraph::characters_to_keep.'+)(<\/p>)/is';
		$replacement = '\1\2'.$htmlString.'\3';
		$this->setText(preg_replace($pattern, $replacement, $this->getText()));
	}
	function getID(){
		return $this->id;
	}
}
?>
