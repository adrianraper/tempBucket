<?php
include_once("getRootDir.php");
include_once("functions.php");

if ($_GET["prog"]=="NNW") {
	$source = $rootDir . $_GET["sF"];
	$dest = $rootDir . $_GET["dF"];
	
	/*$nodes = "";
	
	if (file_exists($source)) {
		// open menu xml
		if ($fp = @fopen($source, "rb")) {	// we can open the file (ignore if we can't)
			// read the content
			$content = @fread($fp, filesize($source));
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
		$fp = @fopen($dest, "wb");
		@fputs($fp, $nodes);
		@fclose($fp);
	}*/
	
	if (file_exists($source)) {
		$s1 = filesize($dest);
		$s2 = filesize($source);
		if (copy($source, $dest)) {
			$s3 = filesize($dest);
			$s4 = filesize($source);
			echo "<sR success=\"true\" info=\"file copied, source: {$source} ; dest: {$dest} ; size: {$s1} to {$s3}\" />";
		} else {
			echo "<sR success=\"true\" info=\"FAIL: file is not copied\" />";
		}
	} else {
		echo "<sR success=\"true\" info=\"FAIL: source file {$source} does not exist\" />";
	}
}
?>