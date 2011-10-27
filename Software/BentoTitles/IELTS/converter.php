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
$batch=true;
if ($plainView) {
	header ('Content-Type: text/plain');
	$newline = "\n";
} else {
	$newline = "<br/>";
}

// This script will read an XML file (or all files in a folder)
// and create an xhtml file that is a conversion to new Baker and Bento format.
// For each node in the menu.xml it will work out which skill the exercise is in
// and output to the new folder structure.

// Get the file
$contentFolder = dirname(__FILE__).'/../../../Content';
$titleFolder = $contentFolder.'/RoadToIELTS-Academic';
//$titleFolderOut = $contentFolder.'/RoadToIELTS2-Academic';
$titleFolderOut = $contentFolder.'/IELTS-Joe';

// Add an extra loop to do all folders at once
$topFolder = $titleFolder.'/Courses';
// Either read all the files in a folder
if ($batch && $handle1 = opendir($topFolder)) {
	
	while (false !== ($folder = readdir($handle1))) {
		if (stristr($folder,'.')===FALSE) {
			$courseFolder = $folder;
			$exerciseFolder = $titleFolder.'/Courses/'.$courseFolder.'/Exercises/';
			//$exerciseFolderOut = $titleFolderOut.'/Courses/'.$courseFolder.'/Exercises/';
			//$exerciseURL = $contentFolder.$titleFolderOut.'/Courses/'.$courseFolder.'/Exercises/';
			//$outURL='';
			//echo "processing $courseFolder $newline";
			$menuFile = $titleFolder.'/Courses/'.$courseFolder.'/menu.xml';
			echo "processing $menuFile $newline";
			
			/*
			 * Merge this file with moveBySkill. So read the menu.xml here instead of the directory.
			 * Then for each file, convert it and write out accordingly.
			 *
			if ($handle = opendir($exerciseFolder)) {
				while (false !== ($file = readdir($handle))) {
					//$exerciseID = substr($file,0,strpos($file,'.xml'));
					// Only pick up files with just numbers, especially ignore *-new.xml
					$pattern = '/^([\d]+).xml/is';
					if (preg_match($pattern, $file, $matches)) {
						//echo $exerciseFolder.$file."$newline";
						convertExercise($matches[1]);
					}
			*/
			$menuXML = simplexml_load_file($menuFile);
			
			// For each node in the menu, get the skill and the filename
			foreach ($menuXML->item as $unitNode) {
				// Convert the caption to a skill
				switch ((string) $unitNode['caption']) {
					case 'Writing 1':
					case 'Writing 2':
						$skillFolder = "writing";
						break;
					case 'Listening':
					case 'Speaking':
					case 'Reading':
						$skillFolder = strtolower((string) $unitNode['caption']);
						break;
						
					default:
						// We don't want any exercises from other units, so jump to the next unit node
						continue(2);
						break;
				}
				$exerciseFolderOut = $titleFolderOut.'/'.$skillFolder.'/exercises/';
				// Then loop for all exercises in that unit node
				foreach ($unitNode->item as $exercise) {
					// But we don't want listening and reading introductions
					if ($skillFolder=='listening' || $skillFolder=='reading') {
						if ((string) $exercise['caption']=='Introduction')
							continue(1);
					} 
					// Finally, copy the file
					
					$exerciseFile = $exercise['fileName'];
					$fromFile = $exerciseFolder.$exerciseFile;
					$toFile = $exerciseFolderOut.$exerciseFile;
					convertExercise($fromFile, $toFile);
					/*if (!copy($fromFile, $toFile)) {
						echo "failed to copy $fromFile $newline";
					} else {
						echo "copied file to ".$toFile."$newline";
					}*/
				}
			}
		}
	}
	// In batch mode you have no interest in viewing an html rendering of the xml
	exit(0);
	
} else {
	// or just a specific one
	$courseFolder = '1150976390861';
	$skillFolder = "writing";
	$skillFolder = "speaking";
	$skillFolder = "reading";
	$skillFolder = "listening";
	$exerciseFolder = $titleFolder.'/Courses/'.$courseFolder.'/Exercises/';
	$exerciseFolderOut = $titleFolderOut.'/'.$skillFolder.'/exercises/';
	$exerciseURL = '/Content/IELTS-Joe/'.$skillFolder.'/exercises/';
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
	//$exerciseID = '1156153794672'; // split screen qbased gapfill with related text
	//$exerciseID = '1156153794672'; // Stopgap with splitscreen
	$exerciseID = '1156153794384'; // For testing customised=true
	$fromFile = $exerciseFolder.$exerciseID.'.xml';
	$toFile = $exerciseFolderOut.$exerciseID.'.xml';
	convertExercise($fromFile, $toFile);
	$outURL = $exerciseURL.$exerciseID.'.xml';
}


// Pass a from file and a to file - full names
//function convertExercise($exerciseID) {
function convertExercise($infile, $outfile) {
//	global $exerciseFolder;
//	global $exerciseFolderOut;
//	global $exerciseURL;
//	global $outURL;
	global $newline;
	global $plainView;
	//echo "checking on $exerciseID $newline";
	//$infile = $exerciseFolder.$exerciseID.'.xml';
	//$outfile = $exerciseFolderOut.$exerciseID.'.xml';

	// Before you spend any time running the conversion, check if the output already exists
	// If it does, see if it has a meta tag for customised=true - in which case leave it alone.
	try {
		$existingXml = simplexml_load_file($outfile);
		// If we can read it, does it have a meta tag?
		//echo "$outfile exists already...$newline";
		if ($existingXml) {
			//var_dump($existingXml->head->meta); exit();
			// Note that this is a neat way to do it with xpath. But if the XML has the following namespace 
			// <bento xmlns="http://www.w3.org/1999/xhtml">
			// xpath stops working. So until we know that we can drop that NS, do it with arrays and foreach
			//if ($existingXml->xpath('//meta[@name="customised" and @content="true"]')) {
			foreach ($existingXml->head->meta as $metaTag) {
				//echo (string) $metaTag['content'];
				if ((string) $metaTag['name']=='customised' && (string) $metaTag['content']=='true') {
					echo "Skip $outfile as it has been customised $newline";
					return;
				}
			}
		}
		
	} catch (Exception $e) {
		echo "Couldn't read $outfile, but no problem!$newline";
		// Do nothing - not being able to read the file means we will just overwrite/create it
	}
	//echo "Convert $infile to $outfile $newline"; return;
	// Load the contents into an XML structure
	try {
		$xml = simplexml_load_file($infile);
		// Confirm that this is an Author Plus file - and see what type
		if (!$xml)
			throw new Exception("Can't read the xml, check the tags");
		if ($xml->getName()=='exercise') {
			$attr = $xml->attributes();
			$type = $attr['type'];
			//echo 'type='.$attr['type']. "$newline";	
		}
	} catch (Exception $e) {
		//var_dump($e);
		echo "Had to skip file $infile as xml problems $newline";
		return false;
	}
	// Do you want to only convert certain file types?
//	if (strtolower($type)!='dropdown')
//	if (strtolower($type)!='cloze')
//		return;
	
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
		case 'analyze':
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
			echo "unknown exercise type $type for $exerciseID $newline";
			return;
	}
	// At the end of construction, you can check the object if you want
	if ($plainView) echo $exercise->toString();
	
	// Then create an output function
//	switch (strtolower($type)) {
//		case 'presentation':
//		case 'dragon':
//		case 'draganddrop':
//		case 'cloze':
//		case 'dropdown':
//		case 'targetspotting':
//		default:
			$converter = New ConversionOps($exercise);
			$converter->setOutputFile($outfile);
			$rc = $converter->createOutput();
			//$outURL = $exerciseURL.$exerciseID.'.xml';
			//echo " and writing out $outfile $newline";
//			break;
//	}
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