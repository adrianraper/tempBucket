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
		$originalContents = file_get_contents($filename); // TODO: check carefully if this is a security hole
		
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
			
			// #153
			$exception = null;
			$stillSave = false;
			try {
				$func($xml);
			} catch (Exception $e) {
				// #598 There may be some exceptions thrown in the func that you still want to press
				// ahead with saving the xml for.
				if ($e->getCode() == '888')
					$stillSave = true;
				$exception = $e;
			}
			
			$dom = new DOMDocument();
			$dom->formatOutput = true;
			$dom->loadXML($xml->asXML());
			
			// If there is an exception then we should replace the file with its original contents, otherwise the new contents
			// gh#924 Not necessarily. If the exception came from the database, we still need to save the xml
			if ($exception && !$stillSave) {
				// Why do we need to write out the original contents, can't we just close the file?
				@fwrite($fp, $originalContents);
			} else {
				@fwrite($fp, $dom->saveXML());
			}
			
			@fclose($fp);

			@rmdir($lockDirname);
			
			// #153
			if ($exception) throw $exception;
	        
	        // In case the calling function wants to do something with the new XML return it as a string (usually this will be ignored though)
			return $dom->saveXML();
		} else {
			throw new Exception("Unable to open $filename for writing");
		}
	}
	
	/**
	 * Build an XML string by loading an href and applying a series of transforms.
	 */
	public static function buildXml($href, $db, $service) {
		$contents = file_get_contents($href->getUrl());
		$xml = simplexml_load_string($contents);
        if ($xml === false)
            foreach(libxml_get_errors() as $error)
                AbstractService::$debugLog->info("xml load error ", $error->message);

		foreach ($href->transforms as $transform) {
            //AbstractService::$debugLog->info("apply transform ".get_class($transform));
			// gh#265
			if (get_class($transform) == "RandomizedTestTransform") {
				$xml = $transform->transform($db, $xml, $href, $service);
				return $xml;
			} else {
				$transform->transform($db, $xml, $href, $service);
			}			
		}
		return $xml->asXML();
	}
	
	/**
	 * Access attributes of a SimpleXML object and get back a simple type
	 */
	public static function xml_attribute($object, $attribute, $type = 'string')	{
		if (isset($object[$attribute])) {
			switch ($type) {
				case 'integer':
					return intval($object[$attribute]);
					break;
				case 'boolean':
					return filter_var($object[$attribute], FILTER_VALIDATE_BOOLEAN);
					break;
				case 'date':
					try {
    					$date = new DateTime($object[$attribute]);
					} catch (Exception $e) {
    					return null;
					}
					return $date->format('Y-m-d');
					break;
				case 'string':
				default:
					return (string) $object[$attribute];
					break;
			}
		}
		return null;
	}
}