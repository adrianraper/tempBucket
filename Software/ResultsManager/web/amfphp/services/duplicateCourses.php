<?php
/*
 * This script will go through all folders in CCB and xx orphaned ones and point out duplicates
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();

// Do a read of the database to get all active accounts into an array
$conditions = array();
$conditions['active'] = true;
$conditions['notLicenceType'] = 5;
$conditions['productCode'] = 54;
$testingAccounts = null;
// Get the array of active accounts just once, then you can use it many times.
$accounts = $dmsService->accountOps->getAccounts($testingAccounts, $conditions);

// For reporting only
$takeAction = true;
if (!$takeAction)
	echo "just reporting, no action taken<br/>";

// First, xx all folders that are not linked to an active C-Builder account
$dir = '../../'.$GLOBALS['ccb_data_dir'].'/';
renameOrphanedFolders($dir);

// Then go through each remaining folder and check that there are no course IDs that exist in other folders
highlightDuplicateCourseIds($dir);

function highlightDuplicateCourseIds($dir) {
	global $takeAction;
	global $accounts;
	echo $dir."<br/>";
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			while (($file = readdir($dh)) !== false) {
				// It seems that, sometimes, this is not a static list, so if you rename it appears again.
				if (substr($file, 0, 1) != "." && substr($file, 0, 3) != "xx-") {
					if (is_dir($dir.$file)) {
						echo "folder: $file <br/>";
						// Read courses.xml
						try {
							$xml = simplexml_load_file($dir.$file."/courses.xml");
							if (!$xml)
								throw new Exception("Failed to load $file /courses.xml");
								
							$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
							$courses = $xml->xpath("//xmlns:course");
							foreach ($courses as $course) {
								$href = $course['href'];
								
								// Can you open the menu.xml for this course?
								try {
									$href = $course['href'];
									$menuXml = simplexml_load_file($dir.$file."/".$href);
									if (!$menuXml)
										throw new Exception("Failed to load $href");
								} catch (Exception $e) {
									echo "&nbsp;&nbsp;".$e->getMessage()."<br/>";
								}
								
								// Does this href exist in any other folder?
								if ($idh = opendir($dir)) {
									while (($otherFolder = readdir($idh)) !== false) {
										if (substr($otherFolder, 0, 1) != "." && 
											substr($otherFolder, 0, 3) != "xx-" &&
											$otherFolder != $file) {
											if (is_dir($dir.$otherFolder)) {
												//echo "&nbsp;&nbsp;checking for $href in: $otherFolder <br/>";
												$menuXml = simplexml_load_file($dir.$otherFolder."/".$href);
												if ($menuXml)
													echo "&nbsp;&nbsp;Found duplicate for $file $href in $otherFolder <br/>";
											}
										}
									}
								}
							}
						} catch (Exception $e) {
							echo "&nbsp;&nbsp;".$e->getMessage()."<br/>";
						}
					}
				}
			}
		}
	}
}

function renameOrphanedFolders($dir) {
	global $takeAction;
	global $accounts;
	//echo $dir."<br/>";
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			while (($file = readdir($dh)) !== false) {
				// It seems that, sometimes, this is not a static list, so if you rename it appears again.
				if (substr($file, 0, 1) != "." && substr($file, 0, 3) != "xx-") {
					if (is_dir($dir.$file)) {
						//echo "folder: $file <br/>";
						foreach ($accounts as $account) {
							foreach ($account->titles as $title) {
								if ($title->productCode == 54)
									if ($title->dbContentLocation == $file)
										continue 3;
							}
						}
						// We didn't find this folder listed in the accounts
						if ($takeAction) 
							rename($dir.$file,$dir.'xx-'.$file);
						echo "renamed to xx-$file <br/>";
					}
				}
			}
			closedir($dh);
		}
	} else {
		echo "Can't find folder: $dir";
	}
}

exit(0);
