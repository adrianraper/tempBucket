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

$simpleXml = simplexml_load_file("RoadToIELTS2/reading/exercises/1156153794672.xml", "SimpleXMLElementEx");

$baseElement = $simpleXml->head->insertChildFirst("base");
$baseElement = $simpleXml->head->base["href"] = "RoadToIELTS2/reading/exercises/";

$simpleXml->body["onload"] = "window.print()";

$dom = new DOMDocument('1.0');
$dom->loadXML($simpleXml->asXML());
echo $dom->saveHTML();