<?php
//
// I just want to pass the contents of POST along to this script
$domain = 'http://www.ClarityEnglish.com';
$script = $domain.'/Software/Common/Source/SQLServer/runFunctionsQuery.php';
$ch = curl_init($script);
curl_setopt($ch, CURLOPT_HEADER, false);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt ($ch, CURLOPT_RETURNTRANSFER, false) ;
// Get the POST data
$post = file_get_contents("php://input");
curl_setopt($ch, CURLOPT_POSTFIELDS, $post);

// grab URL and pass it to the browser
if (curl_exec($ch) === false) {
	$errorString = '<?xml version="1.0" encoding="UTF-8"?><db><err>'.curl_error($ch).'</err></db>';
} else {
	//$info = curl_getinfo($ch);
}
// close cURL resource, and free up system resources
curl_close($ch);

?>