<?php
/* debugging */
function myTrace(&$node, $s) {
	$node .= "<debug>$s</debug>";
}

/* string manipulation */
function getFolderPath($p) {
	$b = basename($p);
	return substr($p, 0, strlen($p)-strlen($b));
}
// v6.4.2.1 AR Function that returns pure folder path from any(?) string. No slash on end.
//v6.4.2.1 This does not work if a folder has a dot in it - such as /hostnoodles/host-for-noodles.com/Courses
function justFolderPath($p) {
	$tmp = str_replace("\\", "/", $p);
	$dot = strrpos($tmp, ".");
	$slash = strrpos($tmp, "/");
	if ($dot > 0 && $dot > $slash) {
		$tmp = substr($tmp, 0, $slash);
	}
	if (substr($tmp, -1) == "/") {
		$tmp=substr($tmp,0,strlen($tmp)-1);
	}
	return $tmp;
}
function justFolderParentPath($p) {
	// first make sure that it doesn't end in a slash
	$tmp = justFolderPath($p);
	// then find the last slash
	$slash = strrpos($tmp, "/");
	if ($slash > 0) {
		$tmp = substr($tmp, 0, $slash);
	}
	if (substr($tmp, -1) == "/") {
		$tmp=substr($tmp,0,strlen($tmp)-1);
	}
	return $tmp;
}

/* xml manipulation */
function removeCdataNodes($var) {
	return ($var["type"]!="cdata");
}

/* recursive zipping function (requires ss_zip.class) */
function addDirToZip( &$zip, $dir, $base ) {
	if($objs = glob($dir."/*")){
		foreach($objs as $obj) {
			if (is_dir($obj)) {
				addDirToZip( $zip, $obj, $base );
			} else {
				$f = str_replace($base, "", $dir)."/".basename($obj);
				$zip->add_file($obj, $f);
			}
		}
	}
}

/* unzipping function (requires php_zip.dll & mkdirr function) */
function unzip($zipFile, $dest) {
	// set time limit
	set_time_limit(3000); //for big archives
	
	// new empty archive with compression level 6
	$zip = new ss_zip('',6);
	
	// open the zip file
	$zip->open($zipFile);

	while($entry=$zip->read()){ 
		$zip->extract_file($entry['idx'],$dest);
	}
}
/*function unzip($dir, $file, $destiny="") {
   $dir .= DIRECTORY_SEPARATOR;
   $path_file = $dir . $file;
   $zip = zip_open($path_file);
   $_tmp = array();
   $count=0;
   if ($zip) {
       while ($zip_entry = zip_read($zip))
       {
           $_tmp[$count]["filename"] = zip_entry_name($zip_entry);
           $_tmp[$count]["stored_filename"] = zip_entry_name($zip_entry);
           $_tmp[$count]["size"] = zip_entry_filesize($zip_entry);
           $_tmp[$count]["compressed_size"] = zip_entry_compressedsize($zip_entry);
           $_tmp[$count]["mtime"] = "";
           $_tmp[$count]["comment"] = "";
           $_tmp[$count]["folder"] = dirname(zip_entry_name($zip_entry));
           $_tmp[$count]["index"] = $count;
           $_tmp[$count]["status"] = "ok";
           $_tmp[$count]["method"] = zip_entry_compressionmethod($zip_entry);
          
           if (zip_entry_open($zip, $zip_entry, "r"))
           {
               $buf = zip_entry_read($zip_entry, zip_entry_filesize($zip_entry));
               if($destiny)
               {
                   $path_file = str_replace("/",DIRECTORY_SEPARATOR, $destiny . zip_entry_name($zip_entry));
               }
               else
               {
                   $path_file = str_replace("/",DIRECTORY_SEPARATOR, $dir . zip_entry_name($zip_entry));
               }
               $new_dir = dirname($path_file);
              
               // Create Recursive Directory
               mkdirr($new_dir);
              

               $fp = fopen($dir . zip_entry_name($zip_entry), "w");
               fwrite($fp, $buf);
               fclose($fp);

               zip_entry_close($zip_entry);
           }
           $count++;
       }

       zip_close($zip);
	return 0;
   } else {
	return 1;
   }
}*/

/* recursive file system functions */
function mkdirr($pathname, $mode = null) {
    // Check if directory already exists
    if (is_dir($pathname) || empty($pathname)) {
        return true;
    }
 
    // Ensure a file does not already exist with the same name
    if (is_file($pathname)) {
        trigger_error('mkdirr() File exists', E_USER_WARNING);
        return false;
    }
 
    // Crawl up the directory tree
    $next_pathname = substr($pathname, 0, strrpos($pathname, DIRECTORY_SEPARATOR));
    if (mkdirr($next_pathname, $mode)) {
        if (!file_exists($pathname)) {
            return mkdir($pathname, $mode);
        }
    }
 
    return false;
}

function rmdirr($dir) {
   if($objs = glob($dir."/*")){
       foreach($objs as $obj) {
           is_dir($obj)? rmdirr($obj) : unlink($obj);
       }
   }
   rmdir($dir);
}

function copydirr($fromDir,$toDir,$chmod=0777) {
	$err = 0;
	
	if (!file_exists($toDir)) {
		if (!mkdir($toDir, $chmod)) {
			$err = 1;
		}
	}
	
	if (!is_writable($toDir)) {
		$err = 1;
	} else if (!is_dir($fromDir)) {
		$err = 2;
	}
	
	if ($err == 0) {
		$exceptions = array('.','..');
		$dp = opendir($fromDir);
		while (false!==($item=readdir($dp))) {
			if (!in_array($item, $exceptions)) {
				$from = str_replace('//', '/', $fromDir.'/'.$item);
				$to = str_replace('//', '/', $toDir.'/'.$item);
				if (is_file($from)) {
					if (@copy($from, $to)) {
						chmod($to, $chmod);
						touch($to, filemtime($from));	// copy last modified time
					} else {
						$err = 4;
					}
				} else if (is_dir($from)) {
					if (@mkdir($to)) {
						chmod($to, $chmod);
					} else {
						$err = 5;
					}
					copydirr($from, $to, $chmod);
				}
			}
		}
		closedir($dp);
	}
	
	return $err;
}

/* unicode functions */
/* function to translate utf8 to unicode (in array) */
// This is copied from an article by Scott Reynen
 function utf8_to_unicode( $str ) {
        
        $unicode = array();        
        $values = array();
        $lookingFor = 1;
        
        for ($i = 0; $i < strlen( $str ); $i++ ) {

            $thisValue = ord( $str[ $i ] );
            
            if ( $thisValue < 128 ) $unicode[] = $thisValue;
            else {
            
                if ( count( $values ) == 0 ) $lookingFor = ( $thisValue < 224 ) ? 2 : 3;
                
                $values[] = $thisValue;
                
                if ( count( $values ) == $lookingFor ) {
            
                    $number = ( $lookingFor == 3 ) ?
                        ( ( $values[0] % 16 ) * 4096 ) + ( ( $values[1] % 64 ) * 64 ) + ( $values[2] % 64 ):
                    	( ( $values[0] % 32 ) * 64 ) + ( $values[1] % 64 );
                        
                    $unicode[] = $number;
                    $values = array();
                    $lookingFor = 1;
            
                } // if
            
            } // if
            
        } // for

        return $unicode;
    
}

/* function to print unicode values out with &# for output purpose */
// This is copied from an article by Scott Reynen
function unicode_to_entities( $unicode ) {
        
        $entities = '';
        foreach( $unicode as $value ) $entities .= '&#' . $value . ';';
        return $entities;
        
}

/* function to get name attributes in unicode in an array */
function getNames( $arr ) {
	$names = array();
	$l = count($arr);
	$i = 0;
	do {
		if ($arr[$i]==110 && $arr[$i+1]==97 && $arr[$i+2]==109 && $arr[$i+3]==101 && $arr[$i+4]==61 && $arr[$i+5]==34) {
			$j = $i+6;
			do {
				$j++;
			} while ($arr[$j]!=34 && $j<$l);
			$n = array();
			for ($k=$i+6; $k<$j; $k++) {
				array_push($n, $arr[$k]);
			}
			array_push($names, $n);
			$i = $j;
		}
		$i++;
	} while ($i < $l);
	return $names;
}

/* function to get caption attributes in unicode in an array */
function getCaptions( $arr ) {
	$captions = array();
	$l = count($arr);
	$i = 0;
	do {
		if ($arr[$i]==99 && $arr[$i+1]==97 && $arr[$i+2]==112 && $arr[$i+3]==116 && $arr[$i+4]==105 && $arr[$i+5]==111 && $arr[$i+6]==110 && $arr[$i+7]==61 && $arr[$i+8]==34) {
			$j = $i+9;
			do {
				$j++;
			} while ($arr[$j]!=34 && $j<$l);
			$n = array();
			for ($k=$i+9; $k<$j; $k++) {
				array_push($n, $arr[$k]);
			}
			array_push($captions, $n);
			$i = $j;
		}
		$i++;
	} while ($i < $l);
	return $captions;
}
?>