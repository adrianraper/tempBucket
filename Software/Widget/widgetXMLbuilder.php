<?php
/**
 * Read the takeielts recognising organisations (ro) xml files from API
 * Build a static file that the widget uses to search and link.
 * This script should be run by a daily trigger/cronjob
 */

/**
 * It would be good to first of all call the API to find out how many ro there are in US
 * $getCountURL = 'http://release.ielts.precedenthost.co.uk:82/api/ro/search?loc=189881&limit=1'
 * $countRO->NumResults[0]
 * Then do it again with the correct limit number
 * $mainURL = 'http://release.ielts.precedenthost.co.uk:82/api/ro/search?loc=189881&limit='.$countRO;
 */
 
	//$getCountURL = 'http://release.ielts.precedenthost.co.uk:82/api/ro/search?loc=189881&limit=1'
	$getCountURL = 'USInstitutionsCount.xml';
	$countXML = simplexml_load_file($getCountURL);
	$roCount = $countXML->NumResults[0];
	//echo "counted=$roCount";

/**
 * If you want to put state into each node, you will have to first call the full locations API
 * Then loop through USA grabbing the locationID of each state.
 * Then you call the search API for each state, which will let you add the state name to the node.
 * Note that this will be the full state name, not the common two letter abbreviation, which we can't get.
 */
	// Whilst in UAT you can't call the URL from a script as it needs name/password. So do it in browser and save.
	//$mainURL = 'http://release.ielts.precedenthost.co.uk:82/api/ro/search?loc=189881&limit='.$roCount;
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
		$newDetail = $newRo->addChild('name', htmlspecialchars($ro->ROName));
		$newDetail = $newRo->addChild('city', $ro->CityName);
		$newDetail = $newRo->addChild('state', $ro->state);
		$newDetail = $newRo->addChild('url', $ro->Url);
	}

	// Write out this XML to a static cache (really a file) for the widgets to pick up
	$rc = $build->asXml($staticCache);
	
	flush();
	exit();
	