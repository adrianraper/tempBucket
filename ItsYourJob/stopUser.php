<?php
session_start();
require_once("Variables.php");
require_once("libQuery.php");
$nowtime = time();
$buildXML='<query dbHost="2" method="stopUser" sessionID="'.$_SESSION['SESSIONID']
        .'" licenceID="'.$_SESSION['LICENCEID'].'" licenceHost="'.$_SESSION['HOST']
        .'" datestamp="'.date("Y-m-d H:i:s", $nowtime).'" cacheVersion="'.$nowtime.'" databaseVersion="5"/>';
sendAndLoad($buildXML, $responseXML, "progress");
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

return true;
?>
