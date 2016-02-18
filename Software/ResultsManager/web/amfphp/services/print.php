<?php
require_once(dirname(__FILE__)."/../../../../Common/SimpleDOM.php");

if (!isset($_GET["u"]) || !isset($_GET["b"])) exit(0);

// Get the url and base path from the get request parameters
$url = base64_decode($_GET["u"]);
$basePath = base64_decode($_GET["b"]);
//$url = "http://dock.contentbench/Content/RoadToIELTS2-International/reading/exercises/1156153794672.xml";
//$basePath = "http://dock.contentbench/Content/RoadToIELTS2-International/reading/exercises";

// Do some basic sanitization to protect against directory traversal
// TODO: This could also match against a regular expression for URLs with an .xml suffix
// #325
$url = preg_replace("..", "", $url);
$basePath = preg_replace("..", "", $basePath);

// Remove any default namespaces before parsing anything and replace the root <bento> node with <html>
$xmlString = file_get_contents($url);
$xmlString = preg_replace('/( *)?xmlns[^=]*="[^"]*"/i', '', $xmlString);
$xmlString = preg_replace("/<bento>/i", "<html>", $xmlString);
$xmlString = preg_replace("/<\/bento>/i", "</html>", $xmlString);

// gh#1238 Some browsers will display this whilst printing, some will not. For those that do
// change the stylesheet that is used for media="screen" to be the same as the print one
$xmlString = preg_replace("/<link rel=\"stylesheet\" .* media=\"screen\" \/>/i", "", $xmlString);
$xmlString = preg_replace("/media=\"print\"/i", "", $xmlString);

// gh#1238 Remove the Bento model which you never want to include as it can be seen
$xmlString = preg_replace("/<script id=\"model\"[\s\S]*<\/script>/mi", "", $xmlString);
// Also the meta tag conversion-date
$xmlString = preg_replace("/<meta name=\"conversion-date\".*\/>/i", "", $xmlString);

// gh#1238 in php5.6 I get an error "simplexml_load_string() expects parameter 1 to be a valid callback"
//$simpleXml = simpledom_load_string($xmlString);
//$simpleXml = call_user_func_array('simplexml_load_string', array($xmlString, 'SimpleDOM'));
$simpleXml = simplexml_load_string($xmlString, 'SimpleDOM');

// Add in a base tag
// gh#1238 Make this the first child in head node
$baseElement = new SimpleDOM('<base href="'.$basePath.'/" />');
$firstHeadNode = $simpleXml->head->meta[0];
$firstHeadNode->insertBeforeSelf($baseElement);

// Add a copyright notice at the end of the document
// gh#1238 Change to "printed from" as we can't claim copyright of just the text
$copyrightElement = $simpleXml->body->addChild("p", "Printed from Road to IELTS, published by British Council and ClarityEnglish.");
$copyrightElement["id"] = "copyright";
$copyrightElement["style"] = "border-top: 1px solid black";

$javascriptElement = $simpleXml->head->addChild("script",
<<<JS
window.onload = function() {
	var i, audioElements, selectElements, selectWidth;
	
	// #203 - the try/catch block is for IE
	audioElements = document.getElementsByTagName('audio');
	for (i = 0; i < audioElements.length; i++) {
		try { audioElements[i].pause(); } catch (e) { }
	}
	
	// #194 - clear all options from dropdowns
	selectElements = document.getElementsByTagName('select');
	for (i = 0; i < selectElements.length; i++) {
		selectWidth = selectElements[i].clientWidth;
		selectElements[i].options.length = 0;
		selectElements[i].setAttribute("style", "width: " + selectWidth + "px;");
	}
	
	window.print();
	// gh#1238 Just let the user close, makes printing less dependent on friendly browser behaviour
	//window.close();
}
JS
);

$dom = new DOMDocument('1.0');
$dom->loadXML($simpleXml->asXML());

header("Content-type: text/html");
echo "<!DOCTYPE html>\n";
echo $dom->saveHTML();