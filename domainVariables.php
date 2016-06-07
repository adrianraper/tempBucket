<?php
$commonDomain = 'http://dock.projectbench/';
$RMServicesPath = $commonDomain."Software/ResultsManager/web/amfphp/services/";
$CommonPortalPath = $commonDomain."Software/Common/Portal/";

if ($_SERVER['SERVER_PORT']!=80) {
	$port=':'.$_SERVER['SERVER_PORT'];
} else {
	$port='';
}
$pageURI  = ereg_replace("/(.+)", "", $_SERVER["SERVER_NAME"].$_SERVER["REQUEST_URI"]);
// Why remove www?
//$domain  = 'http'.'://'.str_replace("www.", "", $pageURI).$port.'/'; 
// Make sure that there is no ending slash on this as we will add it below
if (strrchr($pageURI, '/')=='/') {
	$pageURI = substr($pageURI,0,strlen($pageURI)-1);
}
$domain  = 'http'.'://'.$pageURI.$port.'/';
echo '<script type="text/javascript">';
echo 'var domain = "'.$domain.'";';
echo 'var commonPortal = "'.$CommonPortalPath.'";';
echo '</script>';
?>
