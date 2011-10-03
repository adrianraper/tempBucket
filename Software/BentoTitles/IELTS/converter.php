<?php

require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Model.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Settings.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Exercise.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Presentation.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/DragAndDrop.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Dropdown.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Gapfill.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/MultipleChoice.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Quiz.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/TargetSpotting.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ErrorCorrection.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Content.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Question.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Rubric.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Body.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/QbBody.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Feedbacks.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Feedback.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Text.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/NoScroll.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Paragraph.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/MediaNode.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Field.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/Answer.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/ConversionOps.php");

// If you want to see echo stmts, then use plainView
$plainView=false;
$batch=false;
if ($plainView) {
	header ('Content-Type: text/plain');
	$newline = "\n";
} else {
	$newline = "<br/>";
}

// This script will read an XML file (or all files in a folder)
// and create an xhtml file that is a conversion to new Baker and Bento format.

// Get the file
$contentFolder = '/../../../Content';
$titleFolder = '/RoadToIELTS-Academic';
$titleFolderOut = '/RoadToIELTS2-Academic';
$courseFolder = '/1150976390861';
$exerciseFolder = dirname(__FILE__).$contentFolder.$titleFolder.'/Courses'.$courseFolder.'/Exercises/';
$exerciseFolderOut = dirname(__FILE__).$contentFolder.$titleFolderOut.'/Courses'.$courseFolder.'/Exercises/';
$exerciseURL = $contentFolder.$titleFolderOut.'/Courses'.$courseFolder.'/Exercises/';
$outURL='';

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
	//$exerciseID = '1156153794055'; // presentation
	//$exerciseID = '1156153794170'; // drag and drop
	//$exerciseID = '1156155508240'; // gapfill
	//$exerciseID = '1156153794807'; // dropdown
	//$exerciseID = '1156153794223'; // multiple choice
	//$exerciseID = '1156153794534'; // q based drag and drop
	//$exerciseID = '1156153794851'; // target spotting with feedback
	//$exerciseID = '1156153794618'; // stopgap (q based gapfill)
	//$exerciseID = '1156153794077'; // quiz
	//$exerciseID = '1317260895296'; // correct mistakes (not R2I)
	$exerciseID = '1156153794672'; // split screen qbased gapfill with related text
	convertExercise($exerciseID);
}

function convertExercise($exerciseID) {
	global $exerciseFolder;
	global $exerciseFolderOut;
	global $exerciseURL;
	global $outURL;
	global $newline;
	global $plainView;
	//echo "checking on $exerciseID $newline";
	$infile = $exerciseFolder.$exerciseID.'.xml';
	$outfile = $exerciseFolderOut.$exerciseID.'.xml';
	
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
		case 'draganddrop':
			$exercise = new DragAndDrop($xml);
			break;
		case 'cloze':
		case 'stopgap':
			$exercise = new Gapfill($xml);
			break;
		case 'dropdown':
			$exercise = new Dropdown($xml);
			break;
		case 'multiplechoice':
			$exercise = new MultipleChoice($xml);
			break;
		case 'quiz':
			$exercise = new Quiz($xml);
			break;
		case 'targetspotting':
		case 'proofreading':
			$exercise = new TargetSpotting($xml);
			break;
		case 'errorcorrection':
			$exercise = new ErrorCorrection($xml);
			break;
		default;
			//throw new Exception("unknown exercise type $type");
			echo "unknown exercise type $type for $exerciseID ";
			return;
	}
	// At the end of construction, you can check the object if you want
	if ($plainView) echo $exercise->toString();
	
	// Then create an output function
	switch (strtolower($type)) {
		case 'presentation':
		case 'dragon':
		case 'draganddrop':
		case 'cloze':
		case 'dropdown':
		case 'targetspotting':
		default:
			$converter = New ConversionOps($exercise);
			$converter->setOutputFile($outfile);
			$rc = $converter->createOutput();
			$outURL = $exerciseURL.$exerciseID.'.xml';
			//echo " and writing out $outfile <br/>";
			break;
	}
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