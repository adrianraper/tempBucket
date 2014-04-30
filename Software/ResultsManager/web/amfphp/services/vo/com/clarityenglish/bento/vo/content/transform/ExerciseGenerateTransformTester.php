<?php
// Test through the browser
require_once(dirname(__FILE__)."/ExerciseGenerateTransform.php");
require_once(dirname(__FILE__)."/../../../../../../../../../amfphp/services/RotterdamBuilderService.php");
$a = new ExerciseGenerateTransform();

$contents = file_get_contents("D:/Projects/Clarity/ContentBench/CCB/Clarity/709789692436193040/exercises/123456.xml");
$xml = simplexml_load_string($contents);
$service = new RotterdamBuilderService();
$result = $a->transform(null, $xml, null, $service);

header("Content-Type: text/xml");
echo $result->asXML();
