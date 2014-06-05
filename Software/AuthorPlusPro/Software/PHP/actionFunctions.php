<?php
require_once("ss_zip.class.php");
include_once("getRootDir.php");
require_once("functions.php");
require_once("clarityUniqueID.php");
// v6.5.4.2 A new ZIP class to correct the fact that a ZIP made with ss_zip can't be read by Blackboard
require_once("pclzip.lib.php");

function getLockingUser($path, $user) {
	$lockingUser = "";
	
	if ($fp = @fopen($path, "rb")) {	// we can open the file (ignore if we can't)
		// read the content
		$content = @fread($fp, filesize($path));
		
		// parse xml
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		if ( xml_parse_into_struct($xml, $content, $vals, $index) ) {
			foreach ($vals as $key => $val) {
				if ($val['type']=="complete") {
					if ($val['tag']=="user") {
						// we need to get a locking username which is not the current user
						if (strtoupper($val['value'])!=strtoupper($user) && $lockingUser=="") {
							// only consider the lock less than 1 hour
							$diff = getTimeStamp() - $vals[$key+1]['value'];
							if ($diff < 6000) {
								$lockingUser = $val['value'];
							}
						}
					}
				}
			}
		}
		xml_parser_free($xml);
		
		// close file
		@fclose($fp);
	}
	
	unset($fp);
	
	return $lockingUser;
}

function getLocks($path, $user) {
	$locks = "";
	$thisUserLocking = False;
	
	if ($fp = @fopen($path, "rb")) {	// we can open the file (ignore if we can't)
		// read the content
		$content = @fread($fp, filesize($path));
		
		// parse xml
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		if ( xml_parse_into_struct($xml, $content, $vals, $index) ) {
			foreach ($vals as $val) {
				if ($val['tag']=="lock" && $val['type']=="open") {
					$lck = "<lock>";
				} else if ($val['type']=="complete") {
					// v6.5.4.3 ACL saving, avoid php notices
					if (isset($val['value'])) {
						$valueText = $val['value'];
					} else {
						$valueText = '';
					}
					$lck .= "<".$val['tag'].">".$valueText."</".$val['tag'].">";
					if ($val['tag']=="user" && strtoupper($val['value'])==strtoupper($user)) {
						$thisUserLocking = True;
					}
				} else if ($val['tag']=="lock" && $val['type']=="close") {
					$lck .= "</lock>";
					if (!$thisUserLocking) {
						$locks .= $lck;
					}
					$lck = "";
					$thisUserLocking = False;
				}
			}
		}
		xml_parser_free($xml);
		
		// close file
		@fclose($fp);
	}
	
	unset($fp);
	
	return $locks;
}
function lockFile( &$Query, &$node ) {
	// get lck file path
	global $rootDir;
	$path = $Query["FILEPATH"];
	// v6.4.2.6 include the user data path to help getRootDir
	$udp = $Query["USERDATAPATH"];
	$path = getFullFileName($path, $udp);
	//$path = $rootDir . substr($path, 0, strlen($path)-3) . "lck";
	$path = substr_replace($path,"lck",-3);
	
	// create a lock node for this user
	$user = $Query["USERNAME"];
	$ts = getTimeStamp();
	$ac = $Query["ACCOUNT"];
	$thisUserLck = "<lock><user>$user</user><time>$ts</time><account>$ac</account></lock>";
	$locks = "<locks>";
	
	// if lck file exists, open it
	if (file_exists($path)) {
		$locks .= getLocks($path, $user);
	}

	// open the file with write permission, write the locks out
	if ($fp = @fopen($path, "wb")) {
		//$node .= "<note open='true' lock='$user' />";
		// add this user's lock
		$locks .= $thisUserLck . "</locks>";
		// write the locks out
		@fputs($fp, $locks);
		@fclose($fp);
		// return action success message
		$node .= "<action success='true' file='" .$path ."'/>";
	} else {
		// v6.4.2.6 return action fail message
		$permissions = decoct(fileperms($path) & 0777);
		$node .= "<action success='fail' permissions='".$permissions."' file='" .$path ."'/>";
	}	
	unset($fp);
	return 0;
}

function checkLockCourse( &$Query, &$node ) {
	// get lck file path
	global $rootDir;
	$path = $Query["FILEPATH"];
	// v6.4.2.6 include the user data path to help getRootDir
	$udp = $Query["USERDATAPATH"];
	$path = getFullFileName($path, $udp);
	//$path = getFullFileName($path);
	
	//$path = $rootDir . substr($path, 0, strlen($path)-3) . "lck";
	$path = substr_replace($path,"lck",-3);
	//$path = $rootDir . substr($path, 0, strlen($path)-3) . "lck";
	$folderPath = getFolderPath($path) . "Exercises";
	
	// variables
	$lockingUser = "";
	
	// check if lck file exists for the menu xml
	if (file_exists($path)) {
		$lockingUser = getLockingUser($path, $user);
	}
	
	// if no locking user, we've to search exercise by exercise
	if ($lockingUser=="") {
		if (file_exists($folderPath)) {
			if ($handle = opendir($folderPath)) {
				while (false !== ($file = readdir($handle))) {
					if (substr($file,-4,4)==".lck" && $lockingUser=="") {
						$filePath = $folderPath."/".$file;
						$tmp = getLockingUser($filePath, $user);
						if ($tmp!="") {
							$lockingUser = $tmp;
						}
					}
				}
				closedir($handle);
			}
		}
	}
	
	unset($fp);
	
	// return result
	if ($lockingUser!="") {
		$node .= "<action success='false' lockingUser='$lockingUser' />";
	} else {
		$node .= "<action success='true' />";
	}
	
	return 0;
}

function checkLockFile( &$Query, &$node ) {
	// get lck file path
	global $rootDir;
	$path = $Query["FILEPATH"];
	// v6.4.2.6 include the user data path to help getRootDir
	$udp = $Query["USERDATAPATH"];
	$path = getFullFileName($path, $udp);
	//$path = getFullFileName($path);
	$path = substr_replace($path,"lck",-3);
	//$path = $rootDir . substr($path, 0, strlen($path)-3) . "lck";
	
	// get username
	$user = $Query["USERNAME"];
	
	// variables
	$lockingUser = "";
	
	// check if lck file exists
	if (file_exists($path)) {
		$lockingUser = getLockingUser($path, $user);
		
		if ($lockingUser!="") {
			$node .= "<action success='false' lockingUser='$lockingUser' />";
		} else {
			$node .= "<action success='true' />";
		}
		
	// lck file does not exists, so the file is not locked
	} else {
		$node .= "<action success='true' />";
	}
	
	return 0;
}

function releaseFile( &$Query, &$node ) {
	// get lck file path
	global $rootDir;
	$path = $Query["FILEPATH"];
	// v6.4.2.6 include the user data path to help getRootDir
	$udp = $Query["USERDATAPATH"];
	$path = getFullFileName($path, $udp);
	//$path = getFullFileName($path);
	$path = substr_replace($path,"lck",-3);
	//$path = $rootDir . substr($path, 0, strlen($path)-3) . "lck";
	
	// get username
	$user = $Query["USERNAME"];
	
	// if lck file exists, open it
	if (file_exists($path)) {
		$locks = getLocks($path, $user);
	} else {
		$locks = "";
	}
	
	// if there're locks, write them out to the lck file
	if (strlen($locks)>0) {
		// open the file with write permission, write the locks out
		if ($fp = @fopen($path, "wb")) {
			// add this user's lock
			$locks = "<locks>" . $locks . "</locks>";
			// write the locks out
			@fputs($fp, $locks);
			@fclose($fp);
		}
		
	// if there're no locks, delete the lck file
	} else {
		if (file_exists($path)) {
			@unlink($path);
		}
	}
	
	unset($fp);
	
	// return action success message
	$node .= "<action success='true' />";
	
	return 0;
}

function sendEmail( &$Query, &$node ) {
	$sender = $Query["SENDER"];
	$email = $Query["EMAIL"];
	$subject = $Query["SUBJECT"];
	$body = $Query["BODY"];
	
	$to = "comments@clarityenglish.com";
	$from = $sender."<".$email.">";
	$headers = "From: {$from}\r\nReply-To: {$from}\r\nX-Mailer: PHP/" . phpversion();
	
	$success = mail( $to, $subject, $body, $headers );
	
	if ($success) {
		$node .= "<action success='true' />";
	} else {
		$node .= "<action success='false' />";
	}
	
	return 0;
}

function setSessionVariables( &$Query, &$node ) {
	// always test to start a session before setting/getting session variables
	if (session_id()=="") {
		session_start();
	}
	
	$_SESSION['s_username'] = $Query["USERNAME"];
	$_SESSION['s_password'] = $Query["PASSWORD"];
	$_SESSION['s_contentPath'] = $Query["CONTENTPATH"];
	$node .= "<action success='true' un='".$_SESSION['s_username']."' pwd='".$_SESSION['s_password']."' content='".$_SESSION['s_contentPath']."' />";
	
	return 0;
}

function setUploadLocation( &$Query, &$node ) {
	// check if the upload path exists, if not, create it
	if ($Query["UPLOADPATH"]!="") {
		//global $rootDir;
		$path = $Query["UPLOADPATH"];
		//$dir = $rootDir . $path;
		// v6.4.2.6 include the user data path to help getRootDir
		$udp = $Query["USERDATAPATH"];
		$dir = getFullFileName($path, $udp);
		//$dir = getFullFileName($path);
		
		if (!file_exists($dir)) {
			mkdir($dir, 0777);
		}
		@chmod($dir, 0777);
	}
	
	// always test to start a session before setting/getting session variables
	if (session_id()=="") {
		session_start();
	}
	
	// set session variable for showing upload form
	// AR v6.4.2.5 relative paths
	//$_SESSION['s_uploadPath'] = $Query["UPLOADPATH"];
	$_SESSION['s_uploadPath'] = $dir;
	
	$node .= "<action success='true' path='{$_SESSION['s_uploadPath']}' />";
	
	return 0;
}

function setUploadForm( &$Query, &$node ) {
	// always test to start a session before setting/getting session variables
	if (session_id()=="") {
		session_start();
	}
	
	switch ($Query["UPLOADTYPE"]) {
	case "image" :
		$_SESSION['s_fileType'] = "\".jpg\"";
		break;
	case "audio" :
		$_SESSION['s_fileType'] = "\".mp3\",\".fls\"";
		break;
	case "video" :
		$_SESSION['s_fileType'] = "\".flv\",\".swf\"";
		break;
	case "zip" :
		$_SESSION['s_fileType'] = "\".zip\"";
		break;
	}

	if ($Query["UploadMultiple"]) {
		$_SESSION['s_multipleFiles'] = "true";
	} else {
		$_SESSION['s_multipleFiles'] = "false";
	}
	
	return 0;
}

function checkFileForDownload( &$Query, &$node ) {
	// get file path
	global $rootDir;
	$path = $Query["FILEPATH"];
	// Why does this already have full path? Does it?
	//$path = getFullFileName($path);
	
	// check if the file exists
	$node .= "<note path='$path' root='$rootDir' />";
	if (file_exists($path)) {
		// AR v6.4.2.6 Why return a cut version?
		//$path = substr($path, strlen($rootDir));
		//$path = substr($path, strlen($pathFromHere."/"));
		$node .= "<action success='true' file='$path' />";
	} else {
		$node .= "<action error='no such file exists for downloading' />";
	}
	
	return 0;
}

function getCourseName( $xmlFile, $subFolder ) {
	$courseName = "";
	
	if ($fp = @fopen($xmlFile, "rb")) {	// we can open the file (ignore if we can't)
		// read the content
		$content = @fread($fp, filesize($xmlFile));
		
		// close the file
		@fclose($fp);
		
		// parse xml
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		if ( xml_parse_into_struct($xml, $content, $vals_b4_filter, $index) ) {
			// this is to eliminate extra cdata nodes in handmade xml files
			$vals = array_filter($vals_b4_filter, "removeCdataNodes");
			
			// parse xml
			foreach ($vals as $key => $val) {
				if ($val["tag"]=="course") {
					if ($val["attributes"]["subFolder"]==$subFolder) {
						$courseName = $val["attributes"]["name"];
					}
				}
			}
		}
		xml_parser_free($xml);
	}
	
	unset($fp);
	
	return $courseName;
}

// v6.4.2, DL: delete file
function deleteFile( &$Query, &$node ) {
	// get file path
	global $rootDir;
	$path = $Query["FILEPATH"];
	// v6.4.2.6 include the user data path to help getRootDir
	$udp = $Query["USERDATAPATH"];
	$path = getFullFileName($path, $udp);
	//$path = getFullFileName($path);
	//$path = $rootDir . $path;
	
	// check if the file exists
	if (file_exists($path)) {
		if (unlink($path)) {
			$node .= "<action success='true' info='{$path} is deleted' />";
		} else {
			$node .= "<action error='file cannot be deleted' />";
		}
	} else {
		$node .= "<action error='no such file exists for deletion' />";
	}
	
	return 0;
}

function editCourseXMLForExport( $tempFolder, &$Query ) {
	$courseFile = addSlash($tempFolder)."course.xml";
	
	if ($fp = @fopen($courseFile, "rb")) {	// we can open the file (ignore if we can't)
		// string for holding data to be written out
		$courseList = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><courseList>";
		
		// read the content
		$content = @fread($fp, filesize($courseFile));
		
		// close the file
		@fclose($fp);
		
		// parse xml
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		if ( xml_parse_into_struct($xml, $content, $vals, $index) ) {
			foreach ($vals as $val) {
				if ($val["level"]==2 && $val["tag"]=="course") {
					$match = False;
					foreach ($Query["SUBFOLDERS"] as $subFolder) {
						if (strlen($subFolder)>0) {
							if ($subFolder == $val["attributes"]["subFolder"]) {
								$match = True;
							}
						}
					}
					if ($match) {
						$cn = "<{$val["tag"]} ";
						foreach ($val["attributes"] as $ak => $attr) {
							$cn .= "{$ak}=\"{$attr}\" ";
						}
						$cn .= "/>";
						$courseList .= $cn;
						
						// v6.4.2, DL: get course id for SCORM
						// v6.4.2.1 AR; no need as done separately
						//$Query["CID"] = $val["attributes"]["id"];
						//$Query["CNAME"] = $val["attributes"]["name"];
					}
				}
			}
		}
		xml_parser_free($xml);
		
		// write the list out to the file
		$courseList .= "</courseList>";
		$fp = @fopen($courseFile, "wb");
		@fputs($fp, $courseList);
		@fclose($fp);
	}
	
	unset($fp);
}

function editMenuXMLForExport( $tempFolder, $subFolder, &$Query, &$node ) {
	$tempCourseFolder = "{$tempFolder}/Courses/{$subFolder}";
	$menuFile = str_replace('\\','\\\\',$tempCourseFolder.'/menu.xml');
	$node .= "<note editMenu='$menuFile' />";
	
	// why on earth was this set to read-only? Because I am reading the old one I just copied first.
	// then I will overwrite it with my new one
	if ($fp = fopen($menuFile, "rb")) {	// we can create the file (ignore if we can't)
	//if ($fp = fopen($menuFile, "w")) {	\
		//$node .= "<note>opened the menu.xml</note>";
		// string for holding data to be written out
		$unitList = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		
		// read the content
		$content = @fread($fp, filesize($menuFile));
		
		// close the file
		@fclose($fp);

		// parse xml
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		if ( xml_parse_into_struct($xml, $content, $vals_b4_filter, $index) ) {
			// this is to eliminate extra cdata nodes in handmade xml files
			$vals = array_filter($vals_b4_filter, "removeCdataNodes");
			
			// parse xml
			foreach ($vals as $key => $val) {
				if ($val["tag"]=="item") {
					// unit node
					switch ($val["level"]) {
					case 1:	// unit node
						if ($val["type"]!="close") {
							//$node .= "<note xml='" .$val["attributes"]["caption"] ."' />";
							$unitList .= "<{$val["tag"]} ";
							foreach ($val["attributes"] as $ak => $attr) {
								//v6.4.3 After export all enabledFlags should be 3
								//unit.setAttribute("enabledFlag")=3
								if ($ak=="enabledFlag") {
									$unitList .= "{$ak}=\"3\" ";
								} else {
									$unitList .= "{$ak}=\"{$attr}\" ";
								}
							}
							if ($val["type"]=="open") {
								$unitList .= ">";
							} else {
								$unitList .= "/>";
							}
						} else {
							$unitList .= "</{$val["tag"]}>";
						}
						break;
					case 2:	// exercise node
						$unitNode = "";
						$k = $key + 1;
						// loop through the exercise nodes
						// ignore those which are not selected by the user
						// v6.5.5.6 I get undefined offsets here if I don't check first on $vals[$k]
						//while ($k < count($vals_b4_filter) && $vals[$k]["level"]!=1 && $vals[$k]["level"]!=2) {
						while (isset($vals[$k]) && $k < count($vals_b4_filter) && $vals[$k]["level"]!=1 && $vals[$k]["level"]!=2) {
							if ($vals[$k]["tag"]=="item") {
								//$node .= "<note xml='" .$val["attributes"]["caption"] ."' />";
								foreach($Query["FILES"] as $file) {
									if (strlen($file)>0 && $vals[$k]["attributes"]["fileName"]==basename($file)) {
										$exNode = "<item ";
										//v6.4.2.1 AR You might need to escape & characters since PHP removes
										// the escaping that has already been added.
										//$new = htmlspecialchars("<a href='test'>Test</a>", ENT_QUOTES);
										foreach ($vals[$k]["attributes"] as $ak => $attr) {
											//v6.4.3 After export all enabledFlags should be 3
											//unit.setAttribute("enabledFlag")=3
											if ($ak=="enabledFlag") {
												$exNode .= "{$ak}=\"3\" ";
											} else {
												$exNode .= "{$ak}=\"{$attr}\" ";
											}
										}
										$exNode .= "/>";
										$unitNode .= $exNode;
									}
								}
							}
							$k++;
						}
						if (strlen($unitNode)>0) {
							$u = "<item ";
							foreach ($val["attributes"] as $ak => $attr) {
								$u .= "{$ak}=\"{$attr}\" ";
							}
							$u .= ">";
							$unitList .= $u.$unitNode."</item>";
							
							// v6.4.2, DL: add unit id for SCORM
							// v6.4.2 AR: not needed, come from original query now
							//array_push($Query["UIDS"], $val["attributes"]["id"]);
							//array_push($Query["UNAMES"], $val["attributes"]["caption"]);
						}
						break;
					}
				}
			}
		}
		xml_parser_free($xml);
		
		// write the list out to the new file
		$fp = fopen($menuFile, "wb");
		$numBytes = fwrite($fp, $unitList);
		$node .= "<note writeOutMenu='$menuFile' handle='$fp' numBytes='$numBytes' />";
		fclose($fp);
	}
	
	unset($fp);
}

// v6.4.2 AR 
function editManifestForExport( $manifestFile, &$Query, &$node) {
	if ($fp = @fopen($manifestFile, "rb")) {	// we can open the file (ignore if we can't)
		// string for holding data to be written out
		// v6.5.4.2 Add a line break to try and help a SCO created on a Linux system run in a Windows LMS
		// but that doesn't work, so try to get rid of all line breaks then
		/*	$manifest = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"; 	*/
		/*	$manifest = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"; 	*/
		$manifest = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		//$node .= "<note manifest='{$manifestFile}' />";
		
		// read the content
		$content = @fread($fp, filesize($manifestFile));
		
		// close the file
		@fclose($fp);

		// parse xml
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		if ( xml_parse_into_struct($xml, $content, $vals_b4_filter, $index) ) {
			// this is to eliminate extra cdata nodes in handmade xml files
			$vals = array_filter($vals_b4_filter, "removeCdataNodes");
			
			// parse xml
			$dropItem = false;
			foreach ($vals as $key => $val) {
				switch ($val["type"]) {
				//v6.4.2 Open is the start of a node, close is the end and complete has no sub nodes
				// Look up information in xml_parse_into_struct
				case "open" :
					//$thisNode = $val["tag"];
					//$node .= "<note info='open manifest node $thisNode' />";
					// v6.5.3 drop the item node, it will be replaced
					if ($val["tag"]=="item" || $dropItem) {
						// and don't play within else until you close this
						$dropItem = true;
					} else {
						$manifest .= "<{$val['tag']}";
						if (isset($val["attributes"]) && $val["attributes"]!=NULL) {
							foreach ($val["attributes"] as $ak => $attr) {
								$manifest .= " {$ak}=\"{$attr}\"";
							}
						}
						$manifest .= ">";
					}
					break;
				case "complete" :
					//v6.4.2 The <item></item> node is a placeholder for a whole set of nodes, so treat differently
					// v6.5.3 The <item> tag does have subnodes, so run this in 'close' instead
					//$thisNode = $val["tag"];
					/*
					$node .= "<note info='complete manifest node $thisNode' />";
					if ($val["tag"]=="item") {
						//v6.4.2 Since we don't know how many items there will be, add them dynamically simply
						// whereever you find <item></item> in the manifest
						$i=0;
						foreach ($Query['UIDS'] as $u) {
							//$node .= "<note info='add unit {$u} course {$Query['CID']} unit {$Query['UNAMES'][$i]}' />";
							// v6.4.2 use unitID as identifier, all use the same identifierref
							//$manifest .= "<item identifier=\"{$u}\" isvisible=\"true\" identifierref=\"RES-9E0095DC-62FD-FE31-79AC-8E75BA06EF18\"><title>{$Query['UNAMES'][$i]}</title><adlcp:datafromlms >course={$Query['CID']},unit={$u}</adlcp:datafromlms></item>";
							// v6.5 New id
							//$manifest .= "<item identifier=\"{$u}\" isvisible=\"true\" identifierref=\"RESOURCE-1\">
							 $j = $i+1;
							$manifest .= "<item identifier=\"ITEM_{$j}\" isvisible=\"true\" identifierref=\"RESOURCE_1\">
									<title>{$Query['UNAMES'][$i]}</title>
									<adlcp:datafromlms >course={$Query['CID']},unit={$u}</adlcp:datafromlms>
									</item>";
							$i++;
						}
					} else {
					*/
					// v6.5.3 drop the item node, it will be replaced
					if ($val["tag"]=="item" || $dropItem) {
					} else {
						$manifest .= "<{$val['tag']}";
						if (isset($val["attributes"]) && $val["attributes"]!=NULL) {
							foreach ($val["attributes"] as $ak => $attr) {
								$manifest .= " {$ak}=\"{$attr}\"";
							}
						}
						$manifest .= ">";
						if (isset($val["value"]) && $val["value"]!=NULL) {
					
							if ($val["tag"]=="title" && $val["value"]=="Course name") {
								$manifest .= $Query["CNAME"];
							} else {
								$manifest .= $val["value"];
							}
						}
						$manifest .= "</{$val['tag']}>";
					}
					break;
				case "close" :
					//v6.4.2 The <item></item> node is a placeholder for a whole set of nodes, so treat differently
					//$thisNode = $val["tag"];
					//$node .= "<note info='close manifest node $thisNode' />";
					if ($val["tag"]=="item") {
						//v6.4.2 Since we don't know how many items there will be, add them dynamically simply
						// whereever you find <item></item> in the manifest
						$i=0;
						foreach ($Query['UIDS'] as $u) {
							//$node .= "<note info='add unit {$u} course {$Query['CID']} unit {$Query['UNAMES'][$i]}' />";
							// v6.4.2 use unitID as identifier, all use the same identifierref
							//$manifest .= "<item identifier=\"{$u}\" isvisible=\"true\" identifierref=\"RES-9E0095DC-62FD-FE31-79AC-8E75BA06EF18\"><title>{$Query['UNAMES'][$i]}</title><adlcp:datafromlms >course={$Query['CID']},unit={$u}</adlcp:datafromlms></item>";
							// v6.5.3 New id
							//$manifest .= "<item identifier=\"{$u}\" isvisible=\"true\" identifierref=\"RESOURCE-1\">
							 $j = $i+1;
							// v6.5.4.2 Add a line break to try and help a SCO created on a Linux system run in a Windows LMS
							// but that doesn't work, so try to get rid of all line breaks then
							/* $manifest .= "<item identifier=\"ITEM_{$j}\" isvisible=\"true\" identifierref=\"RESOURCE_1\">
									<title>{$Query['UNAMES'][$i]}</title>
									<adlcp:datafromlms>course={$Query['CID']},unit={$u}</adlcp:datafromlms>
									</item>"; */
							$manifest .= "<item identifier=\"ITEM_{$j}\" isvisible=\"true\" identifierref=\"RESOURCE_1\"><title>{$Query['UNAMES'][$i]}</title>";
							$manifest .= "<adlcp:datafromlms>course={$Query['CID']},unit={$u}</adlcp:datafromlms></item>";
							$i++;
						}
						$dropItem = false;
					} else {
						$manifest .= "</{$val['tag']}>";
					}
					break;
				}
			}
		}
		xml_parser_free($xml);
		// v6.5.4.2 Add a line break to try and help a SCO created on a Linux system run in a Windows LMS
		//$manifest .= "\r\n";
		
		// write the list out to the file
		$fp = @fopen($manifestFile, "wb");
		@fputs($fp, $manifest);
		@fclose($fp);
		
	}
	
	unset($fp);
}

// v6.5.5.2 We need to edit the prefix in SCORMStart.html
// v6.4.2 AR 
function editStartPageForExport( $startPage, &$Query, &$node) {
	if ($fp = fopen($startPage, "rb")) {	// can we open the file?
		
		// read the content
		$content = fread($fp, filesize($startPage));
		fclose($fp);
		
		// Add the prefix to the flashVars list for control.swf
		$content = str_replace('prefix: ""', 'prefix: "'.$Query['PREFIX'].'"', $content);
		
		// Can we also set the webroot?
		// search for http://webserver/Clarity and change it to - well change it to what?
		// We could pick it up from the root that Author Plus is running in, right?
		if (isset($_SERVER['HTTPS'])) {
			$protocol = $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
		} else {
			$protocol = 'http';
		}
		if (isset($_SERVER['HTTP_HOST'])) {
			$host = $_SERVER['HTTP_HOST'];
		}
		
		// This script is down 4 folders from the root I am looking for. It will always be thus.
		$allFolders = explode("/", dirname($_SERVER['PHP_SELF']));
		$throwAway = array_splice($allFolders, -4, 4);
		$rootFolders = implode($allFolders, "/");
		$myRoot = $protocol.'://'.$host.$rootFolders;
		
		$content = str_replace('http://webserver/Clarity', $myRoot, $content);
		
		// write the edited content back to the file
		$fp = fopen($startPage, "wb");
		$bytes = fwrite($fp, $content);
		fclose($fp);
		
	}
	
	unset($fp);
}

// v6.4.2 AR split SCORM export from real file export
function exportFiles( &$Query, &$node ) {
	$basePath = $Query["BASEPATH"];
	$tempFolder = addSlash($basePath).getCurrentServerTime();
	@mkdir($tempFolder, 0777);
	@mkdir(addSlash($tempFolder)."Courses", 0777);
	
	// create folder for individual courses
	// v6.4.3 Just one course
	$subFolder = $Query["CID"];
	//foreach ($Query["SUBFOLDERS"] as $subFolder) {
	//	if (strlen($subFolder)>0) {
	//		@mkdir("{$tempFolder}/Courses/{$subFolder}");
	//		@mkdir("{$tempFolder}/Courses/{$subFolder}/Exercises");
	//		@mkdir("{$tempFolder}/Courses/{$subFolder}/Media");
	//	}
	//}
	//@mkdir(addSlash($tempFolder).addSlash("Courses").addSlash($subFolder));
	@mkdir("{$tempFolder}/Courses/{$subFolder}");
	@mkdir("{$tempFolder}/Courses/{$subFolder}/Exercises");
	@mkdir("{$tempFolder}/Courses/{$subFolder}/Media");
	
	//v6.4.3 Surely it is simpler to just build a new course.xml file since we know it is just one course
	//$result = @copy($Query["BASEPATH"]."/course.xml", $tempFolder."/course.xml");
	createCourseXMLForExport($tempFolder, $Query, $node);
	
	// v6.4.3 For MGS use
	//dim originalContentFolder
	//originalContentFolder = Server.MapPath(Query.originalContentPath)
	//$originalContentFolder = getFullFileName($Query["ORIGINALCONTENTPATH"]);
	$originalContentFolder = getFullFileName($Query["ORIGINALCONTENTPATH"],'');
	//$node .= "<note originalContentFolder='$originalContentFolder' basePath='$basePath' />";

	// copy files to temp folder
	foreach ($Query["FILES"] as $file) {
		if (strlen($file)>0) {
			//$node .= "<note copyFrom='$file' />";
			$file = str_replace("&amp;", "&", $file);
			if (file_exists($file)) {
				//v6.4.3 But you don't know whether the file you are copying came from the original or MGS.
				// BasePath will be MGS if you are in one. So if the paths are different, try replacing both paths, clumsy but should work fine
				$newFile = str_replace($basePath, $tempFolder, $file);
				if ($basePath<>$originalContentFolder) {
					$newFile = str_replace($originalContentFolder, $tempFolder, $newFile);
				}
				$newFolder = getFolderPath($newFile);
				//$node .= "<note exists='$newFolder' />";
				if (file_exists($newFolder)) {
					$node .= "<note copyFrom='$file' />";
					@copy($file, $newFile);
				}
			}
		}
	}
	
	// edit the course.xml according to the selected exercises
	//v6.4.3 Surely it is simpler to just build a new course.xml file since we know it is just one course
	//editCourseXMLForExport( $tempFolder, $Query );
	
	// edit the menu.xml for each course according to the selected exercises
	// v6.4.3 Just one course
	//foreach ($Query["SUBFOLDERS"] as $subFolder) {
		//if (strlen($subFolder)>0) {
			editMenuXMLForExport($tempFolder, $subFolder, $Query, $node);
		//}
	//}
	
	// v6.4.2, DL: add SCORM
	// v6.4.2 AR remove to new function
	//if ($Query["SCORM"]) {
	//	$SCORMfiles = Array("adlcp_rootv1p2.xsd", "APIWrapper.js", "ims_xml.xsd", "imscp_v1p1.xsd", "imsmanifest.xml", "imsmd_v1p2p2.xsd", "SCORMScripts.js", "SCORMStart-{$Query['PRODUCT']}.html");
	//	foreach($SCORMfiles as $file) {
	//		$result = @copy("../SCORM/".$file, $tempFolder."/".$file);
	//	}
	//	
	//	editManifestForExport( $tempFolder."/imsmanifest.xml", $Query );
	//}
	
	// zip the files up
	// v6.5.4.2 Let the function return info too
	//$err = zipFiles($tempFolder, $basePath);
	$err = zipFiles($tempFolder, $basePath, $node);
	
	// delete temp folder after zipping
	// v6.5.5.6 Spelling mistake? No - but not a publicly available function.
	// You can't use rmdir if the folder is not empty
	//rmdirr($tempFolder);
	// This function will delete the ZIP file too if it has the same basename, which it does!
	// So rename the temp folder before you delete it
	$newTempFolderName = $tempFolder."-del";
	rename($tempFolder, $newTempFolderName);
	delTree($newTempFolderName);
	
	if (!$err) {
		$node .= "<action success='true' file='{$tempFolder}.zip' />";
	} else {
		$node .= "<action success='false' />";
	}

	return 0;
}
// kevin at web-power dot co dot uk from PHP.net
// But this deletes a file at the same level as the folder if it has the same base name.
function delTree($dir) {
	$files = glob( $dir . '*', GLOB_MARK );
	foreach( $files as $file ){
		if( is_dir( $file ) )
			delTree( $file );
		else
			unlink( $file );
	}
	if (is_dir($dir)) rmdir( $dir );
}

// v6.4.2 AR new function for putting together a SCORM SCO ZIP pack
function createSCO( &$Query, &$node ) {
	$basePath = $Query["BASEPATH"];
	$tempFolder = addSlash($basePath).getCurrentServerTime();
	@mkdir($tempFolder, 0777);
	
	// v6.4.3 Remove SCORMScripts and APIWrapper to a common place.
	//$SCORMfiles = Array(	"APIWrapper.js", "SCORMScripts.js", 
	// v6.5 New files
	//$SCORMfiles = Array(	"adlcp_rootv1p2.xsd", "ims_xml.xsd", "imscp_v1p1.xsd", "imsmd_v1p2p2.xsd",
	$SCORMfiles = Array("adlcp_rootv1p2.xsd", "ims_xml.xsd", "imscp_rootv1p1p2.xsd", "imsmd_rootv1p2p1.xsd",
						"imsmanifest.xml", "SCORMStart.html");
	foreach($SCORMfiles as $file) {
		$result = @copy("../SCORM/".$file, $tempFolder."/".$file);
	}
	$node .= "<note coursename='{$Query["CNAME"]}' prefix='{$Query["PREFIX"]}' />";
	//$node .= "<note uids='{$Query['UIDS'][1]}' />";
	editManifestForExport( $tempFolder."/imsmanifest.xml", $Query , $node);
	// v6.4.2 You only need to change this file if the webshare is not Clarity and userdatapath not AuthorPlus
	// v6.5.5.2 For Clarity hosting, you need to pass the prefix to the start page. APP has to tell you what it is.
	editStartPageForExport( $tempFolder."/SCORMStart.html", $Query , $node);
	
	// zip the files up
	// v6.5.4.2 Let the function return info too
	//$err = zipFiles($tempFolder, $basePath);
	$err = zipSCORMFiles($tempFolder, $basePath, $node);
	
	// delete temp folder after zipping
	//rmdirr($tempFolder);
	
	if (!$err) {
		$node .= "<action success='true' file='{$tempFolder}.zip' />";
	} else {
		$node .= "<action success='false' error='{$err}' />";
	}

	return 0;
}

//function zipFiles($tempFolder, $basePath) {
function zipFiles($tempFolder, $basePath, &$node) {
	//set_time_limit(3000); //for big archives (this is 3000 seconds! Surely way too much. 60 seconds seems a lot)
	set_time_limit(120); //for big archives (this is 3000 seconds! Surely way too much. 60 seconds seems a lot)
	
	// new empty archive with compression level 6
	$zip = new ss_zip('',6);
	
	//add file from disc and store to the archive under its own name and path
	addDirToZip( $zip, $tempFolder, $tempFolder );
	
	//Saving the archive to server under a name
	$zipFile = addSlash($basePath).basename($tempFolder).".zip";
	//$node .= "<note zipFile='$zipFile' />";
	$zip->save($zipFile);
	
	//v6.4.2.1 It seems that ss_zip doesn't have any error handling - so we should check that the file exists now
	// as a rudimentary error handler.
	
	return 0;
}

// v6.5.4.2 New ZIP class for SCORM (bug when importing this ZIP into Blackboard)
function zipSCORMFiles($tempFolder, $basePath, &$node) {
	//Saving the archive to server under a name
	$zipFile = addSlash($basePath).basename($tempFolder).".zip";
	$archive = new PclZip($zipFile);
	
	// We don't want any folder name in the ZIP. This works beautifully if you know the folder root
	// On a Windows server I don't. On Linux (HCT) I do.
	//realpath can help, but I am nervous of it in different php systems
	
	// Try to base this simply on the first character
	if (substr($tempFolder,0,1)=="/") {
		//$removeName = "\Fixbench\Content\MyCanada".basename($tempFolder,".zip");
		$removeName = $tempFolder;
		//$node .= "<note removeName='{$removeName}' />";
		$returnInfo = $archive->add($tempFolder, PCLZIP_OPT_REMOVE_PATH, $removeName);
		//$returnInfo = $archive->add($tempFolder, PCLZIP_OPT_REMOVE_ALL_PATH);
	} else {
		// Open the folder and add each file individually. This only works for the single-level SCORM folder.
		// And on HCT it only adds the first file into the ZIP. The rest get a 0 code. So use above method for HCT
		if (is_dir($tempFolder)) {
			$dh  = opendir($tempFolder);
			while (false !== ($filename = readdir($dh))) {
				//$node .= "<note checking='{$filename}' />";
				if ($filename != '.' && $filename != '..' && is_file(addSlash($tempFolder).$filename)) {
					$returnInfo = $archive->add(addSlash($tempFolder).$filename, PCLZIP_OPT_REMOVE_ALL_PATH);
					//$node .= "<note returnInfo='".$returnInfo."' />";
				}
			}
		} else {
			//$node .= "<note notFolder='{$tempFolder}' />";
		}
	}
	
	if ($returnInfo == 0) {
		//die('Error : '.$archive->errorInfo(true));
		return ('Error : '.$archive->errorInfo(true));
	} else {
		return 0;
	}
}

function unzipFile( &$Query, &$node ) {
	// get paths
	global $rootDir;
	$path = $Query["BASEPATH"];
	// v6.4.2.6 include the user data path to help getRootDir
	$udp = $Query["USERDATAPATH"];
	$dir = getFullFileName($path, $udp);
	//$dir = getFullFileName($path);
	//$dir = $rootDir . $path;

	$zipName = $Query["ZIPFILE"];
	$zipFolder = "unzip_".substr($zipName, 0, strlen($zipName)-4);
	$dest = "{$dir}/{$zipFolder}";
	
	//create folder
	@mkdir($dest, 0777);
	// move the zip inside that folder
	//v6.4.2.1 AR I don't really want to move the ZIP, can I unzip to another folder?
	// It appears so...
	//@rename($dir."/".$zipName, $dest."/".$zipName);
	
	// unzip the files
	//$err = unzip($dest, $zipName);
	//unzip($dest."/".$zipName, $dest);
	unzip($dir."/".$zipName, $dest);
	
	if (file_exists($dest)) {
		//$node .= "<action success='true' folder='{$Query["BASEPATH"]}/{$zipFolder}' />";
		$node .= "<action success='true' folder='$path/$zipFolder' />";
	} else {
		$node .= "<action error='true' code='{$err}' />";
	}
	
	return 0;
}

function addNewCourseToXML( $xmlFile, $courseName, $courseID ) {
	if ($fp = @fopen($xmlFile, "rb")) {	// we can open the file (ignore if we can't)
		// string for holding data to be written out
		$courseList = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		$courseList .= "<courseList>";
		
		// read the content
		$content = @fread($fp, filesize($xmlFile));
		
		// close the file
		@fclose($fp);
		
		// parse xml
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		if ( xml_parse_into_struct($xml, $content, $vals_b4_filter, $index) ) {
			// this is to eliminate extra cdata nodes in handmade xml files
			$vals = array_filter($vals_b4_filter, "removeCdataNodes");
			
			// parse xml
			foreach ($vals as $val) {
				if ($val["tag"]=="course" && $val["type"]=="complete") {
					$courseList .= "<{$val["tag"]} ";
					foreach ($val["attributes"] as $ak => $attr) {
						$courseList .= "{$ak}=\"{$attr}\" ";
					}
					$courseList .= "/>";
				}
			}
		}
		xml_parser_free($xml);
		
		// add new node
		$courseList .= "<course ";
		$courseList .= "author=\"Clarity\" ";
		$courseList .= "edition=\"1\" ";
		$courseList .= "version=\"1.0\" ";
		$courseList .= "courseFolder=\"Courses\\\" ";
		$courseList .= "id=\"{$courseID}\" ";
		$courseList .= "name=\"{$courseName}\" ";
		$courseList .= "scaffold=\"menu.xml\" ";
		$courseList .= "subFolder=\"{$courseID}\" ";
		$courseList .= "/>";
		
		// finish making xml string
		$courseList .= "</courseList>";
		
		// write the list out to the file
		$fp = @fopen($xmlFile, "wb");
		@fputs($fp, $courseList);
		@fclose($fp);
	}
	
	unset($fp);
}

function editMenuXMLForImport( $xmlFile, &$Query, $unzipFolder, $subFolder, $newCourseFolder , &$node ) {
	$unitList = "";
	
	if ($fp = @fopen($xmlFile, "rb")) {	// we can open the file (ignore if we can't)
		// string for holding data to be written out
		$unitList = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		
		// read the content
		$content = @fread($fp, filesize($xmlFile));

		// close the file
		@fclose($fp);
		
		// parse xml
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		if ( xml_parse_into_struct($xml, $content, $vals_b4_filter, $index) ) {
			// this is to eliminate extra cdata nodes in handmade xml files
			$vals = array_filter($vals_b4_filter, "removeCdataNodes");
			
			// parse xml
			foreach ($vals as $key => $val) {
				if ($val["tag"]=="item") {
					// root node
					switch ($val["level"]) {
					case 1:	// root node
						if ($val["type"]!="close") {
							$unitList .= "<{$val["tag"]} ";
							foreach ($val["attributes"] as $ak => $attr) {
								$unitList .= "{$ak}=\"{$attr}\" ";
							}
							if ($val["type"]=="open") {
								$unitList .= ">";
							} else {
								$unitList .= "/>";
							}
						} else {
							$unitList .= "</{$val["tag"]}>";
						}
						break;
					case 2:	// unit node
						$unitNode = "";
						$k = $key + 1;
						// loop through the exercise nodes
						// ignore those which don't match an item in the files array
						// copy the exercise xml file if selected
						while ($k < count($vals_b4_filter) && $vals[$k]["level"]!=1 && $vals[$k]["level"]!=2) {
							if ($vals[$k]["tag"]=="item") {
								foreach($Query["FILES"] as $file) {
									if (strlen($file)>0 && $vals[$k]["attributes"]["fileName"]==basename($file)) {
										$file = str_replace("&amp;", "&", $file);
										$file = str_replace("\\", "/", $file);
										if (file_exists($file)) {
								//$node .= "<compare file='{$file}' and='{$unzipFolder}/Courses/{$subFolder}' />";
											if (strpos($file, "{$unzipFolder}/Courses/{$subFolder}")!==False) {
												// get new exercise id (which will be: id, aciton, fileName, exerciseID)
												$newExerciseID = getCurrentServerTime();
												// replace folder path
												$newFile = str_replace("{$unzipFolder}/Courses/{$subFolder}", $newCourseFolder, $file);
												// replace file name
												$newFile = str_replace(basename($file), "{$newExerciseID}.xml", $newFile);
												// copy file
												@copy($file, $newFile);
												
												// add exercise node
												$exNode = "<item ";
												foreach ($vals[$k]["attributes"] as $ak => $attr) {
													switch ($ak) {
													case "id" :
													case "action" :
													case "exerciseID" :
														$exNode .= "{$ak}=\"{$newExerciseID}\" ";
														break;
													case "fileName" :
														$exNode .= "{$ak}=\"{$newExerciseID}.xml\" ";
														break;
													// v6.4.3 Also set the enabledFlag based on the MGS
													// No, not here
													//case "enabledFlag":
													//	$exNode .= "{$ak}=\"19\" ";
													//	break;
													default :
														$exNode .= "{$ak}=\"{$attr}\" ";
														break;
													}
												}
												$exNode .= "/>";
												$unitNode .= $exNode;
											}
										}
									}
								}
							}
							$k++;
						}
						if (strlen($unitNode)>0) {
							$u = "<item ";
							foreach ($val["attributes"] as $ak => $attr) {
								$u .= "{$ak}=\"{$attr}\" ";
							}
							$u .= ">";
							$unitList .= $u.$unitNode."</item>";
						}
						break;
					}
				}
			}
		}
		//$node .= "<note parsing='done' />";
		xml_parser_free($xml);
		
		// write the list out to the file
		//v6.4.2.1 AR NO NO, we don't want to update the file at all
		// at least we don't when working within another course, at top level we do
		// so that has to go into importFiles
		//$fp = @fopen($xmlFile, "wb");
		//@fputs($fp, $unitList);
		//@fclose($fp);
	}
	
	unset($fp);
	
	return $unitList;
}

// v6.4.3 This is not used anymore as we always import direct into a single course
function importFiles( &$Query, &$node ) {
	// get paths
	//v6.4.2.1 Problem with folder slashes in later comparisons. Change everything to / ??
	// Also make sure that all folder names do NOT end in slash.
	// v6.4.2.1 AR Query.BasePath is like /Content/AuthorPlus/unzip_1239827349723/
	// Surely it would have been much better to pass the courses folder and full ZIP file separately??
	//$unzipFolder = $Query["BASEPATH"];
	$unzipFolder = justFolderPath($Query["BASEPATH"]);
	//$userFolder = getFolderPath(substr($unzipFolder, 0, strlen($unzipFolder)-1));
	$userFolder = justFolderParentPath($unzipFolder);
	$node .= "<note unzipFolder='{$unzipFolder}' userFolder='{$userFolder}'/>";
	
	// import course 1 by 1
	foreach ($Query["SUBFOLDERS"] as $subFolder) {
		if (strlen($subFolder)>0) {
			// create new folder for a course
			$newCourseID = getCurrentServerTime();
			$newCourseFolder = "{$userFolder}/Courses/{$newCourseID}";
			//$node .= "<note subFolder='{$subFolder}' newFolder='{$newCourseFolder}'/>";
			@mkdir($newCourseFolder, 0777);
			@mkdir($newCourseFolder."/Exercises", 0777);
			@mkdir($newCourseFolder."/Media", 0777);
			// v6.4.2.1 Don't just copy the old menu.xml, you will read and edit it below
			//@copy("{$unzipFolder}/Courses/{$subFolder}/menu.xml", "{$newCourseFolder}/menu.xml");
			
			// copy media files in the course
			foreach ($Query["FILES"] as $file) {
				if (strlen($file)>0) {
					$file = str_replace("&amp;", "&", $file);
					$file = str_replace("\\", "/", $file);
					if (file_exists($file)) {
						if (strpos($file, "{$unzipFolder}/Courses/{$subFolder}")!==False) {
							if (strpos(strtolower($file), ".xml")===False) {
								$newFile = str_replace("{$unzipFolder}/Courses/{$subFolder}", $newCourseFolder, $file);
								@copy($file, $newFile);
			//$node .= "<copy from='{$file}' to='{$newFile}'/>";
							}
						}
					}
				}
			}
			
			// get course name
			$newCourseName = getCourseName( "{$unzipFolder}/course.xml", $subFolder );
			
			// edit course.xml to include the new course
			if (file_exists($newCourseFolder)) {
				//$node .= "<edit xml='{$userFolder}/course.xml' />";
				addNewCourseToXML( "{$userFolder}/course.xml", $newCourseName, $newCourseID );
			}
			
			// v6.4.2.1 This function returns an edited XML object that is what should be put into the menu.
			// It does NOT (any more) actually update the file, so do that now
			$xmlFile = "{$unzipFolder}/Courses/{$subFolder}/menu.xml";
			$unitList = editMenuXMLForImport( $xmlFile, $Query, $unzipFolder, $subFolder, $newCourseFolder , $node);
			$xmlFile = "{$newCourseFolder}/menu.xml";
			$fp = @fopen($xmlFile, "wb");
			@fputs($fp, $unitList);
			@fclose($fp);
			unset($fp);
		}
	}
	
	// delete unzip folder and all its contents
	if (file_exists($unzipFolder)) {
		rmdirr($unzipFolder);
	}
	
	$node .= "<action success='true' />";
	
	return 0;
}

function calUnitXPos($pos, $total) {
	$pos--;	// in PHP, $pos is defined to be start with 1
	//v6.4.2.1 AR Three layouts, 4, 6, more
	if ($total > 6) {
		$n = 24;
		$n += ($pos % 5) * 132;
	} elseif ($total > 4) {
		$n = 156;
		$n += ($pos % 3) * 132;
	} else {
		$n = 156;
		$n += ($pos % 2) * 132;
	}
	return $n;
}

function calUnitYPos($pos, $total) {
	//$pos--;	// in PHP, $pos is defined to be start with 1
	//v6.4.2.1 AR Three layouts, 4, 6, more
	$n = 70;
	if ($total > 6) {
		$n += floor($pos / 6) * 160;
	} else if ($total > 4) {
		$n += floor($pos / 4) * 160;
	} else {
		$n += floor($pos / 3) * 160;
	}
	return $n;
}

//function addNewUnitsToXML( &$vals, &$vals2, $totalNoOfUnits) {
// v6.4.3 I need to pass MGSEnabled (and node for debugging)
//function addNewUnitsToXML( &$vals, &$vals2, $totalNoOfUnits, $MGSEnabled) {
function addNewUnitsToXML( &$vals, &$vals2, $totalNoOfUnits, $MGSEnabled, &$node) {
	$newUnitPos = 0;
	$unitNo = 0;
	$menu = "";
	$menuHead = "";
	// v6.5.5.9 See below for comments about importing to an empty course
	//$menuTail = "";
	$menuTail = "</item>";
	$oldUnitList = "";
	$newUnitList = "";

	// at this point $totalNoOfUnits is the number that you are going to import
	
	// vals is the xml structure of the menu.xml that you are importing from.
	// vals2 is the xml structure of the target course that you are going to merge into
	// get the largest number of "unit" attribute for incrementation
	// v6.5.5.9 If the target course is empty, we must make sure we get a menuTail to close off the unit we are about to add
	foreach ($vals2 as $val2) {
		if ($val2["tag"]=="item") {
			switch ($val2["level"]) {
			case 1 :
				if ($val2["type"]!="close") {
					$menuHead .= "<{$val2["tag"]} ";
					foreach ($val2["attributes"] as $ak => $attr) {
						$menuHead .= "{$ak}=\"{$attr}\" ";
					}
					$menuHead .= ">";
				} else {
					// v6.5.5.9 You might as well just fix this since you always want it
					//$menuTail .= "</{$val2["tag"]}>";
				}
				break;
			case 2 :
				//v6.4.2.1 You are going to do a simple renumber anyway in a minute
				//if ($val2["attributes"]["unit"] >= $newUnitPos) {
				//	$newUnitPos = $val2["attributes"]["unit"];
				//}
				if ($val2["type"]!="close") {
					$totalNoOfUnits++;
				}
				//$unitNo++;
			case 3 :
				if ($val2["type"]!="close") {
					$oldUnitList .= "<{$val2["tag"]} ";
					foreach ($val2["attributes"] as $ak => $attr) {
						// v6.4.3 I don't seem to come here at all
						//$node .= "<note addNewUnitsToXML.attr='$ak' />";
						// Is this the exercise loop or unit loop?						
						// v6.4.3 This will be dependent on being in MGS or not
						//if ($ak=="enabledFlag") {
						//	if ($MGSEnabled) {
						//		$thisEnabledFlag=intval($attr) & 16;
						//	} else {
						//		$thisEnabledFlag=intval($attr);
						//	}
						//	$oldUnitList .= "{$ak}=\"{$thisEnabledFlag}\" ";
							//$node .= "<note addNewUnitsToXML.eF='$thisEnabledFlag' />";
						//} else {
							$oldUnitList .= "{$ak}=\"{$attr}\" ";
						//}
					}
					if ($val2["type"]=="open") {
						$oldUnitList .= ">";
					} else {
						$oldUnitList .= "/>";
					}
				} else {
					$oldUnitList .= "</{$val2["tag"]}>";
				}
				break;
			}
		}
	}

	//v6.4.2.1 Since you are adding new units, you might need to reset the coordinates of the
	// existing menu units
	foreach ($vals2 as $key => $val2) {
		if ($val2["tag"]=="item" && $val2["level"]==2 && $val2["type"]!="close") {
			//the unit number is $unitNo out of $totalNoOfUnits
			// use this to change attributes of unit and x and y
			$unitNo++;
			foreach ($val2["attributes"] as $ak => $attr) {
				switch ($ak) {
				case "picture" :
					$attr = "Menu-APL-{$unitNo}";
					break;
				case "x" :
					$attr = calUnitXPos($unitNo, $totalNoOfUnits);
					break;
				case "y" :
					$attr = calUnitYPos($unitNo, $totalNoOfUnits);
					break;
				case "unit" :
					// v6.4.3 Surely this is wrong?
					//$attr = "Menu-APL-{$unitNo}";
					$attr = "{$unitNo}";
					break;
				}
			}
		}
		//v6.4.2.1 This doesn't update unit attribute in the exercise items - does it matter?
		// v6.4.3 I think it does!
	}
	//$MGSEnabled = $Query["MGSENABLED"];
	//$node .= "<note addNewUnitsToXML.MGSEnabled='$MGSEnabled' />";

	foreach ($vals as $val) {
		if ($val["tag"]=="item") {
			switch ($val["level"]) {
			case 2 :
				if ($val["type"]!="close") {
					//$newUnitPos++;
					$unitNo++;
					$newUnitList .= "<{$val["tag"]} ";
					foreach ($val["attributes"] as $ak => $attr) {
						switch ($ak) {
						case "picture" :
							$newUnitList .= "{$ak}=\"Menu-APL-{$unitNo}\" ";
							break;
						case "x" :
							$newUnitList .= "{$ak}=\"" . calUnitXPos($unitNo, $totalNoOfUnits) . "\" ";
							break;
						case "y" :
							$newUnitList .= "{$ak}=\"" . calUnitYPos($unitNo, $totalNoOfUnits) . "\" ";
							break;
						case "unit" :
							$newUnitList .= "{$ak}=\"{$unitNo}\" ";
							break;
						case "id" :
							$newUnitList .= "{$ak}=\"" . getCurrentServerTime() . "\" ";
							break;
						default :
							$newUnitList .= "{$ak}=\"{$attr}\" ";
							break;
						}
					}
					if ($val["type"]=="open") {
						$newUnitList .= ">";
					} else {
						$newUnitList .= "/>";
					}
				} else {
					$newUnitList .= "</{$val["tag"]}>";
				}
				break;
			case 3 :
				if ($val["type"]!="close") {
					$newUnitList .= "<{$val["tag"]} ";
					foreach ($val["attributes"] as $ak => $attr) {
						switch ($ak) {
						case "unit" :
							$newUnitList .= "{$ak}=\"{$unitNo}\" ";
							break;
						// Is this the exercise loop or unit loop?						
						// v6.4.3 This will be dependent on being in MGS or not
						case "enabledFlag":
							if ($MGSEnabled) {
								$thisEnabledFlag=intval($attr) | 16;
							} else {
								$thisEnabledFlag=intval($attr);
							}
							$node .= "<note addNewUnitsToXML.neweF='$thisEnabledFlag' oldeF='$attr' />";
							$newUnitList .= "{$ak}=\"{$thisEnabledFlag}\" ";
							break;
						default :
							$newUnitList .= "{$ak}=\"{$attr}\" ";
							break;
						}
					}
					if ($val["type"]=="open") {
						$newUnitList .= ">";
					} else {
						$newUnitList .= "/>";
					}
				} else {
					$newUnitList .= "</{$val["tag"]}>";
				}
				break;
			}
		}
	}
	
	$menu = $menuHead . $oldUnitList . $newUnitList . $menuTail;
	return $menu;
}

function importFilesToCurrentCourse( &$Query, &$node ) {
	// get paths
	//v6.4.2.1 Problem with folder slashes in later comparisons. Change everything to / ??
	// Also make sure that all folder names do NOT end in slash.
	// v6.4.2.1 AR Query.BasePath is like /Content/AuthorPlus/unzip_1239827349723/
	// v6.4.3 Or it will be in the MGS if you are
	// Surely it would have been much better to pass the courses folder and full ZIP file separately??
	// get newCourseFolder from MenuXmlPath
	global $rootDir;

	$xmlPath = $Query["MENUXMLPATH"];
	// v6.4.2.6 include the user data path to help getRootDir
	$udp = $Query["USERDATAPATH"];
	$path = getFullFileName($xmlPath, $udp);
	//$path = getFullFileName($xmlPath);
	
	//$unzipFolder = $Query["BASEPATH"];
	//$newCourseMenuXml = $rootDir . $Query["MENUXMLPATH"];
	//$userFolder = getFolderPath(substr($unzipFolder, 0, strlen($unzipFolder)-1));
	$unzipFolder = justFolderPath($Query["BASEPATH"]);
	$userFolder = justFolderParentPath($unzipFolder);
	//v6.4.2.1 This is not getting the right folder on hostfornoodles - due to justFolderPath bug
	//$newCourseMenuXml = justFolderPath($rootDir) . $Query["MENUXMLPATH"];
	//$newCourseFolder = justFolderPath($newCourseMenuXml);
	//$node .= "<note unzipFolder='{$unzipFolder}' userFolder='{$userFolder}'/>";
	//$newCourseMenuXml = justFolderPath($rootDir) . $Query["MENUXMLPATH"];
	// AR v6.4.2.5 relative paths
	//$newCourseMenuXml = $rootDir . $path;
	$newCourseMenuXml = $path;
	$newCourseFolder = justFolderPath($newCourseMenuXml);
	//$node .= "<note unzipFolder='{$unzipFolder}' userFolder='{$userFolder}' courseFolder='{$newCourseFolder}' courseXML='{$newCourseMenuXml}' />";
	// AR v6.4.2.5 relative paths
	//$node .= "<note unzipFolder='{$unzipFolder}' rootDir='{$rootDir}' queryPath='{$path}' courseFolder='{$newCourseFolder}' courseXML='{$newCourseMenuXml}' />";
	$node .= "<note unzipFolder='{$unzipFolder}' rootDir='{$rootDir}' queryPath='{$xmlPath}' courseFolder='{$newCourseFolder}' courseXML='{$newCourseMenuXml}' />";

	// import course 1 by 1
	// v6.4.3 There should only be one, which is already embedded in the newCourseFolder name
	foreach ($Query["SUBFOLDERS"] as $subFolder) {
		$node .= "<note subFolder='$subFolder' />";
		if (strlen($subFolder)>0) {
			
			// create exercises/media folder in the destination course if not exists
			if (!file_exists("{$newCourseFolder}/Exercises")) {
				@mkdir($newCourseFolder."/Exercises", 0777);
			}
			if (!file_exists("{$newCourseFolder}/Media")) {
				@mkdir("{$newCourseFolder}/Media", 0777);
			}
			
			// copy media files in the course
			foreach ($Query["FILES"] as $file) {
				if (strlen($file)>0) {
					// v6.4.3 Move this condition to save a load of file_exists checks
					if (strpos(strtolower($file), ".xml")===False) {
						$file = str_replace("&amp;", "&", $file);
						$file = str_replace("\\", "/", $file);
						if (file_exists($file)) {
							if (strpos($file, "{$unzipFolder}/Courses/{$subFolder}")!==False) {
								// v6.4.3 Move this condition to save a load of file_exists checks
								//if (strpos(strtolower($file), ".xml")===False) {
									$newFile = str_replace("{$unzipFolder}/Courses/{$subFolder}", $newCourseFolder, $file);
									@copy($file, $newFile);
								//}
							}
						}
					}
				}
			}
			
			// open the menu.xml file and do the following:
			// 1. copy exercise xml files
			// 2. delete the units that have no exercises
			// 3. get the no. of units to be imported
			// then the unit nodes in menu.xml is ready to be appended to the one in newCourseFolder
			$unitList = editMenuXMLForImport( "{$unzipFolder}/Courses/{$subFolder}/menu.xml", $Query, $unzipFolder, $subFolder, $newCourseFolder,  $node  );
			//$node .= "<note>$unitList</note>";
			$totalNoOfUnits = 0;
			
			// now the uploaded menu.xml is saved with the selected units & exercises
			// the string that holds the xml is passed back to $unitList
			// parse the string to array
			$xml = xml_parser_create();
			xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
			xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
			if ( xml_parse_into_struct($xml, $unitList, $vals_b4_filter, $index) ) {
				// this is to eliminate extra cdata nodes in handmade xml files
				$vals = array_filter($vals_b4_filter, "removeCdataNodes");
				
				// parse xml
				foreach ($vals as $key => $val) {
					if ($val["tag"]=="item" && $val["level"]==2 && ($val["type"]!="close")) {
						$totalNoOfUnits++;
						//$node .= "<note caption='{$val["attributes"]["caption"]}' />";
					}
				}
			}
			//$node .= "<note unitsToImport='{$totalNoOfUnits}' />";
			xml_parser_free($xml);
			// $vals holds the array with imported menu.xml
			// $totalNoOfUnits holds the no. of units to be imported
						
			// open the menu.xml in newCourseFolder for appending new units
			if ($fp = @fopen($newCourseMenuXml, "rb")) {	// we can open the file (ignore if we can't)
				// string for holding data to be written out
				$menu = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
				
				// read the content
				$content = @fread($fp, filesize($newCourseMenuXml));
				
				// close the file
				@fclose($fp);
				
				$xml = xml_parser_create();
				xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
				xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
				if ( xml_parse_into_struct($xml, $content, $vals_b4_filter, $index) ) {
					// this is to eliminate extra cdata nodes in handmade xml files
					$vals2 = array_filter($vals_b4_filter, "removeCdataNodes");
					
					// add new units (add units in $vals to $vals2)
					$node .= "<note totalNoOfUnits='{$totalNoOfUnits}' />";
					$menu .= addNewUnitsToXML($vals, $vals2, $totalNoOfUnits, $Query["MGSENABLED"], $node);
				}
				xml_parser_free($xml);
				
				// write the list out to the file
				$fp = @fopen($newCourseMenuXml, "wb");
				@fputs($fp, $menu);
				@fclose($fp);
			}
			unset($fp);
		}
	}
	
	// delete unzip folder and all its contents
	if (file_exists($unzipFolder)) {
		rmdirr($unzipFolder);
	}
	
	$node .= "<action success='true' />";
	
	return 0;
}
// v6.4.3 New function to build a fresh course.xml for the export
function createCourseXMLForExport( &$path, &$Query, &$node ) {
	$thisID = $Query["CID"];
	$thisName = $Query["CNAME"];
	$node.="<note msg=\"start createCourse for $thisID\" />";	
	$thisXML = "<courseList><course id=\"$thisID\" name=\"$thisName\" subFolder=\"$thisID\"  scaffold=\"menu.xml\" ";
	$thisXML.= "courseFolder=\"Courses\" version=\"6.4.3\" program=\"Author Plus\" enabledFlag=\"3\" />";
	$thisXML.="</courseList>";
	$thisFile = addSlash($path)."course.xml";
	if ($fp = @fopen($thisFile, "wb")) {
		// write the text out
		@fputs($fp, $thisXML);
		@fclose($fp);
	}	
	unset($fp);
	$node.="<note msg='saved $thisFile' />";
	return 0;
}	
?>