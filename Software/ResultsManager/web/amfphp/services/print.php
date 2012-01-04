<?php
class SimpleXMLElementEx extends SimpleXMLElement {
	
    public function insertChildFirst($name, $value = null, $namespace = null) {
        // Convert ourselves to DOM.
        $targetDom = dom_import_simplexml($this);
        
        // Check for children
        $hasChildren = $targetDom->hasChildNodes();

        // Create the new childnode.
        $newNode = $this->addChild($name, $value, $namespace);

        // Put in the first position.
        if ($hasChildren) {
            $newNodeDom = $targetDom->ownerDocument->importNode(dom_import_simplexml($newNode), true);
            $targetDom->insertBefore($newNodeDom, $targetDom->firstChild);
        }

        // Return the new node.
        return $newNode;
    }
    
}

if (!isset($_GET["u"]) || !isset($_GET["b"])) exit(0);

// Get the url and base path from the get request parameters
$url = base64_decode($_GET["u"]);
$basePath = base64_decode($_GET["b"]);

// Do some basic sanitization to protect against directory traversal
// TODO: This could also match against a regular expression for URLs with an .xml suffix
$url = preg_replace("..", "", $url);
$basePath = preg_replace("..", "", $basePath);

$simpleXml = simplexml_load_file($url, "SimpleXMLElementEx");

// Add in a base tag
$baseElement = $simpleXml->head->insertChildFirst("base");
$baseElement = $simpleXml->head->base["href"] = $basePath."/";

// Add a copyright notice at the end of the document
$copyrightElement = $simpleXml->body->addChild("p", "Copyright © 1993 - 2011 Clarity Language Consultants Ltd. All rights reserved.");
$copyrightElement["style"] = "border-top: 1px solid black";

// Make the page print when loaded
$simpleXml->body["onload"] = "window.print()";

$dom = new DOMDocument('1.0');
$dom->loadXML($simpleXml->asXML());
echo $dom->saveHTML();
?>