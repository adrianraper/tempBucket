<?php
session_start();
require_once("Variables.php");
require_once("libQuery.php");
$userInfo=array();
$errorInfo=array();

// check Instance ID
if(saveBookmark($_SESSION['USERID'], $_GET['m']) == true){
    echo "true";
}else{
    echo "false";
}

function saveBookmark($userID, $bookmark){
    global $userInfo;
    $buildXML = '<query method="emuSaveBookmark" userID="'.$userID.'" bookmark="'.$bookmark.'" dbHost="2"/>';
    sendAndLoad($buildXML, $responseXML, "progress");
    $xml = simplexml_load_string($responseXML);
    $parser = xml_parser_create();
    xml_set_element_handler($parser,"start","stop");
    xml_parse($parser,$responseXML);
    xml_parser_free($parser);
    if($userInfo['USERID'] > 0){
    	$_SESSION['BOOKMARK'] = $_GET['m'];
    	return true;
    }else{
    	return false;
    }
}
?>