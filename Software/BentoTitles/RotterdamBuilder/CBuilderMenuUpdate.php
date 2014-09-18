<?php

//require_once(dirname(__FILE__)."/vo/com/clarityenglish/conversion/ConversionOps.php");

// If you want to see echo stmts, then use plainView
$plainView=false;
if ($plainView) {
	header ('Content-Type: text/plain');
	$newline = "\n";
} else {
	$newline = "<br/>";
}

// This script will read all menu.xml files 
// For each it will run through a set of find/replace on the xml.
// It will make a backup of the original and save the new one.

// Get the files
$topFolder = dirname(__FILE__).'/../../../../ContentBench/CCB';
$filePattern = 'menu.xml';

if ($handle1 = opendir($topFolder)) {
	while (false !== ($folder = readdir($handle1))) {
		// find each account folder
		// && stristr($folder,'ACL')!==FALSE 
		if (stristr($folder,'.')===FALSE && stristr($folder,'ACL')!==FALSE && stristr($folder,'xx-')===FALSE && is_dir($topFolder.'/'.$folder)) { 
			if ($handle2 = opendir($topFolder.'/'.$folder)) {
				while (false !== ($courseFolder = readdir($handle2))) {
					// open the course folders (must start with a number)
					if (stristr('0123456789', substr($courseFolder, 0, 1))) {
						$menuFile = $topFolder.'/'.$folder.'/'.$courseFolder.'/menu.xml';
						if (file_exists($menuFile)) {
							
							// quick search for any tense buster links
							$contents = file_get_contents($menuFile);
							$contentuid = 'contentuid="9.11';
							if (stripos($contents, $contentuid)!==FALSE) {
								echo "tb link in $menuFile$newline";
							
								// make a backup of the file
								copy($menuFile, $topFolder.'/'.$folder.'/'.$courseFolder.'/menu_backup.xml');
								
								// run through an array of search and replace pairs
								// NOTE: if there is a chance that some of the new units IDs are already used, then reverse
								// this replace first to ensure everything is old style.
								$oldElementary = array("9.1189057932446.1",
														"9.1189057932446.2",
														"9.1189057932446.3",
														"9.1189057932446.4",
														"9.1189057932446.5",
														"9.1189057932446.6",
														"9.1189057932446.7",
														"9.1189057932446.8",
														"9.1189057932446.9",
														);
								$newElementary = array("9.1189057932446.1192013076011",
														"9.1189057932446.1192013076442",
														"9.1189057932446.1192013076627",
														"9.1189057932446.1192013076075",
														"9.1189057932446.1192013076406",
														"9.1189057932446.1192013076321",
														"9.1189057932446.1192013076042",
														"9.1189057932446.1192013076921",
														"9.1189057932446.1192013076844",
														);
								$contents = str_replace($oldElementary, $newElementary, $contents);
								
								$oldLowerint = array("9.1189060123431.1",
														"9.1189060123431.2",
														"9.1189060123431.3",
														"9.1189060123431.4",
														"9.1189060123431.5",
														"9.1189060123431.7",
														);
								$newLowerint = array("9.1189060123431.1192625080036",
														"9.1189060123431.1192625080950",
														"9.1189060123431.1192625080536",
														"9.1189060123431.1192625080479",
														"9.1189060123431.1192625080483",
														"9.1189060123431.1192625080519",
														);
								$contents = str_replace($oldLowerint, $newLowerint, $contents);
								
								$oldInt = array("9.1195467488046.1",
														"9.1195467488046.2",
														"9.1195467488046.3",
														"9.1195467488046.4",
														"9.1195467488046.5",
														"9.1195467488046.6",
														);
								$newInt = array("9.1195467488046.1195467532328",
														"9.1195467488046.1195467532329",
														"9.1195467488046.1195467532330",
														"9.1195467488046.1195467532331",
														"9.1195467488046.1195467532343",
														"9.1195467488046.1192625080157",
														);
								$contents = str_replace($oldInt, $newInt, $contents);
								
								$oldUpperint = array("9.1190277377521.1",
														"9.1190277377521.2",
														"9.1190277377521.3",
														"9.1190277377521.4",
														"9.1190277377521.7",
														"9.1190277377521.6",
														);
								$newUpperint = array("9.1190277377521.1192625319573",
														"9.1190277377521.1192625319203",
														"9.1190277377521.1192625319744",
														"9.1190277377521.1192625319263",
														"9.1190277377521.1193054443818",
														"9.1190277377521.1192625319990",
														);
								$contents = str_replace($oldUpperint, $newUpperint, $contents);
								
								$oldAdvanced = array("9.1196935701119.1",
														"9.1196935701119.2",
														"9.1196935701119.3",
														"9.1196935701119.4",
														"9.1196935701119.5",
														"9.1196935701119.6",
														);
								$newAdvanced = array("9.1196935701119.1196204720339",
														"9.1196935701119.1196216926895",
														"9.1196935701119.1196293510373",
														"9.1196935701119.1196301393947",
														"9.1196935701119.1196641272970",
														"9.1196935701119.1196649107233",
														);
								$contents = str_replace($oldAdvanced, $newAdvanced, $contents);
								
								// finally globally change product code
								$oldProductCode = 'contentuid="9.11';
								$newProductCode = 'contentuid="55.11';
								$contents = str_replace($oldProductCode, $newProductCode, $contents);
														
								// save and close
								file_put_contents($menuFile, $contents);
							}
						}
					}
				}
			}
			closedir($handle2);			
		}
	}
}
closedir($handle1);

exit();
