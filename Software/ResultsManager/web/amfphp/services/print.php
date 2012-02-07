<?php
require_once(dirname(__FILE__)."/../../../../Common/SimpleDOM.php");

if (!isset($_GET["u"]) || !isset($_GET["b"])) exit(0);

// Get the url and base path from the get request parameters
$url = base64_decode($_GET["u"]);
$basePath = base64_decode($_GET["b"]);

// Do some basic sanitization to protect against directory traversal
// TODO: This could also match against a regular expression for URLs with an .xml suffix
$url = preg_replace("..", "", $url);
$basePath = preg_replace("..", "", $basePath);

// Remove any default namespaces before parsing anything
$xmlString = file_get_contents($url);
$xmlString = preg_replace('/( *)?xmlns[^=]*="[^"]*"/i', '', $xmlString);
$simpleXml = simpledom_load_string($xmlString);

// Add in a base tag
$baseElement = $simpleXml->head->insertBefore(new SimpleDOM('<base href="'.$basePath.'/" />'));

// Add a copyright notice at the end of the document
$copyrightElement = $simpleXml->body->addChild("p", "Copyright © 1993 - 2011 Clarity Language Consultants Ltd. All rights reserved.");
$copyrightElement["id"] = "copyright";
$copyrightElement["style"] = "border-top: 1px solid black";

// Hide the content in 'screen' media mode, and replace it with a message to close the window once printing is complete
$screenCssElement = $simpleXml->head->addChild("style",
<<<CSS
@media screen {
	body header,
	body section,
	body #copyright {
		display: none;
	}
}
CSS
);
$screenCssElement["type"] = "text/css";

$javascriptElement = $simpleXml->head->addChild("script",
<<<JS
window.onload = function() {
	// #203 - the try/catch block is for IE
	var audioElements = document.getElementsByTagName('audio');
	for (var i = 0; i < audioElements.length; i++) {
		try { audioElements[i].pause(); } catch (e) { }
	}
	
	window.print();
	window.close();
}
JS
);

$dom = new DOMDocument('1.0');
$dom->loadXML($simpleXml->asXML());

echo "<!DOCTYPE html>\n";
echo $dom->saveHTML();