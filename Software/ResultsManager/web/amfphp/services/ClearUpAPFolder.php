<?php
/*
 * This script will go through all folders under /ap/ and 'xx-' ones that are not linked to an active account
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();
session_start();

// Lets only run if you are logged on
if (!Authenticate::isAuthenticated()) {
	echo "<h2>You are not logged in</h2>";
	exit(0);
}

// Do a read of the database to get all active accounts into an array
$conditions = array();
$conditions['active'] = true;
$conditions['notLicenceType'] = 5;
$testingAccounts = null;
// Get the array of active accounts just once, then you can use it many times.
$accounts = $dmsService->accountOps->getAccounts($testingAccounts, $conditions);

// For reporting only
$takeAction = false;

// Get all folders under /ap/ for your current domain
$root = dirname(__FILE__)."/../../../../..";
$dir = $root."/ap/";

// Just for testing
//if (folderRelatedToAP("COPLAND")) {
//	echo "found COPLAND";
//} else {
//	echo "xxCOPLAND";
//}

// First, get rid of all folders that are not linked to an active AP account
keepActiveAccounts($dir);

// Or, for testing, go to specific accounts
//keepCoursesFolder($dir."Clarity/");
//keepActiveCourses($dir."Clarity/");

// Open a known directory, and proceed to read its contents
function keepActiveAccounts($dir) {
	global $takeAction;
	echo $dir."<br/>";
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			while (($file = readdir($dh)) !== false) {
				// It seems that, sometimes, this is not a static list, so if you rename it appears again.
				if (substr($file, 0, 1) != "." && substr($file, 0, 3) != "xx-") {
					if (is_dir($dir.$file)) {
						//echo "folder: $file, ";
						if (folderRelatedToAP($file)) {
							echo "Keep /ap/$file <br/>";
							// Then, for this good folder, get rid of any subfolders that are not /Courses
							keepCoursesFolder($dir.$file."/");
						} else {
							echo "Lets xx /ap/$file <br/>";
							if ($takeAction) 
								rename($dir.$file,$dir.'xx-'.$file);
						}
					} else {
						//echo "don't want file $file, ";
					}
				} else {
					//echo "don't go up to $file, ";
				}
			}
			closedir($dh);
		}
	} else {
		echo "Can't find ap folder: $dir";
	}
}

function keepCoursesFolder($dir) {
	global $takeAction;
	//echo $dir;
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			while (($file = readdir($dh)) !== false) {
				// It seems that, sometimes, this is not a static list, so if you rename it appears again.
				if (substr($file, 0, 1) != "." && substr($file, 0, 3) != "xx-") {
					// Check out all folder
					if (is_dir($dir.$file)) {
						// And only keep /Courses
						if ($file=='Courses') {
							echo "&nbsp;&nbsp;keep $file <br/>";
							// Now lets open course.xml and find out which courses are still active
							keepActiveCourses($dir);
						} else {
							echo "&nbsp;&nbsp;Lets xx $file <br/>";
							if ($takeAction) 
								rename($dir.$file, $dir.'xx-'.$file);
						}
					} else {
						// Keep all files (although maybe we should delete .zip files)
					}
				} else {
					//echo "don't touch $file<br/>;
				}
			}
			closedir($dh);
		}
	} else {
		echo "Can't find folder: $dir";
	}
}

// Open course.xml and then xx all folders in Courses that are not listed in course.xml
function keepActiveCourses($dir) {
	global $takeAction;
	//echo $dir."<br/>";
	// Read course.xml
	if (file_exists($dir."course.xml")) {
		$courseXML = file_get_contents($dir."course.xml");
		//echo $courseXML; return true;
	} else {
		echo "This folder has no course.xml";
		return false;
	}
	// Now go through all folders in /Courses and xx if they are not in course.xml
	$courseFolder = $dir."Courses/";
	if ($dh = opendir($courseFolder)) {
		while (($file = readdir($dh)) !== false) {
			// It seems that, sometimes, this is not a static list, so if you rename it appears again.
			if (substr($file, 0, 1) != "." && substr($file, 0, 3) != "xx-") {
				// Check out all folder
				if (is_dir($courseFolder.$file)) {
					// And only keep those listed in course.xml
					if (stripos($courseXML,'subFolder="'.$file.'"')!==false) {
						echo "&nbsp;&nbsp;&nbsp;&nbsp;keep course $file <br/>";
					} else {
						echo "&nbsp;&nbsp;&nbsp;&nbsp;Lets xx course $file <br/>";
						if ($takeAction) 
							rename($courseFolder.$file, $courseFolder.'xx-'.$file);
					}
				} else {
					// Keep all files (although maybe we should delete .zip files)
				}
			} else {
				//echo "don't touch $file<br/>";
			}
		}
		closedir($dh);
	} else {
		echo "Can't open $courseFolder";
	}
}


function folderRelatedToAP($folderName) {
	global $takeAction;
	global $accounts;
	// Lets keep an inclusion list for folders that are connected through &content in location files
	//$inclusionList = array('hsbcindia', 'tung', 'templates', 'templates_empty');
	$inclusionList = array('hsbcindia', 'templates', 'templates_empty');
	if (in_array(strtolower($folderName), $inclusionList)) return true;

	// and an exclusion list  - I know that we don't want to keep these
	$exclusionList = array('stangbo');
	if (in_array(strtolower($folderName), $exclusionList)) return false;
	
	if ($accounts) {
		// Does this folder exist in the T_Accounts.F_ContentLocation for any active account?
		foreach ($accounts as $account) {
			// Do some error checking for testing accounts that might be a bit odd, like not having any titles
			if (count($account->titles)<1) continue 1;
			foreach ($account->titles as $title) {
				if ($title-> productCode == 1) {
					//echo "$account->name has ap folder $title->contentLocation";
					// $title->contentLocation will look like this ../../ap/COPLAND
					if (stripos($title->contentLocation, $folderName)!==false) {
						return true; // Found this folder, so leave it alone
					}
				}
			}
		}
	} else {
		//echo "no active accounts found";
	}
	return false;
}

exit(0);
?>

