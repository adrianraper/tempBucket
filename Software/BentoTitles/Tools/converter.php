<?php

require_once(dirname(__FILE__)."/vo/com/clarityenglish/Utils/UUID.php");
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
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelAnswer.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelFeedback.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelQuestion.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelDragQuestion.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelDropdownQuestion.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelTargetSpottingQuestion.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelGapfillQuestion.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelMultipleChoiceQuestion.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/vo/ModelErrorCorrectionQuestion.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/ConversionOps.php");
require_once(dirname(__FILE__)."/dindent/src/Indenter.php");

// Allow you to catch simple_xml errors
libxml_use_internal_errors(true);

// If you want to see echo stmts, then use plainView
$plainView=true;
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
$contentFolder = dirname(__FILE__).'/../../../../Contentbench/Content';
$titleFolder = $contentFolder.'/MyCanada';
$titleFolderOut = $contentFolder.'/../Couloir/MyCanada';

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
            //$pattern = '/([\d]+)/i';
            $pattern = '/1127356511328|1127357845125/i';
            //$pattern = '/one.xml/is';
            if (file_exists($menuFile) && preg_match($pattern, $menuFile, $matches)) {
                echo "processing course $courseFolder $newline";

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
                try {
                    $menuXML = simplexml_load_file($menuFile);
                } catch (Exception $e) {
                    echo "Couldn't parse xml in $menufile, so need to skip it.$newline";
                    continue;
                }
                // For each node in the menu, get the filename
                foreach ($menuXML->item as $unitNode) {
                    $exerciseFolderOut = $titleFolderOut . '/exercises/';
                    // Then loop for all exercises in that unit node
                    foreach ($unitNode->item as $exercise) {
                        $exerciseFile = $exercise['fileName'];
                        $fromFile = $exerciseFolder . $exerciseFile;
                        // Optional pattern matching on file name
                        $pattern = '/([\d]+).xml/i';
                        //$pattern = '/1127386318094|1127386318144/i';
                        //$pattern = '/one.xml/is';
                        if (file_exists($fromFile) && preg_match($pattern, $exerciseFile, $matches)) {
                            $toFile = $exerciseFolderOut . $exerciseFile;
                            // Change file type of output
                            $toFile = str_replace('.xml', '.html', $toFile);
                            convertExercise($fromFile, $toFile);
                        }
                    }
                }
            }
		}
	}
	// In batch mode you have no interest in viewing an html rendering of the xml
	exit(0);
	
} else {
	// or just a specific one
	$courseFolder = '1151344537052';
	//$skillFolder = "writing";
	//$skillFolder = "speaking";
	//$skillFolder = "reading";
	$skillFolder = "listening";
	$exerciseFolder = $titleFolder.'/Courses/'.$courseFolder.'/Exercises/';
	$exerciseFolderOut = $titleFolderOut.'/'.$skillFolder.'/exercises/';
	$exerciseURL = '/Content/RoadToIELTS2-General/'.$skillFolder.'/exercises/';
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
	//$exerciseID = '1156153794384'; // For testing customised=true
	//$exerciseID = '1156153794430'; // missing reading text
	//$exerciseID = '1151344172816'; // missing main content
	$exerciseID = '1151344537628'; // warning from GT conversion
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
	global $exerciseID;
	global $newline;
	global $plainView;
	//echo "checking on $exerciseID $newline";
	//$infile = $exerciseFolder.$exerciseID.'.xml';
	//$outfile = $exerciseFolderOut.$exerciseID.'.xml';

	if (!file_exists($infile)){
	    echo "Skip $infile as it doesn't exist! $newline";
	    return;
	}
	    
	// Before you spend any time running the conversion, check if the output already exists
	// If it does, see if it has a meta tag for customised=true - in which case leave it alone.
	if (file_exists($outfile) && filesize($outfile)>0) {
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
	}
	$shortFilename = substr($infile, strripos($infile, '/')+1);
	echo "Convert $shortFilename $newline";
	// Load the contents into an XML structure
	try {
		$xml = simplexml_load_file($infile);
		// Confirm that this is an Author Plus file - and see what type
		if (!$xml)
			throw new Exception("Can't read the xml, check the tags");
		if ($xml->getName()=='exercise') {
			$attr = $xml->attributes();
			$type = $attr['type'];
			// To quickly count how many countdown exercises, just skip everything else
			//if ($attr['type'] != "Countdown")
			//    return false;
			echo 'type='.$attr['type']. "$newline";	
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
	//echo "It is a $type"; return;
	switch (strtolower($type)) {
		case 'presentation':
        case 'bullet':
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
        case 'stopdrop':
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
        case 'questionspotter':
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
	//if ($plainView) echo $exercise->toString();
	
	// Then create an output function
    $converter = New ConversionOps($exercise);
    $converter->setOutputFile($outfile);
    $rc = $converter->createOutput();
    //$outURL = $exerciseURL.$exerciseID.'.xml';
    echo " and writing out $outfile $newline";
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