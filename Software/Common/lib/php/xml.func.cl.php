<?php
include_once("xmlparse.class.cl.php");

/*
 * build XML node
 */
function buildXMLNodeStr($nodeName, $attributes=null, $value=null){
	$xmlNodeStr = "<$nodeName";
	// if this xml node has attributes
	if(count($attributes) > 0){
		foreach($attributes as $attName => $attVal){
			$xmlNodeStr .= " $attName='$attVal'";
		}
	}

	// if this xml node has values
	if($value != null){
		$xmlNodeStr .= ">$value</$nodeName>";
	}else{
		$xmlNodeStr .= "/>";
	}
	return $xmlNodeStr;
}

function xmlToArray($xmlstr){
	$xml_parser = new XMLParse();
	$xml_parser->parse($xmlstr);
	$xml_array = $xml_parser->parsedData;
	$xml_parser->__destruct();
	return $xml_array;
}
?>