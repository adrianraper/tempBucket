<?php

require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Settings.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Exercise.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Presentation.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Content.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Rubric.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Body.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/NoScroll.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Paragraph.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/MediaNode.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/ConversionOps.php");

// If you want to see good echo stmts, then use this
//header ('Content-Type: text/plain');

// This script will read an XML file (or all files in a folder later on)
// and create an html file that is a conversion to new Baker and Bento format.

// Get the file
$contentFolder = '/../../../Content';
$titleFolder = '/RoadToIELTS-Academic';
$courseFolder = '/1150976390861';
$exerciseFolder = dirname(__FILE__).$contentFolder.$titleFolder.'/Courses'.$courseFolder.'/Exercises/';
$exerciseURL = $contentFolder.$titleFolder.'/Courses'.$courseFolder.'/Exercises/';
$exerciseID = '1156153794194';
$exerciseID = '1156153794055';
$infile = $exerciseFolder.$exerciseID.'.xml';
$outfile = $exerciseFolder.$exerciseID.'.xhtml';
$outURL = $exerciseURL.$exerciseID.'.xhtml';

// Load the contents into an XML structure
$xml = simplexml_load_file($infile);

// Confirm that this is an Author Plus file - and see what type
if ($xml->getName()=='exercise') {
	$attr = $xml->attributes();
	$type = $attr['type'];
	//echo 'type='.$attr['type']. "<br />";	
}
// Create an internal exercise to hold the data. 
// Will we need different classes for different types?
if ($type=='Presentation') {
	$exercise = new Presentation($xml);
	//echo $exercise->getRubric();
}
// Then create an output function
if ($type=='Presentation') {
	$converter = New ConversionOps($exercise);
	$converter->setOutputFile($outfile);
	$rc = $converter->createOutput();
}
// It might help to display the output file in the browser
//echo $outURL;
// This is fine, except that it means I lose my URL in the bar so replaying it is not so easy
//header('Location: '.$outURL);
echo <<< EOD
<html>
<head>
<script type="text/javascript">
window.open('$outURL');
</script>
</head>
<body />
EOD;
exit();

?>