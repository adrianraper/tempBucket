<?php
/**
 * Read the takeielts recognising organisations (ro) xml files from API
 * Build a static file that the widget uses to search and link.
 * This script should be run by a daily trigger/cronjob
 */

	//$mainURL = 'http://release.ielts.precedenthost.co.uk:82/api/ro/search?loc=189881';
	$mainURL = 'ROlocations-USA.xml';
	//$detailURL = 'http://www.takeielts.org/api/ro/detail?id=';
	//$staticCache = '../BritishCouncil/widgets/ielts/bin/USInstitutions.xml';
	$staticCache = 'USInstitutions.xml';
	
	// Get the main xml file
	$roXML = simplexml_load_file($mainURL);
	
	// Start the building
	$build = new SimpleXMLElement('<takeielts />');

	
	foreach ($roXML->Result as $ro) {
		$ro->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		$roID = $ro->ROID;
		
		// Put it all into a node in the return object. Keep as close to existing structure as possible
		$newRo = $build->addChild('institution');
		$newDetail = $newRo->addChild('id', $roID);
		$newDetail = $newRo->addChild('name', $ro->ROName);
		$newDetail = $newRo->addChild('city', $ro->CityName);
		$newDetail = $newRo->addChild('state', $ro->state);
		$newDetail = $newRo->addChild('url', $ro->Url);
	}

	// Write out this XML to a static cache (really a file) for the widgets to pick up
	$rc = $build->asXml($staticCache);
	
	flush();
	exit();
	