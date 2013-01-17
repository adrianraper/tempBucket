<?php

class XmlUtils {
	
	/**
	 * Functionally read, process (using $func) and write an XML file.  This uses locking to ensure that people can't modify the file
	 * concurrently.
	 * 
	 * TODO: formatOutput doesn't seem to be doing anything - this will quickly get annoying whilst debugging
	 */
	public static function rewriteXml($filename, $func) {
		$contents = file_get_contents($filename);
		return self::overwriteXml($filename, $contents, $func);
	}
	
	/**
	 * Functionally process (using $func) and write an XML string.  This uses locking to ensure that people can't modify the file
	 * concurrently.  This allows us to fiddle with an XML string before writing it using a function.
	 * 
	 * TODO: formatOutput doesn't seem to be doing anything - this will quickly get annoying whilst debugging
	 */
	public static function overwriteXml($filename, $contents, $func) {
		$lockDirname = $filename.'_lock';
		if ($fp = @fopen($filename, 'w')) {
			// Implement locking with a 10 second timeout in case things go awry
			$timestamp = time();
			while (file_exists($lockDirname) || !mkdir($lockDirname)) {
				usleep(250);
				if ((time() - $timestamp) > 10) {
					throw new Exception("Timeout when waiting for file lock");
				}
			}
			
			$xml = simplexml_load_string($contents);
			
			$func($xml);
			
			$dom = new DOMDocument();
			$dom->formatOutput = true;
			$dom->loadXML($xml->asXML());
			
			@fwrite($fp, $dom->saveXML());
	        @fclose($fp);

			@rmdir($lockDirname);
	        
	        // In case the calling function wants to do something with the new XML return it as a string (usually this will be ignored though)
			return $dom->saveXML();
		} else {
			throw new Exception("Unable to open file for writing");
		}
	}
	
	/**
	 * Build an XML string by loading an href and applying a series of mappings.
	 * 
	 * @param unknown_type $href
	 * @param unknown_type $db
	 * @param unknown_type $mappings
	 */
	public static function buildXml($href, $db, $transforms) {
		$contents = file_get_contents($href->getUrl());
		$xml = simplexml_load_string($contents);
		
		$script = $xml->head->addChild("script");
		$script->addAttribute("id", "mappings");
		$script->addAttribute("type", "application/xml");
		
		foreach ($transforms as $transform) {
			/*$transformXml =*/ $transform['transform']->transform($db, $xml, $transform['options']);
			
			// Some mappings alter the original XML without returning anything so only import the result to $script if there actually is one
			/*if ($mappingXml) {
				$toDom = dom_import_simplexml($script);
    			$fromDom = dom_import_simplexml($mappingXml);
    			$toDom->appendChild($toDom->ownerDocument->importNode($fromDom, true));
			}*/
		}
		
		return $xml->asXML();
	}
	
}