<?php
include_once("getRootDir.php");
include_once("functions.php");

if ($_GET["prog"]=="NNW") {
	$userPath = $rootDir . $_GET["userPath"];
	$folderPath = $rootDir . $_GET["folder"];
	$destPath = $userPath . "/Courses/" . basename($folderPath);
	$menu = $_GET["menu"];
	
	$post = file_get_contents("php://input");
	
	/*if (!file_exists($userPath."/Courses")) {
		@mkdir($userPath."/Courses", 0777);
	}
	
	if (!file_exists($destPath)) {
		@mkdir($destPath, 0777);
		
		@mkdir($destPath."/Exercises", 0777);
		@mkdir($destPath."/Media", 0777);
		//copydirr($folderPath."/Exercises", $destPath."/Exercises");
		//copydirr($folderPath."/Media", $destPath."/Media");
		
		if (!file_exists($userPath."/course.xml")) {
			$post = "\xEF\xBB\xBF<courseList>".$post."</courseList>";
			
		} else {
			$nodes = "";
			if ($fp = @fopen($userPath."/course.xml", "rb")) {	// we can open the file (ignore if we can't)
				// read the content
				$content = @fread($fp, filesize($userPath."/course.xml"));
				// parse xml
				$xml = xml_parser_create();
				xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
				xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
				if ( xml_parse_into_struct($xml, $content, $vals, $index) ) {
					foreach ($vals as $key => $val) {
						if ($val["level"]==2) {
							switch ($val["type"]) {
							case "open" :
							case "complete" :
								$nodes .= "<{$val["tag"]} ";
								foreach ($val["attributes"] as $ak => $attr) {
									if ($ak=="enabledFlag") {
										$attr += 48;
									}
									$nodes .= "{$ak}=\"{$attr}\" ";
								}
								if ($val["type"]=="open") {
									$nodes .= ">";
								} else {
									$nodes .= "/>";
								}
								break;
							case "close" :
								$nodes .= "</{$val["tag"]}>";
								break;
							}
						}
					}
				}
			}
			$post = "\xEF\xBB\xBF<courseList>".$nodes.$post."</courseList>";
		}
		// save course.xml
		$fp = @fopen($userPath."/course.xml", "wb");
		@fputs($fp, $post);
		@fclose($fp);*/
		
		// copy menu xml
		/*if (file_exists($folderPath."/".$menu)) {
			$nodes = "";
			// open menu xml
			if ($fp = @fopen($folderPath."/".$menu, "rb")) {	// we can open the file (ignore if we can't)
				// read the content
				$content = @fread($fp, filesize($folderPath."/".$menu));
				// parse xml
				$xml = xml_parser_create();
				xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
				xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
				if ( xml_parse_into_struct($xml, $content, $vals, $index) ) {
					foreach ($vals as $key => $val) {
						switch ($val["type"]) {
						case "open" :
						case "complete" :
							$nodes .= "<{$val["tag"]} ";
							if ($val["level"]==2||$val["level"]==3) {
								foreach ($val["attributes"] as $ak => $attr) {
									if ($ak=="enabledFlag") {
										$attr += 48;
									}
									$nodes .= "{$ak}=\"{$attr}\" ";
								}
							}
							if ($val["type"]=="open") {
								$nodes .= ">";
							} else {
								$nodes .= "/>";
							}
							break;
						case "close" :
							$nodes .= "</{$val["tag"]}>";
							break;
						}
					}
				}
			}
			
			// save xml file
			$fp = @fopen($destPath."/".$menu, "wb");
			@fputs($fp, $nodes);
			@fclose($fp);
		}
	}*/
	
	if (file_exists($folderPath."/".$menu)) {
		$sourceFile = $folderPath."/".$menu;
		$destFile = substr($sourceFile, 0, strlen($sourceFile) - 4)."-original.xml";
		if (!file_exists($destFile)) {
			@copy($sourceFile, $destFile);
		}
	}
	
	echo "<sR success='true' />";
}
?>