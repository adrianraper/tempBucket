<?php

// Please do remember that if you display in the browser, anything with <> around it will be interpreted!
header ('Content-Type: text/plain');

$characters_to_keep = '[\s\w\<\>#=&;,\[\]\-\'"\/\? \.\t\h\xc2\xa0]';
/*
$fullParagraphHtml = <<<EOD
me<B><TEXTFORMAT LEADING="2">
<P ALIGN="LEFT"><FONT FACE="Verdana" SIZE="12" COLOR="#0000F6" LETTERSPACING="0" KERNING="0"><B>What will I learn in this unit?</B></FONT></P>
</TEXTFORMAT></B>me
EOD;

//$simpleParagraphHtml = '<B><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="Verdana" SIZE="12" COLOR="#000000" LETTERSPACING="0" KERNING="0"><b>What\'ll I learn in this unit?</b></FONT></P></TEXTFORMAT></B>';
//$simplePattern = '/<Bastien [a-zA-Z0-9#=" ]+>([a-zA-Z ]+)<\/Bastien>/U';
//$simplePattern = '/<TEXTFORMAT [^>]+>([\w\d<>#=\'"\/\? ]+)<\/TEXTFORMAT>/isU';
//$simplePattern = '/<TEXTFORMAT [^>]+>([.]+)<\/TEXTFORMAT>/isU';
//$simpleReplace = '\1';
//echo preg_replace($simplePattern, $simpleReplace, $simpleParagraphHtml);
//		echo ereg($simplePattern, $simpleParagraphHtml);

	// get rid of b
	$pattern = '/<B>([\s\w\d<>#=\'"\/\? ]+)<\/B>/is';
	$replacement = '\1';
	$builtHtml = preg_replace($pattern, $replacement, $fullParagraphHtml);
	// then textformat
	$pattern = '/<TEXTFORMAT [^>]+>([\s\w\d<>#=\'"\/\? ]+)<\/TEXTFORMAT>/is';
	$replacement = '\1';
	$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
	// then p
	$pattern = '/<P [^>]+>([\s\w\d<>#=\'"\/\? ]+)<\/P>/is';
	$replacement = '\1';
	$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
	// then font
	$pattern = '/<FONT [^>]+>([\s\w\d<>#=\'"\/\? ]+)<\/FONT>/is';
	$replacement = '\1';
	$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
	// then b
	$pattern = '/<B>([\s\w\d<>#=\'"\/\? ]+)<\/B>/is';
	$replacement = '\1';
	$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
	echo $builtHtml;
	exit();
			
	$pattern = '/(<B>)?<TEXTFORMAT [^>]+>([\s\w\d<>#=\'"\/\? ]+)<\/TEXTFORMAT>(<\/B>)?/is';
	$replacement = '\2';
	$builtHtml = preg_replace($pattern, $replacement, $fullParagraphHtml);

//$builtHtml = '<FONT FACE="Verdana" SIZE="12" COLOR="#000000" LETTERSPACING="0" KERNING="0"></FONT>';
	$pattern = '/<FONT [^>]+ COLOR="([#a-fA-F0-9x]+)" [^>]+>([\s\w\d<>#=\'"\/\? ]+)<\/FONT>/is';
	$replacement = '<FONT COLOR="\1">\2</FONT>';
	$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
	echo $builtHtml;
	
	$pattern = '/<P ALIGN="LEFT">([\s\w\d<>#=\'"\/\? ]+)<\/P>/is';
	$replacement = '<P>\1</P>';
	$keptHtml = preg_replace($pattern, $replacement, $builtHtml);

	echo $keptHtml;
*/
/*
$fullParagraphHtml = <<<EOD
<P ALIGN="LEFT"><FONT FACE="Verdana" SIZE="12" COLOR="#0000F6" LETTERSPACING="0" KERNING="0"><B>What will I learn in this unit?</B></FONT></P>
EOD;
$htmlString = <<<EOD
<FONT FACE="Verdana" SIZE="13" COLOR="#000633" LETTERSPACING="0" KERNING="0">Not very much</FONT>
EOD;

		//$this->text.=$htmlString;
		$pattern = '/(<p [^>]+>)('.$charactersToKeep.'+)(<\/p>)/is';
		$replacement = '\1\2'.$htmlString.'\3';
		echo preg_replace($pattern, $replacement, $fullParagraphHtml);
*/
/*
$htmlString = <<<EOD
<P ALIGN="LEFT">  	&#160;</P>
EOD;
$pattern = '/<P[ >].*>('.$characters_to_keep.'+)<\/P>/is';
$replacement = '\1';
$pureText = preg_replace($pattern, $replacement, $htmlString);
echo $pureText."\n";

$pattern = '/^[\s\xc2\xa0]|&#160;*$/';
if (preg_match($pattern, $pureText)>0) {
	echo 'yes, just white space';
} else {
	echo $htmlString;
}
*/
/*
$builtHtml = <<<EOD
<FONT FACE="Verdana" SIZE="13" COLOR="#000000" LETTERSPACING="0" KERNING="0">You will ...</FONT>
EOD;
	$pattern = '/<FONT [^>]+ COLOR="([#a-fA-F0-9x]+)" [^>]+>('.$characters_to_keep.'+)<\/FONT>/is';
	$replacement = '<font color="\1">\2</font>';
	$builtHtml = preg_replace($pattern, $replacement, $builtHtml);

	$pattern = '/<font color="#000000">('.$characters_to_keep.'+)<\/font>/is';
	$replacement = '\1';
	echo preg_replace($pattern, $replacement, $builtHtml);
*/
/*
$builtHtml = <<<EOD
<tab>[40]</FONT><tab><FONT COLOR="#0000FF">[34]</FONT><tab><FONT COLOR="#0000FF">[24]</FONT><tab><FONT COLOR="#0000FF">[25]
EOD;
$htmlString = <<<EOD
<tab>[21]</FONT><tab><FONT COLOR="#0000FF">[30]</FONT><tab><FONT COLOR="#0000FF">[27]</FONT><tab><FONT COLOR="#0000FF">[22]
EOD;
		$pattern = '/(<p [^>]+>)('.$characters_to_keep.'+)(<\/p>)/is';
		$replacement = '\1\2'.$htmlString.'\3';
		echo preg_replace($pattern, $replacement, $builtHtml);
*/
/*
$file = '123455.xml';
		$pattern = '/^([\d]+).xml/is';
		if (preg_match($pattern, $file, $matches)) {
			echo "matched to ".$matches[1];
		} else {
			echo 'not matched';
		}
*/
/*		
$thisText = '• 	Hello to you all';
echo 'ascii='.ord(substr($thisText,0,1));
		$pattern = '/^[\d\.\s\x95\xb7\xe2]+(.*)/is';
		if (preg_match($pattern, $thisText, $matches)) {
			echo "matched to ".$matches[1];
		} else {
			echo 'not matched '.$matches[0];;
		}
*/
/*
$htmlString = <<<EOD
<tab>[21]<tab>[30]<tab>[27]<tab>[22]
EOD;
		// change <tab> to correct <tab/>
		$htmlString = str_replace('<tab>', '<tab/>', $htmlString);
		// change [xx] to <span>
		$pattern = '/([^\[]*)[\[]([\d]+)[\]]/is';
		$built='';
		if (preg_match_all($pattern, $htmlString, $matches, PREG_SET_ORDER)) {
			foreach ($matches as $m) {
				// read the fields to find the matching answer
				$built.=$m[1].'<span id="'.$m[2].'" draggable="true"></span>';
			}
		}
		//echo $built;
*/
/*
$builtHtml = <<<EOD
<TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="Verdana" SIZE="13" COLOR="#000000" LETTERSPACING="0" KERNING="0">Dear Sally,</FONT></P></TEXTFORMAT>
<TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000" LETTERSPACING="0" KERNING="0"> </FONT></P></TEXTFORMAT>
EOD;
	//$patterns = Array();
	//$patterns[] = '/<FONT [^>]+ COLOR="([#a-fA-F0-9x]+)" [^>]+>/is';
	//$replacement = '<font color="\1">';
	//$builtHtml = preg_replace($patterns, $replacement, $builtHtml);
	$pattern = '/<FONT [^>]+ COLOR="([#a-fA-F0-9x]+)" [^>]+>/is';
	$replacement = '<font color="\1">';
	$builtHtml = preg_replace($pattern, $replacement, $builtHtml);
	echo $builtHtml;
*/
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Model.php");
$model = new Model();

$model->prepareQuestions();

echo $model->toString();
	
exit();

?>