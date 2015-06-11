<?php
session_start();
require_once("Variables.php");
require_once("libQuery.php");
$instanceInfo=array();
$errorInfo=array();

// check Instance ID
$instanceID = getInstanceID($_SESSION['USERID']);
if($instanceID == $_SESSION['InstanceID']){
	echo "true";
}else{
	echo "false, sessionID=".$_SESSION['InstanceID']." and userID=".$_SESSION['USERID']." and instanceID=$instanceID";
}

function getInstanceID($userID){
	global $instanceInfo;
    $buildXML = '<query method="getInstanceID" productCode="1001" userID="'.$userID.'" dbHost="2"/>';
    sendAndLoad($buildXML, $responseXML, "licence");
    $xml = simplexml_load_string($responseXML);
    $parser = xml_parser_create();
    xml_set_element_handler($parser,"start","stop");
    xml_parse($parser,$responseXML);
    xml_parser_free($parser);
    return $instanceInfo['ID'];
}
