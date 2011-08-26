<?php
include_once("getRootDir.php");
include_once("functions.php");

if ($_GET['prog']=="NNW") {
$fileName = $_GET['path'];
// AR v6.4.2.6 Use getRootDir for all this now
// v6.4.2.6 include the user data path to help getRootDir
if (isset($_GET["userDataPath"])) {
	$udp = $_GET["userDataPath"];
} else {
	$udp = "";
}
$filePath = getFullFileName($fileName, $udp);
/*
// AR v6.4.2.5 new version for relative paths
// A relative path is relative to the location.ini file, so how do we get to that from here?
$pathFromHere = "../../../../AuthorPlus";

//print("relative from here $pathFromHere");
// if the filename is relative, we need to add the root folder.
if (substr($fileName,0,1)==".") {
	$fileName = $pathFromHere."/".$fileName;
}
//print("full is $fileName");
$physicalPath = realpath($fileName);
//print("physical file is $physicalPath");
// if realpath didn't work, then try using the relative one
if ($physicalPath.length==0) $physicalPath = $fileName;
$filePath = $physicalPath;
//$filePath = $rootDir . $fileName;
*/
$folderPath = removeSlash(substr($filePath, 0, strlen($filePath) - strlen(basename($filePath))));
$medias = "";

// v6.4.3 If you are exporting you know what course node you want to create, then you read each menu.xml to find which 
// exercises and media are in it ready for copying.
// If you are importing, you read the course.xml from the unzip folder you have just made, then the menu.xml files.
// You can also get the exercises and media to make it easier later to copy them.
// It used to be just one function, but due to course tree we don't want to read the course.xml for exporting
$action = $_GET['action'];
$x = "<courseList>";

// v6.4.3 Export: We know the one courseID from course.xml, so don't need to read that.
if ($action == "export") {
	$courseID = $_GET['courseID'];
	$scaffold = $_GET['scaffold'];
	$subFolder = $_GET['subFolder'];
	//$courseName = escape($_GET['courseName']);
	$courseName = urlencode($_GET['courseName']);
	$courseFolder = "Courses";
	//$originalContentFolder = getFullFileName($_GET['originalContentFolder']);
	$originalContentFolder = getFullFileName($_GET['originalContentFolder'], $udp);
	
	// v6.4.3 New code 
	$filePath = addSlash($folderPath) .addSlash($courseFolder) .addSlash($subFolder) .$scaffold;
	//v6.5.1 And why not send back the ID?
	//$node="<course name=\"$courseName\" check='2' filePath='$filePath' folderPath='$folderPath' subFolder='$subFolder' >";
	$node="<course name='$courseName' id='$courseID' check='2' filePath='$filePath' folderPath='$folderPath' subFolder='$subFolder' >";
	/*
	// Remove the section for reading course.xml - direct read of menu.xml in the right folder now
	if (file_exists($filePath)) {
		// open course xml
		if ($fp = @fopen($filePath, "rb")) {	// we can open the file (ignore if we can't)
			// read the content
			$content = @fread($fp, filesize($filePath));
			// PHP holds string with 1 byte for each character only
			// so we need to hold the unicode for the names of courses in an array
			$unicode = utf8_to_unicode($content);
			$cNames = getNames($unicode);
			$cn = 0;	// counter for names array
			// parse xml
			$xml = xml_parser_create();
			xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
			xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
			if ( xml_parse_into_struct($xml, $content, $vals_b4_filter, $index) ) {
				// this is to eliminate extra cdata nodes in handmade xml files
				$vals = array_filter($vals_b4_filter, "removeCdataNodes");
				
				foreach ($vals as $key => $val) {
					if ($val["type"]=="complete" && $val["level"]==2) {
						$node = "<{$val["tag"]} ";
						foreach ($val["attributes"] as $ak => $attr) {
							if ($ak=="name") {
								//v6.4.2.1 AR This seems overkill as every character is escaped making
								// the xml massively difficult to read. Ditto for caption and label
								$courseName = unicode_to_entities($cNames[$cn]);
								//$courseName = $cNames[$cn];
								$cn++;	// increment name counter
								$node .= "{$ak}=\"{$courseName}\" ";
							} else {
								$node .= "{$ak}=\"".$attr."\" ";
							}
						}
						$node .= "label=\"{$courseName}\" ";
						$node .= "check=\"2\" ";
						$courseFolder = $val["attributes"]["courseFolder"];
						$subFolder = $val["attributes"]["subFolder"];
						$filePath = $folderPath.$courseFolder.$subFolder."/".$val["attributes"]["scaffold"];
						$filePath = str_replace("\\", "/", $filePath);
						$folderPath = str_replace("\\", "/", $folderPath);
						$node .= "filePath=\"{$filePath}\" ";
						$node .= "folderPath=\"{$folderPath}\" ";
						$node .= ">";
	*/					
						// open menu mxl
						if ($fp2 = @fopen($filePath, "rb")) {
							// read the content
							$content = @fread($fp2, filesize($filePath));
							// PHP holds string with 1 byte for each character only
							// so we need to hold the unicode for the names of courses in an array
							$unicode = utf8_to_unicode($content);
							$mNames = getCaptions($unicode);
							$mn = 1;	// counter for names array, [0] should have hold the caption for course name, which should be ignored
							
							$xml = xml_parser_create();
							xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
							xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
							if ( xml_parse_into_struct($xml, $content, $vals2_b4_filter, $index) ) {
								// this is to eliminate extra cdata nodes in handmade xml files
								$vals2 = array_filter($vals2_b4_filter, "removeCdataNodes");
								
								foreach ($vals2 as $key2 => $val2) {
									// unit node
									if ($val2["level"]==2) {
										switch ($val2["type"]) {
										case "open" :
										case "complete" :
											$node .= "<{$val2["tag"]} ";
											foreach ($val2["attributes"] as $ak2 => $attr2) {
												if ($ak2=="caption") {
													// v6.4.2.1 see earlier
													$menuName = unicode_to_entities($mNames[$mn]);
													//$menuName = $mNames[$mn];
													$mn++;	// increment name counter
													$node .= "{$ak2}=\"{$menuName}\" ";
												} else {
													$node .= "{$ak2}=\"{$attr2}\" ";
												}
											}
											// v6.4.3 send back name not label
											//$node .= "label=\"{$menuName}\" ";
											$node .= "name=\"{$menuName}\" ";
											$node .= "check=\"2\" ";
											if ($val2["type"]=="open") {
												$node .= ">";
											} else {
												$node .= "/>";
											}
											break;
										case "close" :
											$node .= "</{$val2["tag"]}>";
											break;
										}
										
									// exercise node
									} else if ($val2["level"]==3) {
										$node .= "<{$val2["tag"]} ";
										foreach ($val2["attributes"] as $ak2 => $attr2) {
											if ($ak2=="caption") {
												$menuName = unicode_to_entities($mNames[$mn]);
												//$menuName = $mNames[$mn];
												$mn++;	// increment name counter
												$node .= "{$ak2}=\"{$menuName}\" ";
											// v6.4.3 check enabledFlag in this loop
											} else if ($ak2=="enabledFlag") {
												$enabledFlag = intval($attr2);
												$node .= "{$ak2}=\"{$attr2}\" ";
											} else {
												$node .= "{$ak2}=\"{$attr2}\" ";
											}
										}
										// v6.4.3 send back name not label
										//$node .= "label=\"{$menuName}\" ";
										$node .= "name=\"{$menuName}\" ";
										$node .= "check=\"2\" ";
										// v6.4.3 Slash not included now
										// v6.4.3 We need to work out whether the exercise is in the MGS or the original
										// So we check the enabledFlag from the menu, then build the filepath appropriately
										// Medias will be read from the file, then their path also stored appropriately
										// The enabledFlag (called check for some reason) will always to back as 2 I think as everything is 
										// put together for the export. No, check is used for the APP tree to show selected nodes.
										if (($enabledFlag & 16) == 16) {
											$contentFolder = $folderPath;
										} else {
											$contentFolder = $originalContentFolder;
										}
										//$filePath = $folderPath.$courseFolder.$subFolder."/Exercises/".$val2["attributes"]["fileName"];
										//$filePath = addSlash($folderPath).addSlash($courseFolder).addSlash($subFolder).addSlash("Exercises").$val2["attributes"]["fileName"];
										$filePath = addSlash($contentFolder).addSlash($courseFolder).addSlash($subFolder).addSlash("Exercises").$val2["attributes"]["fileName"];
										//$filePath = str_replace("\\", "/", $filePath);
										$node .= "filePath=\"{$filePath}\" ";
										$node .= ">";
										
										// open exercise xml
										if ($fp3 = @fopen($filePath, "rb")) {
											$content = @fread($fp3, filesize($filePath));
											
											$xml = xml_parser_create();
											xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
											xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
											if ( xml_parse_into_struct($xml, $content, $vals3, $index) ) {
												foreach ($vals3 as $key3 => $val3) {
													// unit node
													
													// AR If PHP warnings are on for Notice, this could spell problems throughout this file as we test for attributes that are optional
													//if ($val3["level"]==3 && $val3["tag"]=="media" && $val3["attributes"]["location"]!="shared") {
													// v6.5.5.9 question based audio files do not have location attribute set at all, so this doesn't export them
													// All you are trying to do is avoid copying files if location=shared.
													//if (isset($val3["attributes"]["location"]) && $val3["level"]==3 && $val3["tag"]=="media" && $val3["attributes"]["location"]!="shared") {
													if ($val3["level"]==3 && $val3["tag"]=="media" && (!isset($val3["attributes"]["location"]) || $val3["attributes"]["location"]!="shared")) {
														$media = "<{$val3["tag"]} ";
														foreach ($val3["attributes"] as $ak3 => $attr3) {
															$media .= "{$ak3}=\"{$attr3}\" ";
														}
														$media .= "exID=\"{$val2["attributes"]["id"]}\" ";
														// v6.4.3 folder slash not included now
														// v6.4.3 Use different folders based on MGS
														//$filePath = addSlash($folderPath).addSlash($courseFolder).addSlash($subFolder).addSlash("Media").$val3["attributes"]["filename"];
														$filePath = addSlash($contentFolder).addSlash($courseFolder).addSlash($subFolder).addSlash("Media").$val3["attributes"]["filename"];
														//$filePath = $folderPath.$courseFolder.$subFolder."/Media/".$val3["attributes"]["filename"];
														//$filePath = str_replace("\\", "/", $filePath);
														$media .= "filePath=\"{$filePath}\" ";
														$media .= "/>";
														$medias .= $media;
													}
												}
											}
										}
										
										$node .= "</{$val2["tag"]}>";
									}
								}
							}
						}
						
						//$node .= "</{$val["tag"]}>";
						$node.="</course>";
						$x .= $node;
		//			}
		//		}
		//	}
			xml_parser_free($xml);
			
		//	// close file
		//	@fclose($fp);
		//} else {
		//	//$x .= "<note>cannot read the file</note>";
		//}
		
		//unset($fp);
	//}
} else {

	// v6.4.3 Import has a completely different agenda now
	// v6.4.3 Read the course.xml (the one you unzipped on import)
	if (file_exists($filePath)) {
		// open course xml
		if ($fp = @fopen($filePath, "rb")) {	// we can open the file (ignore if we can't)
			// read the content
			$content = @fread($fp, filesize($filePath));
			// PHP holds string with 1 byte for each character only
			// so we need to hold the unicode for the names of courses in an array
			// v6.5.5.6 It seems that some course.xml gets corrupted if it contains single quotes. If I change all to double it is OK.
			// Can I just do that at this point?
			$content = str_replace(chr(39), chr(34), $content);
			//echo $content; exit();
			$unicode = utf8_to_unicode($content);
			$cNames = getNames($unicode);
			$cn = 0;	// counter for names array
			// parse xml
			$xml = xml_parser_create();
			xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
			xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
			if ( xml_parse_into_struct($xml, $content, $vals_b4_filter, $index) ) {
				// this is to eliminate extra cdata nodes in handmade xml files
				$vals = array_filter($vals_b4_filter, "removeCdataNodes");
				
				foreach ($vals as $key => $val) {
					if ($val["type"]=="complete" && $val["level"]==2) {
						$node = "<{$val["tag"]} ";
						foreach ($val["attributes"] as $ak => $attr) {
							if ($ak=="name") {
								//v6.4.2.1 AR This seems overkill as every character is escaped making
								// the xml massively difficult to read. Ditto for caption and label
								$courseName = unicode_to_entities($cNames[$cn]);
								//$courseName = $cNames[$cn];
								$cn++;	// increment name counter
								$node .= "{$ak}=\"{$courseName}\" ";
							} else {
								$node .= "{$ak}=\"".$attr."\" ";
							}
						}
						// v6.4.3 Use name not label
						//$node .= "label=\"{$courseName}\" ";
						$node .= "name=\"{$courseName}\" ";
						$node .= "check=\"2\" ";
						$courseFolder = $val["attributes"]["courseFolder"];
						$subFolder = $val["attributes"]["subFolder"];
						//$filePath = $folderPath.$courseFolder.$subFolder."/".$val["attributes"]["scaffold"];
						$filePath = addSlash($folderPath).addSlash($courseFolder).addSlash($subFolder).$val["attributes"]["scaffold"];
						//$filePath = str_replace("\\", "/", $filePath);
						//$folderPath = str_replace("\\", "/", $folderPath);
						$node .= "filePath=\"{$filePath}\" ";
						$node .= "folderPath=\"{$folderPath}\" ";
						$node .= ">";
						
						// v6.4.3 The menu will always be in the MGS if that is where you are.
						// open menu mxl
						if ($fp2 = @fopen($filePath, "rb")) {
							// read the content
							$content = @fread($fp2, filesize($filePath));
							// PHP holds string with 1 byte for each character only
							// so we need to hold the unicode for the names of courses in an array
							$unicode = utf8_to_unicode($content);
							$mNames = getCaptions($unicode);
							$mn = 1;	// counter for names array, [0] should have hold the caption for course name, which should be ignored
							
							$xml = xml_parser_create();
							xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
							xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
							if ( xml_parse_into_struct($xml, $content, $vals2_b4_filter, $index) ) {
								// this is to eliminate extra cdata nodes in handmade xml files
								$vals2 = array_filter($vals2_b4_filter, "removeCdataNodes");
								
								foreach ($vals2 as $key2 => $val2) {
									// unit node
									if ($val2["level"]==2) {
										switch ($val2["type"]) {
										case "open" :
										case "complete" :
											$node .= "<{$val2["tag"]} ";
											foreach ($val2["attributes"] as $ak2 => $attr2) {
												if ($ak2=="caption") {
													// v6.4.2.1 see earlier
													$menuName = unicode_to_entities($mNames[$mn]);
													//$menuName = $mNames[$mn];
													$mn++;	// increment name counter
													$node .= "{$ak2}=\"{$menuName}\" ";
												} else {
													$node .= "{$ak2}=\"{$attr2}\" ";
												}
											}
											// v6.4.3 send back name not label
											//$node .= "label=\"{$menuName}\" ";
											$node .= "name=\"{$menuName}\" ";
											$node .= "check=\"2\" ";
											if ($val2["type"]=="open") {
												$node .= ">";
											} else {
												$node .= "/>";
											}
											break;
										case "close" :
											$node .= "</{$val2["tag"]}>";
											break;
										}
										
									// exercise node
									} else if ($val2["level"]==3) {
										$node .= "<{$val2["tag"]} ";
										foreach ($val2["attributes"] as $ak2 => $attr2) {
											if ($ak2=="caption") {
												$menuName = unicode_to_entities($mNames[$mn]);
												//$menuName = $mNames[$mn];
												$mn++;	// increment name counter
												$node .= "{$ak2}=\"{$menuName}\" ";
											} else {
												$node .= "{$ak2}=\"{$attr2}\" ";
											}
										}
										// v6.4.3 send back name not label
										//$node .= "label=\"{$menuName}\" ";
										$node .= "name=\"{$menuName}\" ";
										$node .= "check=\"2\" ";
										// v6.4.3 No slash on the end of courseFolder
										// v6.4.3 Slash not included now
										//$filePath = $folderPath.$courseFolder.$subFolder."/Exercises/".$val2["attributes"]["fileName"];
										$filePath = addSlash($folderPath).addSlash($courseFolder).addSlash($subFolder).addSlash("Exercises").$val2["attributes"]["fileName"];
										//$filePath = str_replace("\\", "/", $filePath);
										$node .= "filePath=\"{$filePath}\" ";
										$node .= ">";
										
										// open exercise xml
										if ($fp3 = @fopen($filePath, "rb")) {
											$content = @fread($fp3, filesize($filePath));
											
											$xml = xml_parser_create();
											xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
											xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
											if ( xml_parse_into_struct($xml, $content, $vals3, $index) ) {
												foreach ($vals3 as $key3 => $val3) {
													// unit node
													// AR If PHP warnings are on for Notice, this could spell problems throughout this file as we test for attributes that are optional
													//if ($val3["level"]==3 && $val3["tag"]=="media" && $val3["attributes"]["location"]!="shared") {
													// v6.5.5.9 question based audio files do not have location attribute set at all, so this doesn't export them
													// All you are trying to do is avoid copying files if location=shared.
													//if (isset($val3["attributes"]["location"]) && $val3["level"]==3 && $val3["tag"]=="media" && $val3["attributes"]["location"]!="shared") {
													if ($val3["level"]==3 && $val3["tag"]=="media" && (!isset($val3["attributes"]["location"]) || $val3["attributes"]["location"]!="shared")) {
														$media = "<{$val3["tag"]} ";
														foreach ($val3["attributes"] as $ak3 => $attr3) {
															$media .= "{$ak3}=\"{$attr3}\" ";
														}
														$media .= "exID=\"{$val2["attributes"]["id"]}\" ";
														// v6.4.3 folder slash not included now
														$filePath = addSlash($folderPath).addSlash($courseFolder).addSlash($subFolder).addSlash("Media").$val3["attributes"]["filename"];
														//$filePath = $folderPath.$courseFolder.$subFolder."/Media/".$val3["attributes"]["filename"];
														//$filePath = str_replace("\\", "/", $filePath);
														$media .= "filePath=\"{$filePath}\" ";
														$media .= "/>";
														$medias .= $media;
													}
												}
											}
										}
										
										$node .= "</{$val2["tag"]}>";
									}
								}
							}
						}
						
						$node .= "</{$val["tag"]}>";
						$x .= $node;
					}
				}

			}
			xml_parser_free($xml);
			
			// close file
			@fclose($fp);
		} else {
			//$x .= "<note>cannot read the file</note>";
		}		
		unset($fp);
	}
}
	
$x .= "<medias>{$medias}</medias>";
$x .= "</courseList>";

print($x);
}
?>