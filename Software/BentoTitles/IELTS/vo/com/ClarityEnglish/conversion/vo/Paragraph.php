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
	// Note that this is part of a tag outside than <p>
	var $tagType;

	// What about Chinese characters? Or French for that matter.
	const characters_to_keep = '[\s\w\<\>#=&;,\[\]\-\'"\/\? \.\t\h\xc2\xa0]';
	
	protected $parent;
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		$this->parent = $object;
	}
	
	function __construct($xmlObj=null, $parent=null) {
		// Keep a reference back to the section we are part of
		if ($parent)
			$this->setParent($parent);
		
		//if (($this->getParent()->getSection()==Exercise::EXERCISE_SECTION_NOSCROLL)) {
		//	echo $xmlObj;
		//}
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
		//echo "section=".$section->getSection()."\n";
		// General pattern use
		//$charactersToKeep = '[\s\w\d<>#=&;,\'"\/\? \.\t\h\xc2\xa0]';
		
		//if ($section->getSection()==Exercise::EXERCISE_SECTION_RUBRIC) { 
		if (($section->getSection()==Exercise::EXERCISE_SECTION_RUBRIC) || 
			($section->getSection()==Exercise::EXERCISE_SECTION_NOSCROLL)) {
			// This is what a standard rubric paragraph looks like
			//<paragraph x="12" y="+4" width="605" height="0" style="headline" tabs="0" indent="0" id="1">
			//	<![CDATA[<B><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="Verdana" SIZE="12" COLOR="#000000" LETTERSPACING="0" KERNING="0"><B>Read the text below.</B></FONT></P></TEXTFORMAT></B>]]>
			//</paragraph>
			// Get rid of as many outside tags as you can.
			$builtHtml = $this->getPureText($fullParagraphHtml);
			//echo $builtHtml;
			
		} else {

			// In this function we will use regex to figure out which html tags we should keep and which
			// are no longer required.
			// First, see if there is a standard textformat tag to remove
			// Stuff that looks the same doesn't match the same...
			// Need to cope with extra characters, including tabs and non-breaking spaces. \h?
			// TextFormat has no information that we want to keep.
			//$pattern = '/<TEXTFORMAT [^>]+>('.Paragraph::characters_to_keep.'+)<\/TEXTFORMAT>/is';
			//$replacement = '\1';
			//$builtHtml = preg_replace($pattern, $replacement, $fullParagraphHtml);
			$patterns = Array();
			$patterns[] = '/\<TEXTFORMAT [^\>]+\>/is';
			$patterns[] = '/\<\/TEXTFORMAT\>/is';
			$replacement = '';
			$builtHtml = preg_replace($patterns, $replacement, $fullParagraphHtml);
			//$builtHtml = $fullParagraphHtml;
			
			// In terms of conversion - it is a question of what I want to keep 
			// FONT - I don't care about any changes in face or size (because there are hardly any and they are bound to change). 
			// I want to keep color changes. Ignore everything else.
			//$pattern = '/<FONT [^>]+ COLOR="([#a-fA-F0-9x]+)" [^>]+>('.Paragraph::characters_to_keep.'+)<\/FONT>/is';
			//$replacement = '<font color="\1">\2</font>';
			$pattern = '/<FONT [^>]+ COLOR="([#a-fA-F0-9x]+)" [^>]+>/is';
			$replacement = '<font color="\1">';
			$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
			
			// FONT. If the only thing is color=black then I would like to drop the whole font tag.
			$pattern = '/<font color="#000000">('.Paragraph::characters_to_keep.'+)<\/font>/is';
			$replacement = '\1';
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
	function getPureText($htmlString=null) {
		if (!$htmlString)
			$htmlString = $this->getText();
		//return $htmlString;
		// get rid of b
		// <B> Author Plus mistakenly (sometimes) puts <B> outside textformat - so drop that along with the textformat
		/*
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
		
		// Then font. But this has to be match all since there might be many 
		$pattern = '/<FONT [^>]+>('.Paragraph::characters_to_keep.'+)<\/FONT>/is';
		$replacement = '\1';
		$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
		// then any other b. Likewise, match all
		$pattern = '/<B>('.Paragraph::characters_to_keep.'+)<\/B>/isg';
		$replacement = '\1';
		$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
		*/
		// Just simply get rid of the tags and their attributes
		$patterns = Array();
		$patterns[] = '/\<TEXTFORMAT [^\>]+\>/is';
		$patterns[] = '/\<FONT [^\>]+\>/is';
		$patterns[] = '/\<P [^\>]+\>/is';
		$patterns[] = '/\<B\>/is';
		$patterns[] = '/\<\/TEXTFORMAT\>/is';
		$patterns[] = '/\<\/FONT\>/is';
		$patterns[] = '/\<\/P\>/is';
		$patterns[] = '/\<\/B\>/is';
		$replacement = '';
		$builtHtml = preg_replace($patterns, $replacement, $htmlString);
		//echo $builtHtml;
		return $builtHtml;
	}
	function getText(){
		return $this->text;
	}
	function setText($text){
		$this->text = $text;
	}
	// Add tags round the paragraph based on its type
	function output($lastTagType,$thisTagType){
		// You might want to add tags to the html
		//echo "last=$lastTagType, this=$thisTagType ||";
		$builtHtml='';
		// Is this the start of a list?
		if ($thisTagType=='ol' && $lastTagType!='ol') {
			$builtHtml .='<ol>';
		} else if ($thisTagType=='ul' && $lastTagType!='ul') {
			$builtHtml .='<ul>';
		}
		if ($thisTagType=='ol' || $thisTagType=='ul') {
			// Let's assume you will drop any formatting from within the list item
			//$builtHtml .= '<li>'.$this->text.'</li>';
			$listText = $this->getPureText();
			// Also drop any numbers or bullets
			$listText = $this->textFormatDropListThings($listText);
			$builtHtml .= '<li>'.$listText.'</li>';
		} else {
			$builtHtml .= $this->text;
		}
		// Is this the end of a list?
		if ($lastTagType=='ol' && $thisTagType!='ol') {
			$builtHtml = '</ol>'.$builtHtml;
		} else if ($lastTagType=='ul' && $thisTagType!='ul') {
			$builtHtml = '</ul>'.$builtHtml;
		}
		return $builtHtml;
	}
	function setTagType($tag) {
		if ($tag=='ol' || $tag=='ul') {
			$this->tagType = $tag;
		} else {
			$this->tagType = '';
		}
	}
	function getTagType() {
		return $this->tagType;
	}
	function isOrderedList(){
		return ($this->tagType=='ol');
	}
	// This function adds some html text into this paragraph 
	function mergeText($htmlString) {
		//$this->text.=$htmlString;
		//$charactersToKeep = '[\s\w\d<>#=&;,\'"\/\? \.\t\h\xc2\xa0]';
		// First see if there is a <p> tag surrounding everything?
		$thisText = $this->getText();
		$pattern = '/(<p [^>]+>)('.Paragraph::characters_to_keep.'+)(<\/p>)/is';
		if (preg_match($pattern, $thisText)) {
			$replacement = '\1\2'.$htmlString.'\3';
			$this->setText(preg_replace($pattern, $replacement, $thisText));
		} else {
			// In which case just add to the end
			$this->setText($thisText.$htmlString);
		}
	}
	// This function simply adds to the end of the text 
	function appendText($htmlString) {
		$this->setText($this->getText().$htmlString);
	}
	// A set of functions that format text in particular ways
	public function textFormatDropListThings($listText) {
		$pattern = '/^[\d\.\s\x95\xb7\xe2]+(.*)/is';
		if (preg_match($pattern, $listText, $matches)) {
			$built=$matches[1];
		} else {
			$built=$matches[0];
		}
		return $built;
	}
	function getID(){
		return $this->id;
	}
	// A utility function to describe the object
	function toString() {
		global $newline;
		return $newline."<paragraph>".$this->getPureText()."</paragraph>";
	}
}
?>
