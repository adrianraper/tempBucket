<?php

class XmlUtils {
	
	/**
	 * Functionally read, process (using $func) and write an XML file.  This uses locking to ensure that people can't modify the file
	 * concurrently.
	 * 
	 * TODO: formatOutput doesn't seem to be doing anything - this will quickly get annoying whilst debugging
	 */
	public static function rewriteXml($filename, $func) {
		$fp = fopen($filename, "r+b");
		if (flock($fp, LOCK_EX)) {
			// Read the file
			$contents = fread($fp, filesize($filename));
			$xml = simplexml_load_string($contents);
			
			$func($xml);
			
			$dom = new DOMDocument();
			$dom->formatOutput = true;
			/*$domnode = dom_import_simplexml($xml);
			$domnode = $dom->importNode($domnode, true);
			$dom->appendChild($domnode);*/
			$dom->loadXML($xml->asXML());
			
			ftruncate($fp, 0);
			fseek($fp, 0);
			fwrite($fp, $dom->saveXML());
			fflush($fp);
			flock($fp, LOCK_UN);
		} else {
			// gh#65 - no lock version
			// Read the file
			$contents = fread($fp, filesize($filename));
			$xml = simplexml_load_string($contents);
			
			$func($xml);
			
			$dom = new DOMDocument();
			$dom->formatOutput = true;
			$dom->loadXML($xml->asXML());
			
			ftruncate($fp, 0);
			fseek($fp, 0);
			fwrite($fp, $dom->saveXML());
			fflush($fp);
			// throw new Exception("Problem whilst locking xml file $filename");
		}
		
		fclose($fp);
		
		// In case the calling function wants to do something with the new XML return it as a string (usually this will be ignored though)
		return $dom->saveXML();
	}
	
	/**
	 * Functionally process (using $func) and write an XML string.  This uses locking to ensure that people can't modify the file
	 * concurrently.  This allows us to fiddle with an XML string before writing it using a function.
	 * 
	 * TODO: formatOutput doesn't seem to be doing anything - this will quickly get annoying whilst debugging
	 */
	public static function overwriteXml($filename, $contents, $func) {
		$fp = fopen($filename, "r+b");
		if (flock($fp, LOCK_EX)) {
			$xml = simplexml_load_string($contents);
			
			$func($xml);
			
			$dom = new DOMDocument();
			$dom->formatOutput = true;
			/*$domnode = dom_import_simplexml($xml);
			$domnode = $dom->importNode($domnode, true);
			$dom->appendChild($domnode);*/
			$dom->loadXML($xml->asXML());
			
			ftruncate($fp, 0);
			fseek($fp, 0);
			fwrite($fp, $dom->saveXML());
			fflush($fp);
			flock($fp, LOCK_UN);
		} else {
			// gh#65 - no lock version
			$xml = simplexml_load_string($contents);
			
			$func($xml);
			
			$dom = new DOMDocument();
			$dom->formatOutput = true;
			$dom->loadXML($xml->asXML());
			
			ftruncate($fp, 0);
			fseek($fp, 0);
			fwrite($fp, $dom->saveXML());
			fflush($fp);
			//throw new Exception("Problem whilst locking xml file");
		}
		
		fclose($fp);
		
		// In case the calling function wants to do something with the new XML return it as a string (usually this will be ignored though)
		return $dom->saveXML();
	}
	
}