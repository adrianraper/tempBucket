<?php

// If you want to see echo stmts, then use plainView
$plainView=false;
if ($plainView) {
	header ('Content-Type: text/plain');
	$newline = "\n";
} else {
	$newline = "<br/>";
}

// This script will read all folders and get the menu.xml files.
// For each node in the menu.xml it will work out which skill the exercise is in
// and make a copy of that from the original to the new folder structure.

// Get the file
$originalFolder = dirname(__FILE__).'/../../../Content/RoadToIELTS2-Academic/Courses';
$newFolder = dirname(__FILE__).'/../../../Content/IELTS-Joe';

// Read all the files in the top folder
if ($handle = opendir($originalFolder)) {
	
	while (false !== ($folder = readdir($handle))) {
		if (stristr($folder,'.')===FALSE) {
			$courseFolder = $folder;
			
			$menuFile = $originalFolder.'/'.$courseFolder.'/menu.xml';
			$exerciseFolder = $originalFolder.'/'.$courseFolder.'/Exercises/';
			echo "processing $menuFile $newline";
			$menuXML = simplexml_load_file($menuFile);
			
			// For each node in the menu, get the skill and the filename
			foreach ($menuXML->item as $unitNode) {
				// Convert the caption to a skill
				switch ($unitNode['caption']) {
					case 'Writing 1':
					case 'Writing 2':
						$skillFolder = "writing";
						break;
					case 'Listening':
					case 'Speaking':
					case 'Reading':
						$skillFolder = strtolower($unitNode['caption']);
						break;
						
					default:
						// We don't want any exercises from other units, so jump to the next unit node
						continue(2);
						break;
				}
				$exerciseFolderOut = $newFolder.'/'.$skillFolder.'/exercises/';
				// Then loop for all exercises in that unit node
				foreach ($unitNode->item as $exercise) {
					// But we don't want listening and reading introductions
					if ($skillFolder=='listening' || $skillFolder=='reading') {
						if ($exercise['caption']=='Introduction')
							continue(1);
					} 
					// Finally, copy the file
					$exerciseFile = $exercise['fileName'];
					$fromFile = $exerciseFolder.$exerciseFile;
					$toFile = $exerciseFolderOut.$exerciseFile;
					if (!copy($fromFile, $toFile)) {
						echo "failed to copy $fromFile $newline";
					} else {
						echo "copied file to ".$toFile."$newline";
					}
				}
			}
			
			
		}			
	}
}

exit();
?>