<?php
session_start();
require_once("Variables.php");
require_once("libQuery.php");
$buildXML='<query method="holdLicence" licenceID="'.$_SESSION['LICENCEID'].'" licenceHost="'.$_SESSION['HOST'].'" cacheVersion="'.time().'" databaseVersion="5" />';
sendAndLoad($buildXML, $responseXML, "licence");
if(defined("DEBUG")){
    //debug($buildXML."\r\n".$responseXML."\r\n", 3, "../Debug/debug.txt");
}
$xml = simplexml_load_string($responseXML);
$parser = xml_parser_create();
xml_set_element_handler($parser,"start","stop");
xml_parse($parser,$responseXML);
xml_parser_free($parser);

$errorCode = $errorInfo['CODE'];
switch($errorCode) {
    case '100':
    case '101':
    case '207':
    case '212':
    case '213':
    case '214':
        break;
    default:
}
?>
