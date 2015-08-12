<?php
//
// I just want to pass the contents of POST along to this script
$domain = 'http://www.ClarityEnglish.com';
$domain = 'http://dock.projectbench';
$script = $domain.'/Software/Common/Source/SQLServer/runFunctionsQuery.php';

// Get the POST data
$post = file_get_contents("php://input");
/*
$ch = curl_init($script);
curl_setopt($ch, CURLOPT_HEADER, false);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt ($ch, CURLOPT_RETURNTRANSFER, false) ;
curl_setopt($ch, CURLOPT_POSTFIELDS, $post);

// grab URL and pass it to the browser
if (curl_exec($ch) === false) {
	$errorString = '<?xml version="1.0" encoding="UTF-8"?><db><err>'.curl_error($ch).'</err></db>';
} else {
	//$info = curl_getinfo($ch);
}
// close cURL resource, and free up system resources
curl_close($ch);
*/

	// Initialize the cURL session
	$ch = curl_init();
	
	// Setup the post variables
	$curlOptions = array(CURLOPT_HEADER => false,
						CURLOPT_FAILONERROR=>true,
						CURLOPT_FOLLOWLOCATION=>true,
						CURLOPT_RETURNTRANSFER => true,
						CURLOPT_POST => true,
						CURLOPT_POSTFIELDS => $post,
						CURLOPT_URL => $script
	);
	curl_setopt_array($ch, $curlOptions);
	
	// Execute the cURL session
	$contents = curl_exec($ch);
	if($contents === false){
		$errorString = '<?xml version="1.0" encoding="UTF-8"?><db><err>'.curl_error($ch).'</err></db>';
		curl_close($ch);
	} else {
		curl_close($ch);
		// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
		if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
			$contents = substr($contents,3);
		}
	}
	echo $contents;
	exit(0);
