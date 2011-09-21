<?php

require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Model.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Settings.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Exercise.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Presentation.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/DragAndDrop.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Content.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Rubric.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Body.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/NoScroll.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Paragraph.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/MediaNode.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Field.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Answer.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/ConversionOps.php");

// If you want to see good echo stmts, then use this
$plainView=true;
$batch=false;
if ($plainView) {
	header ('Content-Type: text/plain');
	$newline = "\n";
} else {
	$newline = "<br/>";
}

// This script will read an XML file (or all files in a folder later on)
// and create an xhtml file that is a conversion to new Baker and Bento format.

// Get the file
$contentFolder = '/../../../Content';
$titleFolder = '/RoadToIELTS-Academic';
$courseFolder = '/1150976390861';
$exerciseFolder = dirname(__FILE__).$contentFolder.$titleFolder.'/Courses'.$courseFolder.'/Exercises/';
$exerciseURL = $contentFolder.$titleFolder.'/Courses'.$courseFolder.'/Exercises/';
$outURL='';

function convertExercise($exerciseID) {
	global $exerciseFolder;
	global $exerciseURL;
	global $outURL;
	global $newline;
	//echo "checking on $exerciseID $newline";
	$infile = $exerciseFolder.$exerciseID.'.xml';
	$outfile = $exerciseFolder.$exerciseID.'-new.xml';
	
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
	switch (strtolower($type)) {
		case 'presentation':
			$exercise = new Presentation($xml);
			break;
		case 'dragon':
			$exercise = new DragAndDrop($xml);
			break;
			//echo $exercise->getRubric();
	}
	// At the end of construction, you can check the object if you want
	//echo $exercise->toString();
	
	// Then create an output function
	switch (strtolower($type)) {
		case 'presentation':
		case 'dragon':
			$converter = New ConversionOps($exercise);
			$converter->setOutputFile($outfile);
			$rc = $converter->createOutput();
			$outURL = $exerciseURL.$exerciseID.'-new.xml';
			//echo " and writing out $outfile <br/>";
			break;
	}
}
// Either read all the files in a folder
if ($batch && $handle = opendir($exerciseFolder)) {
	
	while (false !== ($file = readdir($handle))) {
		//$exerciseID = substr($file,0,strpos($file,'.xml'));
		// Only pick up files with just numbers, especially ignore *-new.xml
		$pattern = '/^([\d]+).xml/is';
		if (preg_match($pattern, $file, $matches)) {
			convertExercise($matches[1]);
		}
	}
} else {
	// or just a specific one
	//$exerciseID = '1156153794194';
	//$exerciseID = '1156153794055';
	$exerciseID = '1156153794170';
	convertExercise($exerciseID);
}

// It might help to display the output file in the browser (or the last of many)
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