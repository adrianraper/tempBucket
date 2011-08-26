<?php

require_once($GLOBALS['smarty_libs']."/Smarty.class.php");

class TemplateOps {
	
	var $db;
	
	function TemplateOps($db = null) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
	}
	
	private function getSmarty() {
		$smarty = new Smarty();
		
		// Register any functions that might be used by the templates
		$smarty->register_function("format_ansi_date", array($this, "formatAnsiDate"));
		$smarty->register_function("get_dictionary_label", array($this, "getDictionaryLabel"));
		// This next function will not be cached
		$smarty->register_function("dynamic_user_name", array($this, "getUserName"), false);
		
		$smarty->template_dir = $GLOBALS['smarty_template_dir'];
		$smarty->compile_dir = $GLOBALS['smarty_compile_dir'];
		$smarty->config_dir = $GLOBALS['smarty_config_dir'];
		$smarty->cache_dir = $GLOBALS['smarty_cache_dir'];
		$smarty->plugins_dir[] = $GLOBALS['smarty_plugins_dir'];
		
		// v3.3 Try to use caching intelligently. 
		// For those templates that are used a lot (such as IYJ Unit templates) - set it to 1 hour. 
		// This should cover bursts of emails being sent. But you need to know that the only variable is the name
		// because we have specifically set that up to be read dynamically even from the cache.
		$smarty->caching = 1;
		$smarty->cache_lifetime = 3600;
		//$smarty->clear_compiled_tpl();
		//$smarty->force_compile=true;
		// Note that many emails will want to clear cache before running as they don't want cache as too many variables.
		
		return $smarty;
	}

	function checkTemplate($folder, $templateID) {
		// Protect against directory traversal
		// Bug. I don't use a folder structure anywhere, so this was fine. But when I do, this regex picks up
		// any character rather than just the period it is supposed to!
		//$folder = ereg_replace("../", "", $folder);
		$folder = str_replace("../", "", $folder);
		$templateFolder = $GLOBALS['smarty_template_dir'].$folder."/";
		$templateFile = $templateFolder.$templateID.".tpl";
		//echo "checking $templateFile";
		//AbstractService::$debugLog->warning("checking file ".$templateFile);
		if (file_exists($templateFile)) {
			return true;
		} else {
			return false;
		}
	}
	
	function getTemplates($folder) {
		if ($folder) {
			// Protect against directory traversal
			//$folder = ereg_replace("../", "", $folder);
			$folder = str_replace("../", "", $folder);
			$templateDir = $GLOBALS['smarty_template_dir'].$folder."/";
		} else {
			$templateDir = $GLOBALS['smarty_template_dir'];
		}
		
		$templateDefinitions = array();
		
		// Get all the .tpl files in smarty_template_dir
		$directory = opendir($templateDir);
		
		// Get each entry
		while ($entryName = readdir($directory)) {
			if (preg_match('/^(.*)\.(tpl)$/D', $entryName, $matches) > 0) {
				$templateDefinition = new TemplateDefinition();
				//$templateDefinition->title = $matches[1];
				$templateDefinition->filename = $matches[1];
				
				$content = file_get_contents($templateDir.$templateDefinition->filename.".tpl");
				preg_match('/\{\* Name:(.*)\*\}/', $content, $matches);
				$templateDefinition->title = trim($matches[1]);
				preg_match('/\{\* Description:(.*)\*\}/', $content, $matches);
				$templateDefinition->description = trim($matches[1]);
				
				$templateDefinitions[] = $templateDefinition;
			}
		}
		
		// Close directory
		closedir($directory);
		
		return $templateDefinitions;
	}
	
	function fetchTemplate($templateName, $dataArray, $useCache=false) {
		$smarty = $this->getSmarty();
		
		if ($useCache) {
		} else {
			$smarty->clear_cache($templateName.".tpl");
		}
		// Add in the data arrays
		foreach ($dataArray as $key => $value) {
			//echo "fetchTemplate has data for ".$key;
			$smarty->assign($key, $value);
		}
		
		// Always add in the copy array
		$smarty->assign("copy", $this->copyOps->getCopyArray());
		
		// v3.4 And the template folder? This to allow you to do file_exists within a template.
		$smarty->assign("template_dir", $smarty->template_dir);
		
		return $smarty->fetch($templateName.".tpl");
	}
	
	function clearCache($templateName) {
		$smarty = $this->getSmarty();
		$smarty->clear_cache($templateName.".tpl");
	}
	
	function formatAnsiDate($params, &$smarty) {
		$ansiDate = $params['ansiDate'];
		
		$format = (isset($params['format'])) ? $params['format'] : "%Y-%m-%d";
		
		if ($ansiDate > '2038') $ansiDate = '2038-01-01';
		
		//return $this->db->UnixTimeStamp($ansiDate);
		return strftime($format, $this->db->UnixTimeStamp($ansiDate));
	}
	/**
	 * Used to put the user's name dynamically into a cached template
	 */
	function getUserName($params, & $smarty) {
		return $params['uname'];
	}
	
	/**
	 * Retrieve an entry from the dictionary.  The template needs to pass a class with a getDictionary function (e.g. AccountOps) in order for
	 * this to work.
	 * What about when you want to get more than data and label?
	 */
	function getDictionaryLabel($params, &$smarty) {
		$name = $params['name'];
		$data = $params['data'];
		$dictionarySource = $params['dictionary_source'];
		
		$dictionaryClass = new $dictionarySource($this->db);
		$dictionary = $dictionaryClass->getDictionary($name);
		
		// Go through the dictionary searching for data
		foreach ($dictionary as $item)
			if ($item['data'] == $data) return $item['label'];
		
		return "[Dictionary entry not found]";
	}

}

?>