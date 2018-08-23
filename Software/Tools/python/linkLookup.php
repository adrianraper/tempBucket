<?php
// Get the url checked from $_GET
$requestURL = $_REQUEST['u'];
$requestGroup = $_REQUEST['g'];

// Get the redirect urls' table
$xml = simplexml_load_file('urlTable.xml');
// look up the url which need be redirected
$outputUrl = $xml->






foreach ($xml->children() as $url){
    foreach($url->attributes() as $a => $b){
    	if($a == "old"){
    		$oldUrl = $b;
    	}else if($a == "new"){
    		$newUrl = $b;
    	}
    }
    if($oldUrl == $inputUrl || $inputUrl == urldecode($oldUrl)){
    	$outputUrl = $newUrl;
    	break;
    }
}




// do the redirectation
header("Location: ".$outputUrl);
exit;
?>