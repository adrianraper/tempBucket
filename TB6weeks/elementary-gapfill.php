<?php
	// Get the source question bank
	$questionBank = simplexml_load_file('elementary-gapfill.xml');

	// Set the namespace so that xpath can work
	$questionBank->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');

	// Pull out the questions (suggest using Dave's model from CopyOps then build a new DOMDoc
	foreach ($xml->xpath("//xmlns:course[@id='$courseID']") as $courseNode) {
	}
	$questions = $questionBank->xpath('question');
	
	// Pull out the answers and encode
	//$answers = $questionBank->xpath('questions');

	// Merge the two blocks
	
	// Return the data
	echo $questions->asXML();
	flush();
	exit();